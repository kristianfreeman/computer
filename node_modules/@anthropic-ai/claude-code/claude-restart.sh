#!/usr/bin/env bash

# Claude CLI Restart Wrapper
#
# This script acts as a wrapper around the main Claude CLI (cli.mjs) that:
# 1. Launches the CLI with the same arguments passed to this script
# 2. Monitors the CLI process for a special exit code (42)
# 3. If the special exit code is detected, it restarts the CLI with the same arguments

# Get the real path of this script by using Node.js to follow all symlinks
SCRIPT_PATH="${BASH_SOURCE[0]}"
REAL_SCRIPT_PATH=$(/usr/bin/env node -e "console.log(require('fs').realpathSync('$SCRIPT_PATH'))")

# Get the directory of the real script
SCRIPT_DIR="$( dirname "$REAL_SCRIPT_PATH" )"

# Path to cli.js - look for it in the same directory as this script
CLI_PATH="$SCRIPT_DIR/cli.js"

# DO NOT change the current working directory
# The CLI needs to maintain the original working directory it was launched from

# Define the signals we'll use to indicate a restart is needed
# Using exit code 42 as our special signal for command-based restart
RESTART_EXIT_CODE=42
# Using exit code 43 as our special signal for tool-based restart
TOOL_RESTART_EXIT_CODE=43

# Check if cli.mjs exists
if [ ! -f "$CLI_PATH" ]; then
  echo "Error: Could not find $CLI_PATH"
  exit 1
fi

# Function to start the CLI
start_cli() {
  local is_restart="${2:-false}"
  local args=("$@")
  
  # Remove the is_restart parameter from args
  if [ "$is_restart" = "true" ]; then
    # If second parameter is "true", remove first two parameters
    args=("${args[@]:2}")
  else
    # If second parameter is not "true", just remove first parameter
    args=("${args[@]:1}")
  fi
      
  # If this is a restart triggered by exit code 42 and no args are provided, add 'resume 0' to restore the last conversation
  if [ "$is_restart" = "true" ] && [ ${#args[@]} -eq 0 ]; then
    # Always add resume 0 when restarting due to exit code 42 and no other arguments exist
    args=("resume" "0")
  fi

  # Run cli.mjs with the provided arguments
  "$CLI_PATH" "${args[@]}"
  
  # Capture the exit code
  EXIT_CODE=$?
  
  # Check if we need to restart
  if [ $EXIT_CODE -eq $RESTART_EXIT_CODE ]; then
    
    # When restarting due to exit code 42, filter args to keep only flags (starting with - or --)
    # and add "resume 0" at the end
    local restart_args=()
    for arg in "${args[@]}"; do
      if [[ "$arg" == -* ]]; then
        restart_args+=("$arg")
      fi
    done
    
    # Add resume 0 at the end
    restart_args+=("resume" "0")
    
    start_cli "true" "${restart_args[@]}"
  elif [ $EXIT_CODE -eq $TOOL_RESTART_EXIT_CODE ]; then
    
    # When restarting due to exit code 43 (tool restart), filter args to keep only flags (starting with - or --)
    # and use "Keep going.." prompt instead
    local restart_args=()
    for arg in "${args[@]}"; do
      if [[ "$arg" == -* ]]; then
        restart_args+=("$arg")
      fi
    done
    
    # Start with "Keep going.." prompt
    restart_args+=("Keep going..")
    
    start_cli "true" "${restart_args[@]}"
  else
    # Any other exit code - exit with the same code
    exit $EXIT_CODE
  fi
}

# Start the CLI with all arguments passed to this script
start_cli "false" "$@"