"""
Day 3: SQL Database Agent with Function Calling

This module demonstrates how to build an AI agent that can interact with databases
using function calling. The agent can understand natural language queries and
convert them to SQL, then execute and interpret the results.

This is inspired by the Kaggle code lab: "Talk to a database with function calling"
"""

import os
import sqlite3
from typing import List, Dict, Any, Optional
from dotenv import load_dotenv

from langchain_openai import ChatOpenAI
from langchain.tools import Tool
from langchain.agents import AgentExecutor, create_openai_tools_agent
from langchain.prompts import ChatPromptTemplate, MessagesPlaceholder
from langchain_core.messages import HumanMessage, AIMessage, SystemMessage
from langchain_community.utilities import SQLDatabase
from pydantic import BaseModel, Field

# Load environment variables
load_dotenv()


class SQLQueryInput(BaseModel):
    """Input for SQL query tool."""
    query: str = Field(description="SQL query to execute (SELECT statements only)")


class SQLAgent:
    """
    An AI agent that can query SQL databases using natural language.
    
    Features:
    - Natural language to SQL conversion
    - Safe SQL execution (SELECT only)
    - Result interpretation and formatting
    - Error handling and validation
    """
    
    def __init__(self, database_url: str = "sqlite:///sample.db", model: str = "gpt-3.5-turbo"):
        """
        Initialize the SQL agent.
        
        Args:
            database_url: Database connection string
            model: LLM model to use
        """
        self.llm = ChatOpenAI(model=model, temperature=0.7)
        self.db = SQLDatabase.from_uri(database_url)
        self.tools = self._create_tools()
        self.conversation_history: List[Dict[str, str]] = []
        
        # Create sample database if it doesn't exist
        self._create_sample_database()
    
    def _create_sample_database(self):
        """Create a sample database with sample data."""
        # This is a simplified version - in production, you'd use the actual database
        try:
            conn = sqlite3.connect('sample.db')
            cursor = conn.cursor()
            
            # Create tables
            cursor.execute('''
                CREATE TABLE IF NOT EXISTS customers (
                    id INTEGER PRIMARY KEY,
                    name TEXT,
                    email TEXT,
                    city TEXT,
                    total_orders INTEGER,
                    total_spent REAL
                )
            ''')
            
            cursor.execute('''
                CREATE TABLE IF NOT EXISTS products (
                    id INTEGER PRIMARY KEY,
                    name TEXT,
                    category TEXT,
                    price REAL,
                    stock INTEGER
                )
            ''')
            
            cursor.execute('''
                CREATE TABLE IF NOT EXISTS orders (
                    id INTEGER PRIMARY KEY,
                    customer_id INTEGER,
                    product_id INTEGER,
                    quantity INTEGER,
                    order_date TEXT,
                    total REAL,
                    FOREIGN KEY (customer_id) REFERENCES customers(id),
                    FOREIGN KEY (product_id) REFERENCES products(id)
                )
            ''')
            
            # Insert sample data if tables are empty
            cursor.execute('SELECT COUNT(*) FROM customers')
            if cursor.fetchone()[0] == 0:
                customers = [
                    (1, 'Alice Johnson', 'alice@example.com', 'New York', 5, 1250.00),
                    (2, 'Bob Smith', 'bob@example.com', 'London', 3, 850.50),
                    (3, 'Charlie Brown', 'charlie@example.com', 'Tokyo', 8, 2100.75),
                    (4, 'Diana Prince', 'diana@example.com', 'Paris', 2, 450.00),
                    (5, 'Eve Wilson', 'eve@example.com', 'Berlin', 6, 1800.25),
                ]
                cursor.executemany('INSERT INTO customers VALUES (?, ?, ?, ?, ?, ?)', customers)
                
                products = [
                    (1, 'Laptop', 'Electronics', 999.99, 50),
                    (2, 'Mouse', 'Electronics', 29.99, 200),
                    (3, 'Keyboard', 'Electronics', 79.99, 150),
                    (4, 'Monitor', 'Electronics', 299.99, 75),
                    (5, 'Headphones', 'Electronics', 149.99, 100),
                ]
                cursor.executemany('INSERT INTO products VALUES (?, ?, ?, ?, ?)', products)
                
                orders = [
                    (1, 1, 1, 1, '2024-01-15', 999.99),
                    (2, 1, 2, 2, '2024-01-15', 59.98),
                    (3, 2, 3, 1, '2024-02-01', 79.99),
                    (4, 3, 1, 2, '2024-02-10', 1999.98),
                    (5, 3, 4, 1, '2024-02-10', 299.99),
                    (6, 4, 5, 1, '2024-03-05', 149.99),
                    (7, 5, 1, 1, '2024-03-20', 999.99),
                ]
                cursor.executemany('INSERT INTO orders VALUES (?, ?, ?, ?, ?, ?)', orders)
                
                conn.commit()
            
            conn.close()
        except Exception as e:
            print(f"Note: Could not create sample database: {e}")
    
    def _create_tools(self) -> List[Tool]:
        """Create SQL query tool."""
        def execute_sql_query(query: str) -> str:
            """
            Execute a SQL query safely (SELECT only).
            
            Args:
                query: SQL query string
                
            Returns:
                Query results as formatted string
            """
            # Security: Only allow SELECT statements
            query_upper = query.strip().upper()
            if not query_upper.startswith('SELECT'):
                return "Error: Only SELECT queries are allowed for safety."
            
            try:
                # Use LangChain's SQLDatabase to execute query
                result = self.db.run(query)
                return f"Query Results:\n{result}"
            except Exception as e:
                return f"Error executing query: {str(e)}"
        
        def list_tables() -> str:
            """List all available tables in the database."""
            try:
                tables = self.db.get_usable_table_names()
                return f"Available tables: {', '.join(tables)}"
            except Exception as e:
                return f"Error: {str(e)}"
        
        def get_table_schema(table_name: str) -> str:
            """Get the schema for a specific table."""
            try:
                schema = self.db.get_table_info_no_throw([table_name])
                return f"Schema for {table_name}:\n{schema}"
            except Exception as e:
                return f"Error: {str(e)}"
        
        tools = [
            Tool(
                name="sql_query",
                func=execute_sql_query,
                description="""Execute a SQL SELECT query on the database.
                Use this tool to query customer, product, or order data.
                Only SELECT statements are allowed for safety.
                Example: SELECT * FROM customers LIMIT 10"""
            ),
            Tool(
                name="list_tables",
                func=list_tables,
                description="List all available tables in the database."
            ),
            Tool(
                name="get_table_schema",
                func=get_table_schema,
                description="Get the schema (column names and types) for a specific table."
            ),
        ]
        
        return tools
    
    def query(self, user_query: str) -> str:
        """
        Process a natural language query and return results.
        
        Args:
            user_query: Natural language question about the database
            
        Returns:
            Formatted response with query results
        """
        # Create the agent prompt
        prompt = ChatPromptTemplate.from_messages([
            SystemMessage(content="""You are a helpful SQL database assistant.

You have access to a database with the following tables:
- customers: customer information (id, name, email, city, total_orders, total_spent)
- products: product catalog (id, name, category, price, stock)
- orders: order history (id, customer_id, product_id, quantity, order_date, total)

When a user asks a question:
1. First, use list_tables to see available tables
2. If needed, use get_table_schema to understand table structure
3. Write an appropriate SQL SELECT query
4. Execute the query using sql_query tool
5. Interpret and format the results in a user-friendly way

Always use SELECT queries only. Be clear and helpful in your responses."""),
            MessagesPlaceholder(variable_name="chat_history"),
            ("user", "{input}"),
            MessagesPlaceholder(variable_name="agent_scratchpad"),
        ])
        
        # Create the agent
        agent = create_openai_tools_agent(self.llm, self.tools, prompt)
        agent_executor = AgentExecutor(
            agent=agent,
            tools=self.tools,
            verbose=False,
            handle_parsing_errors=True,
            max_iterations=5
        )
        
        # Prepare chat history
        chat_history = []
        for msg in self.conversation_history[-4:]:
            if msg["role"] == "user":
                chat_history.append(HumanMessage(content=msg["content"]))
            elif msg["role"] == "assistant":
                chat_history.append(AIMessage(content=msg["content"]))
        
        # Execute agent
        try:
            result = agent_executor.invoke({
                "input": user_query,
                "chat_history": chat_history
            })
            response = result["output"]
        except Exception as e:
            response = f"I encountered an error: {str(e)}. Please try rephrasing your question."
        
        # Store in history
        self.conversation_history.append({"role": "user", "content": user_query})
        self.conversation_history.append({"role": "assistant", "content": response})
        
        return response
    
    def reset(self) -> None:
        """Clear conversation history."""
        self.conversation_history = []


def main():
    """Main demo function."""
    print("🤖 Day 3: SQL Database Agent")
    print("=" * 60)
    
    # Check API key
    if not os.getenv("OPENAI_API_KEY"):
        print("\n⚠️  Please set your OPENAI_API_KEY in .env file")
        return
    
    print("\n🚀 Initializing SQL agent...")
    agent = SQLAgent()
    
    print("\n" + "=" * 60)
    print("📝 Sample Database Queries")
    print("=" * 60)
    
    # Sample queries
    test_queries = [
        "What tables are available?",
        "Show me all customers",
        "What are the top 3 customers by total spent?",
        "How many orders were placed in February 2024?",
        "What products are in the Electronics category?",
    ]
    
    for query in test_queries:
        print(f"\n👤 You: {query}")
        response = agent.query(query)
        print(f"🤖 Agent: {response}")
        print("-" * 60)
    
    print("\n✅ Demo completed!")
    print("\n💡 Try running interactively:")
    print("   python sql_agent.py --interactive")


if __name__ == "__main__":
    import sys
    
    if "--interactive" in sys.argv:
        print("🤖 Day 3: SQL Database Agent - Interactive Mode")
        print("=" * 60)
        print("Type 'quit' to exit, 'reset' to clear history\n")
        
        agent = SQLAgent()
        
        while True:
            user_input = input("\nYou: ")
            
            if user_input.lower() == 'quit':
                print("\n👋 Goodbye!")
                break
            
            if user_input.lower() == 'reset':
                agent.reset()
                print("\n🔄 Conversation history cleared.\n")
                continue
            
            if not user_input.strip():
                continue
            
            response = agent.query(user_input)
            print(f"\nAgent: {response}\n")
    else:
        main()



