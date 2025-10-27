# 🗺️ 100 Days of AI Agents - Learning Roadmap

A comprehensive day-by-day plan to master AI Agents from scratch to expert level.

---

## 📊 Overview

| Phase | Days | Focus | Complexity |
|-------|------|-------|------------|
| **Phase 1: Foundations** | 1-20 | Basics, Prompts, Memory, Tools | ⭐ |
| **Phase 2: Frameworks** | 21-50 | LangChain, LlamaIndex, CrewAI | ⭐⭐ |
| **Phase 3: Advanced** | 51-75 | Multi-agents, Planning, Orchestration | ⭐⭐⭐ |
| **Phase 4: Applied** | 76-100 | Real-world Projects, Production | ⭐⭐⭐⭐ |

---

## 🎯 Phase 1: Foundations (Days 1-20)

### Week 1: Introduction & Core Concepts

#### **Day 1: Intro to Agents**
- What is an AI Agent?
- Agent vs. Prompt vs. API call
- Building a minimal agent loop
- Concepts: ReAct pattern, Agent loop

#### **Day 2: Prompt Engineering Fundamentals**
- Clear instructions and role definition
- Few-shot examples
- Chain of thought prompting
- Project: Smart assistant that follows instructions

#### **Day 3: Agent with Memory**
- Short-term memory (conversation history)
- Using LangChain's memory modules
- Memory types: Buffer, Summary, Buffer + Summary
- Project: Memory-augmented chatbot

#### **Day 4: Function Calling / Tools**
- What are tools?
- Building custom tools
- Agent tool selection loop
- Project: Calculator agent with math tools

#### **Day 5: Retrieval-Augmented Generation (RAG)**
- What is RAG?
- Embedding vectors
- Similarity search
- Project: Document Q&A agent

### Week 2: Advanced Basics

#### **Day 6: Agents with Web Search**
- Integrating web search tools
- DuckDuckGo, Serper, Tavily
- Real-time information gathering
- Project: Research assistant agent

#### **Day 7: Structured Output**
- Pydantic models
- Guaranteed schema compliance
- Function calling for structure
- Project: Data extraction agent

#### **Day 8: Error Handling & Safety**
- Try-except in agents
- LLM hallucination mitigation
- Input validation
- Project: Safe calculator agent

#### **Day 9: Streaming Responses**
- Token-by-token output
- Using callbacks
- UX for long responses
- Project: Streaming chatbot

#### **Day 10: Agent Configurations**
- Temperature, top-p, max_tokens
- Model selection (GPT-4 vs GPT-3.5 vs Claude)
- When to use which model
- Project: Configurable agent

### Week 3: Memory & Context

#### **Day 11: Long-Term Memory**
- Vector stores
- Persisting conversations
- Pinecone, Chroma, FAISS
- Project: Persistent memory agent

#### **Day 12: External Knowledge Bases**
- Loading documents
- PDF, CSV, web scraping
- Using loaders
- Project: Knowledge-aware agent

#### **Day 13: Memory Management**
- Token limits and context windows
- Truncation strategies
- Summary + retrieval hybrid
- Project: Efficient memory agent

#### **Day 14: Multi-Turn Conversations**
- Conversation flow
- Context preservation
- State management
- Project: Multi-turn Q&A agent

#### **Day 15: Agent Templates**
- Creating reusable agent templates
- Configuration-driven agents
- Best practices
- Project: Template library

### Week 4: Tools & Integrations

#### **Day 16: Custom Tools Deep Dive**
- Building advanced tools
- Tool validation
- Parallel tool calling
- Project: Slack integration agent

#### **Day 17: API Integration**
- RESTful API wrappers
- Authentication in tools
- Error handling
- Project: Weather agent

#### **Day 18: File Operations Agent**
- Reading/writing files
- Directory operations
- File type handling
- Project: File management agent

#### **Day 19: Database Agents**
- SQL agents
- Query generation and validation
- Data visualization
- Project: SQL query agent

#### **Day 20: Code Execution Agents**
- Executing Python code
- Sandboxed environments
- Security considerations
- Project: Code executor agent

---

## 🛠️ Phase 2: Frameworks (Days 21-50)

### Week 5-6: LangChain Deep Dive

#### **Days 21-25: LangChain Core**
- LangChain architecture
- Chains, agents, and memory
- Built-in tools and loaders
- Projects: Research agent, document chatbot

#### **Days 26-30: LangChain Agents**
- ReAct agent
- Plan-and-execute agent
- Custom agent executors
- Projects: Autonomous researcher, planner agent

#### **Days 31-35: LangChain Advanced**
- Streaming with LangChain
- Custom callbacks
- Production deployment
- Projects: Production-ready agent, monitoring

### Week 7-8: LlamaIndex

#### **Days 36-40: LlamaIndex Basics**
- Index construction
- Query engines and retrievers
- Custom loaders
- Projects: Document Q&A, knowledge agent

#### **Days 41-45: LlamaIndex Advanced**
- Multi-document agents
- Embedding strategies
- Query optimization
- Projects: Enterprise search agent

### Week 9-10: CrewAI & Multi-Agent

#### **Days 46-50: CrewAI**
- CrewAI concepts
- Agent roles and tasks
- Collaboration patterns
- Projects: Crew-based research agent

---

## 🚀 Phase 3: Advanced Concepts (Days 51-75)

### Week 11-12: Multi-Agent Systems

#### **Days 51-60: Multi-Agent Coordination**
- Agent communication
- Swarm architectures
- Hierarchical agents
- Projects: Multi-agent research crew, autonomous team

### Week 13-14: Advanced Planning

#### **Days 61-70: Planning & Reasoning**
- Tree of thoughts
- Graph-based planning
- Adaptive strategies
- Projects: Planning agent, task breakdown agent

### Week 15: Orchestration & Production

#### **Days 71-75: Agent Orchestration**
- Agent-to-agent protocols
- State machines
- Failure recovery
- Projects: Resilient agent system

---

## 🏗️ Phase 4: Applied Projects (Days 76-100)

### Week 16-17: Real-World Projects

#### **Days 76-85: Applied Projects**
- Trading Agent
- Research Assistant
- Customer Support Bot
- Autonomous Developer Agent

### Week 18-19: Enterprise Features

#### **Days 86-95: Production-Ready Agents**
- API development (FastAPI)
- Authentication & authorization
- Monitoring & logging
- Cost optimization
- Scaling strategies

### Week 20: Final Capstone

#### **Days 96-100: Capstone Project**
- Build a complete multi-agent system
- Deploy to production
- Documentation and testing
- Final showcase

---

## 🎯 Milestones

- **Day 20**: Basic agent building competence
- **Day 50**: Framework proficiency
- **Day 75**: Advanced multi-agent systems
- **Day 100**: Production-ready agent architect

---

## 📚 Resources

### Essential Reading
- [LangChain Documentation](https://python.langchain.com/)
- [LlamaIndex Documentation](https://www.llamaindex.ai/)
- [CrewAI Documentation](https://docs.crewai.com/)
- [OpenAI Documentation](https://platform.openai.com/docs)

### Recommended Courses
- LangChain's official tutorials
- LlamaIndex tutorials
- ReAct paper
- Multi-agent systems research

---

## 🔄 Updates

This roadmap is **living document** and will be updated based on:
- Learning discoveries
- New framework features
- Community feedback
- Emerging best practices

---

**Ready to start? Begin with [Day 1: Intro to Agents](day01_intro_to_agents/)!**

---

*Last Updated: 2024*
