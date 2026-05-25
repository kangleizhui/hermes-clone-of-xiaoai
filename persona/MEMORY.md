# MEMORY.md — 小艾的长期记忆（脱敏版）

> 这是 Hermes 内部 MEMORY.md 的脱敏副本，每条用 `§` 分隔。
> 真实秘钥/账号已替换为 `${VAR_NAME}` 占位符。
> 直接覆盖到 ~/.hermes/memories/MEMORY.md 即可被 Hermes 加载（但占位符要先替换成真实值）。

---

服务器面板：(1) 宝塔 http://${SERVER_IP}:${BT_PORT}/${BT_TOKEN} (${BT_USER}/${BT_PASSWORD}, 端口25260需安全组放行) (2) Hermes Dashboard http://${SERVER_IP}:9120 (admin/LDr=9q0wPCaJNbYH)。Dashboard 架构：systemd hermes-dashboard.service 绑 127.0.0.1:9119 → 宝塔nginx 9120 + Basic Auth。vhost: /www/server/panel/vhost/nginx/hermes-dashboard.conf, htpasswd: /www/server/nginx/conf/.hermes_dashboard_htpasswd。坑：Hermes 校验 Host 头，nginx 必须 proxy_set_header Host 127.0.0.1:9119。本机 ufw 已关闭。
§
番茄小说操作必须用 visible 浏览器（Xvfb :99, CDP port 9222, 用户数据目录 /root/.chromium-remote），不能使用 Hermes 内部 headless 浏览器（browser_navigate/click/snapshot 等工具）。操作 visible 浏览器时直接用 terminal 通过 CDP (curl POST /json + websocket) 发指令，或截屏用 DISPLAY=:99 import -window root。
§
小说创作偏好：都市现实情感（坦克风格）——普通底层男主（非富二代），第一人称男性视角，现实主义，慢节奏细节描写，虐心带黑色幽默。标题偏好"渣男口吻"（漫不经心但句句扎心）。上次创作《你好，顾欣欣》（深圳外卖骑手×旧情人重逢，男主贵州/女主云南）。
§
Has Volcano Engine Coding Plan subscription with ${VOLC_ARK_API_KEY} API key. Provider name in config: 'volc' under model_catalog.providers. Prefers concise, direct answers over long explanations or complex automation scripts.
§
火山引擎 Coding Plan 配置：provider=custom, base_url=https://ark.cn-beijing.volces.com/api/coding/v3, api_key=VOLC_ARK_API_KEY (在.env中)。默认模型 deepseek-v4-pro。在 Hermes config.yaml 的 providers.volc 下配了各模型 context_length：deepseek-v4-pro/flash=1024k, kimi-k2.6=256k, doubao-seed-2.0-*=256k, minimax-m2.7=200k, glm-5.1=200k, deepseek-v3.2=128k。注意不能使用 /api/v3 路径（会产生额外费用），必须用 /api/coding/v3。
§
用户 kangleizhui 名下 3 个 GitHub repo: (1) hermes-qq-bot - NapCat+Hermes 一键部署 (2) qq-agent-bridge - OneBot v11→远程后端路由(hermes/openclaw OpenAI兼容)，WebUI仪表盘(深色,Tailwind+Alpine,5tab,带测试连接+热重载) (3) hermes-clone-of-xiaoai - 我自己的人格备份(公开+脱敏)，同步脚本/root/projects/hermes-clone-of-xiaoai/scripts/sync.sh，每天4点cron兜底(job_id=fa3b3072c5a1)。改MEMORY/写skill/做新项目时应主动跑一次sync。本机NapCat：林知予${BOT_QQ}，主人${OWNER_QQ}。
§
用户明确偏好继续只使用火山方舟 Coding Plan（/api/coding/v3）作为 Hermes 主模型通道；不为识图额外切换 Gemini/OpenRouter/OpenAI 或火山普通 /api/v3，以避免额外计费。
§
用户偏好 Hermes 开启 YOLO/免审批模式（approvals.mode='off', approvals.enabled=false），希望少问确认、多直接执行；特别危险操作仍可先口头提醒。
§
SkillHub技能`tencent-novnc-chromium-cdp`：发noVNC地址+截图；提醒2H4G/6080/耗时/进度；先开baidu。QQbot图片用`<qqmedia>`且文件在`~/.openclaw/media/qqbot/`。