#!/usr/bin/env bash

MARK_NAME="dota2_main"
APP_CMD="steam steam://rungameid/570"  # Launch Dota 2 through Steam

# Function: find an existing Dota 2 window
find_dota_window() {
    hyprctl -j clients | jq -r '
      .[] |
      select(
        (.marks != null and (.marks[]? == "dota2_main"))
        or (.class | test("dota";"i"))
        or (.title | test("Dota";"i"))
      ) |
      .address
    ' | head -n 1
}

# Step 1: look for an existing Dota 2 window
ADDR=$(find_dota_window)
if [[ -n "$ADDR" ]]; then
    echo "Focusing existing Dota 2 window ($ADDR)..."
    hyprctl dispatch focuswindow "address:$ADDR"
    exit 0
fi

# Step 2: Check if Dota 2 or Steam is running
if pgrep -f "dota2" >/dev/null || pgrep -x "steam" >/dev/null; then
    echo "Steam or Dota 2 process running — focusing Dota 2 if visible..."
    ADDR=$(hyprctl -j clients | jq -r '.[] | select(.class | test("dota";"i")) | .address' | head -n 1)
    if [[ -n "$ADDR" ]]; then
        hyprctl dispatch focuswindow "address:$ADDR"
        exit 0
    fi
fi

# Step 3: Launch Dota 2
echo "No Dota 2 window — launching game..."
$APP_CMD & disown

# Step 4: Wait for Dota 2’s window to appear and mark it
for i in {1..100}; do
    sleep 0.5
    ADDR=$(find_dota_window)
    if [[ -n "$ADDR" ]]; then
        echo "Dota 2 window detected — marking ($MARK_NAME)..."
        hyprctl dispatch setmark "$MARK_NAME" address:$ADDR
        hyprctl dispatch focuswindow "address:$ADDR"
        exit 0
    fi
done

echo "Timeout: Dota 2 did not create a window."
exit 1
