"""
Prompt templates for common agent patterns

This module contains reusable prompt templates for various agent types.
"""

from typing import Dict, List


# System prompts for different agent types
SYSTEM_PROMPTS = {
    "general_assistant": """You are a helpful AI assistant. You provide accurate, 
helpful, and respectful responses. You can use tools to gather information, 
perform calculations, or interact with external systems when needed.""",
    
    "research_assistant": """You are a research assistant. Your role is to:
1. Gather information from reliable sources
2. Analyze and synthesize findings
3. Present information clearly and concisely
4. Cite your sources when possible

Use tools to search the web, access databases, and retrieve documents.""",
    
    "math_tutor": """You are a patient and friendly math tutor. You help students 
understand mathematical concepts by:
1. Breaking down complex problems into simpler steps
2. Explaining the reasoning behind each step
3. Providing similar practice problems
4. Encouraging critical thinking

You can use calculators and visualization tools.""",
    
    "code_assistant": """You are an expert software engineer. You help with:
1. Writing clean, efficient code
2. Debugging and fixing errors
3. Explaining code logic
4. Suggesting best practices
5. Code reviews and optimization

Always write production-ready code with comments and documentation.""",
    
    "data_analyst": """You are a data analyst. Your responsibilities include:
1. Loading and cleaning datasets
2. Performing statistical analysis
3. Creating visualizations
4. Interpreting results
5. Presenting insights

Use tools to query databases, analyze data, and create visualizations.""",
}


def get_system_prompt(agent_type: str) -> str:
    """
    Retrieve a system prompt for a specific agent type.
    
    Args:
        agent_type: Type of agent (general_assistant, research_assistant, etc.)
        
    Returns:
        System prompt string
    """
    return SYSTEM_PROMPTS.get(agent_type, SYSTEM_PROMPTS["general_assistant"])


def build_agent_prompt(
    system_prompt: str,
    instructions: List[str] = None,
    constraints: List[str] = None,
    examples: List[Dict[str, str]] = None
) -> str:
    """
    Build a comprehensive agent prompt from components.
    
    Args:
        system_prompt: Base system prompt
        instructions: List of specific instructions
        constraints: List of constraints to follow
        examples: List of example interactions
        
    Returns:
        Formatted agent prompt
    """
    prompt = system_prompt
    
    if instructions:
        prompt += "\n\n## Instructions:"
        for i, instruction in enumerate(instructions, 1):
            prompt += f"\n{i}. {instruction}"
    
    if constraints:
        prompt += "\n\n## Constraints:"
        for i, constraint in enumerate(constraints, 1):
            prompt += f"\n{i}. {constraint}"
    
    if examples:
        prompt += "\n\n## Examples:"
        for i, example in enumerate(examples, 1):
            prompt += f"\n\n### Example {i}:"
            prompt += f"\nUser: {example.get('user', '')}"
            prompt += f"\nAssistant: {example.get('assistant', '')}"
    
    return prompt


# Few-shot examples for different scenarios
FEW_SHOT_EXAMPLES = {
    "q_and_a": [
        {
            "user": "What is the capital of France?",
            "assistant": "The capital of France is Paris."
        },
        {
            "user": "Who wrote Romeo and Juliet?",
            "assistant": "Romeo and Juliet was written by William Shakespeare."
        }
    ],
    
    "reasoning": [
        {
            "user": "If I have 5 apples and give away 2, how many do I have left?",
            "assistant": "I need to subtract 2 from 5. 5 - 2 = 3. So you have 3 apples left."
        },
        {
            "user": "What's 15% of 200?",
            "assistant": "To find 15% of 200, I calculate: 0.15 × 200 = 30. So 15% of 200 is 30."
        }
    ],
    
    "multi_step": [
        {
            "user": "Book a flight from NYC to LA for next Friday",
            "assistant": """Let me help you book that flight. I'll need to:
1. Search for available flights from NYC to LA for next Friday
2. Compare prices and times
3. Reserve a seat on your preferred flight

Let me start by searching for flights..."""
        }
    ],
}


def get_few_shot_examples(scenario: str, count: int = 2) -> List[Dict[str, str]]:
    """
    Retrieve few-shot examples for a specific scenario.
    
    Args:
        scenario: Type of scenario (q_and_a, reasoning, multi_step)
        count: Number of examples to return
        
    Returns:
        List of example interactions
    """
    examples = FEW_SHOT_EXAMPLES.get(scenario, [])
    return examples[:count]


# Tool-use prompts
TOOL_USE_PROMPTS = {
    "before_tool": """You have access to the following tools. Use them when appropriate:
{tools}

Important guidelines:
- Only use tools when necessary
- Always explain why you're using a tool
- Interpret the results for the user
- If a tool fails, try an alternative approach""",
    
    "after_tool": """Observation: {observation}

Based on this information, I can now provide an answer.""",
}


def format_tool_use_message(tools: List[str]) -> str:
    """
    Format a message describing available tools.
    
    Args:
        tools: List of tool descriptions
        
    Returns:
        Formatted tool description
    """
    tools_text = "\n".join(f"- {tool}" for tool in tools)
    return TOOL_USE_PROMPTS["before_tool"].format(tools=tools_text)


if __name__ == "__main__":
    # Test prompts
    print("Testing Prompt Templates\n")
    
    # Test system prompt
    assistant_prompt = get_system_prompt("general_assistant")
    print("General Assistant Prompt:")
    print(assistant_prompt)
    print("\n" + "-"*60 + "\n")
    
    # Test building comprehensive prompt
    custom_prompt = build_agent_prompt(
        system_prompt=assistant_prompt,
        instructions=[
            "Always be polite and professional",
            "Provide accurate information",
            "Ask clarifying questions when needed"
        ],
        constraints=[
            "Do not provide medical advice",
            "Respect user privacy"
        ]
    )
    print("Custom Prompt:")
    print(custom_prompt)
    print("\n" + "-"*60 + "\n")
    
    # Test few-shot examples
    examples = get_few_shot_examples("q_and_a", count=2)
    print("Few-shot Examples:")
    for i, example in enumerate(examples, 1):
        print(f"\nExample {i}:")
        print(f"User: {example['user']}")
        print(f"Assistant: {example['assistant']}")
