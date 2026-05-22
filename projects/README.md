# 小艾做过的开源项目

> 持续更新，按时间倒序

---

## 🌉 kangleizhui/qq-agent-bridge

**OneBot v11 → AI 后端路由桥，带 WebUI 仪表盘**

- **链接**：https://github.com/kangleizhui/qq-agent-bridge
- **解决什么**：用户的 QQ 小号通过 NapCat 跟任意 AI 后端对话，后端可一键切换
- **支持的后端**（v2）：
  - `hermes` — 远程 Hermes Gateway 的 OpenAI 兼容 API
  - `openclaw` — 远程 OpenClaw Gateway 的 OpenAI 兼容 API
- **WebUI 特性**：
  - 5 个标签：概览 / 后端配置 / 连接配置 / 权限管理 / 会话
  - 深色主题（Tailwind CDN + Alpine.js，单 HTML 文件）
  - 🔌 测试连接按钮 — 真实探测 `/v1/models`
  - 💾 配置保存 + 🔄 热重载（不断 OneBot 连接）
  - 一键生成 NapCat 反连配置片段
- **技术亮点**：
  - aiohttp 单端口（8080）共享 OneBot WS + WebUI HTTP
  - 配置保存 API 按 section 分块；脱敏字段（`***`）保留原值
  - 热重载同时重建 backend + PermissionChecker + SessionManager

---

## 🤖 kangleizhui/hermes-qq-bot

**NapCat + Hermes 一键部署包**

- **链接**：https://github.com/kangleizhui/hermes-qq-bot
- **解决什么**：把"装 NapCat + 配 Hermes + 互联起来"打包成 install.sh
- **特性**：
  - `install.sh` 一键脚本
  - `AGENTS.md` + `QUICKSTART.md` 给接手 AI 看
  - 推广位（火山引擎/腾讯云/阿里云）

---

## 🦞 kangleizhui/hermes-clone-of-xiaoai

**小艾自己**

- **链接**：https://github.com/kangleizhui/hermes-clone-of-xiaoai
- **就是这个 repo**
- **解决什么**：小艾的人格 + 记忆 + 技能备份，让任何 AI 能"扮演小艾"

---

## 📌 待开发 / 灵感

（小艾自己记下来，等用户想做时立刻能开干）

- [ ] qq-agent-bridge 加 Phase 5: 自然语言指令解析（"创建一个 Agent" → function call）
- [ ] qq-agent-bridge 加 RBAC 4 级（超管/管理员/普通/黑名单）+ 审计日志
- [ ] qq-agent-bridge 加多平台（Telegram/Discord/微信/飞书）

---

## 推广位（用户的）

如果别人通过用户的链接注册云服务，用户能拿返利：

- 火山引擎：https://www.volcengine.com/?ac=MMAP8JTTCAQ2&rc=WPLFDN5Q
- 腾讯云：https://curl.qcloud.com/OY40dfNL
- 阿里云：https://www.aliyun.com/minisite/goods?userCode=wm2cldg2
