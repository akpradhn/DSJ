"""
Day 1: Introduction to AI Agents
Building a minimal agent loop to understand the core concepts.

An AI agent is a system that:
1. Receives input from the user
2. Decides what to do (reason, plan)
3. Uses tools if needed
4. Returns a response
5. Can maintain state/memory

This is a simple implementation of the ReAct pattern.
"""

import os
from typing import Dict, List, Optional
from dotenv import load_dotenv
from langchain_openai import ChatOpenAI
from langchain_core.messages import HumanMessage, AIMessage

# Load environment variables
load_dotenv()


class SimpleAgent:
    """
    A minimal AI agent that can have a conversation and use basic reasoning.
    
    This agent demonstrates:
    - Basic agent loop (input -> process -> output)
    - Conversation history
    - Simple decision making
    """
    
    def __init__(self, model: str = "gpt-3.5-turbo", temperature: float = 0.7):
        """
        Initialize the agent with a language model.
        
        Args:
            model: Model to use (gpt-3.5-turbo, gpt-4, etc.)
            temperature: Sampling temperature (0-2)
        """
        self.llm = ChatOpenAI(model=model, temperature=temperature)
        self.conversation_history: List[Dict[str, str]] = []
        
    def add_to_history(self, role: str, content: str) -> None:
        """
        Add a message to conversation history.
        
        Args:
            role: Message role (user or assistant)
            content: Message content
        """
        self.conversation_history.append({"role": role, "content": content})
    
    def think(self, user_input: str) -> str:
        """
        Process user input and generate a response.
        
        This is the core "agent loop":
        1. Add user message to history
        2. Let the LLM process based on full context
        3. Extract the response
        4. Add response to history
        5. Return response
        
        Args:
            user_input: User's message
            
        Returns:
            Agent's response
        """
        # Add user input to history
        self.add_to_history("user", user_input)
        
        # Prepare messages for the LLM (convert dict format to LangChain format)
        messages = []
        for msg in self.conversation_history:
            if msg["role"] == "user":
                messages.append(HumanMessage(content=msg["content"]))
            elif msg["role"] == "assistant":
                messages.append(AIMessage(content=msg["content"]))
        
        # Get response from LLM
        response = self.llm.invoke(messages)
        response_content = response.content
        
        # Add assistant response to history
        self.add_to_history("assistant", response_content)
        
        return response_content
    
    def reset(self) -> None:
        """Clear conversation history."""
        self.conversation_history = []
    
    def get_history(self) -> List[Dict[str, str]]:
        """
        Get the full conversation history.
        
        Returns:
            List of message dictionaries
        """
        return self.conversation_history.copy()


def main():
    """
    Demo function showing the agent in action.
    """
    print("🤖 Day 1: Introduction to AI Agents")
    print("=" * 50)
    
    # Initialize agent
    agent = SimpleAgent(model="gpt-3.5-turbo", temperature=0.7)
    
    print("\nAgent initialized! Let's have a conversation.")
    print("Type 'quit' to exit, 'reset' to clear history.\n")
    
    while True:
        user_input = input("You: ")
        
        if user_input.lower() == 'quit':
            print("\n👋 Goodbye!")
            break
        
        if user_input.lower() == 'reset':
            agent.reset()
            print("\n🔄 Conversation history cleared.\n")
            continue
        
        if not user_input.strip():
            continue
        
        # Get agent's response
        response = agent.think(user_input)
        print(f"\nAgent: {response}\n")
        
        # Show conversation length
        print(f"[Conversation: {len(agent.conversation_history)} messages]")
        print("-" * 50 + "\n")


if __name__ == "__main__":
    # Check if API key is set
    if not os.getenv("OPENAI_API_KEY"):
        print("⚠️  Warning: OPENAI_API_KEY not found in environment.")
        print("Please set your OpenAI API key in the .env file.")
        print("\nExample usage:")
        print("  from agent import SimpleAgent")
        print("  agent = SimpleAgent()")
        print("  response = agent.think('Hello!')")
        print("  print(response)")
    else:
        main()
