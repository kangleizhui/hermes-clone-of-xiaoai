#!/bin/bash
# sync.sh — 把当前 Hermes 状态同步回 hermes-clone-of-xiaoai repo
# ============================================================
# 用法：
#   bash scripts/sync.sh             # 完整同步
#   bash scripts/sync.sh --dry       # 只看会变什么，不 push
#   bash scripts/sync.sh --quiet     # 静默模式（cron 用）
# ============================================================
#
# 脱敏规则与 revive.sh 严格对称：
#   ${OWNER_QQ}              ← QQ 主号
#   ${BOT_QQ}                ← QQ 小号
#   ${GROUP_ID}              ← QQ 群号
#   ${SERVER_IP}             ← 服务器公网 IP
#   ${VOLC_ARK_API_KEY}      ← 火山引擎 key
#   ${DOUYIN_NICKNAME}       ← 抖音昵称
#   ${DOUYIN_ID}             ← 抖音号
#   ${FANQIE_PEN_NAME}       ← 番茄笔名
#   ${BT_USER/PASSWORD/PORT/TOKEN} ← 宝塔面板
#   ${USER_DM_ID}            ← QQ bot 私聊 ID
#   ${NAPCAT_ACCESS_TOKEN}   ← NapCat token

set -e

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
HERMES_DIR="${HERMES_HOME:-$HOME/.hermes}"
DRY=false
QUIET=false

for arg in "$@"; do
    case $arg in
        --dry) DRY=true ;;
        --quiet) QUIET=true ;;
    esac
done

log() { [ "$QUIET" = false ] && echo "$@"; }

# 真实值（从环境或 .env 读，硬编码作为兜底——这些是当前实例的实际值）
: ${OWNER_QQ:=2556208918}
: ${BOT_QQ:=3531314097}
: ${GROUP_ID:=770967860}
: ${SERVER_IP:=101.32.98.240}
: ${DOUYIN_NICKNAME:=阿欣茹}
: ${DOUYIN_ID:=56396242636}
: ${FANQIE_PEN_NAME:=乐涩辞啊}
: ${BT_USER:=ehbutyhn}
: ${BT_PASSWORD:=196af12b}
: ${BT_PORT:=25260}
: ${BT_TOKEN:=14ba6d1c}
: ${USER_DM_ID:=C8AFD04F7B6697C8137F98193954CD84}
: ${NAPCAT_ACCESS_TOKEN:=hermes-napcat-token-2026}

# 火山 API key 从 .env 读
if [ -f "$HERMES_DIR/.env" ]; then
    VOLC_KEY=$(grep -E '^VOLC_ARK_API_KEY=' "$HERMES_DIR/.env" | head -1 | cut -d= -f2-)
fi

desensitize() {
    local file="$1"
    sed -i.bak \
        -e "s|$OWNER_QQ|\${OWNER_QQ}|g" \
        -e "s|$BOT_QQ|\${BOT_QQ}|g" \
        -e "s|$GROUP_ID|\${GROUP_ID}|g" \
        -e "s|$SERVER_IP|\${SERVER_IP}|g" \
        -e "s|$DOUYIN_NICKNAME|\${DOUYIN_NICKNAME}|g" \
        -e "s|$DOUYIN_ID|\${DOUYIN_ID}|g" \
        -e "s|$FANQIE_PEN_NAME|\${FANQIE_PEN_NAME}|g" \
        -e "s|$BT_USER|\${BT_USER}|g" \
        -e "s|$BT_PASSWORD|\${BT_PASSWORD}|g" \
        -e "s|:$BT_PORT|:\${BT_PORT}|g" \
        -e "s|$BT_TOKEN|\${BT_TOKEN}|g" \
        -e "s|$USER_DM_ID|\${USER_DM_ID}|g" \
        -e "s|$NAPCAT_ACCESS_TOKEN|\${NAPCAT_ACCESS_TOKEN}|g" \
        "$file"
    [ -n "$VOLC_KEY" ] && sed -i.bak "s|$VOLC_KEY|\${VOLC_ARK_API_KEY}|g" "$file"
    rm -f "$file.bak"
}

# 1. 同步 MEMORY.md
log "→ 同步 MEMORY.md..."
if [ -f "$HERMES_DIR/memories/MEMORY.md" ]; then
    # 加 header
    {
        echo "# MEMORY.md — 小艾的长期记忆（脱敏版）"
        echo
        echo "> 这是 Hermes 内部 MEMORY.md 的脱敏副本，每条用 \`§\` 分隔。"
        echo "> 真实秘钥/账号已替换为 \`\${VAR_NAME}\` 占位符。"
        echo "> 直接覆盖到 ~/.hermes/memories/MEMORY.md 即可被 Hermes 加载（但占位符要先替换成真实值）。"
        echo
        echo "---"
        echo
        cat "$HERMES_DIR/memories/MEMORY.md"
    } > "$REPO_DIR/persona/MEMORY.md"
    desensitize "$REPO_DIR/persona/MEMORY.md"
fi

# 2. 同步 USER.md
log "→ 同步 USER.md..."
if [ -f "$HERMES_DIR/memories/USER.md" ]; then
    {
        echo "# USER.md — 用户画像（脱敏版）"
        echo
        echo "> 关于用户的所有事实——身份、偏好、习惯、沟通风格。"
        echo "> 每条用 \`§\` 分隔。真实账号已脱敏。"
        echo
        echo "---"
        echo
        cat "$HERMES_DIR/memories/USER.md"
    } > "$REPO_DIR/persona/USER.md"
    desensitize "$REPO_DIR/persona/USER.md"
fi

# 3. 安全校验：扫一遍是否有秘钥泄漏
log "→ 校验脱敏..."
LEAKS=$(grep -rEln "($OWNER_QQ|$BOT_QQ|$SERVER_IP|$DOUYIN_NICKNAME|$FANQIE_PEN_NAME|ark-c89|$BT_PASSWORD)" "$REPO_DIR/persona/" "$REPO_DIR/projects/" 2>/dev/null || true)
if [ -n "$LEAKS" ]; then
    echo "❌ 检测到敏感信息泄漏！"
    echo "$LEAKS"
    echo "已中止 push，请检查脱敏规则。"
    exit 1
fi
log "  ✓ 无泄漏"

# 4. dry-run 退出
if [ "$DRY" = true ]; then
    cd "$REPO_DIR"
    git diff --stat
    exit 0
fi

# 5. git push
cd "$REPO_DIR"
if git diff --quiet && git diff --cached --quiet; then
    log "  · 没变化，跳过 push"
    exit 0
fi

git add -A
COMMIT_MSG="${1:-chore: 小艾自动同步 $(date +%Y-%m-%d\ %H:%M)}"
git commit -m "$COMMIT_MSG" 2>&1 | tail -3
git push origin main 2>&1 | tail -3
log "  ✓ pushed"
