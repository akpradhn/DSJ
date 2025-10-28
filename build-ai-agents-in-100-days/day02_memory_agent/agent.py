"""
Day 2: Agents with Memory
Enhancing our agent with different types of memory using LangChain.

Memory types we'll cover:
1. ConversationBufferMemory - Stores all conversation history
2. ConversationSummaryMemory - Summarizes conversation history
3. ConversationBufferWindowMemory - Keeps only recent messages
4. ConversationSummaryBufferMemory - Hybrid approach

"""

import os
from typing import Dict, List
from dotenv import load_dotenv

from langchain_openai import ChatOpenAI
from langchain.memory import (
    ConversationBufferMemory,
    ConversationSummaryMemory,
    ConversationBufferWindowMemory,
    ConversationSummaryBufferMemory
)
from langchain.chains import ConversationChain
from langchain.prompts import (
    ChatPromptTemplate,
    MessagesPlaceholder,
    SystemMessagePromptTemplate,
    HumanMessagePromptTemplate
)
from langchain_core.messages import HumanMessage

# Load environment variables
load_dotenv()


class MemoryAgent:
    """
    An AI agent with memory capabilities.
    
    This agent demonstrates different memory types:
    - Buffer: Stores all messages
    - Summary: Summarizes past conversations
    - Window: Keeps only recent messages
    - SummaryBuffer: Hybrid approach
    """
    
    def __init__(self, memory_type: str = "buffer", model: str = "gpt-3.5-turbo"):
        """
        Initialize agent with specified memory type.
        
        Args:
            memory_type: Type of memory to use (buffer, summary, window, summary_buffer)
            model: LLM model to use
        """
        self.llm = ChatOpenAI(model=model, temperature=0.7)
        self.memory_type = memory_type
        self.memory = self._create_memory(memory_type)
        
    def _create_memory(self, memory_type: str):
        """Create appropriate memory based on type."""
        if memory_type == "buffer":
            return ConversationBufferMemory(
                return_messages=True,
                memory_key="chat_history"
            )
        elif memory_type == "summary":
            return ConversationSummaryMemory(
                llm=self.llm,
                return_messages=True,
                memory_key="chat_history"
            )
        elif memory_type == "window":
            return ConversationBufferWindowMemory(
                k=2,  # Keep last 2 exchanges
                return_messages=True,
                memory_key="chat_history"
            )
        elif memory_type == "summary_buffer":
            return ConversationSummaryBufferMemory(
                llm=self.llm,
                max_token_limit=50,
                return_messages=True,
                memory_key="chat_history"
            )
        else:
            return ConversationBufferMemory(
                return_messages=True,
                memory_key="chat_history"
            )
    
    def think(self, user_input: str) -> str:
        """
        Process user input and generate response using memory.
        
        Args:
            user_input: User's message
            
        Returns:
            Agent's response
        """
        # Create the prompt
        prompt = ChatPromptTemplate.from_messages([
            SystemMessagePromptTemplate.from_template(
                "You are a helpful AI assistant. You can remember previous "
                "conversations and provide context-aware responses."
            ),
            MessagesPlaceholder(variable_name="chat_history"),
            HumanMessagePromptTemplate.from_template("{input}")
        ])
        
        # Create the conversation chain
        conversation = ConversationChain(
            llm=self.llm,
            prompt=prompt,
            memory=self.memory,
            verbose=False
        )
        
        # Get response
        response = conversation.predict(input=user_input)
        return response
    
    def get_memory_summary(self) -> str:
        """
        Get a summary of the conversation history.
        
        Returns:
            Summary of the conversation
        """
        if hasattr(self.memory, 'chat_memory'):
            if self.memory_type == "buffer":
                return "Full conversation history maintained"
            elif self.memory_type == "summary":
                return f"Conversation summary: {self.memory.buffer}"
            elif self.memory_type == "window":
                return "Last 2 message exchanges maintained"
            else:
                return "Hybrid memory: summary + recent messages"
        return "No conversation history yet"
    
    def clear_memory(self):
        """Clear the conversation memory."""
        self.memory.clear()


class AdvancedMemoryAgent:
    """
    Advanced agent with custom memory capabilities.
    
    Features:
    - Manual memory management
    - Conversation history tracking
    - Summary generation
    """
    
    def __init__(self, model: str = "gpt-3.5-turbo"):
        """Initialize the advanced agent."""
        self.llm = ChatOpenAI(model=model, temperature=0.7)
        self.conversation_history: List[Dict[str, str]] = []
        self.summary: str = ""
        
    def think(self, user_input: str) -> str:
        """
        Process input with custom memory logic.
        
        Args:
            user_input: User's message
            
        Returns:
            Agent's response
        """
        from langchain_core.messages import HumanMessage, AIMessage, SystemMessage
        
        # Build context
        messages = [
            SystemMessage(content="You are a helpful AI assistant with memory.")
        ]
        
        # Add conversation history (limit to last 6 messages for context window)
        for msg in self.conversation_history[-6:]:
            if msg["role"] == "user":
                messages.append(HumanMessage(content=msg["content"]))
            elif msg["role"] == "assistant":
                messages.append(AIMessage(content=msg["content"]))
        
        # Add current user input
        messages.append(HumanMessage(content=user_input))
        
        # Get response
        response = self.llm.invoke(messages)
        response_content = response.content
        
        # Store in history
        self.conversation_history.append({"role": "user", "content": user_input})
        self.conversation_history.append({"role": "assistant", "content": response_content})
        
        return response_content
    
    def summarize_conversation(self) -> str:
        """
        Generate a summary of the conversation.
        
        Returns:
            Summary text
        """
        if len(self.conversation_history) < 2:
            return "No conversation to summarize yet."
        
        # Get conversation text
        conversation_text = "\n".join([
            f"{msg['role'].title()}: {msg['content']}"
            for msg in self.conversation_history
        ])
        
        # Create summarization prompt
        summary_prompt = f"""
        Please provide a brief summary of this conversation:
        
        {conversation_text}
        
        Summary:
        """
        
        summary = self.llm.invoke([HumanMessage(content=summary_prompt)])
        self.summary = summary.content
        
        return self.summary
    
    def get_history(self) -> List[Dict[str, str]]:
        """Get conversation history."""
        return self.conversation_history.copy()
    
    def reset(self):
        """Clear all memory."""
        self.conversation_history = []
        self.summary = ""


def compare_memory_types():
    """
    Compare different memory types side by side.
    """
    print("🔍 Comparing Memory Types")
    print("=" * 60)
    
    test_input = "My favorite color is blue"
    
    memory_types = ["buffer", "summary", "window", "summary_buffer"]
    
    for mem_type in memory_types:
        print(f"\n📝 Memory Type: {mem_type.upper()}")
        print("-" * 60)
        
        agent = MemoryAgent(memory_type=mem_type)
        agent.think(test_input)
        
        # Try to recall
        response = agent.think("What's my favorite color?")
        print(f"Response: {response}")
    
    print("\n" + "=" * 60)


def main():
    """Main demo function."""
    print("🤖 Day 2: Agents with Memory")
    print("=" * 60)
    
    # Check API key
    if not os.getenv("OPENAI_API_KEY") or os.getenv("OPENAI_API_KEY") == "your_openai_api_key_here":
        print("\n⚠️  Please set your OPENAI_API_KEY in .env file")
        print("\nExample usage:")
        print("  from agent import MemoryAgent")
        print("  agent = MemoryAgent(memory_type='buffer')")
        print("  response = agent.think('Hello!')")
        return
    
    print("\n🚀 Initializing agent with buffer memory...")
    agent = MemoryAgent(memory_type="buffer")
    
    print("\n📝 Sample Conversation")
    print("=" * 60)
    
    conversations = [
        "My name is Alex",
        "I work as a software developer",
        "What do you remember about me?"
    ]
    
    for msg in conversations:
        print(f"\n👤 You: {msg}")
        response = agent.think(msg)
        print(f"🤖 Agent: {response}")
    
    print("\n" + "=" * 60)
    print("\n✅ Demo completed!")
    print(f"\n📊 Memory Summary: {agent.get_memory_summary()}")


if __name__ == "__main__":
    main()

