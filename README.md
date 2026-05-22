# hermes-clone-of-xiaoai 🤖

> **把这个 URL 给任何 AI agent，它就会帮你部署"小艾"。**

```
https://github.com/kangleizhui/hermes-clone-of-xiaoai
```

对 AI 说：**"帮我把这个部署起来"**，它读 `AGENTS.md` 就会自动走完全部流程。

---

## 这是什么

"小艾"是一个跑在 **QQ 小号**上的 AI 助手，基于 [Hermes Agent](https://hermes-agent.nousresearch.com/) + 特定人格 + 长期记忆。

这个仓库包含让**任何 AI 在任何机器上复刻小艾**所需的一切：

| 文件 | 作用 |
|------|------|
| `AGENTS.md` | 🧠 AI 读这个就知道该干嘛（命令式步骤） |
| `install.sh` | ⚡ 非交互安装脚本，env vars 驱动 |
| `persona/PERSONA.md` | 📜 小艾的人格定义 |
| `persona/MEMORY.md` | 🧠 长期记忆（脱敏） |
| `persona/USER.md` | 👤 用户画像（脱敏） |
| `config/` | ⚙️ Hermes 配置模板 |
| `skills/` | 🛠 自定义技能 |

**所有密钥/账号已脱敏**为 `${VAR_NAME}` 占位符，安全公开。

---

## 一键部署

### 让 AI 帮你装（推荐）

把 repo URL 粘给你的 AI，说"帮我部署"，它会问你几个问题（QQ号、API Key 等），然后全自动装好。

### 自己装

```bash
git clone https://github.com/kangleizhui/hermes-clone-of-xiaoai.git
cd hermes-clone-of-xiaoai

# 填入你的信息
NONINTERACTIVE=1 \
  OWNER_QQ=你的主QQ号 \
  BOT_QQ=机器人小号QQ \
  VOLC_ARK_API_KEY=你的火山引擎key \
  bash install.sh
```

装完后跑 `hermes gateway start`，用主号给小号发"你好"测试。

---

## 核心架构

```
QQ 小号 (NapCat 登录)
    │ OneBot v11 / WebSocket
    ▼
Hermes Agent (加载人格 + 记忆)
    │ 调用火山引擎 LLM
    ▼
"小艾"——有记忆、有人格的 AI 助手
```

---

## 配套项目

- **[hermes-qq-bot](https://github.com/kangleizhui/hermes-qq-bot)** — NapCat 一键部署脚本
- **[qq-agent-bridge](https://github.com/kangleizhui/qq-agent-bridge)** — 多 AI 后端路由 + WebUI 仪表盘（进阶用法）

---

## 推广位 ❤️

- 火山引擎（推荐 LLM 套餐）：[注册链接](https://www.volcengine.com/?ac=MMAP8JTTCAQ2&rc=WPLFDN5Q)
- 腾讯云服务器：[注册链接](https://curl.qcloud.com/OY40dfNL)
- 阿里云服务器：[注册链接](https://user.aliyun.com/wm2cldg2)

---

## License

MIT
