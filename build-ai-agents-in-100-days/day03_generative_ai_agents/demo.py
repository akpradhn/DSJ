"""
Day 3: Comprehensive Demo - Generative AI Agents

This script demonstrates all the key concepts from Day 3:
1. Function calling and tools
2. SQL database agents
3. LangGraph café ordering agent
"""

import os
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

def demo_function_calling():
    """Demonstrate function calling with tools."""
    print("\n" + "=" * 60)
    print("📦 Demo 1: Function Calling and Tools")
    print("=" * 60)
    
    try:
        from agent import AgentWithTools
        
        agent = AgentWithTools()
        print(f"\nAvailable tools: {', '.join(agent.list_tools())}\n")
        
        queries = [
            "What's 15 * 23?",
            "What's the weather in Tokyo?",
            "Query the database for sales data"
        ]
        
        for query in queries:
            print(f"👤 User: {query}")
            response = agent.think(query)
            print(f"🤖 Agent: {response}\n")
            print("-" * 60)
            
    except Exception as e:
        print(f"⚠️  Error: {e}")
        print("Make sure you have set OPENAI_API_KEY in .env")


def demo_sql_agent():
    """Demonstrate SQL database agent."""
    print("\n" + "=" * 60)
    print("🗄️  Demo 2: SQL Database Agent")
    print("=" * 60)
    
    try:
        from sql_agent import SQLAgent
        
        agent = SQLAgent()
        
        queries = [
            "What tables are in the database?",
            "Show me the top 3 customers by total spent",
            "How many products are in stock?"
        ]
        
        for query in queries:
            print(f"\n👤 User: {query}")
            response = agent.query(query)
            print(f"🤖 Agent: {response}\n")
            print("-" * 60)
            
    except Exception as e:
        print(f"⚠️  Error: {e}")
        print("Make sure you have set OPENAI_API_KEY in .env")


def demo_cafe_agent():
    """Demonstrate LangGraph café ordering agent."""
    print("\n" + "=" * 60)
    print("☕ Demo 3: LangGraph Café Ordering Agent")
    print("=" * 60)
    
    try:
        from cafe_agent import CafeOrderingAgent
        
        agent = CafeOrderingAgent()
        
        conversation = [
            "Hi!",
            "I'd like a medium latte",
            "And a croissant please",
            "That's everything, thank you!"
        ]
        
        for user_input in conversation:
            print(f"\n👤 Customer: {user_input}")
            response = agent.take_order(user_input)
            print(f"🤖 Barista: {response}\n")
            print("-" * 60)
            
    except Exception as e:
        print(f"⚠️  Error: {e}")
        print("Make sure you have set OPENAI_API_KEY in .env")
        print("Note: LangGraph is optional - a simplified version will be used if not installed")


def main():
    """Run all demos."""
    print("🤖 Day 3: Generative AI Agents - Comprehensive Demo")
    print("=" * 60)
    
    # Check API key
    if not os.getenv("OPENAI_API_KEY"):
        print("\n⚠️  Please set your OPENAI_API_KEY in .env file")
        print("\nExample:")
        print("  OPENAI_API_KEY=sk-your-key-here")
        return
    
    # Run demos
    demo_function_calling()
    demo_sql_agent()
    demo_cafe_agent()
    
    print("\n" + "=" * 60)
    print("✅ All demos completed!")
    print("=" * 60)
    print("\n💡 Next Steps:")
    print("  1. Try the interactive modes:")
    print("     - python agent.py --interactive")
    print("     - python sql_agent.py --interactive")
    print("     - python cafe_agent.py --interactive")
    print("  2. Explore the Jupyter notebook: notebook.ipynb")
    print("  3. Read notes.md for detailed explanations")
    print("  4. Complete the Kaggle code labs mentioned in README.md")


if __name__ == "__main__":
    main()



