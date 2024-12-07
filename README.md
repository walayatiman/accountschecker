# Reddit Account Status Checker

This script checks the status of Reddit accounts from a provided list in data.txt. If an account is suspended or not found (404), it logs the information in suspended.txt and removes the account from the original list. The script also includes functionality to notify the user with sound and display notifications.

## Features

Account Status Checking: Uses Reddit's public API to determine if a Reddit account is active, suspended, or non-existent.
Time Zone Conversion: Displays the time the account was checked in various time zones:

    Local Time
    CET (Central European Time)
    EST (Eastern Standard Time)
    Manila Time
    UTC

Notification with Sound:

    Alerts the user if an account is suspended or not found.
    Plays a sound and shows a desktop notification (requires paplay or afplay for sound).

Automatic Logging:

    Suspended accounts are removed from data.txt.
    Suspended account details, including check times in multiple time zones, are logged in suspended.txt.

## Requirements

    Dependencies:
        curl: For making API requests.
        jq: For parsing JSON responses.
        paplay (Linux) or afplay (macOS): For playing sound notifications.
        notify-send (Linux) or osascript (macOS): For showing desktop notifications.
    Files:
        data.txt: A text file containing one Reddit username per line.
        wed.mp3: A sound file for notifications.

- Light/dark mode toggle
- Live previews
- Fullscreen mode
- Cross platform

## How to Use

    Prepare the Input File:
        Create a file named data.txt in the same directory as the script.
        Add Reddit usernames, one per line.

    Run the Script:

bash reddit_checker.sh

The script will:

    Read usernames from data.txt.
    Check each account's status.
    Log suspended accounts in suspended.txt.
    Notify you with a sound if an account is suspended or not found.

Monitor Output:

    Suspended accounts are logged in suspended.txt.
    Remaining accounts stay in data.txt.
