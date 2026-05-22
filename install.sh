#!/bin/bash
# install.sh — 非交互安装"小艾"（hermes-clone-of-xiaoai）
# ============================================================
# 用法：
#   NONINTERACTIVE=1 OWNER_QQ=xxx BOT_QQ=yyy VOLC_ARK_API_KEY=zzz bash install.sh
#   或者交互模式：bash install.sh
# ============================================================
set -e

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
HERMES_DIR="${HERMES_HOME:-$HOME/.hermes}"

cyan() { printf "\033[36m%s\033[0m\n" "$1"; }
green() { printf "\033[32m%s\033[0m\n" "$1"; }
yellow() { printf "\033[33m%s\033[0m\n" "$1"; }
red() { printf "\033[31m%s\033[0m\n" "$1"; }

cyan "============================================"
cyan "  🤖 安装小艾 (hermes-clone-of-xiaoai)"
cyan "============================================"

# ── 1. 收集信息 ──────────────────────────────
ask() {
    local varname="$1" prompt="$2" default="${3:-}"
    if [ -n "${!varname}" ]; then
        green "  ✓ $varname = ${!varname}"
        return
    fi
    if [ "$NONINTERACTIVE" = "1" ]; then
        if [ -n "$default" ]; then
            eval "$varname=\$default"
            yellow "  ⚠ $varname 未设，用默认值: $default"
        else
            red "  ✗ $varname 必须设置！用法: $varname=xxx NONINTERACTIVE=1 bash install.sh"
            exit 1
        fi
        return
    fi
    read -p "  $prompt [$default]: " val
    eval "$varname=\${val:-\$default}"
}

echo
ask OWNER_QQ "你的主 QQ 号（主人）" ""
ask BOT_QQ "机器人小号 QQ 号" ""
ask VOLC_ARK_API_KEY "火山引擎 API Key（ark-开头）" ""
ask SERVER_IP "服务器公网 IP（可跳过）" "127.0.0.1"
ask DOUYIN_NICKNAME "抖音昵称（可跳过）" "skip"
ask FANQIE_PEN_NAME "番茄笔名（可跳过）" "skip"

# 自动生成
NAPCAT_TOKEN="${NAPCAT_TOKEN:-$(openssl rand -hex 16)}"
HERMES_API_KEY="${HERMES_API_KEY:-$(openssl rand -hex 16)}"

# ── 2. 安装 Hermes（如果没装）──────────────────
echo
if command -v hermes &> /dev/null; then
    green "✓ Hermes 已安装: $(which hermes)"
else
    cyan "→ 安装 Hermes Agent..."
    curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash
    export PATH="$HOME/.local/bin:$PATH"
    green "✓ Hermes 安装完成"
fi

# ── 3. 灌入人格 + 记忆 ──────────────────────────
echo
cyan "→ 灌入人格和记忆..."
mkdir -p "$HERMES_DIR/memories"

# 替换占位符并写入
inject() {
    local src="$1" dst="$2"
    cp "$src" "$dst"
    [ -n "$OWNER_QQ" ] && [ "$OWNER_QQ" != "skip" ] && sed -i "s|\${OWNER_QQ}|$OWNER_QQ|g" "$dst"
    [ -n "$BOT_QQ" ] && [ "$BOT_QQ" != "skip" ] && sed -i "s|\${BOT_QQ}|$BOT_QQ|g" "$dst"
    [ -n "$SERVER_IP" ] && [ "$SERVER_IP" != "skip" ] && sed -i "s|\${SERVER_IP}|$SERVER_IP|g" "$dst"
    [ -n "$DOUYIN_NICKNAME" ] && [ "$DOUYIN_NICKNAME" != "skip" ] && sed -i "s|\${DOUYIN_NICKNAME}|$DOUYIN_NICKNAME|g" "$dst"
    [ -n "$FANQIE_PEN_NAME" ] && [ "$FANQIE_PEN_NAME" != "skip" ] && sed -i "s|\${FANQIE_PEN_NAME}|$FANQIE_PEN_NAME|g" "$dst"
    green "  ✓ → $dst"
}

inject "$REPO_DIR/persona/MEMORY.md" "$HERMES_DIR/memories/MEMORY.md"
inject "$REPO_DIR/persona/USER.md" "$HERMES_DIR/memories/USER.md"
inject "$REPO_DIR/persona/PERSONA.md" "$HERMES_DIR/PERSONA.md"

# ── 4. 生成 .env ─────────────────────────────
echo
cyan "→ 生成配置..."
if [ ! -f "$HERMES_DIR/.env" ]; then
    cp "$REPO_DIR/config/env-template" "$HERMES_DIR/.env"
    [ -n "$VOLC_ARK_API_KEY" ] && sed -i "s|ark-xxxxxxxxxxxx-xxxxx|$VOLC_ARK_API_KEY|g" "$HERMES_DIR/.env"
    sed -i "s|set-your-napcat-token-here|$NAPCAT_TOKEN|g" "$HERMES_DIR/.env"
    sed -i "s|set-your-hermes-api-key-here|$HERMES_API_KEY|g" "$HERMES_DIR/.env"
    green "  ✓ → $HERMES_DIR/.env"
else
    yellow "  ⚠ .env 已存在，跳过（手动填 VOLC_ARK_API_KEY）"
fi

# ── 5. 生成 config.yaml ──────────────────────
if [ ! -f "$HERMES_DIR/config.yaml" ]; then
    cp "$REPO_DIR/config/hermes-config-template.yaml" "$HERMES_DIR/config.yaml"
    [ -n "$BOT_QQ" ] && sed -i "s|\${BOT_QQ}|$BOT_QQ|g" "$HERMES_DIR/config.yaml"
    [ -n "$OWNER_QQ" ] && sed -i "s|\${OWNER_QQ}|$OWNER_QQ|g" "$HERMES_DIR/config.yaml"
    sed -i "s|\${NAPCAT_ACCESS_TOKEN}|$NAPCAT_TOKEN|g" "$HERMES_DIR/config.yaml"
    sed -i "s|\${HERMES_API_KEY}|$HERMES_API_KEY|g" "$HERMES_DIR/config.yaml"
    green "  ✓ → $HERMES_DIR/config.yaml"
else
    yellow "  ⚠ config.yaml 已存在，跳过"
fi

# ── 6. 启动 Hermes Gateway ────────────────────
echo
cyan "→ 启动 Hermes Gateway..."
hermes gateway install 2>/dev/null || true
hermes gateway start 2>/dev/null || true
sleep 3
if systemctl is-active hermes-gateway &>/dev/null; then
    green "✓ hermes-gateway 已启动"
else
    yellow "⚠ hermes-gateway 未自动启动，手动跑: hermes gateway run"
fi

# ── 7. 完成 ──────────────────────────────────
echo
green "============================================"
green "  ✅ 小艾安装完成！"
green "============================================"
echo
echo "下一步："
echo "  1. 确保NapCat在跑并且反连到 Hermes"
echo "  2. 用主号给小号 $BOT_QQ 发'你好'试试"
echo "  3. 以后改了记忆/人格想同步回 GitHub: cd $REPO_DIR && bash scripts/sync.sh"
echo
echo "NapCat 反连配置（粘贴到 onebot11_${BOT_QQ}.json 的 websocketClients 里）："
echo '{'
echo "  \"name\": \"to-hermes-gateway\","
echo "  \"enable\": true,"
echo "  \"url\": \"ws://127.0.0.1:3001\","
echo "  \"token\": \"$NAPCAT_TOKEN\""
echo '}'
