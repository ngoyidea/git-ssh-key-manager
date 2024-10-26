#!/bin/bash

# Colors for better readability
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check Operating System
check_os() {
    case "$(uname -s)" in
        Darwin*) 
            echo ""   
            echo -e "${BLUE}Running on macOS${NC}" ;;
        Linux*) 
            echo ""
            echo -e "${BLUE}Running on Linux${NC}" ;;
        CYGWIN*|MINGW*|MSYS*) 
            echo ""
            echo -e "${BLUE}Running on Windows (Git Bash)${NC}" ;;
        *)          
            echo -e "${RED}Unsupported operating system. Please use Linux, macOS, or Git Bash on Windows.${NC}"
            exit 1 ;;
    esac
}

# Function to display the menu
show_menu() {
    check_os
    echo -e "\n${BLUE}=== Git SSH Key Manager ===${NC}"
    echo "1. Generate new SSH key"
    echo "2. Show key adding instructions"
    echo "3. Configure Git user"
    echo "4. List existing SSH keys"
    echo "5. Test SSH connection"
    echo "6. Exit"
}

# Rest of the functions remain the same as before
generate_ssh_key() {
    echo -e "\n${BLUE}=== Generate SSH Key ===${NC}"
    echo "Select Git provider:"
    echo "1. GitHub"
    echo "2. GitLab"
    echo "3. Bitbucket"
    read -p "Enter choice (1-3): " provider

    case $provider in
        1) provider_name="github" ;;
        2) provider_name="gitlab" ;;
        3) provider_name="bitbucket" ;;
        *) echo -e "${RED}Invalid choice${NC}"; return 1 ;;
    esac

    read -p "Enter a unique identifier for this key (e.g., personal, work): " identifier
    read -p "Enter your email: " email

    key_name="${provider_name}_${identifier}"
    key_path="$HOME/.ssh/${key_name}"

    # Generate SSH key
    ssh-keygen -t ed25519 -C "$email" -f "$key_path"

    # Add to SSH config
    echo -e "\nHost ${provider_name}.com-${identifier}
    HostName ${provider_name}.com
    User git
    IdentityFile $key_path" >> "$HOME/.ssh/config"

    # Start ssh-agent and add key
    eval "$(ssh-agent -s)"
    ssh-add "$key_path"

    echo -e "${GREEN}SSH key generated successfully!${NC}"
    echo -e "Public key (copy this to your Git provider):\n"
    cat "${key_path}.pub"
}

# Function to test SSH connection
test_connection() {
    echo -e "\n${BLUE}=== Test SSH Connection ===${NC}"
    echo "Select Git provider:"
    echo "1. GitHub"
    echo "2. GitLab"
    echo "3. Bitbucket"
    read -p "Enter choice (1-3): " provider

    case $provider in
        1) ssh -T git@github.com ;;
        2) ssh -T git@gitlab.com ;;
        3) ssh -T git@bitbucket.org ;;
        *) echo -e "${RED}Invalid choice${NC}" ;;
    esac
}

# Function to configure Git user
configure_git() {
    echo -e "\n${BLUE}=== Configure Git User ===${NC}"
    read -p "Enter your name: " name
    read -p "Enter your email: " email

    git config --global user.name "$name"
    git config --global user.email "$email"

    echo -e "${GREEN}Git user configured successfully!${NC}"
    echo -e "\nCurrent Git configuration:"
    git config --global --list
}

# Function to list existing SSH keys
list_keys() {
    echo -e "\n${BLUE}=== Existing SSH Keys ===${NC}"
    for key in ~/.ssh/github_* ~/.ssh/gitlab_* ~/.ssh/bitbucket_*; do
        if [ -f "$key" ] && [[ $key != *".pub" ]]; then
            echo -e "\nKey: ${GREEN}$(basename "$key")${NC}"
            echo "Public key:"
            cat "$key.pub"
        fi
    done
}

# Function to show instructions for adding keys
show_instructions() {
    echo -e "\n${BLUE}=== Adding SSH Keys to Git Providers ===${NC}"
    
    echo -e "\n${GREEN}GitHub:${NC}"
    echo "1. Go to Settings > SSH and GPG keys"
    echo "2. Click 'New SSH key'"
    echo "3. Paste your public key and give it a title"
    
    echo -e "\n${GREEN}GitLab:${NC}"
    echo "1. Go to Preferences > SSH Keys"
    echo "2. Paste your public key"
    echo "3. Set an expiration date (optional)"
    
    echo -e "\n${GREEN}Bitbucket:${NC}"
    echo "1. Go to Personal Settings > SSH Keys"
    echo "2. Click 'Add key'"
    echo "3. Paste your public key and click 'Add key'"
}

# Main loop
while true; do
    show_menu
    read -p "Enter choice (1-6): " choice

    case $choice in
        1) generate_ssh_key ;;
        2) show_instructions ;;
        3) configure_git ;;
        4) list_keys ;;
        5) test_connection ;;
        6) echo -e "${GREEN}Goodbye!${NC}"; exit 0 ;;
        *) echo -e "${RED}Invalid choice${NC}" ;;
    esac
done