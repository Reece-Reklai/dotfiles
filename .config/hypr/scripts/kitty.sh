#!/usr/bin/env bash

MARK_NAME="kitty_main"
APP_CMD="kitty"

find_kitty_window() {
    hyprctl -j clients | jq -r '
      .[] |
      select(
        (.marks != null and (.marks[]? == "kitty_main"))
        or (.class | test("kitty";"i"))
        or (.title | test("kitty";"i"))
      ) |
      .address
    ' | head -n 1
}

ADDR=$(find_kitty_window)
if [[ -n "$ADDR" ]]; then
    echo "Focusing existing Kitty window ($ADDR)..."
    hyprctl dispatch focuswindow "address:$ADDR"
    exit 0
fi

if pgrep -x "kitty" >/dev/null; then
    echo "Kitty process running but no window found — focusing..."
    ADDR=$(find_kitty_window)
    [[ -n "$ADDR" ]] && hyprctl dispatch focuswindow "address:$ADDR" && exit 0
fi

echo "No Kitty running — launching..."
$APP_CMD & disown

for i in {1..40}; do
    sleep 0.3
    ADDR=$(find_kitty_window)
    if [[ -n "$ADDR" ]]; then
        echo "Kitty window detected — marking ($MARK_NAME)..."
        hyprctl dispatch setmark "$MARK_NAME" address:$ADDR
        hyprctl dispatch focuswindow "address:$ADDR"
        exit 0
    fi
done

echo "Timeout: Kitty did not create a window."
exit 1
