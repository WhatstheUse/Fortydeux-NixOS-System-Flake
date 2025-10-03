I#!/usr/bin/env bash

# Script to open a file with an application picker
# This allows Yazi to open files with user-selected applications
# Provides intelligent MIME type detection and appropriate app suggestions

if [ $# -eq 0 ]; then
    echo "Usage: $0 <file>"
    exit 1
fi

FILE="$1"

# Check if file exists
if [ ! -f "$FILE" ] && [ ! -d "$FILE" ]; then
    echo "Error: File '$FILE' does not exist"
    exit 1
fi

# Get MIME type using the file command
MIME_TYPE=$(file --mime-type "$FILE" | cut -d: -f2 | tr -d ' ')



# Create a mapping from display names to commands
declare -A APP_MAP
APP_MAP["Visual Studio Code"]="code"
APP_MAP["Cursor"]="cursor"
APP_MAP["Zed Editor"]="zeditor"
APP_MAP["Kate"]="kate"
APP_MAP["Lapce"]="lapce"
APP_MAP["Ghostwriter"]="ghostwriter"
APP_MAP["Helix"]="hx"
APP_MAP["Micro"]="micro"
APP_MAP["Neovim"]="nvim"
APP_MAP["Emacs"]="emacs"
APP_MAP["Gedit"]="gedit"
APP_MAP["ReText"]="retext"
APP_MAP["Apostrophe"]="apostrophe"
APP_MAP["Gwenview"]="gwenview"
APP_MAP["Feh"]="feh"
APP_MAP["Sxiv"]="sxiv"
APP_MAP["Nomacs"]="nomacs"
APP_MAP["Eye of GNOME"]="eog"
APP_MAP["Shotwell"]="shotwell"
APP_MAP["GIMP"]="gimp"
APP_MAP["Krita"]="krita"
APP_MAP["Inkscape"]="inkscape"
APP_MAP["MPV"]="mpv"
APP_MAP["VLC"]="vlc"
APP_MAP["Totem"]="totem"
APP_MAP["Celluloid"]="celluloid"
APP_MAP["SMPlayer"]="smplayer"
APP_MAP["Audacity"]="audacity"
APP_MAP["Rhythmbox"]="rhythmbox"
APP_MAP["Clementine"]="clementine"
APP_MAP["Okular"]="okular"
APP_MAP["Evince"]="evince"
APP_MAP["Zathura"]="zathura"
APP_MAP["Firefox"]="firefox"
APP_MAP["Chromium"]="chromium"
APP_MAP["Brave Browser"]="brave-browser"
APP_MAP["LibreOffice"]="libreoffice"
APP_MAP["OnlyOffice"]="onlyoffice-desktopeditors"
APP_MAP["Ark"]="ark"
APP_MAP["File Roller"]="file-roller"
APP_MAP["Xarchiver"]="xarchiver"
APP_MAP["Kitty"]="kitty"
APP_MAP["Foot"]="foot"
APP_MAP["Alacritty"]="alacritty"

# Create a simple, maintainable application list
# Format: "Display Name" - wofi shows clean names
APP_LIST=""

# Common applications for different file types
case "$MIME_TYPE" in
    text/*|text/x-*|application/json|application/xml|text/yaml|text/x-toml|text/x-nix|text/x-shellscript)
        # Text/Code files
        echo "📝 Text & Code Editors" >&2
        apps=("Visual Studio Code" "Cursor" "Zed Editor" "Kate" "Lapce" "Ghostwriter" "Neovim" "Emacs" "ReText" "Apostrophe" "OnlyOffice" "Helix" "Micro" "Gedit")
        for app in "${apps[@]}"; do
            if command -v "${APP_MAP["$app"]}" >/dev/null 2>&1; then
                APP_LIST="$APP_LIST
$app"
            fi
        done
        ;;
    image/*)
        # Images
        echo "🖼️ Image Viewers & Editors" >&2
        apps=("Gwenview" "Feh" "Sxiv" "Nomacs" "Eye of GNOME" "Shotwell" "GIMP" "Krita" "Inkscape")
        for app in "${apps[@]}"; do
            if command -v "${APP_MAP["$app"]}" >/dev/null 2>&1; then
                
                APP_LIST="$APP_LIST
$app"
            fi
        done
        ;;
    video/*)
        # Videos
        echo "🎬 Video Players" >&2
        apps=("MPV" "VLC" "Totem" "Celluloid" "SMPlayer")
        for app in "${apps[@]}"; do
            if command -v "${APP_MAP["$app"]}" >/dev/null 2>&1; then
                
                APP_LIST="$APP_LIST
$app"
            fi
        done
        ;;
    audio/*)
        # Audio
        echo "🎵 Audio Players & Editors" >&2
        apps=("MPV" "VLC" "Audacity" "Rhythmbox" "Clementine")
        for app in "${apps[@]}"; do
            if command -v "${APP_MAP["$app"]}" >/dev/null 2>&1; then
                
                APP_LIST="$APP_LIST
$app"
            fi
        done
        ;;
    application/pdf)
        # PDFs
        echo "📄 PDF Viewers" >&2
        apps=("Okular" "Evince" "Zathura" "Firefox" "Chromium")
        for app in "${apps[@]}"; do
            if command -v "${APP_MAP["$app"]}" >/dev/null 2>&1; then
                
                APP_LIST="$APP_LIST
$app"
            fi
        done
        ;;
    application/vnd.oasis.opendocument.*|application/vnd.openxmlformats-officedocument.*|application/msword|application/vnd.ms-*)
        # Documents
        echo "📊 Document Editors" >&2
        apps=("LibreOffice" "OnlyOffice" "Kate" "Gedit")
        for app in "${apps[@]}"; do
            if command -v "${APP_MAP["$app"]}" >/dev/null 2>&1; then
                
                APP_LIST="$APP_LIST
$app"
            fi
        done
        ;;
    application/zip|application/x-*)
        # Archives
        echo "📦 Archive Managers" >&2
        apps=("Ark" "File Roller" "Xarchiver")
        for app in "${apps[@]}"; do
            if command -v "${APP_MAP["$app"]}" >/dev/null 2>&1; then
                
                APP_LIST="$APP_LIST
$app"
            fi
        done
        ;;
    text/html|text/css)
        # Web
        echo "🌐 Web Browsers" >&2
        apps=("Firefox" "Chromium" "Brave Browser")
        for app in "${apps[@]}"; do
            if command -v "${APP_MAP["$app"]}" >/dev/null 2>&1; then
                
                APP_LIST="$APP_LIST
$app"
            fi
        done
        ;;
    *)
        # Default: show some universal apps
        echo "🔧 Universal Applications" >&2
        apps=("Firefox" "Kitty" "Foot" "Alacritty")
        for app in "${apps[@]}"; do
            if command -v "${APP_MAP["$app"]}" >/dev/null 2>&1; then
                
                APP_LIST="$APP_LIST
$app"
            fi
        done
        ;;
esac

# Add some universal apps that are usually available
echo "💻 System Applications" >&2
apps=("Firefox" "Kitty" "Foot" "Alacritty")
for app in "${apps[@]}"; do
    if command -v "${APP_MAP["$app"]}" >/dev/null 2>&1; then
        
        APP_LIST="$APP_LIST
$app"
    fi
done

# Remove duplicates and sort
APP_LIST=$(echo -e "$APP_LIST" | sort -u | grep -v '^$')

# Show file information header
echo "📁 Opening: $(basename "$FILE")" >&2
echo "🔍 Type: $MIME_TYPE" >&2
echo "" >&2

# Use available application pickers with enhanced styling and icon support
if command -v wofi >/dev/null 2>&1; then
    # Wofi with clean interface - shows clean app names, returns commands
    # Format: "Display Name" - wofi displays clean names, we map to commands
    SELECTED_APP=$(echo -e "$APP_LIST" | wofi \
        --dmenu \
        --prompt "Open with:" \
        --width 600 \
        --height 500)
    
    # Map the selected app name to its command
    if [ -n "$SELECTED_APP" ]; then
        SELECTED="${APP_MAP["$SELECTED_APP"]}"
    fi
elif command -v rofi >/dev/null 2>&1; then
    # Rofi as fallback
    SELECTED_APP=$(echo -e "$APP_LIST" | rofi \
        -dmenu \
        -p "Open with:" \
        -i)
    
    # Map the selected app name to its command
    if [ -n "$SELECTED_APP" ]; then
        SELECTED="${APP_MAP["$SELECTED_APP"]}"
    fi
elif command -v fuzzel >/dev/null 2>&1; then
    # Fuzzel as fallback
    SELECTED_APP=$(echo -e "$APP_LIST" | fuzzel \
        --dmenu \
        --prompt "Open with:" \
        --width 60 \
        --lines 15 \
        --border-width 2 \
        --border-radius 12 \
        --horizontal-pad 12 \
        --vertical-pad 8 \
        --inner-pad 4 \
        --selection-radius 8)
    
    # Map the selected app name to its command
    if [ -n "$SELECTED_APP" ]; then
        SELECTED="${APP_MAP["$SELECTED_APP"]}"
    fi
elif command -v dmenu >/dev/null 2>&1; then
    SELECTED_APP=$(echo -e "$APP_LIST" | dmenu -p "Open with:")
    
    # Map the selected app name to its command
    if [ -n "$SELECTED_APP" ]; then
        SELECTED="${APP_MAP["$SELECTED_APP"]}"
    fi
else
    echo "No suitable application picker found. Please install wofi, rofi, fuzzel, or dmenu."
    exit 1
fi

# Function to launch terminal-based editors in a terminal emulator
launch_in_terminal() {
    local editor="$1"
    local file="$2"
    
    # Check for available terminal emulators in order of preference
    if command -v kitty >/dev/null 2>&1; then
        exec kitty -e "$editor" "$file"
    elif command -v alacritty >/dev/null 2>&1; then
        exec alacritty -e "$editor" "$file"
    elif command -v foot >/dev/null 2>&1; then
        exec foot -e "$editor" "$file"
    elif command -v gnome-terminal >/dev/null 2>&1; then
        exec gnome-terminal -- "$editor" "$file"
    elif command -v xterm >/dev/null 2>&1; then
        exec xterm -e "$editor" "$file"
    else
        # Fallback: try to launch directly (may not work for terminal editors)
        exec "$editor" "$file"
    fi
}

# Open the file with the selected application
if [ -n "$SELECTED" ]; then
    echo "Opening '$FILE' with $SELECTED" >&2
    
    # Check if it's a terminal-based editor that needs special handling
    case "$SELECTED" in
        "hx"|"nvim"|"micro"|"emacs")
            launch_in_terminal "$SELECTED" "$FILE"
            ;;
        *)
            # For GUI applications, launch directly
            exec "$SELECTED" "$FILE"
            ;;
    esac
else
    echo "No application selected" >&2
    exit 1
fi
