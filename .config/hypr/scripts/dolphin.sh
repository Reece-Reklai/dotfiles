#!/usr/bin/env bash

APP_NAME="dolphin"
MARK_NAME="dolphin_main"
APP_CMD="dolphin"

# Function: find an existing Dolphin window
find_dolphin_window() {
    hyprctl -j clients | jq -r '
      .[] |
      select(
        (.marks != null and (.marks[]? == "dolphin_main"))
        or (.class | test("dolphin";"i"))
        or (.title | test("dolphin";"i"))
      ) |
      .address
    ' | head -n 1
}

# Step 1: Look for an existing Dolphin window
ADDR=$(find_dolphin_window)
if [[ -n "$ADDR" ]]; then
    echo "Focusing existing Dolphin window ($ADDR)..."
    hyprctl dispatch focuswindow "address:$ADDR"
    exit 0
fi

# Step 2: Dolphin not found → check if process running
if pgrep -x "dolphin" >/dev/null; then
    echo "Dolphin process running but no window found — focusing first visible one..."
    ADDR=$(hyprctl -j clients | jq -r '.[] | select(.class | test("dolphin";"i")) | .address' | head -n 1)
    if [[ -n "$ADDR" ]]; then
        hyprctl dispatch focuswindow "address:$ADDR"
        exit 0
    fi
fi

# Step 3: Launch Dolphin
echo "No Dolphin running — launching..."
$APP_CMD & disown

# Step 4: Wait for Dolphin’s first window and mark it
for i in {1..40}; do
    sleep 0.3
    ADDR=$(find_dolphin_window)
    if [[ -n "$ADDR" ]]; then
        echo "Dolphin window detected — marking ($MARK_NAME)..."
        hyprctl dispatch setmark "$MARK_NAME" address:$ADDR
        hyprctl dispatch focuswindow "address:$ADDR"
        exit 0
    fi
done

echo "Timeout: Dolphin did not create a window."
exit 1
