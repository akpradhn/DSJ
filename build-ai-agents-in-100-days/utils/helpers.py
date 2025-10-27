"""
Utility functions for 100 Days of AI Agents

This module contains common helper functions used across different days and projects.
"""

import os
from typing import Any, Dict, List, Optional
from dotenv import load_dotenv
from datetime import datetime
import json

# Load environment variables
load_dotenv()


def load_api_keys() -> Dict[str, Optional[str]]:
    """
    Load all API keys from environment variables.
    
    Returns:
        Dictionary containing all API keys
    """
    return {
        "openai": os.getenv("OPENAI_API_KEY"),
        "anthropic": os.getenv("ANTHROPIC_API_KEY"),
        "google": os.getenv("GOOGLE_API_KEY"),
        "pinecone": os.getenv("PINECONE_API_KEY"),
        "langchain": os.getenv("LANGCHAIN_API_KEY"),
    }


def validate_api_key(service: str) -> bool:
    """
    Validate if an API key exists for a given service.
    
    Args:
        service: Name of the service (openai, anthropic, google, etc.)
        
    Returns:
        True if API key exists, False otherwise
    """
    keys = load_api_keys()
    return keys.get(service) is not None and keys[service] != f"your_{service}_api_key_here"


def print_agent_title(title: str, day: int = None) -> None:
    """
    Print a formatted title for agent demonstrations.
    
    Args:
        title: Title of the agent
        day: Day number (optional)
    """
    print("\n" + "="*60)
    print(f"{title}")
    if day:
        print(f"Day {day}")
    print("="*60 + "\n")


def save_conversation(conversation: List[Dict[str, Any]], filename: str) -> None:
    """
    Save a conversation to a JSON file.
    
    Args:
        conversation: List of message dictionaries
        filename: Output filename
    """
    with open(filename, 'w', encoding='utf-8') as f:
        json.dump(conversation, f, indent=2, ensure_ascii=False)


def load_conversation(filename: str) -> List[Dict[str, Any]]:
    """
    Load a conversation from a JSON file.
    
    Args:
        filename: Input filename
        
    Returns:
        List of message dictionaries
    """
    with open(filename, 'r', encoding='utf-8') as f:
        return json.load(f)


def format_message(message: Dict[str, Any]) -> str:
    """
    Format a message dictionary for display.
    
    Args:
        message: Message dictionary with 'role' and 'content' keys
        
    Returns:
        Formatted string
    """
    role = message.get('role', 'unknown').upper()
    content = message.get('content', '')
    return f"{role}: {content}"


def calculate_cost(model: str, prompt_tokens: int, completion_tokens: int) -> float:
    """
    Calculate the cost of an API call based on token usage.
    
    Pricing (as of 2024):
    - GPT-4: $0.03/1K prompt tokens, $0.06/1K completion tokens
    - GPT-3.5: $0.0015/1K prompt tokens, $0.002/1K completion tokens
    - Claude Opus: $0.015/1K tokens (input), $0.075/1K tokens (output)
    
    Args:
        model: Model name
        prompt_tokens: Number of prompt tokens
        completion_tokens: Number of completion tokens
        
    Returns:
        Estimated cost in USD
    """
    pricing = {
        "gpt-4": (0.03, 0.06),
        "gpt-4-turbo": (0.01, 0.03),
        "gpt-3.5-turbo": (0.0015, 0.002),
        "claude-3-opus": (0.015, 0.075),
        "claude-3-sonnet": (0.003, 0.015),
        "claude-3-haiku": (0.00025, 0.00125),
    }
    
    if model not in pricing:
        return 0.0
    
    prompt_price, completion_price = pricing[model]
    cost = (prompt_tokens / 1000) * prompt_price + (completion_tokens / 1000) * completion_price
    return round(cost, 6)


def log_agent_action(action: str, details: Dict[str, Any] = None) -> None:
    """
    Log an agent action with timestamp.
    
    Args:
        action: Description of the action
        details: Additional details (optional)
    """
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    print(f"\n[{timestamp}] {action}")
    
    if details:
        for key, value in details.items():
            print(f"  {key}: {value}")


def safe_divide(a: float, b: float, default: float = 0.0) -> float:
    """
    Safely divide two numbers, returning a default value if division by zero.
    
    Args:
        a: Numerator
        b: Denominator
        default: Default value if division by zero
        
    Returns:
        Result of division or default value
    """
    try:
        return a / b if b != 0 else default
    except TypeError:
        return default


def chunk_text(text: str, chunk_size: int = 1000, overlap: int = 200) -> List[str]:
    """
    Split text into overlapping chunks.
    
    Args:
        text: Input text to chunk
        chunk_size: Size of each chunk
        overlap: Number of overlapping characters
        
    Returns:
        List of text chunks
    """
    chunks = []
    start = 0
    
    while start < len(text):
        end = start + chunk_size
        chunks.append(text[start:end])
        
        if end >= len(text):
            break
            
        start = end - overlap
    
    return chunks


if __name__ == "__main__":
    # Test the helper functions
    print_agent_title("Testing Helper Functions")
    
    # Test API key loading
    keys = load_api_keys()
    print(f"Loaded API keys: {list(keys.keys())}")
    
    # Test validation
    for service in ["openai", "anthropic", "google"]:
        is_valid = validate_api_key(service)
        print(f"{service} API key: {'✅ Valid' if is_valid else '❌ Not set'}")
    
    # Test cost calculation
    cost = calculate_cost("gpt-4", 1000, 500)
    print(f"\nEstimated cost for GPT-4 (1000 prompt + 500 completion tokens): ${cost}")
