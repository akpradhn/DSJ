"""
Configuration settings for 100 Days of AI Agents

This module contains configuration constants and settings used across the project.
"""

import os
from dotenv import load_dotenv
from typing import Dict, Any

# Load environment variables
load_dotenv()


# Model Configuration
MODEL_CONFIG = {
    "openai": {
        "default_model": os.getenv("DEFAULT_MODEL", "gpt-4"),
        "embedding_model": os.getenv("DEFAULT_EMBEDDING_MODEL", "text-embedding-3-small"),
        "temperature": 0.7,
        "max_tokens": 2000,
        "top_p": 1.0,
        "frequency_penalty": 0.0,
        "presence_penalty": 0.0,
    },
    "anthropic": {
        "default_model": "claude-3-sonnet-20240229",
        "temperature": 0.7,
        "max_tokens": 2000,
    },
    "google": {
        "default_model": "gemini-pro",
        "temperature": 0.7,
        "max_tokens": 2000,
    },
}


# Vector Store Configuration
VECTOR_STORES = {
    "chroma": {
        "persist_directory": "./chroma_db",
        "collection_name": "100_days_agents",
    },
    "pinecone": {
        "index_name": "100-days-agents",
        "metric": "cosine",
        "dimension": 1536,
    },
}


# Agent Configuration
AGENT_CONFIG = {
    "max_iterations": 10,
    "max_execution_time": 300,  # seconds
    "verbose": True,
    "return_intermediate_steps": True,
    "handle_parsing_errors": True,
}


# API Configuration
API_CONFIG = {
    "timeout": 60,
    "max_retries": 3,
    "retry_delay": 1,
    "stream": False,
}


# Directory Structure
DIRECTORIES = {
    "days": "day{:02d}_{}",
    "projects": "projects",
    "data": "data",
    "logs": "logs",
    "outputs": "outputs",
    "cache": ".cache",
}


# Feature Flags
FEATURES = {
    "enable_streaming": True,
    "enable_monitoring": True,
    "enable_caching": True,
    "enable_tracing": os.getenv("LANGCHAIN_TRACING_V2", "false") == "true",
}


def get_model_config(provider: str) -> Dict[str, Any]:
    """
    Get model configuration for a specific provider.
    
    Args:
        provider: Model provider (openai, anthropic, google)
        
    Returns:
        Configuration dictionary
    """
    return MODEL_CONFIG.get(provider, MODEL_CONFIG["openai"]).copy()


def get_vector_store_config(store: str) -> Dict[str, Any]:
    """
    Get vector store configuration.
    
    Args:
        store: Vector store type (chroma, pinecone)
        
    Returns:
        Configuration dictionary
    """
    return VECTOR_STORES.get(store, VECTOR_STORES["chroma"]).copy()


def get_agent_config() -> Dict[str, Any]:
    """
    Get agent configuration.
    
    Returns:
        Configuration dictionary
    """
    return AGENT_CONFIG.copy()


def get_api_config() -> Dict[str, Any]:
    """
    Get API configuration.
    
    Returns:
        Configuration dictionary
    """
    return API_CONFIG.copy()


def update_config(section: str, key: str, value: Any) -> None:
    """
    Update a configuration value.
    
    Args:
        section: Configuration section name
        key: Configuration key
        value: New value
    """
    config_maps = {
        "model": MODEL_CONFIG,
        "vector_store": VECTOR_STORES,
        "agent": AGENT_CONFIG,
        "api": API_CONFIG,
    }
    
    config = config_maps.get(section)
    if config and key in config:
        config[key] = value
        print(f"Updated {section}.{key} to {value}")


def create_day_directory(day_number: int, topic: str) -> str:
    """
    Create a properly formatted day directory name.
    
    Args:
        day_number: Day number
        topic: Topic name
        
    Returns:
        Directory name
    """
    # Replace spaces with underscores and make lowercase
    topic_normalized = topic.lower().replace(" ", "_")
    return DIRECTORIES["days"].format(day_number, topic_normalized)


if __name__ == "__main__":
    print("Configuration Settings\n")
    print(f"OpenAI Model: {get_model_config('openai')['default_model']}")
    print(f"Temperature: {get_model_config('openai')['temperature']}")
    print(f"Max Tokens: {get_model_config('openai')['max_tokens']}")
    print(f"\nFeature Flags:")
    for feature, enabled in FEATURES.items():
        print(f"  {feature}: {'✅' if enabled else '❌'}")
