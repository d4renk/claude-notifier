# Claude Notifier - Linux 版本

Linux 下使用多渠道推送（无需桌面通知）。

## 一键安装

```bash
git clone https://github.com/zengwenliang416/claude-notifier.git
cd claude-notifier
./install-linux.sh
```

安装脚本会：
- ✅ 检查 Node.js 环境
- ✅ 安装文件到 `~/.claude/notifier/`
- ✅ 安装 undici 依赖
- ✅ 创建配置文件模板
- ✅ 配置环境变量

## 系统要求

- **Node.js**: 14.0+
- **系统**: 任何 Linux 发行版（Ubuntu/Debian/CentOS/Arch 等）

安装 Node.js：
```bash
# Ubuntu/Debian
sudo apt install nodejs npm

# CentOS/RHEL
sudo yum install nodejs npm

# Arch
sudo pacman -S nodejs npm

# 或使用 nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
nvm install --lts
```

## 快速配置

### 1. 配置通知渠道

编辑 `~/.claude/notifier/config.sh`：

**推荐：ntfy（最简单）**
```bash
export NTFY_TOPIC="your-unique-topic"
```

然后在手机安装 [ntfy App](https://ntfy.sh/) 并订阅该 topic。

**其他渠道**：
```bash
# Bark (iOS)
export BARK_PUSH="your-device-key"

# Telegram
export TG_BOT_TOKEN="your-bot-token"
export TG_USER_ID="your-chat-id"

# 钉钉
export DD_BOT_TOKEN="your-token"
export DD_BOT_SECRET="your-secret"
```

### 2. 配置 Claude Code Hook

编辑 `~/.claude/settings.json`：

```json
{
  "hooks": {
    "Stop": [{
      "matcher": "",
      "hooks": [{
        "type": "command",
        "command": "/home/你的用户名/.claude/notifier/mcp-notify-hook.sh"
      }]
    }]
  }
}
```

**重要**：将路径替换为你的实际用户名。

### 3. 测试

```bash
cd ~/.claude/notifier
echo '{"hook_event_name":"Stop","cwd":"test","message":"测试通知"}' | ./mcp-notify-hook.sh
```

检查手机，应该收到测试通知了！

## 支持的渠道

| 渠道 | 难度 | 推荐场景 |
|------|------|----------|
| **ntfy** | ⭐ 最简单 | 跨平台、无需注册 |
| **Telegram** | ⭐⭐ | 全平台、功能强大 |
| **钉钉** | ⭐⭐ | 企业团队 |
| **飞书** | ⭐⭐ | 企业团队 |

支持 20+ 渠道，完整列表见 [config.sample.sh](../config.sample.sh)

## 智能路由

根据事件类型自动选择渠道：

- **成功**（任务完成）→ ntfy
- **错误**（执行失败）→ telegram, dingtalk, feishu, ntfy
- **需关注**（需确认）→ telegram, dingtalk, feishu

自定义路由：
```bash
# 在 config.sh 中配置
export CLAUDE_NOTIFY_ROUTE_SUCCESS="telegram"  # 成功推 Telegram
export CLAUDE_NOTIFY_ROUTE_ERROR="all"         # 错误推所有渠道
```

## 手动安装

如果不想用安装脚本：

```bash
# 1. 克隆仓库
git clone https://github.com/zengwenliang416/claude-notifier.git
cd claude-notifier

# 2. 安装依赖
npm install undici

# 3. 配置
cp config.sample.sh config.sh
vim config.sh

# 4. 配置 Hook
vim ~/.claude/settings.json
# 添加指向 scripts/mcp-notify-hook.sh 的 Hook

# 5. 测试
./test-mcp-notify.sh
```

## 故障排查

### 没收到通知？

1. 检查 Node.js：`node -v`
2. 检查依赖：`ls node_modules/undici`
3. 检查配置：`cat config.sh | grep NTFY_TOPIC`
4. 手动测试：`./test-mcp-notify.sh`

### Hook 没触发？

1. 检查路径是否为绝对路径
2. 检查脚本权限：`chmod +x scripts/mcp-notify-hook.sh`
3. 重启 Claude Code 会话

## 卸载

```bash
rm -rf ~/.claude/notifier
# 手动从 ~/.bashrc 或 ~/.zshrc 删除 CLAUDE_NOTIFY_CONFIG 环境变量
# 手动从 ~/.claude/settings.json 删除 Hook 配置
```

## 文档

- 📖 [快速入门](../docs/QUICK_START.md)
- 📚 [完整文档](../docs/MCP_NOTIFY_HOOK.md)
- 📁 [文档中心](../docs/README.md)

## 许可证

MIT License
