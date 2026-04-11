"""
Day 3: Generative AI Agents - Function Calling and Tools

This module demonstrates how to build sophisticated AI agents with function calling
capabilities. Agents can use tools to interact with external systems, databases, and APIs.

Key Concepts:
1. Function calling / Tool definition
2. Tool selection and execution
3. Agent loop with tools
4. Error handling and validation
"""

import os
import json
from typing import Dict, List, Optional, Any, Callable
from dotenv import load_dotenv

from langchain_openai import ChatOpenAI
from langchain.tools import Tool, StructuredTool
from langchain.agents import AgentExecutor, create_openai_tools_agent
from langchain.prompts import ChatPromptTemplate, MessagesPlaceholder
from langchain_core.messages import HumanMessage, AIMessage, SystemMessage
from pydantic import BaseModel, Field

# Load environment variables
load_dotenv()


# Tool Definitions
class CalculatorInput(BaseModel):
    """Input for calculator tool."""
    expression: str = Field(description="Mathematical expression to evaluate (e.g., '2 + 2', '10 * 5')")


class WeatherInput(BaseModel):
    """Input for weather tool."""
    location: str = Field(description="City name or location (e.g., 'New York', 'London')")


class DatabaseQueryInput(BaseModel):
    """Input for database query tool."""
    query: str = Field(description="SQL query to execute")


def calculator_tool(expression: str) -> str:
    """
    Evaluate a mathematical expression safely.
    
    Args:
        expression: Mathematical expression as string
        
    Returns:
        Result of the calculation
    """
    try:
        # Only allow safe mathematical operations
        allowed_chars = set('0123456789+-*/.() ')
        if not all(c in allowed_chars for c in expression):
            return "Error: Invalid characters in expression"
        
        result = eval(expression)
        return f"Result: {result}"
    except Exception as e:
        return f"Error: {str(e)}"


def weather_tool(location: str) -> str:
    """
    Get weather information for a location (mock implementation).
    
    Args:
        location: City or location name
        
    Returns:
        Weather information
    """
    # Mock weather data - in production, this would call a real weather API
    mock_weather = {
        "new york": "Sunny, 72°F",
        "london": "Cloudy, 55°F",
        "tokyo": "Rainy, 68°F",
        "paris": "Partly cloudy, 65°F"
    }
    
    location_lower = location.lower()
    weather = mock_weather.get(location_lower, f"Weather data not available for {location}")
    return f"Weather in {location}: {weather}"


def database_query_tool(query: str) -> str:
    """
    Execute a SQL query (mock implementation).
    
    Args:
        query: SQL query string
        
    Returns:
        Query results
    """
    # Mock database - in production, this would execute real SQL
    query_lower = query.lower()
    
    if "select" in query_lower and "customers" in query_lower:
        return "Query results: [Customer 1, Customer 2, Customer 3]"
    elif "select" in query_lower and "sales" in query_lower:
        return "Total sales: $125,000"
    elif "select" in query_lower and "products" in query_lower:
        return "Products: [Product A, Product B, Product C]"
    else:
        return f"Executed query: {query}\nResults: [Sample data]"


class AgentWithTools:
    """
    An AI agent with function calling capabilities.
    
    This agent can:
    - Use tools to perform actions
    - Select appropriate tools based on user input
    - Execute tools and incorporate results into responses
    """
    
    def __init__(self, model: str = "gpt-3.5-turbo", temperature: float = 0.7):
        """
        Initialize the agent with tools.
        
        Args:
            model: LLM model to use
            temperature: Sampling temperature
        """
        self.llm = ChatOpenAI(model=model, temperature=temperature)
        self.tools = self._create_tools()
        self.conversation_history: List[Dict[str, str]] = []
        
    def _create_tools(self) -> List[Tool]:
        """Create and return a list of available tools."""
        tools = [
            StructuredTool.from_function(
                func=calculator_tool,
                name="calculator",
                description="Evaluates mathematical expressions. Use this for any math calculations.",
                args_schema=CalculatorInput
            ),
            StructuredTool.from_function(
                func=weather_tool,
                name="weather",
                description="Gets weather information for a given location. Use this when asked about weather.",
                args_schema=WeatherInput
            ),
            StructuredTool.from_function(
                func=database_query_tool,
                name="database_query",
                description="Executes SQL queries on the database. Use this to query customer, sales, or product data.",
                args_schema=DatabaseQueryInput
            ),
        ]
        return tools
    
    def think(self, user_input: str) -> str:
        """
        Process user input and generate response using tools if needed.
        
        Args:
            user_input: User's message
            
        Returns:
            Agent's response
        """
        # Create the agent prompt
        prompt = ChatPromptTemplate.from_messages([
            SystemMessage(content="""You are a helpful AI assistant with access to various tools.
            
You can:
- Perform calculations using the calculator tool
- Get weather information using the weather tool
- Query databases using the database_query tool

When a user asks a question that requires using a tool, use the appropriate tool and provide a clear answer based on the tool's result.

Be concise and helpful."""),
            MessagesPlaceholder(variable_name="chat_history"),
            ("user", "{input}"),
            MessagesPlaceholder(variable_name="agent_scratchpad"),
        ])
        
        # Create the agent
        agent = create_openai_tools_agent(self.llm, self.tools, prompt)
        
        # Create agent executor
        agent_executor = AgentExecutor(
            agent=agent,
            tools=self.tools,
            verbose=False,
            handle_parsing_errors=True
        )
        
        # Prepare chat history
        chat_history = []
        for msg in self.conversation_history[-6:]:  # Keep last 6 messages for context
            if msg["role"] == "user":
                chat_history.append(HumanMessage(content=msg["content"]))
            elif msg["role"] == "assistant":
                chat_history.append(AIMessage(content=msg["content"]))
        
        # Execute agent
        try:
            result = agent_executor.invoke({
                "input": user_input,
                "chat_history": chat_history
            })
            response = result["output"]
        except Exception as e:
            response = f"I encountered an error: {str(e)}. Please try rephrasing your question."
        
        # Store in history
        self.conversation_history.append({"role": "user", "content": user_input})
        self.conversation_history.append({"role": "assistant", "content": response})
        
        return response
    
    def reset(self) -> None:
        """Clear conversation history."""
        self.conversation_history = []
    
    def get_history(self) -> List[Dict[str, str]]:
        """Get conversation history."""
        return self.conversation_history.copy()
    
    def list_tools(self) -> List[str]:
        """List available tools."""
        return [tool.name for tool in self.tools]


class CustomToolAgent:
    """
    Advanced agent that allows adding custom tools dynamically.
    """
    
    def __init__(self, model: str = "gpt-3.5-turbo"):
        """Initialize with empty tools list."""
        self.llm = ChatOpenAI(model=model, temperature=0.7)
        self.tools: List[Tool] = []
        self.conversation_history: List[Dict[str, str]] = []
    
    def add_tool(self, tool: Tool) -> None:
        """
        Add a custom tool to the agent.
        
        Args:
            tool: LangChain Tool object
        """
        self.tools.append(tool)
    
    def think(self, user_input: str) -> str:
        """Process input with available tools."""
        if not self.tools:
            # If no tools, just use LLM directly
            messages = [
                SystemMessage(content="You are a helpful AI assistant."),
                HumanMessage(content=user_input)
            ]
            response = self.llm.invoke(messages)
            return response.content
        
        # Use agent with tools
        prompt = ChatPromptTemplate.from_messages([
            SystemMessage(content="You are a helpful AI assistant with access to tools."),
            MessagesPlaceholder(variable_name="chat_history"),
            ("user", "{input}"),
            MessagesPlaceholder(variable_name="agent_scratchpad"),
        ])
        
        agent = create_openai_tools_agent(self.llm, self.tools, prompt)
        agent_executor = AgentExecutor(agent=agent, tools=self.tools, verbose=False)
        
        chat_history = []
        for msg in self.conversation_history[-6:]:
            if msg["role"] == "user":
                chat_history.append(HumanMessage(content=msg["content"]))
            elif msg["role"] == "assistant":
                chat_history.append(AIMessage(content=msg["content"]))
        
        result = agent_executor.invoke({
            "input": user_input,
            "chat_history": chat_history
        })
        
        response = result["output"]
        self.conversation_history.append({"role": "user", "content": user_input})
        self.conversation_history.append({"role": "assistant", "content": response})
        
        return response


def main():
    """Main demo function."""
    print("🤖 Day 3: Generative AI Agents - Function Calling")
    print("=" * 60)
    
    # Check API key
    if not os.getenv("OPENAI_API_KEY"):
        print("\n⚠️  Please set your OPENAI_API_KEY in .env file")
        return
    
    print("\n🚀 Initializing agent with tools...")
    agent = AgentWithTools()
    
    print(f"\n📦 Available tools: {', '.join(agent.list_tools())}")
    print("\n" + "=" * 60)
    print("📝 Sample Interactions")
    print("=" * 60)
    
    # Sample interactions
    test_queries = [
        "What's 25 * 17?",
        "What's the weather in New York?",
        "Query the database for all customers",
        "Calculate 100 + 200 and then get weather for London"
    ]
    
    for query in test_queries:
        print(f"\n👤 You: {query}")
        response = agent.think(query)
        print(f"🤖 Agent: {response}")
        print("-" * 60)
    
    print("\n✅ Demo completed!")
    print("\n💡 Try running the agent interactively:")
    print("   python agent.py --interactive")


if __name__ == "__main__":
    import sys
    
    if "--interactive" in sys.argv:
        # Interactive mode
        print("🤖 Day 3: Generative AI Agents - Interactive Mode")
        print("=" * 60)
        print("Type 'quit' to exit, 'reset' to clear history, 'tools' to list tools\n")
        
        agent = AgentWithTools()
        
        while True:
            user_input = input("You: ")
            
            if user_input.lower() == 'quit':
                print("\n👋 Goodbye!")
                break
            
            if user_input.lower() == 'reset':
                agent.reset()
                print("\n🔄 Conversation history cleared.\n")
                continue
            
            if user_input.lower() == 'tools':
                print(f"\n📦 Available tools: {', '.join(agent.list_tools())}\n")
                continue
            
            if not user_input.strip():
                continue
            
            response = agent.think(user_input)
            print(f"\nAgent: {response}\n")
    else:
        main()



