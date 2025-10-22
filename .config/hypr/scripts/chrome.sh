#!/usr/bin/env bash

# === Hyprland + Wayland Chrome Focus/Launch ===

MARK_NAME="chrome_main"
CHROME_CMD="google-chrome --ozone-platform=wayland --enable-features=UseOzonePlatform"

# Function: find an existing Chrome window
find_chrome_window() {
    hyprctl -j clients | jq -r '
      .[] |
      select(
        (.marks != null and (.marks[]? == "chrome_main"))
        or (.class | test("chrome";"i"))
        or (.title | test("chrome";"i"))
      ) |
      .address
    ' | head -n 1
}

# Step 1: look for an existing Chrome window
ADDR=$(find_chrome_window)
if [[ -n "$ADDR" ]]; then
    echo "Focusing existing Chrome window ($ADDR)..."
    hyprctl dispatch focuswindow "address:$ADDR"
    exit 0
fi

# Step 2: Chrome not found → check if process running
if pgrep -x "chrome" >/dev/null || pgrep -x "google-chrome" >/dev/null; then
    echo "Chrome process running but no window found — focusing first visible one..."
    ADDR=$(hyprctl -j clients | jq -r '.[] | select(.class | test("chrome";"i")) | .address' | head -n 1)
    if [[ -n "$ADDR" ]]; then
        hyprctl dispatch focuswindow "address:$ADDR"
        exit 0
    fi
fi

# Step 3: Launch Chrome (first instance)
echo "No Chrome running — launching..."
$CHROME_CMD & disown

# Step 4: Wait for Chrome’s first window to appear and mark it
for i in {1..40}; do
    sleep 0.3
    ADDR=$(find_chrome_window)
    if [[ -n "$ADDR" ]]; then
        echo "Chrome window detected — marking ($MARK_NAME)..."
        hyprctl dispatch setmark "$MARK_NAME" address:$ADDR
        hyprctl dispatch focuswindow "address:$ADDR"
        exit 0
    fi
done

echo "Timeout: Chrome did not create a window."
exit 1
