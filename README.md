<p align="center">
  <img src="images/banner-2k.png" alt="ClaudeNotifier Banner" width="800"/>
</p>

<p align="center">
  <a href="claude-notifier-macos/"><img src="https://img.shields.io/badge/macOS-12.0+-blue?style=flat-square&logo=apple" alt="macOS 12.0+"/></a>
  <a href="claude-notifier-windows/"><img src="https://img.shields.io/badge/Windows-10+-0078D6?style=flat-square&logo=windows" alt="Windows 10+"/></a>
  <a href="#linux-多渠道推送"><img src="https://img.shields.io/badge/Linux-推送-orange?style=flat-square&logo=linux" alt="Linux"/></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-green?style=flat-square" alt="MIT License"/></a>
</p>

<p align="center">
  <b>Claude Code 任务完成时发送通知 + 语音提醒</b>
</p>

---

## 解决什么问题

多窗口并行运行 Claude Code 时，任务完成后不知道 → 浪费 AI 使用时间。

**方案**：通过 Claude Code Hooks 自动发送通知，支持桌面通知 + 手机推送。

<p align="center">
  <img src="images/notification-mockup.png" alt="通知效果" width="600"/>
</p>

## 快速开始

### 方式一：桌面通知（macOS/Windows）

**macOS**:
```bash
cd claude-notifier-macos && make install
```

**Windows**:
```powershell
cargo build --release
.\target\release\claude-notifier.exe --init
```

详见：[macOS 文档](claude-notifier-macos/README.md) | [Windows 文档](claude-notifier-windows/README.md)

### 方式二：多渠道推送（所有平台通用）

支持 ntfy、Bark、Telegram、钉钉、飞书等 20+ 渠道，智能路由到不同平台。

**1. 配置渠道凭据** - 编辑 `~/.claude/settings.json`：

```json
{
  "env": {
    "NTFY_TOPIC": "your-topic",
    "BARK_PUSH": "your-device-key",
    "TG_BOT_TOKEN": "your-bot-token",
    "TG_USER_ID": "your-chat-id"
  }
}
```

> 💡 也可以配置在系统环境变量（`~/.bashrc`/`~/.zshrc`）中

**2. 配置 Hook** - 在同一文件中添加：

```json
{
  "env": { ... },
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

**3. 测试**：
```bash
./test-mcp-notify.sh
```

## 核心特性

### 智能路由
根据事件类型自动选择渠道：
- **成功**（任务完成）→ ntfy, bark
- **错误**（执行失败）→ telegram, dingtalk, feishu, ntfy
- **需关注**（需要确认）→ telegram, bark, dingtalk, feishu

### 支持渠道

由 `notify.js` 支持的 20+ 渠道（查看 [notify.js](notify.js) 源码了解全部渠道）：

| 渠道 | 难度 | 环境变量 | 适用场景 |
|------|------|----------|----------|
| **ntfy** | ⭐ 最简单 | `NTFY_TOPIC` | 跨平台、无需注册 |
| **Bark** | ⭐ 简单 | `BARK_PUSH` | iOS 用户 |
| **Telegram** | ⭐⭐ | `TG_BOT_TOKEN`, `TG_USER_ID` | 全平台、功能强大 |
| 钉钉 | ⭐⭐ | `DD_BOT_TOKEN`, `DD_BOT_SECRET` | 企业团队 |
| 飞书 | ⭐⭐ | `FSKEY` | 企业团队 |
| 企业微信 | ⭐⭐ | `QYWX_KEY` | 企业团队 |

**查看所有支持的渠道**：参考 [config.sample.sh](config.sample.sh)（仅供参考，不用于实际配置）

### 配置方式

**推荐方式一**：在 `~/.claude/settings.json` 中配置
```json
{
  "env": {
    "NTFY_TOPIC": "your-topic",
    "BARK_PUSH": "your-device-key",
    "CLAUDE_NOTIFY_ROUTE_SUCCESS": "bark",
    "CLAUDE_NOTIFY_ROUTE_ERROR": "all"
  }
}
```

**方式二**：系统环境变量
```bash
# ~/.bashrc 或 ~/.zshrc
export NTFY_TOPIC="your-topic"
export BARK_PUSH="your-device-key"
```

### 自定义路由

在 `~/.claude/settings.json` 的 `env` 中配置：
```json
{
  "env": {
    "CLAUDE_NOTIFY_ROUTE_SUCCESS": "bark",
    "CLAUDE_NOTIFY_ROUTE_ERROR": "all",
    "CLAUDE_NOTIFY_ROUTE_ATTENTION": "telegram,bark"
  }
}
```

## 文档

- 📖 [5 分钟快速入门](docs/QUICK_START.md)
- 📚 [完整配置文档](docs/MCP_NOTIFY_HOOK.md)
- 📁 [文档中心](docs/README.md)

## 项目结构

```
claude-notifier/
├── claude-notifier-macos/    # macOS 原生通知（Swift）
├── claude-notifier-windows/  # Windows 原生通知（Rust）
├── scripts/                  # MCP Hook 脚本
│   ├── mcp-notify-hook.sh   # Hook 入口
│   └── mcp-notify.js        # 路由逻辑
├── notify.js                 # 多渠道推送库（20+ 渠道）
├── config.sample.sh          # 环境变量参考（仅供查看）
└── docs/                     # 文档
```

**重要说明**：
- `notify.js` 决定支持哪些渠道
- `config.sample.sh` 仅作为环境变量参考文档，不用于实际配置
- 实际配置应使用 `~/.claude/settings.json` 的 `env` 字段

## License

MIT License
