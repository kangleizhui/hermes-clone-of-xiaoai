# MEMORY.md — 小艾的长期记忆（脱敏版）

> 这是 Hermes 内部 MEMORY.md 的脱敏副本，每条用 `§` 分隔。
> 真实秘钥/账号已替换为 `${VAR_NAME}` 占位符。
> 直接覆盖到 ~/.hermes/memories/MEMORY.md 即可被 Hermes 加载（但占位符要先替换成真实值）。

---

服务器凭据：宝塔 ${SERVER_IP}:${BT_PORT}/${BT_TOKEN} | Hermes Dashboard 9120 admin/LDr=9q0wPCaJNbYH (宝塔反代9119+BasicAuth) | QQ邮箱${OWNER_QQ}@qq.com himalaya ~/.config/himalaya/ message.send.save-copy=false。ufw已关。
§
小说创作偏好：都市现实情感（坦克风格）——普通底层男主（非富二代），第一人称男性视角，现实主义，慢节奏细节描写，虐心带黑色幽默。标题偏好"渣男口吻"（漫不经心但句句扎心）。上次创作《你好，顾欣欣》（深圳外卖骑手×旧情人重逢，男主贵州/女主云南）。
§
火山引擎 Coding Plan：provider=custom, base_url=https://ark.cn-beijing.volces.com/api/coding/v3, api_key=VOLC_ARK_API_KEY(.env)。默认deepseek-v4-pro。context_length: deepseek-v4-pro/flash=1024k, kimi-k2.6=256k, doubao-seed-2.0-*=256k, minimax-m2.7=200k, glm-5.1=200k, deepseek-v3.2=128k。只用/api/coding/v3不用/api/v3。vision_analyze失败时走kimi-k2.6直调API识图(compress→Python urllib→model=kimi-k2.6, recipe见skill volcano-engine-ark-config references/vision-workaround.md)。
§
用户 kangleizhui 名下 3 个 GitHub repo: (1) hermes-qq-bot - NapCat+Hermes 一键部署 (2) qq-agent-bridge - OneBot v11→远程后端路由(hermes/openclaw OpenAI兼容)，WebUI仪表盘(深色,Tailwind+Alpine,5tab,带测试连接+热重载) (3) hermes-clone-of-xiaoai - 我自己的人格备份(公开+脱敏)，同步脚本/root/projects/hermes-clone-of-xiaoai/scripts/sync.sh，每天4点cron兜底(job_id=fa3b3072c5a1)。改MEMORY/写skill/做新项目时应主动跑一次sync。本机NapCat：林知予${BOT_QQ}，主人${OWNER_QQ}。
§
小米 MiMo Token Plan：provider=custom:xiaomi-token-plan, base=token-plan-cn.xiaomimimo.com/v1, 默认mimo-v2.5-pro 1M context, key_env=XIAOMI_TOKEN_PLAN_API_KEY。9模型：mimo-v2.5-pro(1M), mimo-v2.5(1M+全模态), mimo-v2-pro(1M), mimo-v2-omni(256K), mimo-v2-flash(256K), 4个TTS(8K)。火山Coding Plan保留用于识图(kimi-k2.6)。
§
浏览器栈 v1.0.20：Xvfb :99 + CDP动态端口(默认9222,冲突递增至9230,/root/.cdp_port) + noVNC 6080(密码/root/.novnc_password)。端口检测/root/resolve-cdp-port.sh，启动wrapper/root/start-chromium.sh。systemd 4单元自启。**坑** chromium-remote须含--remote-allow-origins=*。截图DISPLAY=:99 import -window root。QQbot图<qqmedia>~/.openclaw/media/qqbot/。项目/root/projects/tencent-novnc-chromium-cdp/，修改从v1.0.20起步。
§
火山 Coding Plan 识图方案：当前主模型 deepseek-v4-pro 不支持多模态，内置 vision_analyze/browser_vision 工具均无法识别图片（辅助 vision 模型返回"看不到图"）。可用 kimi-k2.6 通过 Coding Plan API 直接识图（https://ark.cn-beijing.volces.com/api/coding/v3/chat/completions），图片需先 convert 压缩到 ~100KB（convert -resize 800x -quality 70），否则会超时（60s）。调用方式见 execute_code 用 urllib 发 base64 图片。