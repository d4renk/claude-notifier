## 测试配置文件（不包含真实密钥）

## 通知环境变量
## 1. Bark (测试环境)
export BARK_PUSH="test-device-key"
export BARK_ICON="https://qn.whyour.cn/logo.png"
export BARK_SOUND="bell"
export BARK_GROUP="Claude"
export BARK_LEVEL="active"
export BARK_ARCHIVE=""
export BARK_URL=""

## 2. Telegram (测试环境)
export TG_BOT_TOKEN="test-bot-token"
export TG_USER_ID="test-user-id"
export TG_API_HOST="https://api.telegram.org"
export TG_PROXY_AUTH=""
export TG_PROXY_HOST=""
export TG_PROXY_PORT=""

## 3. 钉钉 (测试环境)
export DD_BOT_TOKEN="test-dd-token"
export DD_BOT_SECRET="test-dd-secret"

## 4. 飞书 (测试环境)
export FSKEY="test-fs-key"
export FSSECRET="test-fs-secret"

## 5. Ntfy (测试环境)
export NTFY_URL="https://ntfy.sh"
export NTFY_TOPIC="test-claude-notify"
export NTFY_PRIORITY="3"
export NTFY_TOKEN=""
export NTFY_USERNAME=""
export NTFY_PASSWORD=""
export NTFY_ACTIONS=""

## Claude Code MCP 通知路由规则
export CLAUDE_NOTIFY_TITLE="Claude Code 测试"
export CLAUDE_NOTIFY_ROUTE_SUCCESS="ntfy,bark"
export CLAUDE_NOTIFY_ROUTE_ERROR="telegram,dingtalk,feishu,ntfy"
export CLAUDE_NOTIFY_ROUTE_ATTENTION="telegram,bark,dingtalk,feishu"
export CLAUDE_NOTIFY_ROUTE_WARN="ntfy,telegram"
export CLAUDE_NOTIFY_ROUTE_INFO="ntfy"
export CLAUDE_NOTIFY_ROUTE_DEFAULT=""

## 启用一言（测试时可禁用以简化输出）
export HITOKOTO="false"
