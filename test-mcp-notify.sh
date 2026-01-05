#!/bin/bash
# 测试脚本：验证 MCP 通知 Hook 的路由逻辑

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MCP_HOOK="$SCRIPT_DIR/scripts/mcp-notify-hook.sh"

# 确保脚本可执行
chmod +x "$MCP_HOOK"

echo "=========================================="
echo "MCP Notify Hook 路由逻辑测试"
echo "=========================================="
echo ""

# 测试用例 1: Stop 事件（成功）
echo "测试 1: Stop 事件（默认路由到 ntfy + bark）"
echo '{"hook_event_name":"Stop","cwd":"/home/sun/test-project","message":"任务已完成"}' | "$MCP_HOOK"
echo ""

# 测试用例 2: SubagentStop 事件
echo "测试 2: SubagentStop 事件（成功级别）"
echo '{"hook_event_name":"SubagentStop","cwd":"/home/sun/another-project","message":"子任务完成"}' | "$MCP_HOOK"
echo ""

# 测试用例 3: 工具失败事件
echo "测试 3: PostToolUse 事件（工具失败，路由到 telegram + dingtalk + feishu + ntfy）"
echo '{"hook_event_name":"PostToolUse","tool_name":"Bash","tool_response":{"success":false,"error":"Command failed"},"cwd":"/home/sun/error-project"}' | "$MCP_HOOK"
echo ""

# 测试用例 4: Notification 事件（需要确认）
echo "测试 4: Notification 事件（需要用户确认，路由到 telegram + bark + dingtalk + feishu）"
echo '{"hook_event_name":"Notification","message":"需要您的授权才能继续","cwd":"/home/sun/auth-project"}' | "$MCP_HOOK"
echo ""

# 测试用例 5: PreCompact 事件（警告）
echo "测试 5: PreCompact 事件（警告级别，路由到 ntfy + telegram）"
echo '{"hook_event_name":"PreCompact","message":"即将压缩上下文","cwd":"/home/sun/compact-project"}' | "$MCP_HOOK"
echo ""

# 测试用例 6: 自定义事件路由
echo "测试 6: 使用环境变量自定义路由（CLAUDE_NOTIFY_ROUTE_STOP=bark）"
CLAUDE_NOTIFY_ROUTE_STOP="bark" echo '{"hook_event_name":"Stop","cwd":"/home/sun/custom-project","message":"自定义路由测试"}' | "$MCP_HOOK"
echo ""

echo "=========================================="
echo "路由规则说明："
echo "=========================================="
echo "优先级: 事件级路由 > 级别级路由 > 默认路由 > 内置默认"
echo ""
echo "内置默认路由："
echo "  - success:   ntfy, bark"
echo "  - error:     telegram, dingtalk, feishu, ntfy"
echo "  - attention: telegram, bark, dingtalk, feishu"
echo "  - warn:      ntfy, telegram"
echo "  - info:      ntfy"
echo ""
echo "可通过环境变量覆盖："
echo "  - CLAUDE_NOTIFY_ROUTE_STOP=渠道列表"
echo "  - CLAUDE_NOTIFY_ROUTE_SUCCESS=渠道列表"
echo "  - CLAUDE_NOTIFY_ROUTE_ERROR=渠道列表"
echo "  - 等等..."
echo ""
echo "测试完成！"
