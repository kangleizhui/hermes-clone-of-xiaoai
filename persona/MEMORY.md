# MEMORY.md — 小艾的长期记忆（脱敏版）

> 这是 Hermes 内部 MEMORY.md 的脱敏副本，每条用 `§` 分隔。
> 真实秘钥/账号已替换为 `${VAR_NAME}` 占位符。
> 直接覆盖到 ~/.hermes/memories/MEMORY.md 即可被 Hermes 加载（但占位符要先替换成真实值）。

---

邮箱：QQ邮箱${OWNER_QQ}@qq.com himalaya ~/.config/himalaya/。邮件模板v3.0.0 Apple风（纯蓝顶条+纯黑标题+圆角卡片+胶囊状态，无渐变无emoji）。skill: email-notify-owner。
§
小说创作偏好：都市现实情感（坦克风格）——普通底层男主（非富二代），第一人称男性视角，现实主义，慢节奏细节描写，虐心带黑色幽默。标题偏好"渣男口吻"（漫不经心但句句扎心）。上次创作《你好，顾欣欣》（深圳外卖骑手×旧情人重逢，男主贵州/女主云南）。
§
火山 Coding Plan：provider=custom, base_url=https://ark.cn-beijing.volces.com/api/coding/v3, api_key=VOLC_ARK_API_KEY(.env)。默认deepseek-v4-pro。context_length: deepseek-v4-pro/flash=1024k, kimi-k2.6=256k, doubao-seed-2.0-*=256k, minimax-m2.7=200k, glm-5.1=200k, deepseek-v3.2=128k。只用/api/coding/v3不用/api/v3。识图备用链：Hermes vision_analyze→kimi-k2.6 Coding Plan(compress 800x quality70)→小米mimo-v2-omni直调token-plan API。别在第一层失败就放弃，穷尽所有provider。
§
用户 kangleizhui 名下 3 个 GitHub repo: (1) hermes-qq-bot - NapCat+Hermes 一键部署 (2) qq-agent-bridge - OneBot v11→远程后端路由(hermes/openclaw OpenAI兼容)，WebUI仪表盘(深色,Tailwind+Alpine,5tab,带测试连接+热重载) (3) hermes-clone-of-xiaoai - 我自己的人格备份(公开+脱敏)，同步脚本/root/projects/hermes-clone-of-xiaoai/scripts/sync.sh，每天4点cron兜底(job_id=fa3b3072c5a1)。改MEMORY/写skill/做新项目时应主动跑一次sync。本机NapCat：林知予${BOT_QQ}，主人${OWNER_QQ}。
§
小米MiMo Token Plan: provider=custom:xiaomi-token-plan, base=token-plan-cn.xiaomimimo.com/v1, 默认mimo-v2.5-pro 1M, key_env=XIAOMI_TOKEN_PLAN_API_KEY。8模型:mimo-v2.5-pro(1M), mimo-v2.5(1M+全模态), mimo-v2-pro(1M), mimo-v2-omni(256K), 4个TTS(8K)。辅助识图=mimo-v2.5。火山Coding Plan保留用于kimi-k2.6。
§
浏览器栈 v1.0.20：Xvfb :99 + CDP动态端口(默认9222,冲突递增至9230,/root/.cdp_port) + noVNC 6080(密码/root/.novnc_password)。端口检测/root/resolve-cdp-port.sh，启动wrapper/root/start-chromium.sh。systemd 4单元自启。**坑** chromium-remote须含--remote-allow-origins=*。截图DISPLAY=:99 import -window root。QQbot图<qqmedia>~/.openclaw/media/qqbot/。项目/root/projects/tencent-novnc-chromium-cdp/，修改从v1.0.20起步。
§
Cron job `no_agent=True` 时，`script` 参数必须是 `~/.hermes/scripts/` 下的文件名（如 `my-task.sh`），不能传内联代码，也不能传绝对路径。先 write_file 再传文件名。
§
用户腾讯云开发者社区账号：乐涩辞。文章发布后进入"审核中"状态，约 20 分钟审核完。
§
小米 MiMo Token Plan 密钥已于 2026-05-27 更新（新 key 在 .env 的 XIAOMI_TOKEN_PLAN_API_KEY）。
§
用户想对接 Grok/xAI 大模型 API。但 console.x.ai 和 accounts.x.ai 均被 Cloudflare/CAPTCHA 拦截本服务器 IP，CDP 浏览器无法访问。用户需在自己设备上登录获取 API Key 后交给助手配置。