#!/bin/bash
# Claude Notifier 环境变量配置参考
#
# 重要说明：
# - 本文件仅作为环境变量参考，列出所有可配置项
# - 实际配置请使用 ~/.claude/settings.json 的 env 字段
# - 或配置在系统环境变量中（~/.bashrc 或 ~/.zshrc）
#
# 支持的渠道由 notify.js 决定，共 20+ 个渠道

## =============================================================================
## 通知渠道配置（选择需要的渠道配置即可）
## =============================================================================

## 1. ntfy（推荐：最简单，无需注册）
## 官方网站：https://ntfy.sh
export NTFY_URL=""              # ntfy 服务器地址，默认 https://ntfy.sh
export NTFY_TOPIC=""            # ntfy 主题名（必填）
export NTFY_PRIORITY="3"        # 推送优先级，默认 3
export NTFY_TOKEN=""            # 推送 token（可选）
export NTFY_USERNAME=""         # 用户名（可选）
export NTFY_PASSWORD=""         # 密码（可选）
export NTFY_ACTIONS=""          # 推送动作（可选）

## 2. Bark（推荐：iOS 用户）
## App Store 下载 Bark，获取设备码
export BARK_PUSH=""             # 设备码或完整 URL，如 https://api.day.app/ABC123DEF
export BARK_ICON=""             # 推送图标 URL（可选）
export BARK_SOUND=""            # 推送声音，如 choo（可选）
export BARK_GROUP=""            # 推送分组，默认 QingLong（可选）
export BARK_LEVEL=""            # 推送时效性：active/timeSensitive/passive（可选）
export BARK_ARCHIVE=""          # 是否存档（可选）
export BARK_URL=""              # 推送跳转 URL（可选）

## 3. Telegram
## 官方文档：https://core.telegram.org/bots
## 步骤：1) @BotFather 创建 bot 获取 token  2) @getuseridbot 获取用户 ID
export TG_BOT_TOKEN=""          # Telegram bot token（必填）
export TG_USER_ID=""            # Telegram 用户 ID（必填）
export TG_API_HOST=""           # API 地址，默认 https://api.telegram.org（可选）
export TG_PROXY_HOST=""         # 代理地址（可选）
export TG_PROXY_PORT=""         # 代理端口（可选）
export TG_PROXY_AUTH=""         # 代理认证参数（可选）

## 4. 钉钉机器人
## 官方文档：https://developers.dingtalk.com/document/app/custom-robot-access
export DD_BOT_TOKEN=""          # 钉钉机器人 webhook 的 access_token（必填）
export DD_BOT_SECRET=""         # 钉钉机器人加签密钥（可选，推荐配置）

## 5. 飞书机器人
## 官方文档：https://www.feishu.cn/hc/zh-CN/articles/360024984973
export FSKEY=""                 # 飞书机器人 webhook key（必填）
export FSSECRET=""              # 飞书机器人签名校验密钥（可选）

## 6. 企业微信机器人
## 官方文档：https://work.weixin.qq.com/api/doc/90000/90136/91770
export QYWX_KEY=""              # 企业微信机器人 webhook key（必填）
export QYWX_ORIGIN=""           # 企业微信 API 地址，默认 https://qyapi.weixin.qq.com

## 7. 企业微信应用
## 官方文档：https://work.weixin.qq.com/api/doc/90000/90135/90236
## 格式：corpid,corpsecret,touser,agentid,消息类型（0=卡片/1=文本/图片id=图文）
export QYWX_AM=""               # 企业微信应用参数，逗号分隔（必填）

## 8. Server 酱（微信推送）
## 官方网站：https://sct.ftqq.com
export PUSH_KEY=""              # Server 酱 SCHKEY 或 SendKey（必填）

## 9. PushPlus（微信推送）
## 官方网站：http://www.pushplus.plus
export PUSH_PLUS_TOKEN=""       # PushPlus 用户令牌（必填）
export PUSH_PLUS_USER=""        # 群组编码，一对多推送（可选）
export PUSH_PLUS_TEMPLATE=""    # 发送模板：html/txt/json/markdown（可选）
export PUSH_PLUS_CHANNEL=""     # 发送渠道：wechat/webhook/cp/mail/sms（可选）
export PUSH_PLUS_WEBHOOK=""     # webhook 编码（可选）
export PUSH_PLUS_CALLBACKURL="" # 回调地址（可选）
export PUSH_PLUS_TO=""          # 好友令牌（可选）

## 10. iGot（聚合推送）
## 官方网站：https://push.hellyw.com
export IGOT_PUSH_KEY=""         # iGot 推送 key（必填）

## 11. pushMe
## 官方网站：https://push.i-i.me
export PUSHME_KEY=""            # pushMe push_key（必填）
export PUSHME_URL=""            # 自建 PushMeServer 地址（可选）

## 12. pushDeer
## 官方网站：https://www.pushdeer.com
export DEER_KEY=""              # PushDeer key（必填）
export DEER_URL=""              # PushDeer 服务器地址（可选）

## 13. gotify（自托管）
## 官方网站：https://gotify.net
export GOTIFY_URL=""            # gotify 服务器地址，如 https://push.example.de:8080（必填）
export GOTIFY_TOKEN=""          # gotify 消息应用 token（必填）
export GOTIFY_PRIORITY="0"      # 推送优先级，默认 0

## 14. Chronocat（QQ 机器人）
## 官方文档：https://chronocat.vercel.app
export CHRONOCAT_URL=""         # Chronocat 连接地址，如 http://127.0.0.1:16530（必填）
export CHRONOCAT_TOKEN=""       # 访问密钥（必填）
export CHRONOCAT_QQ=""          # 推送目标，如 user_id=123;group_id=456（必填）

## 15. go-cqhttp（QQ 机器人）
## 官方文档：https://docs.go-cqhttp.org
export GOBOT_URL=""             # go-cqhttp URL，如 http://127.0.0.1/send_private_msg（必填）
export GOBOT_TOKEN=""           # access_token（可选）
export GOBOT_QQ=""              # 推送目标，user_id=123 或 group_id=456（必填）

## 16. 微加机器人
## 官方网站：http://www.weplusbot.com
export WE_PLUS_BOT_TOKEN=""     # 微加机器人令牌（必填）
export WE_PLUS_BOT_RECEIVER=""  # 消息接收人（可选）
export WE_PLUS_BOT_VERSION=""   # 版本：pro/personal，默认 pro

## 17. 智能微秘书（aibotk）
## 官方网站：http://wechat.aibotk.com
export AIBOTK_KEY=""            # 智能微秘书 apikey（必填）
export AIBOTK_TYPE=""           # 发送目标类型：room/contact（必填）
export AIBOTK_NAME=""           # 群名或用户昵称（必填）

## 18. Qmsg 酱（QQ 推送）
## 官方文档：https://qmsg.zendee.cn/docs/api/
export QMSG_KEY=""              # Qmsg 酱 key（必填）
export QMSG_TYPE=""             # 推送类型：send(私聊)/group(群聊)（必填）

## 19. Synology Chat（群晖）
export CHAT_URL=""              # Synology Chat URL，如 http://IP:PORT/webapi/***token=（必填）
export CHAT_TOKEN=""            # Chat token（必填）

## 20. wxPusher（微信推送）
## 官方文档：https://wxpusher.zjiecode.com/docs/
export WXPUSHER_APP_TOKEN=""    # wxPusher appToken（必填）
export WXPUSHER_TOPIC_IDS=""    # 主题 ID，多个用分号分隔（可选）
export WXPUSHER_UIDS=""         # 用户 ID，多个用分号分隔（可选）

## 21. SMTP（邮件通知）
## JavaScript 环境使用
export SMTP_SERVICE=""          # 邮箱服务名，如 126/163/Gmail/QQ（必填）
export SMTP_EMAIL=""            # SMTP 邮箱地址（必填）
export SMTP_PASSWORD=""         # SMTP 登录密码或特殊口令（必填）
export SMTP_NAME=""             # 收发件人姓名（可选）
export SMTP_TO=""               # 收件邮箱，默认发给自己（可选）

## Python 环境使用（如需使用 Python 脚本）
export SMTP_SERVER=""           # SMTP 服务器，如 smtp.exmail.qq.com:465
export SMTP_SSL=""              # 是否使用 SSL：true/false

## 22. 自定义 Webhook
export WEBHOOK_URL=""           # 自定义 webhook URL，支持 $title 和 $content 变量（必填）
export WEBHOOK_METHOD=""        # 请求方法：GET/POST/PUT（必填）
export WEBHOOK_CONTENT_TYPE=""  # Content-Type，如 application/json（可选）
export WEBHOOK_HEADERS=""       # 自定义请求头，多行用换行分隔（可选）
export WEBHOOK_BODY=""          # 请求体，支持 $title 和 $content 变量（可选）

## =============================================================================
## 路由配置（自定义通知路由规则）
## =============================================================================

## 全局配置
export CLAUDE_NOTIFY_TITLE="Claude Code"  # 通知标题前缀

## 事件级路由（优先级最高）
## 格式：逗号分隔的渠道列表，如 "ntfy,bark" 或 "all"（所有已配置渠道）
export CLAUDE_NOTIFY_ROUTE_STOP=""              # Stop 事件路由
export CLAUDE_NOTIFY_ROUTE_SUBAGENT_STOP=""     # SubagentStop 事件路由
export CLAUDE_NOTIFY_ROUTE_NOTIFICATION=""      # Notification 事件路由
export CLAUDE_NOTIFY_ROUTE_PRE_TOOL_USE=""      # PreToolUse 事件路由
export CLAUDE_NOTIFY_ROUTE_POST_TOOL_USE=""     # PostToolUse 事件路由
export CLAUDE_NOTIFY_ROUTE_PRE_COMPACT=""       # PreCompact 事件路由
export CLAUDE_NOTIFY_ROUTE_USER_PROMPT_SUBMIT="" # UserPromptSubmit 事件路由

## 级别级路由
export CLAUDE_NOTIFY_ROUTE_SUCCESS="ntfy,bark"                  # 成功级别（任务完成）
export CLAUDE_NOTIFY_ROUTE_ERROR="telegram,dingtalk,feishu,ntfy" # 错误级别（执行失败）
export CLAUDE_NOTIFY_ROUTE_ATTENTION="telegram,bark,dingtalk,feishu" # 需关注级别（需要确认）
export CLAUDE_NOTIFY_ROUTE_WARN="ntfy,telegram"                # 警告级别
export CLAUDE_NOTIFY_ROUTE_INFO="ntfy"                         # 信息级别

## 全局默认路由（当上述都未匹配时使用）
export CLAUDE_NOTIFY_ROUTE_DEFAULT=""

## =============================================================================
## 其他配置
## =============================================================================

## 一言（随机句子）
export HITOKOTO="false"         # 是否在通知末尾添加一言，true/false（默认关闭）

## 跳过推送的标题（多个用换行分隔）
export SKIP_PUSH_TITLE=""       # 包含这些标题的通知不推送，如 "调试\n测试\ndraft"
