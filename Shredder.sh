#!/bin/bash

# Check if running as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root, young apprentice." >&2
    exit 1
fi

# Determine the current user's username and home directory
if [ $SUDO_USER ]; then
    user="$SUDO_USER"
else
    user="$(whoami)"
fi
home_dir=$(getent passwd "$user" | cut -d: -f6)

echo "Initiating protocol: Silence of the Logs, Master Shredder."

# Attempt to shred the user's zsh history file and verify deletion
zsh_history="$home_dir/.zsh_history"
if [ -f "$zsh_history" ]; then
    echo "Engaging shredder for $zsh_history..."
    shred -u "$zsh_history"
    echo "Validation procedure: Attempting to display remnants of $zsh_history:"
    cat "$zsh_history" || echo "Confirmation: $zsh_history has been eradicated, Master."
else
    echo "Alert: $zsh_history does not exist in the archives."
fi

echo "Proceeding to cleanse remaining historical imprints, Master Shredder."
# Securely shred all users' bash history files in /home and verify
find /home -type f -name '.bash_history' -exec bash -c 'shred -u "$1" && echo "$1 has been obliterated from existence." || echo "Error: Failed to shred $1."' -- {} \;

# Securely shred the current user's bash history and verify
bash_history="$home_dir/.bash_history"
if [ -f "$bash_history" ]; then
    shred -u "$bash_history"
    echo "Validation procedure: Attempting to display remnants of $bash_history:"
    cat "$bash_history" || echo "Confirmation: $bash_history has been eradicated, Master."
fi

echo "All traces have been eliminated, Master Shredder. We have left no trace."
