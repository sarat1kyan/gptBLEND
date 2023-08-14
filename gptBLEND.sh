#!/bin/bash

echo "ok, let's blend..."

# Set log file path
LOG_FILE="blender_script.log"

# Check for dependencies
dependencies="curl jq blender python python3"
missing_dependencies=()

for dependency in $dependencies; do
    if ! command -v "$dependency" >$LOG_FILE 2>&1 ; then
        missing_dependencies+=("$dependency")
    fi
done

if [ ${#missing_dependencies[@]} -gt 0 ]; then
    echo "Error: The following dependencies are missing: ${missing_dependencies[@]}"
    read -p "Would you like to install them now? (y/n) " install_deps

    if [[ "$install_deps" == "y" ]]; then
        # Detect package manager
        if command -v apt &> $LOG_FILE; then
            sudo apt install "${missing_dependencies[@]}"
            pip install openai torch transformers
        elif command -v yum &> $LOG_FILE; then
            sudo yum install "${missing_dependencies[@]}"
            pip install openai torch transformers
        elif command -v pacman &> $LOG_FILE; then
            sudo pacman -S "${missing_dependencies[@]}"
            pip install openai torch transformers
        elif command -v dnf &> $LOG_FILE; then
            sudo dnf install "${missing_dependencies[@]}"
            pip install openai torch transformers
        elif command -v zypper &> $LOG_FILE; then
            sudo zypper install "${missing_dependencies[@]}"
            pip install openai torch transformers
        elif command -v apk &> $LOG_FILE; then
            sudo apk add "${missing_dependencies[@]}"
            pip install openai torch transformers
        else
            echo "Error: Could not detect supported package manager. Please install the missing dependencies manually."
            exit 1
        fi
    else
        echo "Error: The missing dependencies must be installed to run this script. Please install them manually."
        exit 1
    fi
fi

# How to use this damn script
echo "This script generates Python code for Blender using the ChatGPT API."
echo "To use this script, enter a prompt that describes the Python code you want to generate."
echo "For best results, use natural language and be as specific as possible."
echo 'For example: "Generate Python code to create a 3D model of a car in Blender"' | tee -a "$LOG_FILE"

# Prompt the user for input
read -p "Enter a prompt: " prompt

# Validate the input prompt
if [ -z "$prompt" ]; then
    echo "Error: Prompt cannot be empty. Please try again." | tee -a "$LOG_FILE"
    exit 1
fi

# Send request to ChatGPT API
response=$(curl -s -H "Authorization: Bearer YOUR_API_KEY" -d "{\"prompt\": \"$prompt\"}" https://api.openai.com/v1/engines/davinci-codex/completions | jq -r ".choices[0].text")

# Extract the generated Python code from the API response
code="$response"

# Validate the generated code
if [ -z "$code" ]; then
    echo "Error: Generated code is empty. Please try a different prompt." | tee -a "$LOG_FILE"
    exit 1
fi

# Save the Python code to a file
echo "$code" > blend.py

# Run the blender command
blender -b -P blend.py

echo "Blending complete."
