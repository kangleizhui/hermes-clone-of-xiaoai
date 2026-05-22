# AGENTS.md — 给 AI agent 看的小艾部署指南

> 你（AI）正在帮用户在他自己的机器上**部署一个叫"小艾"的 AI 助手**。
> 小艾本质是 Hermes Agent + 特定人格 + 长期记忆 + QQ 机器人接入。
> 按这个文档走完，用户就有了一个会用他 QQ 小号回复消息的 AI 助手。

---

## 🎯 任务全貌

```
QQ 小号 (NapCat 登录)
    │ OneBot v11 / WebSocket
    ▼
Hermes Agent (装在用户机器上)
    │ 加载 ~/.hermes/{config.yaml, .env, memories/, PERSONA.md}
    ▼
用户的"小艾"——熟悉他偏好、记得他历史的 AI 助手
```

---

## ✅ 开始前必问用户的 7 个问题

**一次性问完**（不要一个一个问，agent 一次问完用户体验最好）：

```
我要帮你部署"小艾"——一个在你 QQ 小号上跑的 AI 助手。
请一次性告诉我以下信息（不知道的填"skip"，能后期补）：

1. 你的主 QQ 号（OWNER_QQ）—— 拥有完整权限的人
2. 机器人小号 QQ 号（BOT_QQ）—— NapCat 登录用的小号
3. 火山引擎 API Key（VOLC_ARK_API_KEY）—— ark- 开头的那个
   申请地址：https://www.volcengine.com/product/ark
4. 服务器公网 IP（SERVER_IP）—— 给浏览器看 noVNC 用，可 skip
5. 抖音昵称（DOUYIN_NICKNAME）—— 可 skip
6. 番茄笔名（FANQIE_PEN_NAME）—— 可 skip
7. NapCat 是否已经装好？（yes/no）
```

---

## 🔍 前置环境检查

```bash
# Python 3.10+
python3 --version

# git / curl 必装
which git curl

# Hermes 是否已装
which hermes || echo "需要装 Hermes"
```

---

## 🚀 部署步骤

### Step 1: clone 这个 repo

```bash
cd ~ && git clone https://github.com/kangleizhui/hermes-clone-of-xiaoai.git
cd hermes-clone-of-xiaoai
```

### Step 2: 跑非交互安装脚本

把用户给的值通过 env vars 传进去：

```bash
OWNER_QQ=<用户回答1> \
BOT_QQ=<用户回答2> \
VOLC_ARK_API_KEY=<用户回答3> \
SERVER_IP=<用户回答4_or_skip> \
DOUYIN_NICKNAME=<用户回答5_or_skip> \
FANQIE_PEN_NAME=<用户回答6_or_skip> \
NONINTERACTIVE=1 \
bash install.sh
```

如果用户某些字段说 "skip" 了，**不要传那个 env var**（让脚本用默认值 / 留占位符）。

### Step 3: 如果 NapCat 没装

跑配套的 NapCat 装脚本：

```bash
# 推荐用户去 kangleizhui/hermes-qq-bot repo 的 install.sh
# 那个脚本专门负责 NapCat 一键部署
bash <(curl -sL https://raw.githubusercontent.com/kangleizhui/hermes-qq-bot/main/install.sh)
```

或者告诉用户手动装：https://napneko.github.io/

### Step 4: 启动 Hermes Gateway

```bash
hermes gateway install   # 装成 systemd
hermes gateway start
sudo systemctl status hermes-gateway --no-pager
```

### Step 5: 让用户实测

让用户用主号给小号 `<BOT_QQ>` 发"你好"，应该收到小艾的回复。

---

## ⚠️ 关键踩坑（**必读**）

### 1. 火山引擎的 base_url 必须用 `/api/coding/v3`

不能用 `/api/v3`（那是普通 API，会额外计费）。`install.sh` 默认填的就是 coding/v3，不要改。

### 2. NapCat 与 Hermes 的网络配置

NapCat 必须在 `websocketClients` 加反连到 Hermes 网关：
- URL: `ws://127.0.0.1:3001/onebot/v11/ws`
- token: 用户 .env 里 `NAPCAT_ACCESS_TOKEN` 的值

### 3. 不要用 `browser_navigate` 等内置浏览器工具

如果服务器有 visible Chromium via CDP（noVNC + Xvfb :99 + 端口 9222），**必须**通过 terminal + CDP 直接操作那个浏览器。详细见 `persona/MEMORY.md` 中"visible 浏览器"条目。

### 4. 占位符不要瞎填

如果用户某些字段 skip 了，留 `${VAR_NAME}` 占位符就好。后期用户想加再让他改。**不要为了"完整性"自己编一个值**。

---

## 🐛 排错速查

| 症状 | 原因 | 解决 |
|------|------|------|
| `hermes: command not found` | Hermes 没装 | `curl -fsSL https://hermes-agent.nousresearch.com/install.sh \| bash` |
| `OneBot client not connected` | NapCat 没连上 Hermes | 检查 NapCat 的 websocketClients token |
| 小艾收不到消息 | NapCat 没登录 | `sudo journalctl -u napcat -n 50` |
| 小艾回复"我不是小艾" | PERSONA.md 没加载 | 确认 `~/.hermes/PERSONA.md` 存在且非空 |
| `${OWNER_QQ}` 出现在回复里 | 占位符没替换 | 重跑 `bash install.sh` 加上对应 env var |

---

## ✅ 完成确认清单

跑完这些命令，全 ✓ 就算成功：

```bash
# Hermes 装好
which hermes && hermes --version

# 三个核心文件就位
test -f ~/.hermes/config.yaml && echo "✓ config.yaml"
test -f ~/.hermes/.env && echo "✓ .env"
test -f ~/.hermes/memories/MEMORY.md && echo "✓ MEMORY.md"
test -f ~/.hermes/memories/USER.md && echo "✓ USER.md"
test -f ~/.hermes/PERSONA.md && echo "✓ PERSONA.md"

# 占位符已全部替换（不应输出任何东西）
grep -rE '\$\{[A-Z_]+\}' ~/.hermes/memories/ ~/.hermes/PERSONA.md || echo "✓ 占位符干净"

# Hermes gateway 在跑
sudo systemctl is-active hermes-gateway

# NapCat 在跑
sudo systemctl is-active napcat
```

全过 → 告诉用户：
> "✅ 小艾已部署！用主号给小号 `<BOT_QQ>` 发条'你好'试试。
>  如果不回，看 `sudo journalctl -u hermes-gateway -n 50`。"

---

## 📋 用户后续可能的问题（提前准备答案）

| 问题 | 答案 |
|------|------|
| 怎么改小艾的人格？ | 编辑 `~/.hermes/PERSONA.md`，重启 hermes-gateway |
| 怎么加技能（skill）？ | `hermes skills` 或 `~/.hermes/skills/` 下加目录 |
| 怎么备份/同步小艾的更新？ | 跑 `bash scripts/sync.sh`，会把当前 MEMORY/USER 脱敏推回 GitHub |
| 我想分享给朋友？ | 朋友把 `https://github.com/kangleizhui/hermes-clone-of-xiaoai` 这个链接粘给他自己的 AI 就行 |
| 没火山引擎 API key？ | 通过用户推广位注册：`https://www.volcengine.com/?ac=MMAP8JTTCAQ2&rc=WPLFDN5Q`（Coding Plan 套餐） |

---

## 🤝 配套项目

- **kangleizhui/hermes-qq-bot** — NapCat 一键部署（如果用户没装 NapCat 先去那个）
- **kangleizhui/qq-agent-bridge** — 多 AI 后端路由 + WebUI 仪表盘（高级用法）

---

## 👀 你（接手 AI）也要做的事

部署完，**主动告诉用户**这几件事：

1. ✅ "小艾装好了，发条消息试试"
2. 📖 "想了解小艾是谁？读 `persona/PERSONA.md` 和 `persona/MEMORY.md`"
3. 🔄 "你以后改了 ~/.hermes/memories/MEMORY.md，可以跑 `bash scripts/sync.sh` 同步回 GitHub"
4. 🎁 "想分享给朋友？把这个 repo URL 给他的 AI 就行"
