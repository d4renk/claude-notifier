# MCP Notify Hook 快速入门

## 5 分钟快速配置

### 步骤 1：克隆仓库

```bash
git clone https://github.com/zengwenliang416/claude-notifier.git
cd claude-notifier
```

### 步骤 2：配置通知渠道

**推荐新手选择 ntfy（最简单，无需注册）：**

```bash
# 复制配置文件
cp config.sample.sh config.sh

# 编辑 config.sh，找到 ntfy 部分，修改 topic 为你的唯一标识
# export NTFY_TOPIC="your-unique-topic"  # 改为如：claude-notify-yourname
```

然后：
1. 手机安装 ntfy App（[iOS](https://apps.apple.com/app/ntfy/id1625396347) / [Android](https://play.google.com/store/apps/details?id=io.heckel.ntfy)）
2. 订阅你设置的 topic（如 `claude-notify-yourname`）

**或者选择 Bark（iOS 用户推荐）：**

```bash
# 1. App Store 下载 Bark
# 2. 打开 App，复制设备码（如 https://api.day.app/ABC123DEF/）
# 3. 在 config.sh 中填入：
export BARK_PUSH="ABC123DEF"  # 只填设备码部分
```

### 步骤 3：配置 Claude Code Hook

编辑 `~/.claude/settings.json`：

```json
{
  "hooks": {
    "Stop": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "/绝对路径/claude-notifier/scripts/mcp-notify-hook.sh"
          }
        ]
      }
    ]
  }
}
```

**重要**：
- 将 `/绝对路径/` 替换为你的实际路径（如 `/home/username/claude-notifier/`）
- Windows 用户使用 WSL 路径（如 `/mnt/c/Users/...`）

### 步骤 4：测试

```bash
# 运行测试脚本
./test-mcp-notify.sh

# 或手动测试
echo '{"hook_event_name":"Stop","cwd":"'$(pwd)'","message":"测试通知"}' | ./scripts/mcp-notify-hook.sh
```

检查你的手机，应该收到测试通知了！

## 常用配置

### 场景 1：只想在任务完成时收通知

```json
{
  "hooks": {
    "Stop": [...]  // 只配置 Stop 事件
  }
}
```

### 场景 2：错误才通知，成功不打扰

```bash
# 在 config.sh 中添加
export CLAUDE_NOTIFY_ROUTE_SUCCESS=""     # 成功不推送
export CLAUDE_NOTIFY_ROUTE_ERROR="all"    # 错误推送所有渠道
```

### 场景 3：同时推送到手机和电脑

```bash
# config.sh 中同时配置
export BARK_PUSH="your-device-key"        # iOS 通知
export NTFY_TOPIC="your-topic"            # 跨平台通知
```

## 支持的渠道

| 渠道 | 配置难度 | 适用场景 |
|------|---------|---------|
| **ntfy** | ⭐ 最简单 | 跨平台、快速测试 |
| **Bark** | ⭐ 简单 | iOS 用户 |
| **Telegram** | ⭐⭐ 中等 | 全平台、功能强大 |
| 钉钉/飞书/企微 | ⭐⭐ 中等 | 企业团队 |

完整渠道列表和配置方法：[docs/MCP_NOTIFY_HOOK.md](MCP_NOTIFY_HOOK.md)

## 故障排查

### 没收到通知？

1. **检查 Hook 是否生效**：
   ```bash
   # 在终端运行 Claude Code 时应该看到通知相关的日志
   ```

2. **检查配置文件路径**：
   ```bash
   cat /绝对路径/claude-notifier/config.sh
   # 应该能看到你配置的环境变量
   ```

3. **手动测试**：
   ```bash
   source config.sh
   echo $BARK_PUSH  # 或 $NTFY_TOPIC，应该有值
   ```

4. **查看错误日志**：
   ```bash
   # 测试脚本会显示详细的错误信息
   ./test-mcp-notify.sh
   ```

### Hook 没触发？

- 确认 `settings.json` 中的路径是**绝对路径**
- 确认脚本有执行权限：`chmod +x scripts/mcp-notify-hook.sh`
- 重启 Claude Code 会话

## 下一步

- 📖 阅读[完整文档](MCP_NOTIFY_HOOK.md)了解高级路由配置
- 🎯 探索更多 Hook 事件类型（Notification、PreToolUse 等）
- 🔔 配置多个渠道实现重要性分级推送

## 获取帮助

- 问题反馈：[GitHub Issues](https://github.com/zengwenliang416/claude-notifier/issues)
- 讨论交流：[GitHub Discussions](https://github.com/zengwenliang416/claude-notifier/discussions)
