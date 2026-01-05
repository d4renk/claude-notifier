# MCP Notify Hook 使用文档

## 概述

MCP Notify Hook 是一个智能通知路由系统，可以根据 Claude Code Hook 事件类型和级别，将通知路由到不同的渠道（钉钉、Telegram、Bark、ntfy、飞书、企业微信等）。

## 架构

```
Claude Code Hook 事件 → mcp-notify-hook.sh → mcp-notify.js → notify.js → 多渠道并行发送
                        (加载配置)          (路由逻辑)     (发送逻辑)
```

## 核心特性

1. **智能路由**：根据事件类型和级别自动选择推送渠道
2. **多渠道并行**：支持同时推送到多个渠道
3. **项目识别**：通知中自动显示项目名称
4. **灵活配置**：支持事件级、级别级、全局默认三层路由规则
5. **渠道过滤**：自动屏蔽未配置的渠道环境变量

## 安装配置

### 1. 创建配置文件

复制示例配置：

```bash
cp config.sample.sh config.sh
```

编辑 `config.sh`，填入你的通知渠道凭据（至少配置一个）：

```bash
# Bark (iOS)
export BARK_PUSH="your-device-key"

# Telegram
export TG_BOT_TOKEN="your-bot-token"
export TG_USER_ID="your-chat-id"

# ntfy
export NTFY_TOPIC="your-topic"

# 钉钉
export DD_BOT_TOKEN="your-token"
export DD_BOT_SECRET="your-secret"

# 飞书
export FSKEY="your-webhook-key"
export FSSECRET="your-secret"  # 可选
```

### 2. 配置 Claude Code Hooks

编辑 `~/.claude/settings.json`，添加 Hook 配置：

```json
{
  "hooks": {
    "Notification": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "/home/sun/claude-notifier/scripts/mcp-notify-hook.sh"
          }
        ]
      }
    ],
    "Stop": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "/home/sun/claude-notifier/scripts/mcp-notify-hook.sh"
          }
        ]
      }
    ]
  }
}
```

**Hook 事件类型说明**：

- `Stop`: 主任务完成时触发
- `SubagentStop`: 子任务（Task 工具）完成时触发
- `Notification`: Claude 需要用户确认时触发
- `PreToolUse`: 工具执行前触发
- `PostToolUse`: 工具执行后触发
- `PreCompact`: 上下文压缩前触发
- `UserPromptSubmit`: 用户提交提示后触发

## 路由规则

### 级别分类

MCP Notify Hook 自动将事件分为 5 个级别：

| 级别 | 说明 | 触发条件 | 默认渠道 |
|------|------|----------|----------|
| **success** | 成功 | Stop/SubagentStop 事件 | ntfy, bark |
| **error** | 错误 | 工具执行失败、包含 error 字段 | telegram, dingtalk, feishu, ntfy |
| **attention** | 需要关注 | Notification 且包含"授权/确认/允许"等关键词 | telegram, bark, dingtalk, feishu |
| **warn** | 警告 | PreCompact 事件 | ntfy, telegram |
| **info** | 信息 | 其他 Notification 事件 | ntfy |

### 路由优先级

```
事件级路由 > 级别级路由 > 默认路由 > 内置默认
```

### 配置环境变量

在 `config.sh` 中配置：

```bash
## 全局标题
export CLAUDE_NOTIFY_TITLE="Claude Code"

## 事件级路由（优先级最高）
export CLAUDE_NOTIFY_ROUTE_STOP="bark"              # Stop 事件只推送到 Bark
export CLAUDE_NOTIFY_ROUTE_NOTIFICATION="telegram"  # Notification 只推送到 Telegram

## 级别级路由
export CLAUDE_NOTIFY_ROUTE_SUCCESS="ntfy,bark"                      # 成功推送到 ntfy + bark
export CLAUDE_NOTIFY_ROUTE_ERROR="telegram,dingtalk,feishu,ntfy"   # 错误推送到所有渠道
export CLAUDE_NOTIFY_ROUTE_ATTENTION="telegram,bark"                # 需关注推送到 telegram + bark
export CLAUDE_NOTIFY_ROUTE_WARN="ntfy,telegram"                     # 警告推送到 ntfy + telegram
export CLAUDE_NOTIFY_ROUTE_INFO="ntfy"                              # 信息只推送到 ntfy

## 全局默认路由（当前面都未匹配时使用）
export CLAUDE_NOTIFY_ROUTE_DEFAULT="ntfy"

## 特殊值 "all" 表示所有已配置渠道
export CLAUDE_NOTIFY_ROUTE_ERROR="all"
```

### 路由示例

**示例 1：任务完成只推送到 iOS**

```bash
export CLAUDE_NOTIFY_ROUTE_SUCCESS="bark"
```

**示例 2：错误推送到所有渠道，成功只推送到 ntfy**

```bash
export CLAUDE_NOTIFY_ROUTE_ERROR="all"
export CLAUDE_NOTIFY_ROUTE_SUCCESS="ntfy"
```

**示例 3：不同事件不同渠道**

```bash
export CLAUDE_NOTIFY_ROUTE_STOP="bark"           # 主任务完成推送到手机
export CLAUDE_NOTIFY_ROUTE_SUBAGENT_STOP="ntfy"  # 子任务完成推送到 ntfy
export CLAUDE_NOTIFY_ROUTE_NOTIFICATION="telegram,dingtalk"  # 需确认时推送到 IM
```

## 通知格式

### 标题格式

```
{CLAUDE_NOTIFY_TITLE} · {项目名称}
```

例如：`Claude Code · claude-notifier`

### 消息格式

**任务完成**：
```
任务已完成
Project: claude-notifier
```

**需要确认**：
```
需要您的授权才能继续
Project: auth-demo
```

**工具失败**：
```
工具完成: Bash
Tool failed
Error: Command exited with code 1
Project: test-project
```

## 测试

### 运行测试脚本

```bash
./test-mcp-notify.sh
```

测试脚本会模拟 6 个场景：
1. Stop 事件（成功）
2. SubagentStop 事件（成功）
3. 工具失败事件（错误）
4. 需要确认事件（attention）
5. 上下文压缩事件（警告）
6. 自定义路由事件

### 手动测试

```bash
# 测试 Stop 事件
echo '{"hook_event_name":"Stop","cwd":"/home/test","message":"测试完成"}' | ./scripts/mcp-notify-hook.sh

# 测试错误事件
echo '{"hook_event_name":"PostToolUse","tool_response":{"success":false,"error":"测试错误"},"cwd":"/home/test"}' | ./scripts/mcp-notify-hook.sh
```

## 高级用法

### 1. 禁用一言

在 `config.sh` 中设置：

```bash
export HITOKOTO="false"
```

### 2. 跳过特定标题

```bash
export SKIP_PUSH_TITLE="调试测试
临时任务
draft"
```

### 3. 自定义环境变量路径

```bash
export CLAUDE_NOTIFY_CONFIG=/path/to/your/config.sh
./scripts/mcp-notify-hook.sh
```

### 4. 调试模式

查看 Hook 输出：

```bash
# 在 settings.json 中添加
{
  "hooks": {
    "Stop": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "/home/sun/claude-notifier/scripts/mcp-notify-hook.sh 2>&1 | tee /tmp/hook.log"
          }
        ]
      }
    ]
  }
}
```

## 支持的渠道

| 渠道 | 配置复杂度 | 推荐场景 | 状态 |
|------|------------|----------|------|
| **ntfy** | 低（只需 topic） | 快速测试、跨平台 | ✅ 推荐 |
| **Bark** | 低（只需 device key） | iOS 用户 | ✅ 推荐 |
| **Telegram** | 中（需创建 bot） | 全平台、重要通知 | ✅ 推荐 |
| **钉钉** | 中（需创建机器人） | 企业团队 | ✅ 已测试 |
| **飞书** | 中（需创建机器人） | 企业团队 | ✅ 已测试 |
| **企业微信** | 中（需创建应用） | 企业团队 | ✅ 已测试 |
| Server 酱 | 低 | 微信推送 | ✅ 支持 |
| PushPlus | 低 | 微信推送 | ✅ 支持 |

完整配置参考：[config.sample.sh](../config.sample.sh)

## 故障排查

### 1. Hook 未触发

检查：
- `~/.claude/settings.json` 中 Hook 配置是否正确
- 脚本路径是否为绝对路径
- 脚本是否有执行权限 (`chmod +x`)

### 2. 通知未发送

检查：
- `config.sh` 中凭据是否正确
- 网络是否可访问推送服务（如 Telegram 需要代理）
- 查看终端输出的错误信息

### 3. 路由不符合预期

检查：
- 环境变量优先级（事件 > 级别 > 默认）
- 环境变量名称是否正确（区分大小写）
- 使用 `echo` 验证环境变量值

```bash
source config.sh
echo $CLAUDE_NOTIFY_ROUTE_SUCCESS
```

### 4. 消息被截断

某些渠道有长度限制：
- Telegram: 4096 字符
- 钉钉: 20000 字符
- 企业微信: 2048 字节（中文约 680 字）

`mcp-notify.js` 会自动截断超长消息到 300 字符。

## 常见问题

**Q: 为什么测试时除了 ntfy 其他都失败？**

A: 测试配置使用的是虚拟凭据。请在 `config.sh` 中填入真实凭据后再测试。

**Q: 可以只启用一个渠道吗？**

A: 可以。只需在 `config.sh` 中配置一个渠道的环境变量即可。

**Q: 如何实现"成功静默，失败告警"？**

A: 配置：
```bash
export CLAUDE_NOTIFY_ROUTE_SUCCESS=""        # 成功不推送
export CLAUDE_NOTIFY_ROUTE_ERROR="all"       # 错误推送所有渠道
```

**Q: 多个项目如何配置不同的路由？**

A: 可以在项目目录下创建 `.clauderc` 或使用项目级别的环境变量配置。

**Q: Hook 会影响 Claude Code 性能吗？**

A: 不会。通知推送是异步并行的，不会阻塞 Claude 的响应。

## 贡献

欢迎提交 Issue 和 Pull Request！

## 许可证

MIT License
