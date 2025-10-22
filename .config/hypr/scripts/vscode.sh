#!/usr/bin/env bash


MARK_NAME="vscode_main"
APP_CMD="flatpak run com.visualstudio.code"

# Function: find an existing VS Code window
find_vscode_window() {
    hyprctl -j clients | jq -r '
      .[] |
      select(
        (.marks != null and (.marks[]? == "vscode_main"))
        or (.class | test("code";"i"))
        or (.title | test("Visual Studio Code";"i"))
      ) |
      .address
    ' | head -n 1
}

# Step 1: look for an existing VS Code window
ADDR=$(find_vscode_window)
if [[ -n "$ADDR" ]]; then
    echo "Focusing existing VS Code window ($ADDR)..."
    hyprctl dispatch focuswindow "address:$ADDR"
    exit 0
fi

# Step 2: VS Code not found → check if process running
if pgrep -f "com.visualstudio.code" >/dev/null || pgrep -x "code" >/dev/null; then
    echo "VS Code process running but no window found — focusing first visible one..."
    ADDR=$(hyprctl -j clients | jq -r '.[] | select(.class | test("code";"i")) | .address' | head -n 1)
    if [[ -n "$ADDR" ]]; then
        hyprctl dispatch focuswindow "address:$ADDR"
        exit 0
    fi
fi

# Step 3: Launch VS Code (first instance)
echo "No VS Code running — launching..."
$APP_CMD & disown

# Step 4: Wait for VS Code’s first window to appear and mark it
for i in {1..40}; do
    sleep 0.3
    ADDR=$(find_vscode_window)
    if [[ -n "$ADDR" ]]; then
        echo "VS Code window detected — marking ($MARK_NAME)..."
        hyprctl dispatch setmark "$MARK_NAME" address:$ADDR
        hyprctl dispatch focuswindow "address:$ADDR"
        exit 0
    fi
done

echo "Timeout: VS Code did not create a window."
exit 1
