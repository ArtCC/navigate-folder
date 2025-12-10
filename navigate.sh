#!/bin/zsh

# Interactive folder navigation script for macOS - Version 1.0.0
# Author: Arturo Carretero Calvo
# Date: July 25, 2025

clear

# Function to display current directory
show_directory() {
    echo ""
    echo "📁 Current directory: $(pwd)"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
}

# Function to display numbered folders
show_folders() {
    # Completely clear the global array
    unset folders
    declare -gA folders  # Global associative array
    
    # Get folders using ls
    local counter=1
    
    # Check if there are folders
    if ! ls -d */ &>/dev/null; then
        echo "❌ No folders in this directory."
        return 1
    fi
    
    echo "📂 Available folders:"
    echo ""
    
    # Fill the associative array and display folders
    for dir in */; do
        if [[ -d "$dir" ]]; then
            folder_name="${dir%/}"
            folders[$counter]="$folder_name"
            echo "  $counter) $folder_name"
            ((counter++))
        fi
    done
    
    return 0
}

# Function to display menu
show_menu() {
    echo ""
    echo "🔧 Options:"
    echo "  0) 🔙 Go up one level"
    echo "  q) 🚪 Exit"
    echo ""
}

# Function to process user choice
process_option() {
    local option="$1"
    # Calculate number of folders
    local num_folders=${#folders[@]}
    
    # Exit
    if [[ "$option" == "q" || "$option" == "Q" || "$option" == "quit" ]]; then
        echo ""
        echo "👋 Goodbye!"
        return 99  # Special exit code
    fi
    
    # Go up one level
    if [[ "$option" == "0" ]]; then
        local current_dir=$(pwd)
        local parent_dir=$(dirname "$current_dir")
        
        # Check if we're not at root
        if [[ "$parent_dir" == "/" ]]; then
            echo ""
            echo "⚠️  Already at system root. Cannot go up further."
            return 1
        fi
        
        # Try to change to parent directory
        if cd "$parent_dir" 2>/dev/null; then
            echo ""
            echo "✅ Moved up to parent directory"
            return 0
        else
            echo ""
            echo "❌ Error accessing parent directory"
            return 1
        fi
    fi
    
    # Check if it's a valid number
    if [[ "$option" =~ ^[1-9][0-9]*$ ]]; then
        if [[ -n "${folders[$option]}" ]]; then
            # Use option directly as associative array key
            local chosen_folder="${folders[$option]}"
            
            # Try to change to directory
            if cd "$chosen_folder" 2>/dev/null; then
                echo ""
                echo "✅ Entered: $chosen_folder"
                return 0
            else
                echo ""
                echo "❌ Error accessing folder: $chosen_folder"
                return 1
            fi
        else
            echo ""
            echo "❌ Number out of range. Choose between 1 and $num_folders."
            return 1
        fi
    else
        echo ""
        echo "❌ Invalid option. Use numbers, 0 to go up, or 'q' to exit."
        return 1
    fi
}

# Main function
main() {
    # Initialize global associative array
    declare -gA folders
    
    echo "🗂️  Folder Navigator v1.0.0"
    echo "=========================="
    
    # Change to specified directory if provided
    if [[ -n "$1" && -d "$1" ]]; then
        if cd "$1" 2>/dev/null; then
            echo "📍 Starting in: $1"
        else
            echo "❌ Could not access: $1"
            echo "📍 Using current directory: $(pwd)"
        fi
    else
        echo "📍 Current directory: $(pwd)"
    fi
    
    # Main loop
    while true; do
        show_directory
        
        if show_folders; then
            show_menu
            printf "👉 Choose an option: "
            read -r option
            
            # Process the option
            process_option "$option"
            result=$?
            
            # Check if we should exit
            if [[ $result -eq 99 ]]; then
                break
            fi
        else
            # No folders, show basic options only
            echo ""
            echo "🔧 Options:"
            echo "  0) 🔙 Go up one level"
            echo "  q) 🚪 Exit"
            echo ""
            printf "👉 Choose an option: "
            read -r option
            
            process_option "$option"
            result=$?
            
            if [[ $result -eq 99 ]]; then
                break
            fi
        fi
        
        # Brief pause
        sleep 0.3
    done
}

# Execute the script
main "$@"