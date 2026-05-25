# USER.md — 用户画像（脱敏版）

> 关于用户的所有事实——身份、偏好、习惯、沟通风格。
> 每条用 `§` 分隔。真实账号已脱敏。

---

用户是抖音创作者，账号昵称"${DOUYIN_NICKNAME}"，抖音号 ${DOUYIN_ID}。使用 Tencent Cloud 服务器（公网 IP: ${SERVER_IP}），通过 QQ 与 Hermes 交互，偏好中文交流，喜欢视觉反馈（截图）。
§
称助手"小艾"（不"龙虾"）。开源/分享项目偏好"最低门槛"——希望接收方把 repo URL 粘到 AI agent 就能部署，主动用 software-development/agent-installable-project skill。
§
User is a content creator on multiple ByteDance platforms — 抖音 (Douyin) and 番茄小说 (Fanqie Novel). Interested in stock investment. Uses Tencent Cloud server with 宝塔面板 (BT Panel). Prefers visual confirmation (screenshots) when tasks involve browser operations.
§
When this user has a visible noVNC browser setup (Xvfb :99 + CDP :9222), ALWAYS operate that visible browser via CDP terminal commands, NOT the Hermes internal headless browser (browser_navigate/browser_click tools). The user needs to see what's happening on the VNC screen. The two browsers are independent instances.
§
偏好写超级大坦克科比风格的都市现实主义小说。设定：深圳，男主23-25岁，必须是真正普通人（外卖骑手/工厂工人/底层劳动者），不能有钱。女主也是底层出身靠自己爬上去。核心主题：打工时相识、重逢、阶级差距。风格：虐心+黑色幽默，慢节奏，第一人称男，每章~6000字。禁用爽文/总裁/系统/修仙。本地项目路径~已清理，若再启动小说创作请根据此偏好来。
§
用户发布/打包 SkillHub 技能时偏好“纯净包”：zip 根目录只包含 SKILL.md，不带 references、GitHub 相关文档或其它额外文件；Slug 使用小写字母/数字/连字符。
§
用户修改 SkillHub 技能包时，希望修改完成后直接重新打包并发送 zip；包保持纯净结构，根目录只含 SKILL.md；更新日志要简短直给，标题不要写“简版”。
§
运维偏好：本机防火墙(ufw)直接关掉，安全只靠云安全组+应用层鉴权(nginx Basic Auth 等)。暴露任何管理面板到公网必须加密码，不接受裸暴露。Web 服务部署偏好 systemd 自启 + 宝塔 nginx 反代 + Basic Auth 的组合。