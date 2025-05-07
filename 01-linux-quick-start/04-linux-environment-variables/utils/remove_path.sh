#!/bin/bash

# Usage: ./remove_path.sh /path/to/remove

REMOVE_PATH="$1"

if [ -z "$REMOVE_PATH" ]; then
  echo "Usage: $0 /path/to/remove"
  exit 1
fi

# Remove the path from $PATH
NEW_PATH=$(echo "$PATH" | tr ':' '\n' | grep -v -F "$REMOVE_PATH" | paste -sd ':' -)

export PATH="$NEW_PATH"

echo "Removed '$REMOVE_PATH' from PATH."
echo "New PATH is: $PATH"
