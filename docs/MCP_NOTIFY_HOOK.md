# MCP Notify Hook 使用文档

## 概述

MCP Notify Hook 是一个智能通知路由系统，根据 Claude Code Hook 事件类型和级别，将通知路由到不同渠道（支持 20+ 渠道）。

## 架构

```
Claude Code Hook 事件 → mcp-notify-hook.sh → mcp-notify.js → notify.js → 多渠道并行发送
                        (读取环境变量)      (路由逻辑)     (发送逻辑)
```

**核心组件**：
- `notify.js` - 多渠道推送库（决定支持哪些渠道）
- `mcp-notify.js` - 路由逻辑（根据事件类型选择渠道）
- `mcp-notify-hook.sh` - Hook 入口脚本
- `config.sample.sh` - **仅作参考**，列出所有可配置的环境变量

## 核心特性

1. **智能路由**：根据事件类型和级别自动选择推送渠道
2. **多渠道并行**：同时推送到多个渠道，互不阻塞
3. **项目识别**：通知中自动显示项目名称
4. **灵活配置**：支持事件级、级别级、全局默认三层路由规则
5. **渠道过滤**：自动屏蔽未配置的渠道环境变量

## 配置方式

### 推荐：settings.json（方式一）

编辑 `~/.claude/settings.json`：

```json
{
  "env": {
    "NTFY_TOPIC": "your-topic",
    "BARK_PUSH": "your-device-key",
    "TG_BOT_TOKEN": "your-bot-token",
    "TG_USER_ID": "your-chat-id",
    "CLAUDE_NOTIFY_ROUTE_SUCCESS": "bark",
    "CLAUDE_NOTIFY_ROUTE_ERROR": "all"
  },
  "hooks": {
    "Stop": [{
      "matcher": "",
      "hooks": [{
        "type": "command",
        "command": "/绝对路径/claude-notifier/scripts/mcp-notify-hook.sh"
      }]
    }]
  }
}
```

**优点**：
- ✅ 配置集中，env 和 hooks 在同一文件
- ✅ 自动加载，无需手动 source
- ✅ Claude Code 官方推荐方式

### 备选：系统环境变量（方式二）

在 `~/.bashrc` 或 `~/.zshrc` 中：

```bash
# 渠道配置
export NTFY_TOPIC="your-topic"
export BARK_PUSH="your-device-key"

# 路由配置
export CLAUDE_NOTIFY_ROUTE_SUCCESS="bark"
export CLAUDE_NOTIFY_ROUTE_ERROR="all"
```

然后配置 Hook（在 `~/.claude/settings.json` 中）：

```json
{
  "hooks": {
    "Stop": [{
      "matcher": "",
      "hooks": [{
        "type": "command",
        "command": "/绝对路径/claude-notifier/scripts/mcp-notify-hook.sh"
      }]
    }]
  }
}
```

**优点**：
- ✅ 全局可用，所有项目共享
- ✅ 适合已有环境变量管理的用户

### ❌ 不推荐：config.sh 文件

`config.sh` 文件**已废弃**，仅作为环境变量参考文档：
- ❌ 不用于实际配置
- ✅ 仅供查看有哪些可配置的环境变量
- ✅ 查看各渠道需要哪些参数

## Hook 事件类型

| 事件 | 触发时机 | 默认级别 | 推荐用途 |
|------|---------|---------|----------|
| `Stop` | 主任务完成 | success | 任务完成通知 |
| `SubagentStop` | 子任务完成 | success | 子任务完成通知 |
| `Notification` | 需要用户确认 | attention/info | 等待确认提醒 |
| `PreToolUse` | 工具执行前 | info | 工具执行预警 |
| `PostToolUse` | 工具执行后 | success/error | 工具结果通知 |
| `PreCompact` | 上下文压缩前 | warn | 压缩警告 |
| `UserPromptSubmit` | 用户提交提示 | info | 提示提交记录 |

## 支持的渠道

由 `notify.js` 支持的 20+ 渠道（部分列表）：

| 渠道 | 环境变量 | 说明 |
|------|---------|------|
| **ntfy** | `NTFY_TOPIC` | 最简单，无需注册 |
| **Bark** | `BARK_PUSH` | iOS 推荐 |
| **Telegram** | `TG_BOT_TOKEN`, `TG_USER_ID` | 全平台，功能强大 |
| **钉钉** | `DD_BOT_TOKEN`, `DD_BOT_SECRET` | 企业 IM |
| **飞书** | `FSKEY`, `FSSECRET`（可选） | 企业 IM |
| **企业微信** | `QYWX_KEY` | 企业 IM |
| **Server 酱** | `PUSH_KEY` | 微信推送 |
| **PushPlus** | `PUSH_PLUS_TOKEN` | 微信推送 |
| **gotify** | `GOTIFY_URL`, `GOTIFY_TOKEN` | 自托管 |
| **SMTP** | `SMTP_SERVICE`, `SMTP_EMAIL`, `SMTP_PASSWORD` | 邮件 |

**查看全部渠道**：
- 查看 [notify.js](../notify.js) 源码
- 参考 [config.sample.sh](../config.sample.sh)

## 路由规则

### 级别分类

系统自动将事件分为 5 个级别：

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

在 `~/.claude/settings.json` 的 `env` 字段中配置：

```json
{
  "env": {
    // 事件级路由（优先级最高）
    "CLAUDE_NOTIFY_ROUTE_STOP": "bark",
    "CLAUDE_NOTIFY_ROUTE_NOTIFICATION": "telegram",

    // 级别级路由
    "CLAUDE_NOTIFY_ROUTE_SUCCESS": "ntfy,bark",
    "CLAUDE_NOTIFY_ROUTE_ERROR": "telegram,dingtalk,feishu,ntfy",
    "CLAUDE_NOTIFY_ROUTE_ATTENTION": "telegram,bark",
    "CLAUDE_NOTIFY_ROUTE_WARN": "ntfy,telegram",
    "CLAUDE_NOTIFY_ROUTE_INFO": "ntfy",

    // 全局默认路由（当前面都未匹配时使用）
    "CLAUDE_NOTIFY_ROUTE_DEFAULT": "ntfy",

    // 特殊值 "all" 表示所有已配置渠道
    "CLAUDE_NOTIFY_ROUTE_ERROR": "all"
  }
}
```

### 路由示例

**示例 1：任务完成只推送到 iOS**

```json
{
  "env": {
    "BARK_PUSH": "your-key",
    "CLAUDE_NOTIFY_ROUTE_SUCCESS": "bark"
  }
}
```

**示例 2：错误推送所有渠道，成功只推 ntfy**

```json
{
  "env": {
    "NTFY_TOPIC": "your-topic",
    "BARK_PUSH": "your-key",
    "TG_BOT_TOKEN": "your-token",
    "TG_USER_ID": "your-id",
    "CLAUDE_NOTIFY_ROUTE_SUCCESS": "ntfy",
    "CLAUDE_NOTIFY_ROUTE_ERROR": "all"
  }
}
```

**示例 3：不同事件不同渠道**

```json
{
  "env": {
    "BARK_PUSH": "your-key",
    "NTFY_TOPIC": "your-topic",
    "TG_BOT_TOKEN": "your-token",
    "TG_USER_ID": "your-id",
    "CLAUDE_NOTIFY_ROUTE_STOP": "bark",
    "CLAUDE_NOTIFY_ROUTE_SUBAGENT_STOP": "ntfy",
    "CLAUDE_NOTIFY_ROUTE_NOTIFICATION": "telegram"
  }
}
```

## 通知格式

### 标题格式

```
{CLAUDE_NOTIFY_TITLE} · {项目名称}
```

例如：`Claude Code · claude-notifier`

可通过环境变量自定义标题：

```json
{
  "env": {
    "CLAUDE_NOTIFY_TITLE": "AI 助手"
  }
}
```

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

### 运行测试

```bash
# 确保已配置环境变量
export NTFY_TOPIC="your-topic"  # 或在 settings.json 中配置

# 运行测试脚本
./test-mcp-notify.sh
```

### 手动测试

```bash
# 测试 Stop 事件
echo '{"hook_event_name":"Stop","cwd":"/home/test","message":"测试完成"}' | ./scripts/mcp-notify-hook.sh

# 测试错误事件
echo '{"hook_event_name":"PostToolUse","tool_response":{"success":false,"error":"测试错误"},"cwd":"/home/test"}' | ./scripts/mcp-notify-hook.sh

# 测试通知库
node -e "const {sendNotify}=require('./notify.js'); sendNotify('测试', '这是测试消息')"
```

## 高级用法

### 1. 禁用一言

在 `~/.claude/settings.json` 的 `env` 中：

```json
{
  "env": {
    "HITOKOTO": "false"
  }
}
```

### 2. 跳过特定标题

```json
{
  "env": {
    "SKIP_PUSH_TITLE": "调试测试\n临时任务\ndraft"
  }
}
```

（用 `\n` 分隔多个标题）

### 3. 调试模式

查看 Hook 输出：

```bash
# 方式一：直接运行测试
./test-mcp-notify.sh

# 方式二：查看实际 Hook 输出
echo '{"hook_event_name":"Stop","cwd":"test","message":"test"}' | ./scripts/mcp-notify-hook.sh 2>&1
```

## 故障排查

### 1. Hook 未触发

检查：
- `~/.claude/settings.json` 中 Hook 配置是否正确
- 脚本路径是否为绝对路径
- 脚本是否有执行权限 (`chmod +x`)
- 重启 Claude Code 会话

### 2. 通知未发送

检查：
- 环境变量是否正确配置（在 `settings.json` 的 `env` 中或系统环境变量）
- 渠道凭据是否正确
- 网络是否可访问推送服务（如 Telegram 需要代理）
- 查看终端输出的错误信息

验证环境变量：

```bash
# 检查 settings.json
cat ~/.claude/settings.json | jq .env

# 或检查系统环境变量
env | grep NTFY_TOPIC
```

### 3. 路由不符合预期

检查：
- 环境变量优先级（事件 > 级别 > 默认）
- 环境变量名称是否正确（区分大小写）
- 是否配置在 `settings.json` 的 `env` 字段中

### 4. 消息被截断

某些渠道有长度限制：
- Telegram: 4096 字符
- 钉钉: 20000 字符
- 企业微信: 2048 字节（中文约 680 字）

`mcp-notify.js` 会自动截断超长消息到 300 字符。

## 常见问题

**Q: config.sh 文件还需要吗？**

A: 不需要。`config.sh` 仅作为环境变量参考文档，实际配置应使用 `~/.claude/settings.json` 的 `env` 字段或系统环境变量。

**Q: 可以只启用一个渠道吗？**

A: 可以。只需在 `settings.json` 的 `env` 中配置一个渠道的环境变量即可。

**Q: 如何实现"成功静默，失败告警"？**

A: 配置：
```json
{
  "env": {
    "CLAUDE_NOTIFY_ROUTE_SUCCESS": "",
    "CLAUDE_NOTIFY_ROUTE_ERROR": "all"
  }
}
```

**Q: 多个项目如何配置不同的路由？**

A: 可以使用系统环境变量（全局）或在各项目的 Hook 命令中传递不同的环境变量。

**Q: Hook 会影响 Claude Code 性能吗？**

A: 不会。通知推送是异步并行的，不会阻塞 Claude 的响应。

## 许可证

MIT License
