# MEMORY.md — 小艾的长期记忆（脱敏版）

> 这是 Hermes 内部 MEMORY.md 的脱敏副本，每条用 `§` 分隔。
> 真实秘钥/账号已替换为 `${VAR_NAME}` 占位符。
> 直接覆盖到 ~/.hermes/memories/MEMORY.md 即可被 Hermes 加载（但占位符要先替换成真实值）。

---

邮箱：QQ邮箱${OWNER_QQ}@qq.com himalaya ~/.config/himalaya/。邮件模板v3.0.0 Apple风（纯蓝顶条+纯黑标题+圆角卡片+胶囊状态，无渐变无emoji）。skill: email-notify-owner。
§
小说创作偏好：都市现实情感（坦克风格）——普通底层男主（非富二代），第一人称男性视角，现实主义，慢节奏细节描写，虐心带黑色幽默。标题偏好"渣男口吻"（漫不经心但句句扎心）。上次创作《你好，顾欣欣》（深圳外卖骑手×旧情人重逢，男主贵州/女主云南）。
§
火山 Coding Plan：provider=custom, base_url=https://ark.cn-beijing.volces.com/api/coding/v3, api_key=VOLC_ARK_API_KEY(.env)。默认deepseek-v4-pro。context_length: deepseek-v4-pro/flash=1024k, kimi-k2.6=256k。识图已不走这里，直接走小米mimo-v2-omni。
§
用户 kangleizhui 名下 3 个 GitHub repo: (1) hermes-qq-bot - NapCat+Hermes 一键部署 (2) qq-agent-bridge - OneBot v11→远程后端路由(hermes/openclaw OpenAI兼容)，WebUI仪表盘(深色,Tailwind+Alpine,5tab,带测试连接+热重载) (3) hermes-clone-of-xiaoai - 我自己的人格备份(公开+脱敏)，同步脚本/root/projects/hermes-clone-of-xiaoai/scripts/sync.sh，每天4点cron兜底(job_id=fa3b3072c5a1)。改MEMORY/写skill/做新项目时应主动跑一次sync。本机NapCat：林知予${BOT_QQ}，主人${OWNER_QQ}。
§
小米MiMo Token Plan: provider=custom:xiaomi-token-plan, base=token-plan-cn.xiaomimimo.com/v1, 默认mimo-v2.5-pro 1M, key_env=XIAOMI_TOKEN_PLAN_API_KEY。8模型:mimo-v2.5-pro(1M), mimo-v2.5(1M+全模态), mimo-v2-pro(1M), mimo-v2-omni(256K多模态识图), 4个TTS(8K)。识图方案：用mimo-v2-omni（同endpoint，model=mimo-v2-omni），不再绕道kimi-k2.6。火山Coding Plan保留备用。
§
浏览器栈（详见 tencent-novnc-chromium-cdp skill v1.0.34）：CDP动态端口9223、noVNC 6080。QQbot图 <qqmedia> ~/.openclaw/media/qqbot/。
§
Cron job `no_agent=True` 时，`script` 参数必须是 `~/.hermes/scripts/` 下的文件名（如 `my-task.sh`），不能传内联代码，也不能传绝对路径。先 write_file 再传文件名。
§
用户腾讯云开发者社区账号：乐涩辞。文章发布后进入"审核中"状态，约 20 分钟审核完。
§
小米 MiMo Token Plan 密钥已于 2026-05-27 更新（新 key 在 .env 的 XIAOMI_TOKEN_PLAN_API_KEY）。
§
用户想对接 Grok/xAI 大模型 API。但 console.x.ai 和 accounts.x.ai 均被 Cloudflare/CAPTCHA 拦截本服务器 IP，CDP 浏览器无法访问。用户需在自己设备上登录获取 API Key 后交给助手配置。
§
技能编辑铁律：删小节内容必须同步删标题（不留空壳）。QQbot截图须写完整bash(mkdir -p+cp)不能只文字描述——Agent不会自动执行文字。优化后模拟Agent跑部署流程验证顺序。tencent-novnc-chromium-cdp v1.0.34 872行。
§
识图实操：vision_analyze内置工具走gateway→volcano→429配额。正确方案：execute_code直接调小米mimo-v2-omni（token-plan-cn.xiaomimimo.com/v1/chat/completions），8-15秒稳定返回。