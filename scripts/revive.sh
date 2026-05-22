#!/bin/bash
# revive.sh — 在新机器上复活小艾
# ============================================================
# 用法：
#   1. clone 这个 repo
#   2. cd hermes-clone-of-xiaoai
#   3. bash scripts/revive.sh
# ============================================================
set -e

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
HERMES_DIR="${HERMES_HOME:-$HOME/.hermes}"

cyan() { printf "\033[36m%s\033[0m\n" "$1"; }
green() { printf "\033[32m%s\033[0m\n" "$1"; }
yellow() { printf "\033[33m%s\033[0m\n" "$1"; }
red() { printf "\033[31m%s\033[0m\n" "$1"; }

cyan "============================================"
cyan "  🤖 复活小艾 (hermes-clone-of-xiaoai)"
cyan "============================================"
echo
echo "这个脚本会把小艾的人格 + 记忆灌入到 $HERMES_DIR"
echo

# 0. 检查 Hermes 是否装了
if ! command -v hermes &> /dev/null; then
    red "✗ 没找到 hermes 命令"
    echo "  请先装 Hermes Agent: https://hermes-agent.nousresearch.com/docs/install"
    exit 1
fi
green "✓ Hermes 已安装: $(which hermes)"

# 1. 收集占位符的真实值
echo
yellow "请填入真实信息（直接回车跳过则保留占位符）："
echo

read -p "你的主 QQ 号 (\${OWNER_QQ})? " OWNER_QQ
read -p "机器人小号 QQ (\${BOT_QQ})? " BOT_QQ
read -p "服务器公网 IP (\${SERVER_IP})? " SERVER_IP
read -p "火山引擎 API Key (\${VOLC_ARK_API_KEY})? " VOLC_KEY
read -p "抖音昵称 (\${DOUYIN_NICKNAME})? " DOUYIN_NICK
read -p "番茄笔名 (\${FANQIE_PEN_NAME})? " PEN_NAME

# 2. 替换占位符并写入 memories
mkdir -p "$HERMES_DIR/memories"

replace_placeholders() {
    local src="$1"
    local dst="$2"
    cp "$src" "$dst.tmp"
    [ -n "$OWNER_QQ" ] && sed -i "s|\${OWNER_QQ}|$OWNER_QQ|g" "$dst.tmp"
    [ -n "$BOT_QQ" ] && sed -i "s|\${BOT_QQ}|$BOT_QQ|g" "$dst.tmp"
    [ -n "$SERVER_IP" ] && sed -i "s|\${SERVER_IP}|$SERVER_IP|g" "$dst.tmp"
    [ -n "$DOUYIN_NICK" ] && sed -i "s|\${DOUYIN_NICKNAME}|$DOUYIN_NICK|g" "$dst.tmp"
    [ -n "$PEN_NAME" ] && sed -i "s|\${FANQIE_PEN_NAME}|$PEN_NAME|g" "$dst.tmp"
    mv "$dst.tmp" "$dst"
}

echo
cyan "灌入 MEMORY.md..."
replace_placeholders "$REPO_DIR/persona/MEMORY.md" "$HERMES_DIR/memories/MEMORY.md"
green "  ✓ → $HERMES_DIR/memories/MEMORY.md"

cyan "灌入 USER.md..."
replace_placeholders "$REPO_DIR/persona/USER.md" "$HERMES_DIR/memories/USER.md"
green "  ✓ → $HERMES_DIR/memories/USER.md"

# 3. PERSONA.md → ~/.hermes/PERSONA.md（如果 Hermes 支持的话）
cyan "灌入 PERSONA.md..."
replace_placeholders "$REPO_DIR/persona/PERSONA.md" "$HERMES_DIR/PERSONA.md"
green "  ✓ → $HERMES_DIR/PERSONA.md"

# 4. 生成 .env（如果不存在）
if [ ! -f "$HERMES_DIR/.env" ]; then
    cyan "生成 .env 模板..."
    cp "$REPO_DIR/config/env-template" "$HERMES_DIR/.env"
    [ -n "$VOLC_KEY" ] && sed -i "s|ark-xxxxxxxxxxxx-xxxxx|$VOLC_KEY|g" "$HERMES_DIR/.env"
    green "  ✓ → $HERMES_DIR/.env"
else
    yellow "  ⚠ $HERMES_DIR/.env 已存在，跳过（请手动检查 VOLC_ARK_API_KEY）"
fi

# 5. 生成 config.yaml（如果不存在）
if [ ! -f "$HERMES_DIR/config.yaml" ]; then
    cyan "生成 config.yaml 模板..."
    cp "$REPO_DIR/config/hermes-config-template.yaml" "$HERMES_DIR/config.yaml"
    [ -n "$BOT_QQ" ] && sed -i "s|\${BOT_QQ}|$BOT_QQ|g" "$HERMES_DIR/config.yaml"
    [ -n "$OWNER_QQ" ] && sed -i "s|\${OWNER_QQ}|$OWNER_QQ|g" "$HERMES_DIR/config.yaml"
    green "  ✓ → $HERMES_DIR/config.yaml"
else
    yellow "  ⚠ $HERMES_DIR/config.yaml 已存在，跳过"
fi

echo
green "============================================"
green "  ✅ 小艾已复活！"
green "============================================"
echo
echo "下一步："
echo "  1. 跑 hermes chat 试试，问她'你是谁'"
echo "  2. 如果有 QQ 机器人要接：跑 hermes gateway setup"
echo "  3. 改 PERSONA/MEMORY/USER 后想同步回 repo：bash scripts/sync.sh"
