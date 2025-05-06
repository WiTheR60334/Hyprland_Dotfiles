#!/bin/bash
rofi_config="$HOME/.config/rofi/config-alt-tab.rasi"

# Kill Rofi if already running
if pgrep -x "rofi" >/dev/null; then
    pkill rofi
    exit 0
fi

# Fetch the list of windows with address and class
mapfile -t windows < <(hyprctl clients -j | jq -r '.[] | "\(.address) \(.class)"')

# Clean up the window names and prepare for Rofi with icons
declare -A window_map
window_list=""
for window in "${windows[@]}"; do
    address=$(echo "$window" | awk '{print $1}')
    app_id=$(echo "$window" | awk '{print $2}')

    # Clean up the app_id for display name
    case "$app_id" in
        "code-oss" | ".code-oss")
            clean_name="Code-OSS"
            icon="code-oss"
            ;;
        "google-chrome")
            clean_name="Google Chrome"
            icon="google-chrome"
            ;;
        "kitty")
            clean_name="Kitty"
            icon="kitty"
            ;;
        "org.gnome.SystemMonitor")
            clean_name="System Monitor"
            icon="org.gnome.SystemMonitor"
            ;;
        "org.gnome.Nautilus")
            clean_name="Files"
            icon="org.gnome.Nautilus"
            ;;
        "org.gnome.TextEditor")
            clean_name="Text Editor"
            icon="org.gnome.TextEditor"
            ;;
        "org.gnome.Calculator")
            clean_name="Calculator"
            icon="org.gnome.Calculator"
            ;;
        "org.gnome.Calendar")
            clean_name="Calendar"
            icon="org.gnome.Calendar"
            ;;
        "org.gnome.clocks")
            clean_name="Clocks"
            icon="org.gnome.clocks"
            ;;
        "org.gnome.Software")
            clean_name="Software"
            icon="org.gnome.software"
            ;;
        *)
            # Capitalize the first letter of the app_id
            clean_name="$(echo "$app_id" | awk '{print toupper(substr($0,1,1)) tolower(substr($0,2))}')"
            icon="$app_id"
            ;;
    esac

    # Store the mapping of clean name to address
    window_map["$clean_name"]="$address"
    # Format for Rofi with icon
    window_list+="$clean_name\0icon\x1f$icon\n"
done

# Launch Rofi and let the user select a window
selected=$(echo -e "$window_list" | rofi -dmenu -config "$rofi_config" -p "Switch to window: " -show-icons)

# If a window was selected, focus it using hyprctl
if [ -n "$selected" ]; then
    address=${window_map["$selected"]}
    if [ -n "$address" ]; then
        hyprctl dispatch focuswindow "address:$address"
    fi
fi