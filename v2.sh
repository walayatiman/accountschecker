while true; do
    mapfile -t data_array < accounts.txt
    # Get the current local time
    local_time=$(date "+%Y-%m-%d %H:%M:%S")
    
    # Convert the current time to CET, EST, Manila Time, and UTC
    cet_time=$(TZ="CET" date "+%Y-%m-%d %H:%M:%S")
    est_time=$(TZ="America/New_York" date "+%Y-%m-%d %H:%M:%S")
    manila_time=$(TZ="Asia/Manila" date "+%Y-%m-%d %H:%M:%S")
    utc_time=$(TZ="UTC" date "+%Y-%m-%d %H:%M:%S")
    
    notify_with_sound() {
        local message="$1"
        local title="$2"
        local sound_file="./wed.mp3"  # Hardcoded path to the sound file
        
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
        
        is_suspended=$(echo "$response" | jq -r '.data.is_suspended')
        is_not_found=$(echo "$response" | jq -r '.error')
        
        # Get the current suspension time (if suspended)
        if [ "$is_suspended" == "true" ]; then
            suspension_time=$(date "+%Y-%m-%d %H:%M:%S")
            echo "Account $1 is suspended"
            notify_with_sound "Account $1 is suspended" "Account Status"
            
            # Remove the account from data.txt and add it to suspended.txt with suspension times
            sed -i "/^$1$/d" accounts.txt
            echo "$1 - Suspended at $suspension_time" >> suspended.txt
            echo "Manila Time: $local_time" >> suspended.txt
            echo "CET Time: $cet_time" >> suspended.txt
            echo "EST Time: $est_time" >> suspended.txt
            printf "\n\n" >> suspended.txt
            elif [ "$is_not_found" == "404" ]; then
            echo "Account $1 not found."
            notify_with_sound "Account $1 not found, check manually" "Account Status"
            # Remove the account from data.txt and add it to suspended.txt with 404 error message
            sed -i "/^$1$/d" accounts.txt
            echo "$1 - Not Found (404) - Check Manually" >> suspended.txt
            echo "Manila Time: $local_time" >> suspended.txt
            echo "CET Time: $cet_time" >> suspended.txt
            echo "EST Time: $est_time" >> suspended.txt
            printf "\n\n" >> suspended.txt
            elif [ "$is_not_found" == "429" ]; then
            echo "Error 429: Rate limit exceeded for user $1. Retrying in 30 seconds..."
            sleep 30
            fetch_account_data $1  # Retry the request
        else
            # If no error and not suspended, display the account data
            echo "$1 is still active."
        fi
    }
    
    # Loop through each account in data.txt
    for item in "${data_array[@]}"; do
        echo -e "Checking account: $item"
        fetch_account_data "$item"
        sleep 10
    done
    sleep 60
done
