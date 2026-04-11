#!/bin/bash

# 100 Days of AI Agents - Environment Setup Script

# Get the directory of this script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# Get the project root (parent of setup directory)
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"

# Change to project root
cd "$PROJECT_ROOT"

echo "🚀 Setting up 100 Days of AI Agents environment..."

# Check Python version
python_version=$(python3 --version 2>&1 | awk '{print $2}')
echo "✅ Python version: $python_version"

major=$(echo $python_version | cut -d. -f1)
minor=$(echo $python_version | cut -d. -f2)

if [ "$major" -lt 3 ] || ([ "$major" -eq 3 ] && [ "$minor" -lt 9 ]); then
    echo "⚠️  Warning: Python 3.9+ required. Current version: $python_version"
    echo "Please upgrade to Python 3.9 or higher"
    exit 1
else
    echo "✅ Python version is compatible"
fi

# Create virtual environment
echo "📦 Creating virtual environment..."
python3 -m venv venv

# Activate virtual environment
echo "🔄 Activating virtual environment..."
source venv/bin/activate

# Upgrade pip
echo "⬆️  Upgrading pip..."
pip install --upgrade pip

# Install requirements
echo "📚 Installing dependencies..."
pip install -r "$SCRIPT_DIR/requirements.txt"

# Create .env file if it doesn't exist
if [ ! -f "$PROJECT_ROOT/.env" ]; then
    echo "📝 Creating .env file..."
    cat > "$PROJECT_ROOT/.env" << EOF
# OpenAI API Key
OPENAI_API_KEY=your_openai_api_key_here

# Anthropic API Key
ANTHROPIC_API_KEY=your_anthropic_api_key_here

# Google Gemini API Key
GOOGLE_API_KEY=your_google_api_key_here

# Pinecone (Optional)
PINECONE_API_KEY=your_pinecone_api_key_here
PINECONE_ENVIRONMENT=your_pinecone_environment_here

# LangChain Settings
LANGCHAIN_API_KEY=your_langchain_api_key_here
LANGCHAIN_TRACING_V2=true
LANGCHAIN_ENDPOINT=https://api.smith.langchain.com
LANGCHAIN_PROJECT=100-days-of-ai-agents

# Model Settings (Optional)
DEFAULT_MODEL=gpt-4
DEFAULT_EMBEDDING_MODEL=text-embedding-3-small
EOF
    echo "✅ Created .env file. Please add your API keys!"
else
    echo "✅ .env file already exists"
fi

# Create utils directory if it doesn't exist
if [ ! -d "$PROJECT_ROOT/utils" ]; then
    echo "✅ Utils directory already exists"
fi

echo ""
echo "🎉 Setup complete!"
echo ""
echo "📝 Next steps:"
echo "1. Activate virtual environment: cd \"$PROJECT_ROOT\" && source venv/bin/activate"
echo "2. Add your API keys to .env file"
echo "3. Start with Day 1: cd day01_intro_to_agents"
echo ""
echo "Happy coding! 🚀"
