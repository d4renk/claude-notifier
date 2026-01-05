#!/bin/bash
# 测试脚本：验证 MCP 通知 Hook（从环境变量读取配置）

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MCP_HOOK="$SCRIPT_DIR/scripts/mcp-notify-hook.sh"

# 确保脚本可执行
chmod +x "$MCP_HOOK"

echo "=========================================="
echo "MCP Notify Hook 测试"
echo "=========================================="
echo ""

# 检查是否配置了至少一个渠道
if [[ -z "${NTFY_TOPIC:-}${BARK_PUSH:-}${TG_BOT_TOKEN:-}${DD_BOT_TOKEN:-}${FSKEY:-}" ]]; then
    echo "❌ 错误：未检测到任何通知渠道配置"
    echo ""
    echo "请先配置至少一个渠道的环境变量："
    echo ""
    echo "方式一：在 ~/.claude/settings.json 中配置："
    echo '  {'
    echo '    "env": {'
    echo '      "NTFY_TOPIC": "your-topic"'
    echo '    }'
    echo '  }'
    echo ""
    echo "方式二：在当前 shell 中导出："
    echo '  export NTFY_TOPIC="your-topic"'
    echo ""
    echo "支持的渠道变量："
    echo "  - NTFY_TOPIC (ntfy)"
    echo "  - BARK_PUSH (Bark)"
    echo "  - TG_BOT_TOKEN + TG_USER_ID (Telegram)"
    echo "  - DD_BOT_TOKEN + DD_BOT_SECRET (钉钉)"
    echo "  - FSKEY (飞书)"
    echo ""
    echo "查看所有渠道：cat config.sample.sh"
    exit 1
fi

echo "✅ 检测到已配置的渠道："
[[ -n "${NTFY_TOPIC:-}" ]] && echo "  - ntfy (topic: ${NTFY_TOPIC})"
[[ -n "${BARK_PUSH:-}" ]] && echo "  - Bark (device: ${BARK_PUSH})"
[[ -n "${TG_BOT_TOKEN:-}" ]] && echo "  - Telegram (user: ${TG_USER_ID:-})"
[[ -n "${DD_BOT_TOKEN:-}" ]] && echo "  - 钉钉"
[[ -n "${FSKEY:-}" ]] && echo "  - 飞书"
echo ""

# 测试用例 1: Stop 事件（成功）
echo "测试 1: Stop 事件 (成功 → ntfy, bark)"
echo '{"hook_event_name":"Stop","cwd":"'"$SCRIPT_DIR"'","message":"任务已完成"}' | "$MCP_HOOK"
echo ""

# 测试用例 2: 工具失败事件
echo "测试 2: 工具失败 (错误 → telegram, dingtalk, feishu, ntfy)"
echo '{"hook_event_name":"PostToolUse","tool_name":"Bash","tool_response":{"success":false,"error":"Command failed"},"cwd":"'"$SCRIPT_DIR"'"}' | "$MCP_HOOK"
echo ""

# 测试用例 3: Notification 事件（需要确认）
echo "测试 3: 需要确认 (attention → telegram, bark, dingtalk, feishu)"
echo '{"hook_event_name":"Notification","message":"需要您的授权才能继续","cwd":"'"$SCRIPT_DIR"'"}' | "$MCP_HOOK"
echo ""

echo "=========================================="
echo "路由规则说明："
echo "=========================================="
echo "优先级: 事件级 > 级别级 > 默认 > 内置"
echo ""
echo "内置默认路由："
echo "  - success:   ntfy, bark"
echo "  - error:     telegram, dingtalk, feishu, ntfy"
echo "  - attention: telegram, bark, dingtalk, feishu"
echo "  - warn:      ntfy, telegram"
echo "  - info:      ntfy"
echo ""
echo "自定义路由（在 settings.json 或环境变量中配置）："
echo "  - CLAUDE_NOTIFY_ROUTE_SUCCESS=bark"
echo "  - CLAUDE_NOTIFY_ROUTE_ERROR=all"
echo "  - CLAUDE_NOTIFY_ROUTE_STOP=ntfy"
echo "  等等..."
echo ""
echo "测试完成！检查你配置的渠道是否收到通知。"
