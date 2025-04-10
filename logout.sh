#!/bin/bash

# Configuration
LOGOUT_URL="https://login.iitmandi.ac.in:1003/logout?"

# Optional: set a User-Agent to mimic a browser
USER_AGENT="Mozilla/5.0 (X11; Linux x86_64; rv:109.0) Gecko/20100101 Firefox/115.0"

# Send logout request
curl -ksL -A "$USER_AGENT" "$LOGOUT_URL" -o /dev/null

# Check if logout worked
if [ $? -eq 0 ]; then
    echo "!!!Logged out successfully!!!"
else
    echo "!!!Logout failed!!!"
fi


