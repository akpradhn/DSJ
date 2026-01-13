# Day 3: Generative AI Agents

Welcome to Day 3.

Today you'll learn to build sophisticated AI agents by understanding their core components and the iterative development process. You'll also learn more about advanced agentic architectures and approaches such as multi-agent systems, agent evaluation and more.

The codelabs cover how to connect LLMs to existing systems and to the real world. Learn about function calling by giving SQL tools to a chatbot (including an example using Gemini 2.0's Live API), and learn how to build a LangGraph agent that takes orders in a café.

## 🎯 Learning Objectives

By the end of this day, you'll understand:
- Core components of sophisticated AI agents
- Function calling and tool integration
- How to connect LLMs to existing systems (databases, APIs)
- Building agents with LangGraph
- Advanced agentic architectures
- Multi-agent systems concepts
- Agent evaluation techniques

## 📚 Day 3 Assignments

### Complete Unit 3a - "Generative AI Agents":

1. **Listen to the summary podcast episode** for this unit.

2. **Read the "Generative AI Agents" whitepaper** to complement the podcast.

3. **Complete these code labs on Kaggle:**
   - **Talk to a database with function calling** - Learn how to give SQL tools to a chatbot
   - **Build an agentic ordering system in LangGraph** - Create a café ordering agent

### [Optional] Advanced 3b - "Agents Companion":

1. **Listen to the summary podcast episode** for this unit.

2. **Read the advanced "Agents Companion" whitepaper.**

3. **Want to have an interactive conversation?** Try adding the whitepapers to NotebookLM

4. **[Optional] Read a case study** which talks about how a leading technology regulatory reporting solutions provider used an agentic generative AI system to automate ticket-to-code creation in software development, achieving a 2.5x productivity boost.

5. **[Optional] Watch the YouTube livestream recording.** Paige Bailey will be joined by expert speakers from Google - Alan Blount, Antonio Gulli, Steven Johnson, Jaclyn Konzelmann, Patrick Marlow, Anant Nawalgaria and Julia Wiesinger to discuss generative AI agents.

## 🚀 Running Day 3

### Prerequisites
1. Complete Day 1 and Day 2
2. Have your API keys set in `.env`
3. Install additional dependencies:
   ```bash
   pip install langgraph sqlalchemy
   ```

### Option 1: SQL Database Agent Demo
```bash
cd day03_generative_ai_agents
source ../../venv/bin/activate
python sql_agent.py
```

### Option 2: LangGraph Café Ordering Agent
```bash
cd day03_generative_ai_agents
source ../../venv/bin/activate
python cafe_agent.py
```

### Option 3: Interactive Notebook
```bash
cd day03_generative_ai_agents
source ../../venv/bin/activate
jupyter notebook notebook.ipynb
```

### Option 4: Full Demo
```bash
cd day03_generative_ai_agents
source ../../venv/bin/activate
python demo.py
```

## 📚 Files in This Day

- **`agent.py`** - Main agent implementation with function calling
- **`sql_agent.py`** - SQL database agent with function calling
- **`cafe_agent.py`** - LangGraph café ordering system
- **`demo.py`** - Comprehensive demonstration script
- **`notebook.ipynb`** - Interactive Jupyter notebook
- **`notes.md`** - Detailed explanations and concepts
- **`README.md`** - This file

## 🔍 What You'll Learn

### 1. Function Calling / Tools

Function calling allows agents to interact with external systems:

```python
from agent import AgentWithTools

agent = AgentWithTools()
response = agent.think("What's the total sales for Q1?")
# Agent automatically uses SQL tool to query database
```

### 2. SQL Database Agent

Connect LLMs to databases using function calling:

```python
from sql_agent import SQLAgent

agent = SQLAgent(database_url="sqlite:///sales.db")
response = agent.query("Show me top 10 customers by revenue")
```

### 3. LangGraph Agent

Build stateful, multi-step agents with LangGraph:

```python
from cafe_agent import CafeOrderingAgent

agent = CafeOrderingAgent()
agent.take_order("I'd like a large coffee and a croissant")
```

### 4. Core Components

- **Tools**: Functions the agent can call
- **Memory**: Conversation and context management
- **Planning**: Multi-step reasoning
- **Execution**: Tool invocation and result handling
- **Evaluation**: Measuring agent performance

## 💡 Try This

1. **Custom Tools**: Create your own tools for the agent
2. **Database Integration**: Connect to your own database
3. **LangGraph Workflows**: Build custom agent workflows
4. **Multi-Agent Systems**: Experiment with agent collaboration
5. **Evaluation**: Test agent performance on different tasks

## 📖 Next Steps

- Read `notes.md` for detailed explanations
- Complete the Kaggle code labs
- Experiment with the agents in `notebook.ipynb`
- Tomorrow: Advanced agent architectures and multi-agent systems!

## ⚠️ Troubleshooting

**Import Errors**: Make sure you've installed `langgraph` and `sqlalchemy`
**Database Connection**: Ensure your database URL is correct
**API Key Issues**: Verify your `.env` file has valid API keys

---

Happy coding! 🚀



