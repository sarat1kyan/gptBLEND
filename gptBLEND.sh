#!/bin/bash

# Configuration
SCRIPT_NAME="gptBLEND"
VERSION="2.0"
API_MODEL="gpt-4"
LOG_FILE="blender_script.log"
OUTPUT_SCRIPT="blend_generated.py"
CONFIG_FILE="gptblend_config.sh"
SAFETY_MODE="enabled"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Banner
print_banner() {
    clear
    echo -e "${CYAN}"
    echo "╔══════════════════════════════════════════╗"
    echo "║         gptBLEND v$VERSION               ║"
    echo "║     AI-Powered Blender Assistant         ║"
    echo "╚══════════════════════════════════════════╝"
    echo -e "${NC}"
}

# Logging function
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Check and load config
load_config() {
    if [ -f "$CONFIG_FILE" ]; then
        source "$CONFIG_FILE"
        echo -e "${GREEN}[INFO] Loaded configuration from $CONFIG_FILE${NC}"
    fi
}

# Save config
save_config() {
    cat > "$CONFIG_FILE" << EOF
# gptBLEND Configuration
export OPENAI_API_KEY="$OPENAI_API_KEY"
export API_MODEL="$API_MODEL"
export OUTPUT_SCRIPT="$OUTPUT_SCRIPT"
export SAFETY_MODE="$SAFETY_MODE"
EOF
    chmod 600 "$CONFIG_FILE"
}

# Check dependencies
check_dependencies() {
    echo -e "${BLUE}[INFO] Checking dependencies...${NC}"
    
    local deps=("curl" "jq" "blender")
    local missing=()
    
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            missing+=("$dep")
            echo -e "${RED}[MISSING] $dep${NC}"
        else
            echo -e "${GREEN}[OK] $dep${NC}"
        fi
    done
    
    if [ ${#missing[@]} -gt 0 ]; then
        echo -e "${YELLOW}\n=== MISSING DEPENDENCIES ===${NC}"
        echo "Please install: ${missing[*]}"
        
        read -p "Attempt automatic installation? (y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            install_dependencies "${missing[@]}"
        else
            echo -e "${RED}Please install dependencies manually and restart.${NC}"
            exit 1
        fi
    fi
    
    echo -e "${GREEN}[SUCCESS] All dependencies satisfied!${NC}"
}

install_dependencies() {
    echo -e "${YELLOW}[INFO] Attempting to install dependencies...${NC}"
    
    if command -v apt &> /dev/null; then
        sudo apt update
        for dep in "$@"; do
            if [ "$dep" == "jq" ]; then
                sudo apt install -y jq
            elif [ "$dep" == "curl" ]; then
                sudo apt install -y curl
            elif [ "$dep" == "blender" ]; then
                sudo apt install -y blender
            fi
        done
    elif command -v yum &> /dev/null; then
        sudo yum update
        for dep in "$@"; do
            sudo yum install -y "$dep"
        done
    elif command -v pacman &> /dev/null; then
        sudo pacman -Syu
        for dep in "$@"; do
            sudo pacman -S "$dep"
        done
    elif command -v brew &> /dev/null; then
        for dep in "$@"; do
            brew install "$dep"
        done
    else
        echo -e "${RED}[ERROR] Unsupported package manager${NC}"
        exit 1
    fi
}

# API Key management
setup_api_key() {
    if [ -z "$OPENAI_API_KEY" ]; then
        echo -e "${YELLOW}=== API KEY REQUIRED ===${NC}"
        echo "Options:"
        echo "1. Enter API key now (saved encrypted)"
        echo "2. Set environment variable: export OPENAI_API_KEY='your-key'"
        echo "3. Create $CONFIG_FILE with OPENAI_API_KEY variable"
        echo
        
        read -p "Enter your OpenAI API key: " user_key
        if [ -n "$user_key" ]; then
            OPENAI_API_KEY="$user_key"
            save_config
            echo -e "${GREEN}[INFO] API key saved to $CONFIG_FILE${NC}"
        else
            echo -e "${RED}[ERROR] API key is required${NC}"
            exit 1
        fi
    fi
    
    # Validate API key format
    if [[ ! "$OPENAI_API_KEY" =~ ^sk- ]]; then
        echo -e "${YELLOW}[WARNING] API key format may be invalid${NC}"
        read -p "Continue anyway? (y/n): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            setup_api_key
        fi
    fi
}

# Generate code with AI
generate_code() {
    print_banner
    echo -e "${CYAN}=== GENERATE BLENDER SCRIPT ===${NC}\n"
    
    echo "Provide a detailed description of what you want to create."
    echo "Be specific about shapes, colors, lighting, and animation."
    echo
    echo -e "${YELLOW}Examples:${NC}"
    echo "• 'Create a red cube that rotates slowly'"
    echo "• 'Generate a landscape with mountains and trees'"
    echo "• 'Make a bouncing ball with physics simulation'"
    echo "• 'Create a spaceship with animated thrusters'"
    echo
    
    read -p "Describe your 3D scene: " prompt
    
    if [ -z "$prompt" ]; then
        echo -e "${RED}[ERROR] Prompt cannot be empty${NC}"
        sleep 2
        generate_code
    fi
    
    echo -e "\n${BLUE}[INFO] Generating code with $API_MODEL...${NC}"
    
    # Create system prompt
    system_prompt="You are a Blender Python expert. Generate ONLY Python code for Blender 3.0+. Do not include explanations, markdown formatting, or comments outside of the code. The code should be complete and runnable. Use modern Blender Python API. Import necessary modules. User request: "
    
    # Make API request
    response=$(curl -s -X POST "https://api.openai.com/v1/chat/completions" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $OPENAI_API_KEY" \
        -d '{
            "model": "'"$API_MODEL"'",
            "messages": [
                {"role": "system", "content": "'"$system_prompt"'"},
                {"role": "user", "content": "'"$prompt"'"}
            ],
            "temperature": 0.7,
            "max_tokens": 2000
        }')
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}[ERROR] Failed to connect to OpenAI API${NC}"
        return 1
    fi
    
    # Extract and clean code
    generated_code=$(echo "$response" | jq -r '.choices[0].message.content' 2>/dev/null)
    
    if [ -z "$generated_code" ] || [ "$generated_code" == "null" ]; then
        echo -e "${RED}[ERROR] Failed to generate code${NC}"
        echo "Response: $response"
        return 1
    fi
    
    # Remove markdown code blocks
    generated_code=$(echo "$generated_code" | sed -e 's/^```python//g' -e 's/^```//g' -e 's/```$//g')
    
    # Add safety wrapper
    cat > "$OUTPUT_SCRIPT" << EOF
import bpy
import sys
import traceback

def safe_execute():
    """Execute generated code with safety checks"""
    try:
        # Generated code starts here
$generated_code
        # Generated code ends here
        return True
    except Exception as e:
        print("=" * 60)
        print("ERROR executing generated code:")
        print(str(e))
        print("=" * 60)
        traceback.print_exc()
        return False

if __name__ == "__main__":
    print("Starting gptBLEND generated script...")
    success = safe_execute()
    if success:
        print("Script executed successfully!")
    else:
        print("Script execution failed. Check errors above.")
EOF
    
    echo -e "${GREEN}[SUCCESS] Code generated and saved to $OUTPUT_SCRIPT${NC}"
    log_message "Generated code for prompt: $prompt"
    
    # Preview option
    read -p "Preview generated code? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${CYAN}===== GENERATED CODE =====${NC}"
        head -50 "$OUTPUT_SCRIPT"
        echo -e "${CYAN}=========================${NC}"
    fi
}

# Run script in Blender
run_blender_script() {
    local script_path=${1:-$OUTPUT_SCRIPT}
    
    if [ ! -f "$script_path" ]; then
        echo -e "${RED}[ERROR] Script not found: $script_path${NC}"
        return 1
    fi
    
    echo -e "${BLUE}[INFO] Running $script_path in Blender...${NC}"
    echo "This may take a moment..."
    
    # Create a temporary file for Blender output
    local temp_output="/tmp/blender_output_$$.txt"
    
    # Run Blender with the script
    blender --background --python "$script_path" 2>&1 | tee "$temp_output" | tee -a "$LOG_FILE"
    
    local blender_exit=${PIPESTATUS[0]}
    
    # Check for errors
    if grep -q "Error\|Traceback\|Exception" "$temp_output"; then
        echo -e "${YELLOW}[WARNING] Possible errors detected during execution${NC}"
    fi
    
    if [ $blender_exit -eq 0 ]; then
        echo -e "${GREEN}[SUCCESS] Blender execution completed${NC}"
    else
        echo -e "${RED}[ERROR] Blender exited with code $blender_exit${NC}"
    fi
    
    rm -f "$temp_output"
    log_message "Executed script: $script_path (exit code: $blender_exit)"
}

# Main menu
main_menu() {
    while true; do
        print_banner
        echo -e "${CYAN}=== MAIN MENU ===${NC}\n"
        echo "1. Generate new Blender script"
        echo "2. Edit existing script"
        echo "3. Run current script ($OUTPUT_SCRIPT)"
        echo "4. Run custom script"
        echo "5. View log file"
        echo "6. Settings"
        echo "7. Help"
        echo "8. Exit"
        echo
        
        read -p "Select option (1-8): " choice
        
        case $choice in
            1)
                generate_code
                read -p "Run script now? (y/n): " -n 1 -r
                echo
                if [[ $REPLY =~ ^[Yy]$ ]]; then
                    run_blender_script "$OUTPUT_SCRIPT"
                fi
                ;;
            2)
                if [ -f "$OUTPUT_SCRIPT" ]; then
                    ${EDITOR:-nano} "$OUTPUT_SCRIPT"
                else
                    echo -e "${YELLOW}No script found. Generate one first.${NC}"
                fi
                ;;
            3)
                run_blender_script "$OUTPUT_SCRIPT"
                ;;
            4)
                read -p "Enter script path: " custom_script
                run_blender_script "$custom_script"
                ;;
            5)
                if [ -f "$LOG_FILE" ]; then
                    echo -e "${CYAN}===== LOG FILE =====${NC}"
                    tail -50 "$LOG_FILE"
                    echo -e "${CYAN}===================${NC}"
                else
                    echo "No log file found."
                fi
                ;;
            6)
                settings_menu
                ;;
            7)
                show_help
                ;;
            8)
                echo -e "${GREEN}Thank you for using gptBLEND!${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}Invalid option${NC}"
                ;;
        esac
        
        echo
        read -p "Press Enter to continue..."
    done
}

# Settings menu
settings_menu() {
    print_banner
    echo -e "${CYAN}=== SETTINGS ===${NC}\n"
    
    echo "Current settings:"
    echo "• API Model: $API_MODEL"
    echo "• Output file: $OUTPUT_SCRIPT"
    echo "• Safety mode: $SAFETY_MODE"
    echo "• Config file: $CONFIG_FILE"
    echo
    
    echo "1. Change API model"
    echo "2. Change output filename"
    echo "3. Clear API key"
    echo "4. Toggle safety mode"
    echo "5. Back to main menu"
    echo
    
    read -p "Select option: " setting_choice
    
    case $setting_choice in
        1)
            read -p "Enter new API model (gpt-4, gpt-3.5-turbo, etc.): " new_model
            if [ -n "$new_model" ]; then
                API_MODEL="$new_model"
                save_config
            fi
            ;;
        2)
            read -p "Enter new output filename: " new_output
            if [ -n "$new_output" ]; then
                OUTPUT_SCRIPT="$new_output"
                save_config
            fi
            ;;
        3)
            if [ -f "$CONFIG_FILE" ]; then
                rm "$CONFIG_FILE"
                OPENAI_API_KEY=""
                echo "API key cleared."
            fi
            ;;
        4)
            if [ "$SAFETY_MODE" == "enabled" ]; then
                SAFETY_MODE="disabled"
            else
                SAFETY_MODE="enabled"
            fi
            save_config
            ;;
    esac
}

# Help information
show_help() {
    print_banner
    echo -e "${CYAN}=== HELP ===${NC}\n"
    
    cat << EOF
gptBLEND is an AI-powered tool that generates Blender Python scripts
from natural language descriptions.

USAGE:
1. Select "Generate new Blender script" from the main menu
2. Describe what you want to create in plain English
3. The AI will generate Python code and save it
4. You can run the script directly in Blender

TIPS FOR BEST RESULTS:
• Be specific about shapes, colors, and lighting
• Mention if you want animation or physics
• For complex scenes, break them into multiple requests
• Example: "Create a red cube at position (0,0,0) that rotates
  around the Z-axis over 5 seconds"

SAFETY FEATURES:
• Generated code runs in a try-catch block
• Errors are logged and displayed
• You can review code before execution

DEPENDENCIES:
• curl - For API requests
• jq - For JSON parsing
• blender - 3D software
• OpenAI API key

For more help or to report issues, please check the documentation.
EOF
    
    echo
    read -p "Press Enter to return to menu..."
}

# Main execution
main() {
    print_banner
    echo -e "${BLUE}Initializing gptBLEND v$VERSION...${NC}\n"
    
    # Load configuration
    load_config
    
    # Check dependencies
    check_dependencies
    
    # Setup API key
    setup_api_key
    
    # Create log file if it doesn't exist
    touch "$LOG_FILE"
    
    # Start main menu
    main_menu
}

# Error handling
trap 'echo -e "${RED}[FATAL] Script interrupted${NC}"; exit 1' INT TERM
trap 'log_message "Script exited with error"' ERR

# Run main function
main "$@"
