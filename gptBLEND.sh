#!/bin/bash

echo "ok, let's blend..."

banner1() {
  local text="$@"
  local length=$(( ${#text} + 2 ))
  local line=$(printf '%*s' "$length" '' | tr ' ' '-')
  echo "+$line+"
  printf "| %s |\n" "$(date)"
  echo "+$line+"
  printf "|$bold%s$reset|\n" "$text"
  echo "+$line+"
}


#clolors
white='\e[1;37m'
green='\e[0;32m'
blue='\e[1;34m'
red='\e[1;31m'
yellow='\e[1;33m' 
echo ""
echo ""
banner() {
	echo -e $'\e[1;33m\e[0m\e[1;37m       ▄████  ██▓███  ▄▄▄█████▓ ▄▄▄▄    ██▓    ▓█████  ███▄    █ ▓█████▄    \e[0m'
	echo -e $'\e[1;33m\e[0m\e[1;37m      ██▒ ▀█▒▓██░  ██▒▓  ██▒ ▓▒▓█████▄ ▓██▒    ▓█   ▀  ██ ▀█   █ ▒██▀ ██▌   \e[0m'
	echo -e $'\e[1;33m\e[0m\e[1;37m     ▒██░▄▄▄░▓██░ ██▓▒▒ ▓██░ ▒░▒██▒ ▄██▒██░    ▒███   ▓██  ▀█ ██▒░██   █▌   \e[0m'
	echo -e $'\e[1;33m\e[0m\e[1;37m     ░▓█  ██▓▒██▄█▓▒ ▒░ ▓██▓ ░ ▒██░█▀  ▒██░    ▒▓█  ▄ ▓██▒  ▐▌██▒░▓█▄   ▌   \e[0m'
	echo -e $'\e[1;33m\e[0m\e[1;37m     ░▒▓███▀▒▒██▒ ░  ░  ▒██▒ ░ ░▓█  ▀█▓░██████▒░▒████▒▒██░   ▓██░░▒████▓    \e[0m'
	echo -e $'\e[1;33m\e[0m\e[1;37m      ░▒   ▒ ▒▓▒░ ░  ░  ▒ ░░   ░▒▓███▀▒░ ▒░▓  ░░░ ▒░ ░░ ▒░   ▒ ▒  ▒▒▓  ▒    \e[0m'
	echo -e $'\e[1;33m\e[0m\e[1;37m       ░   ░ ░▒ ░         ░    ▒░▒   ░ ░ ░ ▒  ░ ░ ░  ░░ ░░   ░ ▒░ ░ ▒  ▒    \e[0m'
	echo -e $'\e[1;33m\e[0m\e[1;37m     ░ ░   ░ ░░         ░       ░    ░   ░ ░      ░      ░   ░ ░  ░ ░  ░    \e[0m'
	echo -e $'\e[1;33m\e[0m\e[1;37m           ░                    ░          ░  ░   ░  ░         ░    ░       \e[0m'
	echo -e $'\e[1;33m\e[0m\e[1;37m                                     ░                            ░         \e[0m'
	
	
	echo""    
	echo -e $'\e[1;33m\e[0m\e[1;33m    ██████████\e[0m'"\e[96m██████████"'\e[1;33m\e[0m\e[1;31m██████████\e[0m' '\e[1;32m\e[0m\e[1;32m blender with GPT \e[0m''\e[1;37m\e[0m\e[1;37m \e[0m'                                       
	echo ""
	echo -e $'\e[1;33m\e[0m\e[1;33m  [ \e[0m\e[1;32m Follow on Github :- https://github.com/54R4T1KY4N \e[0m \e[1;32m\e[0m\e[1;33m] \e[0m'
	echo ""
	echo -e $'\e[1;37m\e[0m\e[1;37m    +-+-+-+-+-+-+-+ >>\e[0m'
	echo -e "\e[93m    gptBLEND |1|.|3| stable"      
	echo -e $'\e[1;37m\e[0m\e[1;37m    +-+-+-+-+-+-+-+ >>\e[0m' 
	echo ""                                                
}
banner 

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
    banner1 "Error: The following dependencies are missing: ${missing_dependencies[@]}"
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
            banner1 "Error: Could not detect supported package manager. Please install the missing dependencies manually."
            exit 1
        fi
    else
        banner1 "Error: The missing dependencies must be installed to run this script. Please install them manually."
        exit 1
    fi
fi

# How to use this damn script
banner1 "This script generates Python code for Blender using the ChatGPT API."
banner1 "To use this script, enter a prompt that describes the Python code you want to generate."
banner1 "For best results, use natural language and be as specific as possible."
banner1 'For example: "Generate Python code to create a 3D model of a car in Blender"' | tee -a "$LOG_FILE"

# Prompt the user for input
read -p "Enter a prompt: " prompt

# Validate the input prompt
if [ -z "$prompt" ]; then
    banner1 "Error: Prompt cannot be empty. Please try again." | tee -a "$LOG_FILE"
    exit 1
fi

# Send request to ChatGPT API
response=$(curl -s -H "Authorization: Bearer YOUR_API_KEY" -d "{\"prompt\": \"$prompt\"}" https://api.openai.com/v1/engines/davinci-codex/completions | jq -r ".choices[0].text")

# Extract the generated Python code from the API response
code="$response"

# Validate the generated code
if [ -z "$code" ]; then
    banner1 "Error: Generated code is empty. Please try a different prompt." | tee -a "$LOG_FILE"
    exit 1
fi

# Save the Python code to a file
echo "$code" > blend.py

# Run the blender command
blender -b -P blend.py

banner1 "Blending complete."
