# MCP Notify Hook 快速入门

## 3 分钟快速配置

### 步骤 1：克隆仓库

```bash
git clone https://github.com/zengwenliang416/claude-notifier.git
cd claude-notifier
```

### 步骤 2：配置通知渠道

编辑 `~/.claude/settings.json`，添加 `env` 字段：

**推荐：ntfy（最简单，无需注册）**

```json
{
  "env": {
    "NTFY_TOPIC": "claude-notify-yourname"
  }
}
```

然后：
1. 手机安装 ntfy App（[iOS](https://apps.apple.com/app/ntfy/id1625396347) / [Android](https://play.google.com/store/apps/details?id=io.heckel.ntfy)）
2. 订阅你设置的 topic（如 `claude-notify-yourname`）

**或者：Bark（iOS 用户推荐）**

```json
{
  "env": {
    "BARK_PUSH": "ABC123DEF"
  }
}
```

（从 Bark App 复制设备码，只填设备码部分，不含 URL）

**或者：Telegram（全平台）**

```json
{
  "env": {
    "TG_BOT_TOKEN": "your-bot-token",
    "TG_USER_ID": "your-chat-id"
  }
}
```

**查看所有支持的渠道**：参考 [config.sample.sh](../config.sample.sh)（仅供查看，列出所有可用环境变量）

### 步骤 3：配置 Claude Code Hook

在同一个 `~/.claude/settings.json` 文件中添加 `hooks` 字段：

```json
{
  "env": {
    "NTFY_TOPIC": "your-topic"
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

**重要**：将 `/绝对路径/` 替换为实际路径：
- Linux/macOS: `/home/username/claude-notifier/`
- Windows WSL: `/mnt/c/Users/username/claude-notifier/`

### 步骤 4：测试

```bash
# 方式一：运行测试脚本（需要先配置环境变量）
export NTFY_TOPIC="your-topic"  # 或其他渠道变量
./test-mcp-notify.sh

# 方式二：手动测试
echo '{"hook_event_name":"Stop","cwd":"'$(pwd)'","message":"测试通知"}' | ./scripts/mcp-notify-hook.sh
```

检查手机，应该收到测试通知了！

## 配置方式说明

### 方式一：settings.json（推荐）

```json
{
  "env": {
    "NTFY_TOPIC": "your-topic",
    "BARK_PUSH": "your-key",
    "CLAUDE_NOTIFY_ROUTE_SUCCESS": "bark",
    "CLAUDE_NOTIFY_ROUTE_ERROR": "all"
  }
}
```

**优点**：
- ✅ 配置集中管理
- ✅ 自动加载，无需手动 source
- ✅ 与 Hook 配置在同一文件

### 方式二：系统环境变量

```bash
# ~/.bashrc 或 ~/.zshrc
export NTFY_TOPIC="your-topic"
export BARK_PUSH="your-key"
```

**优点**：
- ✅ 全局可用
- ✅ 适合多项目共享

### ❌ 不推荐：config.sh 文件

`config.sh` 文件已**废弃**，仅作为环境变量参考文档：
- ❌ 不用于实际配置
- ✅ 仅供查看有哪些可配置的环境变量
- ✅ 查看各渠道需要哪些参数

## 常用场景配置

### 场景 1：只想在任务完成时收通知

```json
{
  "env": {
    "NTFY_TOPIC": "your-topic"
  },
  "hooks": {
    "Stop": [...]  // 只配置 Stop 事件
  }
}
```

### 场景 2：错误才通知，成功不打扰

```json
{
  "env": {
    "NTFY_TOPIC": "your-topic",
    "CLAUDE_NOTIFY_ROUTE_SUCCESS": "",
    "CLAUDE_NOTIFY_ROUTE_ERROR": "all"
  }
}
```

### 场景 3：同时推送到手机和 Telegram

```json
{
  "env": {
    "BARK_PUSH": "your-device-key",
    "TG_BOT_TOKEN": "your-token",
    "TG_USER_ID": "your-id"
  }
}
```

### 场景 4：企业团队（钉钉 + 飞书）

```json
{
  "env": {
    "DD_BOT_TOKEN": "your-dd-token",
    "DD_BOT_SECRET": "your-dd-secret",
    "FSKEY": "your-fs-key",
    "CLAUDE_NOTIFY_ROUTE_ERROR": "dingtalk,feishu"
  }
}
```

## 支持的渠道

| 渠道 | 配置难度 | 必需环境变量 | 推荐场景 |
|------|---------|-------------|----------|
| **ntfy** | ⭐ 最简单 | `NTFY_TOPIC` | 跨平台、快速测试 |
| **Bark** | ⭐ 简单 | `BARK_PUSH` | iOS 用户 |
| **Telegram** | ⭐⭐ | `TG_BOT_TOKEN`, `TG_USER_ID` | 全平台 |
| 钉钉 | ⭐⭐ | `DD_BOT_TOKEN`, `DD_BOT_SECRET` | 企业 |
| 飞书 | ⭐⭐ | `FSKEY` | 企业 |
| 企业微信 | ⭐⭐ | `QYWX_KEY` | 企业 |
| Server 酱 | ⭐ | `PUSH_KEY` | 微信推送 |
| PushPlus | ⭐ | `PUSH_PLUS_TOKEN` | 微信推送 |

**查看全部 20+ 渠道**：查看 [notify.js](../notify.js) 源码或 [config.sample.sh](../config.sample.sh) 参考文档

## 故障排查

### 没收到通知？

1. **检查环境变量是否正确**：
   ```bash
   # 在终端运行 Claude Code，观察启动日志
   # 或者检查 settings.json 的 env 字段
   cat ~/.claude/settings.json | jq .env
   ```

2. **手动测试推送**：
   ```bash
   export NTFY_TOPIC="your-topic"
   node -e "const {sendNotify}=require('./notify.js'); sendNotify('测试', '这是测试消息')"
   ```

3. **查看错误日志**：
   运行测试脚本查看详细错误：
   ```bash
   ./test-mcp-notify.sh
   ```

### Hook 没触发？

1. 确认 `settings.json` 中的路径是**绝对路径**
2. 确认脚本有执行权限：`chmod +x scripts/mcp-notify-hook.sh`
3. 重启 Claude Code 会话

### 推送失败？

1. **ntfy**: 检查 topic 名称是否正确
2. **Bark**: 检查设备码是否正确（不含 URL）
3. **Telegram**: 检查 bot token 和 chat ID 是否匹配
4. **网络**: 某些服务（如 Telegram）可能需要代理

## 下一步

- 📖 阅读[完整文档](MCP_NOTIFY_HOOK.md)了解高级路由配置
- 🎯 探索更多 Hook 事件类型（Notification、PreToolUse 等）
- 🔔 配置多个渠道实现重要性分级推送

## 获取帮助

- 问题反馈：[GitHub Issues](https://github.com/zengwenliang416/claude-notifier/issues)
- 讨论交流：[GitHub Discussions](https://github.com/zengwenliang416/claude-notifier/discussions)
