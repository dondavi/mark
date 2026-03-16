#!/bin/bash
# Initialization script for development environment using AWS Bedrock
# 
# USAGE:
#   source ./initdev.sh
#   OR
#   . ./initdev.sh
#
# Note: This script must be sourced (not executed) to set variables in the parent shell

# Check if script is being sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "ERROR: This script must be sourced, not executed."
    echo "Usage: source ./initdev.sh"
    echo "   or: . ./initdev.sh"
    exit 1
fi

# Check if .env file exists
if [[ ! -f .env ]]; then
    echo "WARNING: .env file not found. Creating a template..."
    cat > .env << 'EOF'
# AWS Bedrock Configuration
ANTHROPIC_MODEL=us.anthropic.claude-4-5-opus-20250929-v1:0
ANTHROPIC_SMALL_FAST_MODEL=us.anthropic.claude-3-5-haiku-20241022-v1:0
AWS_BEARER_TOKEN_BEDROCK=your-token-here
AWS_REGION=your-region-here
EOF
    echo "Please edit .env file with your actual values and source this script again."
    return 1
fi

# Source the .env file to load variables
source .env

# Export environment variables
export CLAUDE_CODE_USE_BEDROCK=1
export ANTHROPIC_MODEL="$ANTHROPIC_MODEL"
export ANTHROPIC_SMALL_FAST_MODEL="$ANTHROPIC_SMALL_FAST_MODEL"
export AWS_BEARER_TOKEN_BEDROCK="$AWS_BEARER_TOKEN_BEDROCK"
export AWS_REGION="$AWS_REGION"

# Display confirmation
echo "✓ Environment variables set successfully:"
echo "  CLAUDE_CODE_USE_BEDROCK=$CLAUDE_CODE_USE_BEDROCK"
echo "  ANTHROPIC_MODEL=$ANTHROPIC_MODEL"
echo "  ANTHROPIC_SMALL_FAST_MODEL=$ANTHROPIC_SMALL_FAST_MODEL"
echo "  AWS_BEARER_TOKEN_BEDROCK=${AWS_BEARER_TOKEN_BEDROCK:0:20}..." # Only show first 20 chars
echo "  AWS_REGION=$AWS_REGION"
echo ""
echo "Environment is ready for development!"

