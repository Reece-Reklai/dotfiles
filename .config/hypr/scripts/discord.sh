#!/usr/bin/env bash

MARK_NAME="discord_main"
APP_CMD="flatpak run com.discordapp.Discord"

# Function: find an existing Discord window
find_discord_window() {
    hyprctl -j clients | jq -r '
      .[] |
      select(
        (.marks != null and (.marks[]? == "discord_main"))
        or (.class | test("discord";"i"))
        or (.title | test("Discord";"i"))
      ) |
      .address
    ' | head -n 1
}

# Step 1: look for an existing Discord window
ADDR=$(find_discord_window)
if [[ -n "$ADDR" ]]; then
    echo "Focusing existing Discord window ($ADDR)..."
    hyprctl dispatch focuswindow "address:$ADDR"
    exit 0
fi

# Step 2: Discord not found → check if process running
if pgrep -f "com.discordapp.Discord" >/dev/null || pgrep -x "Discord" >/dev/null; then
    echo "Discord process running but no window found — focusing first visible one..."
    ADDR=$(hyprctl -j clients | jq -r '.[] | select(.class | test("discord";"i")) | .address' | head -n 1)
    if [[ -n "$ADDR" ]]; then
        hyprctl dispatch focuswindow "address:$ADDR"
        exit 0
    fi
fi

# Step 3: Launch Discord (first instance)
echo "No Discord running — launching..."
$APP_CMD & disown

# Step 4: Wait for Discord’s first window to appear and mark it
for i in {1..40}; do
    sleep 0.3
    ADDR=$(find_discord_window)
    if [[ -n "$ADDR" ]]; then
        echo "Discord window detected — marking ($MARK_NAME)..."
        hyprctl dispatch setmark "$MARK_NAME" address:$ADDR
        hyprctl dispatch focuswindow "address:$ADDR"
        exit 0
    fi
done

echo "Timeout: Discord did not create a window."
exit 1
