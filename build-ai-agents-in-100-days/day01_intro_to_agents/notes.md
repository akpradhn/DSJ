# Day 1 Notes: Introduction to AI Agents

## Learning Objectives

By the end of this day, you should understand:
1. What an AI agent is and how it differs from simple LLM calls
2. The basic agent loop architecture
3. How to implement a minimal agent in Python using LangChain
4. Key concepts: ReAct pattern, state management, conversation history

---

## Core Concepts

### 1. What is an AI Agent?

An **AI Agent** is an autonomous system that:
- Receives inputs from its environment
- Maintains internal state (memory)
- Makes decisions based on current state and inputs
- Can use tools to interact with the world
- Produces outputs that affect the environment

**Key Distinction**: 
- **LLM Call**: Single request → response
- **AI Agent**: Maintains state, can use tools, makes decisions over time

### 2. The Agent Loop

The basic agent loop follows this pattern:

```
┌─────────────────────────────────────────┐
│  1. Observe: Receive user input         │
└───────────────┬─────────────────────────┘
                │
                ▼
┌─────────────────────────────────────────┐
│  2. Think: Process input + context      │
│     - Understand the task               │
│     - Consider available tools           │
│     - Plan next action                  │
└───────────────┬─────────────────────────┘
                │
                ▼
┌─────────────────────────────────────────┐
│  3. Act (optional): Use tools           │
│     - Call APIs                         │
│     - Query databases                    │
│     - Execute code                       │
└───────────────┬─────────────────────────┘
                │
                ▼
┌─────────────────────────────────────────┐
│  4. Observe: Get tool results           │
└───────────────┬─────────────────────────┘
                │
                ▼
┌─────────────────────────────────────────┐
│  5. Respond: Return final answer        │
└─────────────────────────────────────────┘
```

This can repeat multiple times in complex scenarios.

### 3. ReAct Pattern

**ReAct** stands for **Reasoning + Acting**.

- **Reasoning**: The agent thinks about what to do
- **Acting**: The agent uses tools when needed
- **Iteration**: The agent can repeat until satisfied

Example:
```
User: "What's the weather in NYC?"
Agent: "I need to check the weather. Let me use the weather tool."
Agent: [Uses tool] "The weather is 72°F and sunny."
Agent: "The weather in NYC is currently 72°F and sunny."
```

### 4. Memory and State

Agents maintain **state** which includes:
- **Conversation history**: Previous messages
- **Context**: Information from earlier interactions
- **Memory**: Long-term or short-term information

This allows the agent to have multi-turn conversations and remember previous interactions.

---

## Implementation Details

### SimpleAgent Class

Our `SimpleAgent` class implements:

1. **Initialization**:
   - Sets up the LLM (Language Model)
   - Initializes empty conversation history
   - Configures parameters (temperature, model, etc.)

2. **Think Method**:
   - Adds user input to history
   - Converts history to LLM format
   - Invokes LLM with full context
   - Adds response to history
   - Returns response

3. **State Management**:
   - `add_to_history()`: Add messages
   - `get_history()`: Retrieve history
   - `reset()`: Clear history

### Key Code Patterns

#### Pattern 1: Conversation Loop
```python
while True:
    user_input = input("You: ")
    response = agent.think(user_input)
    print(f"Agent: {response}")
```

#### Pattern 2: History Tracking
```python
self.conversation_history.append({
    "role": "user",
    "content": user_input
})
```

#### Pattern 3: LLM Invocation
```python
messages = [HumanMessage(content=msg) for msg in history]
response = self.llm.invoke(messages)
```

---

## Extending the Agent

### Add Tools (Day 4)

```python
def use_tool(self, tool_name: str, params: dict):
    """Use a tool (calculator, API, database, etc.)"""
    if tool_name == "calculator":
        return evaluate(params["expression"])
    elif tool_name == "weather":
        return get_weather(params["location"])
```

### Add Memory (Day 2)

```python
def remember(self, key: str, value: Any):
    """Store information in long-term memory"""
    self.memory[key] = value
```

### Add Error Handling (Day 8)

```python
def think(self, user_input: str) -> str:
    try:
        response = self.llm.invoke(...)
        return response.content
    except Exception as e:
        return f"Error: {str(e)}"
```

---

## Common Patterns

### 1. Streaming Responses
```python
for chunk in self.llm.stream(messages):
    print(chunk.content, end='')
```

### 2. Conditional Tool Use
```python
if needs_calculation:
    result = self.calculator_tool(expression)
    final_response = self.llm.invoke([..., result])
else:
    final_response = self.llm.invoke(...)
```

### 3. Multi-turn Planning
```python
plan = self.llm.invoke([HumanMessage("Break down this task")])
for step in plan.content.split("\n"):
    self.execute_step(step)
```

---

## Key Takeaways

1. **Agents are stateful**: They remember context
2. **Agents can be iterative**: They can loop until complete
3. **Agents can use tools**: External APIs, functions, databases
4. **Agents make decisions**: They choose what to do next

---

## Practice Exercises

1. **Add a name to your agent**: Modify the system prompt to give the agent a personality
2. **Add a counter**: Track how many messages have been exchanged
3. **Add verbose mode**: Log what the agent is "thinking" before responding
4. **Add a greeting**: Make the agent greet the user on first interaction

---

## Resources

- [LangChain Agents Documentation](https://python.langchain.com/docs/modules/agents/)
- [ReAct Paper](https://arxiv.org/abs/2210.03629)
- [OpenAI Function Calling Guide](https://platform.openai.com/docs/guides/function-calling)

---

## Next Day Preview

Tomorrow we'll add **memory** to our agent so it can:
- Remember information across sessions
- Use vector stores for semantic search
- Maintain both short-term and long-term memory

See you on Day 2! 🚀
