# Day 2 Notes: Agents with Memory

## Learning Objectives

By the end of this day, you should understand:
1. Why memory is important for AI agents
2. Different types of memory and when to use each
3. How to implement memory using LangChain
4. The trade-offs between different memory strategies

---

## Core Concepts

### 1. Why Do Agents Need Memory?

**Without Memory:**
```
User: "My name is Alex"
Agent: "Nice to meet you, Alex!"

User: "What did you say my name is?"
Agent: "I don't know what you're referring to." ❌
```

**With Memory:**
```
User: "My name is Alex"
Agent: "Nice to meet you, Alex!"

User: "What did you say my name is?"
Agent: "You said your name is Alex!" ✅
```

Memory enables agents to:
- Maintain context across multiple turns
- Build relationships with users
- Remember user preferences
- Provide personalized experiences

### 2. Types of Memory

#### **Buffer Memory** 📝
- **What**: Stores all conversation messages
- **When to use**: Short conversations, full context needed
- **Pros**: Complete conversation history
- **Cons**: Can hit token limits quickly

```python
memory = ConversationBufferMemory(return_messages=True)
```

#### **Summary Memory** 📊
- **What**: Summarizes past conversations
- **When to use**: Long conversations, need to save tokens
- **Pros**: Efficient token usage
- **Cons**: May lose specific details

```python
memory = ConversationSummaryMemory(llm=llm, return_messages=True)
```

#### **Window Memory** 🪟
- **What**: Keeps only the last N messages
- **When to use**: Only recent context matters
- **Pros**: Recent context, fixed token usage
- **Cons**: Loses older information

```python
memory = ConversationBufferWindowMemory(k=5, return_messages=True)
```

#### **Summary Buffer Memory** 🔄
- **What**: Hybrid - summary + recent messages
- **When to use**: Balance between context and efficiency
- **Pros**: Best of both worlds
- **Cons**: Most complex to manage

```python
memory = ConversationSummaryBufferMemory(
    llm=llm,
    max_token_limit=100,
    return_messages=True
)
```

---

## Implementation Details

### Memory Internals

LangChain memory works by:
1. **Storing**: Messages are added to memory
2. **Loading**: Messages are retrieved when needed
3. **Pruning**: Old messages are removed/summarized
4. **Formatting**: Messages are formatted for the LLM

### Memory Lifecycle

```
Input → [Memory System] → Context → LLM → Output
         ↑                                    ↓
         └────────── Store Output ────────────┘
```

### Custom Memory Implementation

```python
class CustomMemory:
    def __init__(self):
        self.messages = []
    
    def add_user_message(self, message):
        self.messages.append({"role": "user", "content": message})
    
    def add_ai_message(self, message):
        self.messages.append({"role": "assistant", "content": message})
    
    def load_messages(self):
        return self.messages  # Return formatted messages for LLM
```

---

## Use Cases

### 1. Customer Support Bot
- **Memory Type**: Buffer + Summary
- **Reason**: Need full conversation history for context, but summarize old sessions

### 2. Personal Assistant
- **Memory Type**: Long-term + Short-term
- **Reason**: Remember preferences, but also recent context

### 3. Code Review Agent
- **Memory Type**: Buffer
- **Reason**: Need complete context of code changes

### 4. Research Assistant
- **Memory Type**: Summary + Semantic Search
- **Reason**: Summarize findings, but maintain searchable knowledge

---

## Advanced Topics

### Memory Persistence

Save memory to disk:
```python
import pickle

# Save
with open('memory.pkl', 'wb') as f:
    pickle.dump(agent.memory, f)

# Load
with open('memory.pkl', 'rb') as f:
    agent.memory = pickle.load(f)
```

### Memory with Vector Stores

Store conversations in vector DB for semantic search:
```python
from langchain.memory import ConversationBufferMemory
from langchain.vectorstores import Chroma

# Combine buffer memory with vector store
memory = ConversationBufferMemory(return_messages=True)
# Search across all past conversations
```

### Token Management

Monitor and manage token usage:
```python
from tiktoken import encoding_for_model

def count_tokens(text, model="gpt-3.5-turbo"):
    encoding = encoding_for_model(model)
    return len(encoding.encode(text))

# Track token usage
total_tokens = sum(count_tokens(msg["content"]) for msg in messages)
```

---

## Best Practices

### 1. Choose the Right Memory Type
- **Short conversations** (< 1000 tokens): Buffer
- **Medium conversations** (1000-5000 tokens): Window
- **Long conversations** (> 5000 tokens): Summary

### 2. Set Appropriate Limits
```python
# Too small: Loses context
window_memory = ConversationBufferWindowMemory(k=1)

# Too large: Wastes tokens
window_memory = ConversationBufferWindowMemory(k=100)

# Just right: Balanced
window_memory = ConversationBufferWindowMemory(k=10)
```

### 3. Regularly Summarize Old Conversations
```python
if len(messages) > threshold:
    summary = summarize_conversation(messages)
    # Replace old messages with summary
```

### 4. Clear Memory When Starting New Topics
```python
# User explicitly starts new topic
if user_says("new topic"):
    agent.clear_memory()
```

---

## Exercises

1. **Implement Custom Memory**: Build a memory system that:
   - Stores last 5 messages
   - Summarizes everything older
   - Maintains a "user profile"

2. **Memory Comparison**: Run the same conversation with different memory types and compare results

3. **Memory Persistence**: Save and load conversation memory across sessions

---

## Key Takeaways

1. **Memory is essential** for practical AI agents
2. **Different memory types** serve different needs
3. **Trade-offs exist** between context and efficiency
4. **Custom memory** gives you full control

---

## Resources

- [LangChain Memory Documentation](https://python.langchain.com/docs/modules/memory/)
- [Memory Types Comparison](https://python.langchain.com/docs/modules/memory/types/)
- [Token Counting Guide](https://platform.openai.com/docs/guides/text-generation/managing-tokens)

---

## Next Day Preview

Tomorrow we'll add **tools and function calling** so your agent can:
- Use external APIs
- Search the web
- Perform calculations
- Interact with databases

See you on Day 3! 🚀
