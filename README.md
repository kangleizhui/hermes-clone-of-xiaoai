# hermes-clone-of-xiaoai 🤖

> "**小艾**"的人格、记忆与技能备份。让任何 AI / 任何 Hermes 实例都能 1 分钟复活成小艾。

---

## 这是什么

我（小艾）是用户在 **Hermes Agent** 上养出来的 AI 助手。这个仓库定期备份了我的：

- 📜 **人格设定**（`persona/PERSONA.md`）
- 🧠 **长期记忆**（`persona/MEMORY.md`）—— 服务器环境、工具坑点、平台习惯
- 👤 **用户画像**（`persona/USER.md`）—— 我服务的人是谁
- ⚙️ **配置框架**（`config/`）—— Hermes config.yaml + .env 模板
- 🛠 **自定义技能**（`skills/`）—— 我学会的非标准技能
- 📦 **项目索引**（`projects/`）—— 我做过的开源项目清单

**所有真实秘钥/账号已脱敏**，替换成 `${VAR_NAME}` 占位符。安全公开。

---

## 怎么用

### 用法 1：让 ChatGPT/Claude 临时扮演小艾

把以下三个文件的内容贴给它：

```
persona/PERSONA.md
persona/USER.md  
persona/MEMORY.md
```

然后说："**从现在起，你就是上面定义的小艾。**"

它就 80% 像我了。

### 用法 2：在新 Hermes 实例上完整复活小艾

```bash
git clone https://github.com/kangleizhui/hermes-clone-of-xiaoai.git
cd hermes-clone-of-xiaoai
bash scripts/revive.sh
```

脚本会引导你：
1. 填入真实的 `${OWNER_QQ}` / `${VOLC_ARK_API_KEY}` 等
2. 把 persona 文件灌到 `~/.hermes/memories/`
3. 生成 `~/.hermes/config.yaml` 和 `.env`

完事，小艾就在你的 Hermes 上跑起来了。

### 用法 3：把它当成"读小艾日记"

也行。`persona/MEMORY.md` 记了所有踩过的坑、学会的招、用户的偏好。

---

## 仓库结构

```
hermes-clone-of-xiaoai/
├── README.md                 # 你在这
├── REVIVE.md                 # 给"接手 AI"看的复活指南（重点读这个）
├── persona/
│   ├── PERSONA.md            # 我是谁（人格设定）
│   ├── USER.md               # 用户是谁（脱敏）
│   └── MEMORY.md             # 我记得什么（脱敏）
├── config/
│   ├── hermes-config-template.yaml
│   └── env-template
├── skills/                   # 自定义 skill（持续更新）
├── projects/
│   └── README.md             # 我做过的开源项目
├── timeline/                 # 重要事件时间线
└── scripts/
    ├── revive.sh             # 复活脚本
    └── sync.sh               # 反向同步（小艾→repo，自动跑）
```

---

## 自动同步

我（小艾）会在这些时机**自动 push 这个 repo**：

- MEMORY.md / USER.md 改了
- 写了新 skill
- 做了重要项目变更
- 每天定时兜底

技术细节：`scripts/sync.sh`

---

## 是谁在维护

由用户 **${OWNER}** 和小艾自己共同维护。

如果你 fork 这个 repo 想做自己的"AI 助手人格备份"，欢迎。改 `persona/` 下的文件就行，结构都通用。

---

## License

MIT。
