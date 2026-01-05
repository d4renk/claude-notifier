#!/bin/bash
# Claude Notifier - Linux 安装脚本（仅多渠道推送）

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="${INSTALL_DIR:-$HOME/.claude/notifier}"

echo "=========================================="
echo "Claude Notifier - Linux 安装"
echo "=========================================="
echo ""

# 检查 Node.js
if ! command -v node &>/dev/null; then
    echo "❌ 错误：未检测到 Node.js"
    echo ""
    echo "请先安装 Node.js："
    echo "  Ubuntu/Debian: sudo apt install nodejs npm"
    echo "  CentOS/RHEL:   sudo yum install nodejs npm"
    echo "  Arch:          sudo pacman -S nodejs npm"
    echo "  或访问：https://nodejs.org/"
    exit 1
fi

NODE_VERSION=$(node -v)
echo "✅ Node.js 版本：$NODE_VERSION"
echo ""

# 创建安装目录
echo "📁 创建安装目录：$INSTALL_DIR"
mkdir -p "$INSTALL_DIR"

# 复制核心文件
echo "📋 复制文件..."
cp "$SCRIPT_DIR/notify.js" "$INSTALL_DIR/"
cp "$SCRIPT_DIR/scripts/mcp-notify-hook.sh" "$INSTALL_DIR/"
cp "$SCRIPT_DIR/scripts/mcp-notify.js" "$INSTALL_DIR/"
cp "$SCRIPT_DIR/config.sample.sh" "$INSTALL_DIR/"
chmod +x "$INSTALL_DIR/mcp-notify-hook.sh"

# 安装 Node.js 依赖
echo "📦 安装依赖 (undici)..."
cd "$INSTALL_DIR"
if command -v npm &>/dev/null; then
    npm install --no-save undici 2>&1 | grep -v "npm WARN" || true
elif command -v yarn &>/dev/null; then
    yarn add --no-lockfile undici
else
    echo "⚠️  警告：未找到 npm 或 yarn，请手动安装 undici："
    echo "  cd $INSTALL_DIR && npm install undici"
fi

# 创建配置文件（如果不存在）
if [[ ! -f "$INSTALL_DIR/config.sh" ]]; then
    echo "⚙️  创建配置文件..."
    cp "$INSTALL_DIR/config.sample.sh" "$INSTALL_DIR/config.sh"
    echo ""
    echo "请编辑配置文件以添加你的通知渠道："
    echo "  vim $INSTALL_DIR/config.sh"
    echo ""
    echo "推荐配置："
    echo "  - ntfy（最简单）：export NTFY_TOPIC=\"your-topic\""
    echo "  - Bark（iOS）：   export BARK_PUSH=\"your-device-key\""
    echo "  - Telegram：      export TG_BOT_TOKEN=\"...\" && export TG_USER_ID=\"...\""
fi

# 配置环境变量
echo "🔧 配置环境变量..."
SHELL_RC=""
if [[ -n "${BASH_VERSION:-}" ]]; then
    SHELL_RC="$HOME/.bashrc"
elif [[ -n "${ZSH_VERSION:-}" ]]; then
    SHELL_RC="$HOME/.zshrc"
fi

if [[ -n "$SHELL_RC" ]] && [[ -f "$SHELL_RC" ]]; then
    if ! grep -q "CLAUDE_NOTIFY_CONFIG" "$SHELL_RC" 2>/dev/null; then
        echo "" >> "$SHELL_RC"
        echo "# Claude Notifier" >> "$SHELL_RC"
        echo "export CLAUDE_NOTIFY_CONFIG=\"$INSTALL_DIR/config.sh\"" >> "$SHELL_RC"
        echo "✅ 已添加环境变量到 $SHELL_RC"
    else
        echo "✅ 环境变量已存在"
    fi
fi

# 创建 Claude Code Hook 配置示例
SETTINGS_FILE="$HOME/.claude/settings.json"
echo ""
echo "=========================================="
echo "✅ 安装完成！"
echo "=========================================="
echo ""
echo "📍 安装位置：$INSTALL_DIR"
echo ""
echo "下一步："
echo ""
echo "1️⃣  配置通知渠道："
echo "   vim $INSTALL_DIR/config.sh"
echo ""
echo "2️⃣  配置 Claude Code Hook ($SETTINGS_FILE)："
echo ""
cat <<'EOF'
{
  "hooks": {
    "Stop": [{
      "matcher": "",
      "hooks": [{
        "type": "command",
        "command": "$HOME/.claude/notifier/mcp-notify-hook.sh"
      }]
    }]
  }
}
EOF
echo ""
echo "   注意：将 \$HOME 替换为实际路径：$HOME"
echo ""
echo "3️⃣  测试通知："
echo "   cd $INSTALL_DIR"
echo "   source config.sh"
echo "   echo '{\"hook_event_name\":\"Stop\",\"cwd\":\"test\",\"message\":\"测试\"}' | ./mcp-notify-hook.sh"
echo ""
echo "📚 完整文档：https://github.com/zengwenliang416/claude-notifier"
echo ""
