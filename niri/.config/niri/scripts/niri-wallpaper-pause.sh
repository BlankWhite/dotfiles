#!/usr/bin/env bash

SOCKET="/tmp/mpv-wallpaper.sock"
LAST_PAUSE=""

set_pause() {
    local pause="$1"

    # 状态没有变化时不重复发送命令。
    [[ "$pause" == "$LAST_PAUSE" ]] && return

    if printf '{"command":["set_property","pause",%s]}\n' "$pause" \
        | socat - "$SOCKET" >/dev/null 2>&1; then
        LAST_PAUSE="$pause"
    fi
}

update_pause_state() {
    local outputs workspaces windows

    outputs=$(niri msg --json outputs 2>/dev/null) || return
    workspaces=$(niri msg --json workspaces 2>/dev/null) || return
    windows=$(niri msg --json windows 2>/dev/null) || return

    # 根据每块屏幕的逻辑宽度判断，而不是写死主屏的 2560。
    # 任意屏幕的当前工作区存在占满屏幕宽度的窗口时暂停壁纸。
    if jq -e -n \
        --argjson outputs "$outputs" \
        --argjson workspaces "$workspaces" \
        --argjson windows "$windows" '
            any(
                $workspaces[];
                .is_active and .output != null
                and (. as $workspace
                    | $outputs[$workspace.output].logical.width as $output_width
                    | any(
                        $windows[];
                        .workspace_id == $workspace.id
                        and ((.layout.window_size[0] // 0) >= $output_width)
                    )
                )
            )
        ' >/dev/null; then
        set_pause true
    else
        set_pause false
    fi
}

update_pause_state

# 窗口、工作区或输出变化后，重新检查所有屏幕。
niri msg --json event-stream | while IFS= read -r event; do
    case "$event" in
        *WindowsChanged*|*WindowLayoutsChanged*|*WindowOpenedOrChanged*|*WindowClosed*|*WorkspacesChanged*|*WorkspaceActivated*|*WorkspaceActiveWindowChanged*|*Output*)
            update_pause_state
            ;;
    esac
done
