#!/bin/bash

# ------------------ Configuration ------------------
read -p "Enter your IIT Mandi LDAP Username: " USERNAME
read -s -p "Enter your LDAP Password: " PASSWORD

#USERNAME="username" # Replace with your LDAP username
#PASSWORD="password"  # Replace with your LDAP password 
LOGIN_URL="https://login.iitmandi.ac.in:1003/"
PORTAL_URL="${LOGIN_URL}portal?"
USER_AGENT="Mozilla/5.0 (X11; Linux x86_64; rv:115.0) Gecko/20100101 Firefox/115.0"
# ---------------------------------------------------

# Temporary files
COOKIE_JAR=$(mktemp)
HTML_RESPONSE=$(mktemp)
POST_RESPONSE=$(mktemp)

# Step 1: Fetch login page
wget --quiet --no-check-certificate \
    --header="User-Agent: $USER_AGENT" \
    --save-cookies "$COOKIE_JAR" \
    --keep-session-cookies \
    "$PORTAL_URL" -O "$HTML_RESPONSE"

if [ ! -s "$HTML_RESPONSE" ]; then
    echo "!!!Failed to fetch the login page!!!"
    exit 1
fi

# Step 2: Extract the magic number from the login page (hidden field)
MAGIC_NUMBER=$(grep -oP 'name="magic" value="\K[^"]+' "$HTML_RESPONSE")
# Step 2: Extract hidden inputs (magic + 4Tredir)
FORM_DATA=$(grep -oP '<input[^>]+type="hidden"[^>]*>' "$HTML_RESPONSE" | \
    sed -nE 's/.*name="([^"]*)".*value="([^"]*)".*/\1=\2/p' | paste -sd "&" -)

# Append credentials
FORM_DATA="${FORM_DATA}&username=${USERNAME}&password=${PASSWORD}"

# Step 3: Send POST request to log in
wget --quiet --no-check-certificate \
    --header="User-Agent: $USER_AGENT" \
    --load-cookies "$COOKIE_JAR" \
    --post-data="$FORM_DATA" \
   "$LOGIN_URL" -O "$POST_RESPONSE"

# Extract magic number after login to verify with initial one 
VALID_MAGIC_NUMBER=$(cat "$POST_RESPONSE" | grep -oP 'window\.location="https://login\.iitmandi\.ac\.in:1003/portal\?\K[^"]+')

if [[ "$MAGIC_NUMBER" == "$VALID_MAGIC_NUMBER" ]]; then
    echo "!!!Login successful!!!" 
else
    echo "!!!Login unsuccessfull, check password or username!!!"
fi

# Cleanup
rm -f "$COOKIE_JAR" "$HTML_RESPONSE" "$POST_RESPONSE"

