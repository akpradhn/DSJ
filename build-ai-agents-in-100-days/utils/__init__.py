"""
Utils package for 100 Days of AI Agents

This package contains helper modules for common functionality across all days and projects.
"""

from .helpers import (
    load_api_keys,
    validate_api_key,
    print_agent_title,
    save_conversation,
    load_conversation,
    format_message,
    calculate_cost,
    log_agent_action,
    safe_divide,
    chunk_text,
)

from .prompts import (
    get_system_prompt,
    build_agent_prompt,
    get_few_shot_examples,
    format_tool_use_message,
    SYSTEM_PROMPTS,
    FEW_SHOT_EXAMPLES,
    TOOL_USE_PROMPTS,
)

from .config import (
    get_model_config,
    get_vector_store_config,
    get_agent_config,
    get_api_config,
    update_config,
    create_day_directory,
    MODEL_CONFIG,
    VECTOR_STORES,
    AGENT_CONFIG,
    API_CONFIG,
    FEATURES,
)

__all__ = [
    # Helpers
    "load_api_keys",
    "validate_api_key",
    "print_agent_title",
    "save_conversation",
    "load_conversation",
    "format_message",
    "calculate_cost",
    "log_agent_action",
    "safe_divide",
    "chunk_text",
    # Prompts
    "get_system_prompt",
    "build_agent_prompt",
    "get_few_shot_examples",
    "format_tool_use_message",
    "SYSTEM_PROMPTS",
    "FEW_SHOT_EXAMPLES",
    "TOOL_USE_PROMPTS",
    # Config
    "get_model_config",
    "get_vector_store_config",
    "get_agent_config",
    "get_api_config",
    "update_config",
    "create_day_directory",
    "MODEL_CONFIG",
    "VECTOR_STORES",
    "AGENT_CONFIG",
    "API_CONFIG",
    "FEATURES",
]
