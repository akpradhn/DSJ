"""
Day 3: LangGraph Café Ordering Agent

This module demonstrates building a stateful agent using LangGraph that can
take orders in a café. The agent maintains order state and can handle multi-step
conversations to complete an order.

This is inspired by the Kaggle code lab: "Build an agentic ordering system in LangGraph"
"""

import os
from typing import TypedDict, Annotated, List, Dict, Any
from dotenv import load_dotenv

from langchain_openai import ChatOpenAI
from langchain_core.messages import HumanMessage, AIMessage, SystemMessage
from langchain_core.prompts import ChatPromptTemplate

# Try to import LangGraph, fallback to basic implementation if not available
try:
    from langgraph.graph import StateGraph, END
    from langgraph.graph.message import add_messages
    LANGGRAPH_AVAILABLE = True
except ImportError:
    LANGGRAPH_AVAILABLE = False
    print("⚠️  LangGraph not installed. Using simplified implementation.")
    print("   Install with: pip install langgraph")

# Load environment variables
load_dotenv()


# Café Menu
CAFE_MENU = {
    "coffee": {
        "small": 2.50,
        "medium": 3.00,
        "large": 3.50
    },
    "latte": {
        "small": 3.50,
        "medium": 4.00,
        "large": 4.50
    },
    "cappuccino": {
        "small": 3.50,
        "medium": 4.00,
        "large": 4.50
    },
    "espresso": {
        "single": 2.00,
        "double": 3.00
    },
    "croissant": 3.00,
    "muffin": 2.50,
    "sandwich": 5.50,
    "salad": 6.00,
}


class OrderState(TypedDict):
    """State for the café ordering agent."""
    messages: Annotated[List[Any], add_messages]
    order_items: List[Dict[str, Any]]
    order_total: float
    order_complete: bool
    customer_name: str


class CafeOrderingAgent:
    """
    A stateful café ordering agent built with LangGraph.
    
    The agent can:
    - Take orders for food and drinks
    - Remember order items across turns
    - Calculate totals
    - Confirm and complete orders
    """
    
    def __init__(self, model: str = "gpt-3.5-turbo"):
        """
        Initialize the café ordering agent.
        
        Args:
            model: LLM model to use
        """
        self.llm = ChatOpenAI(model=model, temperature=0.7)
        self.menu = CAFE_MENU
        
        if LANGGRAPH_AVAILABLE:
            self.graph = self._build_graph()
        else:
            self.graph = None
            # Fallback to simple state management
            self.state = {
                "order_items": [],
                "order_total": 0.0,
                "order_complete": False,
                "customer_name": ""
            }
    
    def _build_graph(self):
        """Build the LangGraph workflow."""
        workflow = StateGraph(OrderState)
        
        # Add nodes
        workflow.add_node("agent", self._agent_node)
        workflow.add_node("process_order", self._process_order_node)
        workflow.add_node("calculate_total", self._calculate_total_node)
        
        # Set entry point
        workflow.set_entry_point("agent")
        
        # Add edges
        workflow.add_edge("agent", "process_order")
        workflow.add_edge("process_order", "calculate_total")
        workflow.add_conditional_edges(
            "calculate_total",
            self._should_complete_order,
            {
                "continue": "agent",
                "complete": END
            }
        )
        
        return workflow.compile()
    
    def _agent_node(self, state: OrderState) -> OrderState:
        """Agent node that processes user input."""
        messages = state.get("messages", [])
        order_items = state.get("order_items", [])
        
        # Build context about current order
        order_context = ""
        if order_items:
            order_context = f"\nCurrent order: {order_items}\n"
        
        # Create prompt
        prompt = ChatPromptTemplate.from_messages([
            SystemMessage(content=f"""You are a friendly café barista taking orders.

Menu:
{self._format_menu()}

{order_context}

Your tasks:
1. Greet customers warmly
2. Take their order (item, size if applicable)
3. Confirm items and sizes
4. Ask if they want anything else
5. When order is complete, summarize the order and total

Be friendly, helpful, and confirm details before finalizing."""),
            *messages
        ])
        
        response = self.llm.invoke(prompt.format_messages())
        
        return {
            "messages": [response]
        }
    
    def _process_order_node(self, state: OrderState) -> OrderState:
        """Process the order and extract items."""
        messages = state.get("messages", [])
        last_message = messages[-1] if messages else None
        
        if last_message and isinstance(last_message, AIMessage):
            # Extract order items from the agent's response
            # This is simplified - in production, use structured output or NER
            order_items = state.get("order_items", [])
            
            # Simple extraction (in production, use more sophisticated parsing)
            content = last_message.content.lower()
            
            # Check for menu items mentioned
            for item, prices in self.menu.items():
                if isinstance(prices, dict):
                    # Has sizes
                    for size in prices.keys():
                        if item in content and size in content:
                            order_items.append({
                                "item": item,
                                "size": size,
                                "price": prices[size]
                            })
                            break
                else:
                    # Fixed price
                    if item in content:
                        order_items.append({
                            "item": item,
                            "price": prices
                        })
        
        return {
            "order_items": order_items
        }
    
    def _calculate_total_node(self, state: OrderState) -> OrderState:
        """Calculate the order total."""
        order_items = state.get("order_items", [])
        total = sum(item.get("price", 0) for item in order_items)
        
        return {
            "order_total": total
        }
    
    def _should_complete_order(self, state: OrderState) -> str:
        """Determine if order should be completed."""
        messages = state.get("messages", [])
        last_message = messages[-1] if messages else None
        
        if last_message:
            content = last_message.content.lower()
            if any(word in content for word in ["complete", "done", "that's all", "finish"]):
                return "complete"
        
        return "continue"
    
    def _format_menu(self) -> str:
        """Format the menu for display."""
        menu_text = "Menu:\n"
        for item, prices in self.menu.items():
            if isinstance(prices, dict):
                menu_text += f"  {item.title()}:\n"
                for size, price in prices.items():
                    menu_text += f"    {size.title()}: ${price:.2f}\n"
            else:
                menu_text += f"  {item.title()}: ${prices:.2f}\n"
        return menu_text
    
    def take_order(self, user_input: str) -> str:
        """
        Process a user input in the ordering conversation.
        
        Args:
            user_input: User's message
            
        Returns:
            Agent's response
        """
        if LANGGRAPH_AVAILABLE and self.graph:
            # Use LangGraph
            state = {
                "messages": [HumanMessage(content=user_input)],
                "order_items": [],
                "order_total": 0.0,
                "order_complete": False,
                "customer_name": ""
            }
            
            result = self.graph.invoke(state)
            last_message = result["messages"][-1]
            return last_message.content if hasattr(last_message, 'content') else str(last_message)
        else:
            # Fallback implementation
            return self._simple_order_processing(user_input)
    
    def _simple_order_processing(self, user_input: str) -> str:
        """Simple order processing without LangGraph."""
        user_lower = user_input.lower()
        
        # Initialize conversation
        if not hasattr(self, '_conversation_started'):
            self._conversation_started = True
            return "Welcome to our café! How can I help you today? Here's our menu:\n\n" + self._format_menu()
        
        # Extract order items
        order_items = self.state["order_items"]
        
        # Check for menu items
        for item, prices in self.menu.items():
            if isinstance(prices, dict):
                for size in prices.keys():
                    if item in user_lower and size in user_lower:
                        order_items.append({
                            "item": item,
                            "size": size,
                            "price": prices[size]
                        })
                        break
            else:
                if item in user_lower:
                    order_items.append({
                        "item": item,
                        "price": prices
                    })
        
        # Calculate total
        total = sum(item.get("price", 0) for item in order_items)
        self.state["order_total"] = total
        
        # Generate response
        if "done" in user_lower or "that's all" in user_lower or "complete" in user_lower:
            # Complete order
            order_summary = "\n".join([
                f"  - {item.get('item', '').title()} {item.get('size', '').title() if item.get('size') else ''}: ${item.get('price', 0):.2f}"
                for item in order_items
            ])
            
            response = f"""Perfect! Here's your order:

{order_summary}

Total: ${total:.2f}

Thank you! Your order will be ready shortly. Have a great day!"""
            
            # Reset for next order
            self.state = {
                "order_items": [],
                "order_total": 0.0,
                "order_complete": False,
                "customer_name": ""
            }
            self._conversation_started = False
            
            return response
        else:
            # Continue taking order
            if order_items:
                items_text = ", ".join([
                    f"{item.get('item', '').title()} {item.get('size', '').title() if item.get('size') else ''}"
                    for item in order_items
                ])
                return f"Got it! I have: {items_text}. Anything else?"
            else:
                return "I'd be happy to help! What would you like to order?"


def main():
    """Main demo function."""
    print("🤖 Day 3: LangGraph Café Ordering Agent")
    print("=" * 60)
    
    # Check API key
    if not os.getenv("OPENAI_API_KEY"):
        print("\n⚠️  Please set your OPENAI_API_KEY in .env file")
        return
    
    print("\n🚀 Initializing café ordering agent...")
    agent = CafeOrderingAgent()
    
    print("\n" + "=" * 60)
    print("📝 Sample Ordering Conversation")
    print("=" * 60)
    
    # Sample conversation
    conversation = [
        "Hello!",
        "I'd like a large coffee",
        "And a croissant",
        "That's all, thanks!"
    ]
    
    for user_input in conversation:
        print(f"\n👤 Customer: {user_input}")
        response = agent.take_order(user_input)
        print(f"🤖 Barista: {response}")
        print("-" * 60)
    
    print("\n✅ Demo completed!")
    print("\n💡 Try running interactively:")
    print("   python cafe_agent.py --interactive")


if __name__ == "__main__":
    import sys
    
    if "--interactive" in sys.argv:
        print("🤖 Day 3: Café Ordering Agent - Interactive Mode")
        print("=" * 60)
        print("Type 'quit' to exit, 'menu' to see menu\n")
        
        agent = CafeOrderingAgent()
        
        while True:
            user_input = input("\nYou: ")
            
            if user_input.lower() == 'quit':
                print("\n👋 Goodbye!")
                break
            
            if user_input.lower() == 'menu':
                print("\n" + agent._format_menu())
                continue
            
            if not user_input.strip():
                continue
            
            response = agent.take_order(user_input)
            print(f"\nBarista: {response}\n")
    else:
        main()



