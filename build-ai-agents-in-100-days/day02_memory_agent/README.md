# Day 2: Agents with Memory

Welcome to Day 2! Today we'll add memory capabilities to our agent.

## 🎯 Learning Objectives

By the end of this day, you'll understand:
- Why memory is essential for AI agents
- Different types of memory (Buffer, Summary, Window, etc.)
- How to implement memory using LangChain
- Trade-offs between different memory strategies

## 🚀 Running Day 2

### Prerequisites
1. Complete Day 1
2. Have your API key set in `.env`

### Run the Notebook
```bash
cd day02_memory_agent
source ../venv/bin/activate
jupyter notebook notebook.ipynb
```

### Run the Demo Script
```bash
cd day02_memory_agent
source ../venv/bin/activate
python agent.py
```

### Test Memory Types
```python
from agent import MemoryAgent, compare_memory_types

# Compare different memory types
compare_memory_types()

# Or use a specific memory type
agent = MemoryAgent(memory_type="buffer")
agent.think("Remember this!")
agent.think("What did I say?")
```

## 📚 Files in This Day

- **`agent.py`** - Memory-enabled agents
- **`notebook.ipynb`** - Interactive exercises
- **`notes.md`** - Detailed explanations
- **`README.md`** - This file

## 🔍 What You'll Learn

### Memory Types

#### 1. **Buffer Memory** - Store Everything
```python
from agent import MemoryAgent

agent = MemoryAgent(memory_type="buffer")
agent.think("Store this message")
# All messages are kept in memory
```

#### 2. **Summary Memory** - Summarize Past
```python
agent = MemoryAgent(memory_type="summary")
agent.think("Long conversation...")
# Old conversations are summarized
```

#### 3. **Window Memory** - Recent Only
```python
agent = MemoryAgent(memory_type="window")
agent.think("Message 1")
agent.think("Message 2")
# Only recent messages kept
```

#### 4. **Summary Buffer** - Hybrid
```python
agent = MemoryAgent(memory_type="summary_buffer")
# Recent in buffer, old summarized
```

### Advanced Memory

```python
from agent import AdvancedMemoryAgent

agent = AdvancedMemoryAgent()

# Have a conversation
agent.think("I'm learning AI")
agent.think("I'm on Day 2")

# Generate summary
summary = agent.summarize_conversation()
print(summary)
```

## 💡 Try This

1. **Compare Memory Types**: Run the same conversation with different memory types
2. **Custom Memory**: Modify the memory behavior
3. **Memory Limits**: Experiment with window sizes and token limits
4. **Persistence**: Try saving and loading conversation memory

## 📖 Next Steps

- Read `notes.md` for detailed explanations
- Try the exercises in `notebook.ipynb`
- Tomorrow: Adding tools and function calling!

---

Happy coding! 🚀
