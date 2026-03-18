#!/usr/bin/env bash

DIR="${1:-/home/wither}"
rofi_theme="$HOME/.config/rofi/gridfile.rasi"

# Function to get icons for folder/file
get_icon() {
    local path="$1"
    local name
    name=$(basename "$path")
    
    if [ -d "$path" ]; then
        echo "folder"           # folder icon
    elif [[ "$name" == .* ]]; then
        echo "hiddenfile"       # dotfile icon
    else
        # Get lowercase extension
        local ext="${name##*.}"
        ext="${ext,,}"  # convert to lowercase

        case "$ext" in
            txt) echo "document" ;;
            pdf) echo "pdf" ;;
            doc|docx) echo "word" ;;
            xls|xlsx|csv) echo "excel" ;;
            ppt|pptx) echo "ppt" ;;
            jpg|jpeg|png|gif|bmp) echo "image" ;;
            mp3|wav|ogg|flac) echo "audio" ;;
            mp4|mkv|avi|mov) echo "video" ;;
            *) echo "file" ;;
        esac
    fi
}



# Build menu entries
MENU=""
declare -A path_map

# Add ".." option to go to parent directory if not root
if [ "$DIR" != "/" ]; then
    PARENT_ICON="go-up"
    MENU+="..\0icon\x1f$PARENT_ICON\n"
    path_map[".."]="$(dirname "$DIR")"
fi

# "Open in Nautilus" option
MENU+="Open in Nautilus\0icon\x1ffolder_open\n"
path_map["Open in Nautilus"]="$DIR"

# Loop through files/folders
for f in "$DIR"/* "$DIR"/.*; do
    [ "$f" = "$DIR/." ] && continue
    [ "$f" = "$DIR/.." ] && continue
    [ ! -e "$f" ] && continue

    NAME=$(basename "$f")
    ICON=$(get_icon "$f")
    MENU+="$NAME\0icon\x1f$ICON\n"
    path_map["$NAME"]="$f"
done

# Launch Rofi
selected=$(echo -e "$MENU" | rofi -dmenu -i -p "$DIR" -theme "$rofi_theme" -show-icons)
[ -z "$selected" ] && exit 0

FILE="${path_map[$selected]}"

# Handle navigation
if [[ "$selected" == "Open in Nautilus" ]]; then
    nautilus "$DIR" &
    exit 0
elif [[ "$selected" == ".." ]]; then
    "$0" "$FILE"    # call script with parent directory
elif [ -d "$FILE" ]; then
    "$0" "$FILE"    # recurse into folder
else
    xdg-open "$FILE" &   # open file
fi
