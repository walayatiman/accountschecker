#!/bin/bash

# Read the file into an array
while true; do
    mapfile -t data_array < data.txt
    # Get the current local time
    # Get the current local time
    local_time=$(date "+%Y-%m-%d %H:%M:%S")
    
    # Convert the current time to CET and EST
    cet_time=$(TZ="CET" date "+%Y-%m-%d %H:%M:%S")
    est_time=$(TZ="America/New_York" date "+%Y-%m-%d %H:%M:%S")
    
    notify_with_sound() {
        local message="$1"
        local title="$2"
        local sound_file="./wed.mp3" # Hardcoded path to the sound file
        
        # Check if the sound file exists
        if [[ ! -f "$sound_file" ]]; then
            echo "Sound file not found: $sound_file"
            return 1
        fi
        
        if [[ "$OSTYPE" == "darwin"* ]]; then
            # macOS
            osascript -e "display notification \"$message\" with title \"$title\"" && afplay "$sound_file"
            elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
            # Linux
            notify-send "$title" "$message" && paplay "$sound_file"
        else
            echo "Unsupported OS"
            return 2
        fi
    }
    
    fetch_account_data() {
        response=$(curl -s "https://www.reddit.com/user/$1/about.json" | jq .)
        
        if [ "$error" == "429" ]; then
            echo "Rate limit exceeded (429) for user $1. Retrying in 30 seconds..."
            sleep 30
            fetch_account_data $1  # Retry by calling the function again
        else
            
            is_suspended=$(echo "$response" | jq -r '.data.is_suspended')
            is_not_found=$(echo "$response" | jq -r '.error')
            
            echo "$response" | jq .
            if [ "$is_suspended" == "true" ]; then
                echo "Account $1 is suspended"
                echo "Manila Time: $local_time"
                echo "CET Time: $cet_time"
                echo "EST Time: $est_time"
                notify_with_sound "Account $1 is suspended" "Account Status"
                elif [ "$is_not_found" == "404" ]; then  # Assuming you have the status_code variable set earlier
                echo "Account $1 not found."
                notify_with_sound "Account $1 not found, check manually" "Account Status"
                elif [ "$is_not_found" == "429" ]; then  # Assuming you have the status_code variable set earlier
                echo "Error 429: Rate limit exceeded for user $1. Retrying in 30 seconds..."
                sleep 30
                fetch_account_data $1  # Recalling the function to retry fetching the data
            else
                # If no error and not suspended, display the account data
                echo "$1 is still active."
            fi
        fi
    }
    
    # Echo the data in the array with an extra newline
    
    for item in "${data_array[@]}"; do
        echo -e "checking account: $item"
        fetch_account_data "$item"
        sleep 10
    done
    sleep 60
done

