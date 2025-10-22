#!/usr/bin/env bash

MARK_NAME="steam_main"
APP_CMD="steam"

# Function: find an existing Steam window
find_steam_window() {
    hyprctl -j clients | jq -r '
      .[] |
      select(
        (.marks != null and (.marks[]? == "steam_main"))
        or (.class | test("steam";"i"))
        or (.title | test("Steam";"i"))
      ) |
      .address
    ' | head -n 1
}

# Step 1: look for an existing Steam window
ADDR=$(find_steam_window)
if [[ -n "$ADDR" ]]; then
    echo "Focusing existing Steam window ($ADDR)..."
    hyprctl dispatch focuswindow "address:$ADDR"
    exit 0
fi

# Step 2: Steam not found → check if process running
if pgrep -x "steam" >/dev/null; then
    echo "Steam process running but no window found — focusing first visible one..."
    ADDR=$(hyprctl -j clients | jq -r '.[] | select(.class | test("steam";"i")) | .address' | head -n 1)
    if [[ -n "$ADDR" ]]; then
        hyprctl dispatch focuswindow "address:$ADDR"
        exit 0
    fi
fi

# Step 3: Launch Steam (first instance)
echo "No Steam running — launching..."
$APP_CMD & disown

# Step 4: Wait for Steam’s first window to appear and mark it
for i in {1..60}; do
    sleep 0.5
    ADDR=$(find_steam_window)
    if [[ -n "$ADDR" ]]; then
        echo "Steam window detected — marking ($MARK_NAME)..."
        hyprctl dispatch setmark "$MARK_NAME" address:$ADDR
        hyprctl dispatch focuswindow "address:$ADDR"
        exit 0
    fi
done

echo "Timeout: Steam did not create a window."
exit 1
