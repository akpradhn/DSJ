"""
Day 1 Demo - Quick demonstration of the agent
"""
import sys
import os

# Add parent directory to path for imports
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from dotenv import load_dotenv
load_dotenv()

from agent import SimpleAgent

def run_demo():
    print("🤖 Day 1: Introduction to AI Agents")
    print("=" * 60)
    print("\nThis is a simple demonstration of the AI Agent.\n")
    
    # Check API key
    if not os.getenv("OPENAI_API_KEY") or os.getenv("OPENAI_API_KEY") == "your_openai_api_key_here":
        print("⚠️  Warning: OPENAI_API_KEY not configured.")
        print("\nTo run this demo:")
        print("1. Add your OpenAI API key to .env file in the project root")
        print("2. Run: python demo.py")
        print("\n📝 Quick test without API key:")
        print("Let me show you the agent structure instead...\n")
        return
    
    print("🚀 Initializing agent...")
    agent = SimpleAgent(model="gpt-3.5-turbo", temperature=0.7)
    
    # Sample conversation
    print("\n" + "=" * 60)
    print("📝 Sample Conversation")
    print("=" * 60 + "\n")
    
    test_conversations = [
        "Hello! I'm learning about AI agents.",
        "What makes you different from a regular chatbot?",
        "Can you remember information across multiple turns?"
    ]
    
    for i, question in enumerate(test_conversations, 1):
        print(f"👤 You ({i}): {question}")
        try:
            response = agent.think(question)
            print(f"🤖 Agent: {response}\n")
            print(f"   💡 Conversation has {len(agent.conversation_history)} messages")
            print("-" * 60 + "\n")
        except Exception as e:
            print(f"❌ Error: {e}\n")
            print("Make sure your OpenAI API key is valid.\n")
            return
    
    print("✅ Demo completed successfully!")
    print("\n📚 Next steps:")
    print("- Read notes.md for detailed explanations")
    print("- Try different temperatures in the agent")
    print("- Experiment with conversation history")
    print("\n🎉 Happy coding!")

if __name__ == "__main__":
    run_demo()

