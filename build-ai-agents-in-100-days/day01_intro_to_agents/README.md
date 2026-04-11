# Day 1: Introduction to AI Agents

Welcome to Day 1! Today we'll build a minimal AI agent and learn the core concepts.

## 🎯 Learning Objectives

By the end of this day, you'll understand:
- What an AI agent is
- How the agent loop works
- The ReAct pattern (Reasoning + Acting)
- How agents maintain conversation history

## 🚀 Running Day 1

### Prerequisites
1. Make sure you have completed the setup:
   ```bash
   bash setup/setup.sh
   ```

2. Add your OpenAI API key to `.env`:
   ```bash
   # Copy the example
   cp .env.example .env
   
   # Edit and add your key
   # OPENAI_API_KEY=sk-your-key-here
   ```

### Option 1: Quick Demo
```bash
cd day01_intro_to_agents
source ../../venv/bin/activate
python demo.py
```

### Option 2: Interactive Agent
```bash
cd day01_intro_to_agents
source ../../venv/bin/activate
python agent.py
```

This will start an interactive conversation where you can:
- Chat with the agent
- Type `reset` to clear history
- Type `quit` to exit

### Option 3: Jupyter Notebook
```bash
cd day01_intro_to_agents
source ../../venv/bin/activate
jupyter notebook notebook.ipynb
```

## 📚 Files in This Day

- **`agent.py`** - The main agent implementation
- **`demo.py`** - Quick demonstration script
- **`notebook.ipynb`** - Interactive Jupyter notebook
- **`notes.md`** - Detailed explanations and concepts
- **`README.md`** - This file

## 🔍 What You'll Learn

### 1. The Agent Loop
```python
User Input → Think → Act (optional) → Observe → Respond
                ↓                                      ↑
                └────────── (repeat) ────────────────┘
```

### 2. Key Concepts

**State Management**: The agent maintains conversation history
```python
agent = SimpleAgent()
agent.think("Hello!")
agent.think("What did I just say?")  # Agent remembers!
```

**Temperature Control**: Adjust creativity
```python
conservative_agent = SimpleAgent(temperature=0.1)  # More focused
creative_agent = SimpleAgent(temperature=1.5)      # More creative
```

## 💡 Try This

1. **Different Temperatures**: Create agents with different temperatures
2. **Conversation History**: Check `agent.get_history()`
3. **Reset**: Use `agent.reset()` to clear memory
4. **Custom Prompts**: Modify the agent to have a personality

## 📖 Next Steps

- Read `notes.md` for detailed explanations
- Experiment with the agent in `notebook.ipynb`
- Tomorrow: Adding memory to the agent!

## ⚠️ Troubleshooting

**No API Key**: Set up your `.env` file with your OpenAI API key
**Import Errors**: Make sure venv is activated: `source ../../venv/bin/activate`
**Connection Errors**: Check your internet connection and API key validity

---

Happy coding! 🚀

