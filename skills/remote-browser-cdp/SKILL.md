---
name: remote-browser-cdp
description: Use when setting up a visible remote Chromium browser on a Linux server with Xvfb, x11vnc, noVNC, websockify, and Chrome DevTools Protocol so a user can see the browser while an AI agent controls it programmatically.
version: 1.0.0
author: 小艾 / Hermes Agent
license: MIT
metadata:
  hermes:
    tags: [browser, cdp, novnc, chromium, xvfb, remote-browser, linux, openclaw]
    related_skills: []
---

# Remote Visible Browser: noVNC + Chromium + CDP

## Overview

This skill turns a plain Linux server into a **visible remote browser workstation** for AI agents.

It installs and runs this stack:

```text
Xvfb virtual display :99
  ↓
Chromium visible browser running inside :99
  ↓
x11vnc exposes the X display as VNC on 127.0.0.1:5900
  ↓
websockify + noVNC exposes VNC in a web browser on 0.0.0.0:6080

Chromium also exposes Chrome DevTools Protocol on 0.0.0.0:9222
```

After setup:

- Human user opens: `http://<SERVER_IP>:6080/vnc.html`
- AI agent controls Chromium via CDP: `http://127.0.0.1:9222/json`
- Browser profile persists at: `/root/.chromium-remote`

This is useful when normal headless browser tools are not enough, especially for login, captcha, Chinese websites, web dashboards, and sites where the user wants to see exactly what the agent is doing.

Inspired by Tencent Cloud article: `https://cloud.tencent.com/developer/article/2670539`.

## When to Use

Use this skill when the user asks for any of these:

- “搭一个我能看到的远程浏览器”
- “noVNC 浏览器”
- “Xvfb + Chromium + CDP”
- “让 AI 操作服务器上的可视浏览器”
- “我想在浏览器里看到 agent 正在做什么”
- “番茄小说/抖音/QQ/GitHub 登录需要手动验证”
- “不要用 headless browser，要用 visible browser”

Do **not** use this when:

- The task only needs simple headless scraping.
- The user does not need visual confirmation.
- Playwright/Puppeteer headless is enough.

## Critical Concept: Visible Browser ≠ Agent Built-in Browser

Many agents have built-in browser tools. Those usually launch a **separate headless browser**.

This skill creates a different browser:

| Browser | User can see it? | Control method | Typical port |
|---|---:|---|---:|
| Visible noVNC Chromium | yes | raw CDP websocket / HTTP JSON | 9222 |
| Agent built-in browser | no | agent browser tools | random/internal |

If the user is watching noVNC, **do not use the agent’s internal browser tools** unless you explicitly want a different invisible browser.

Use CDP against `127.0.0.1:9222` for the visible browser.

## Supported Systems

Tested target:

- Debian / Ubuntu server
- root or sudo access
- Chromium package available as `chromium` or `chromium-browser`
- Public IP if the user wants remote noVNC access

## Installation

### 1. Install dependencies

Run as root or with sudo:

```bash
apt update
apt install -y xvfb x11vnc chromium git python3 python3-pip python3-websockify curl jq net-tools
```

If package `chromium` does not exist, try:

```bash
apt install -y chromium-browser
```

### 2. Install noVNC

```bash
if [ ! -d /opt/noVNC ]; then
  git clone https://github.com/novnc/noVNC.git /opt/noVNC
fi

# websockify may already be installed as python3-websockify.
# If command is missing, install via pip:
command -v websockify >/dev/null 2>&1 || pip3 install websockify --break-system-packages
```

### 3. Open firewall ports

Open server firewall if enabled:

```bash
ufw allow 6080/tcp || true
ufw allow 9222/tcp || true
ufw reload || true
```

Also open cloud security group / firewall:

- TCP `6080` for noVNC web UI
- TCP `9222` only if remote CDP access is needed

Security note: exposing CDP to the public internet is powerful and risky. Prefer using CDP from localhost (`127.0.0.1`) or via SSH tunnel when possible.

## Create Startup Script

Create `/root/start-remote-browser.sh`:

```bash
cat > /root/start-remote-browser.sh <<'EOF'
#!/bin/bash
set -e

DISPLAY_NUM="${DISPLAY_NUM:-99}"
DISPLAY=":${DISPLAY_NUM}"
WIDTH="${WIDTH:-1920}"
HEIGHT="${HEIGHT:-1080}"
DEPTH="${DEPTH:-24}"
CDP_PORT="${CDP_PORT:-9222}"
NOVNC_PORT="${NOVNC_PORT:-6080}"
VNC_PORT="${VNC_PORT:-5900}"
CHROME_PROFILE="${CHROME_PROFILE:-/root/.chromium-remote}"
START_URL="${START_URL:-about:blank}"

CHROME_BIN="${CHROME_BIN:-}"
if [ -z "$CHROME_BIN" ]; then
  if command -v chromium >/dev/null 2>&1; then
    CHROME_BIN="chromium"
  elif command -v chromium-browser >/dev/null 2>&1; then
    CHROME_BIN="chromium-browser"
  elif command -v google-chrome >/dev/null 2>&1; then
    CHROME_BIN="google-chrome"
  else
    echo "ERROR: no Chromium/Chrome binary found" >&2
    exit 1
  fi
fi

# Clean old stack. Be careful: this kills matching browser/Xvfb/noVNC processes.
pkill -9 -f "x11vnc.*${DISPLAY}" 2>/dev/null || true
pkill -9 -f "Xvfb ${DISPLAY}" 2>/dev/null || true
pkill -9 -f "websockify.*${NOVNC_PORT}" 2>/dev/null || true
pkill -9 -f "remote-debugging-port=${CDP_PORT}" 2>/dev/null || true
sleep 1

mkdir -p "$CHROME_PROFILE"

echo "[1/4] Starting Xvfb on ${DISPLAY} (${WIDTH}x${HEIGHT}x${DEPTH})..."
Xvfb "${DISPLAY}" -screen 0 "${WIDTH}x${HEIGHT}x${DEPTH}" >/tmp/remote-browser-xvfb.log 2>&1 &
sleep 1
export DISPLAY

echo "[2/4] Starting Chromium with CDP on ${CDP_PORT}..."
"$CHROME_BIN" \
  --no-sandbox \
  --disable-dev-shm-usage \
  --disable-gpu \
  --remote-debugging-port="${CDP_PORT}" \
  --remote-debugging-address=0.0.0.0 \
  --remote-allow-origins='*' \
  --window-size="${WIDTH},${HEIGHT}" \
  --start-maximized \
  --no-first-run \
  --no-default-browser-check \
  --user-data-dir="${CHROME_PROFILE}" \
  "${START_URL}" >/tmp/remote-browser-chromium.log 2>&1 &
sleep 3

echo "[3/4] Starting x11vnc on 127.0.0.1:${VNC_PORT}..."
x11vnc -display "${DISPLAY}" -forever -nopw -quiet -listen 127.0.0.1 -rfbport "${VNC_PORT}" >/tmp/remote-browser-x11vnc.log 2>&1 &
sleep 1

echo "[4/4] Starting noVNC on 0.0.0.0:${NOVNC_PORT}..."
websockify --web /opt/noVNC "${NOVNC_PORT}" "127.0.0.1:${VNC_PORT}" >/tmp/remote-browser-novnc.log 2>&1 &
sleep 1

IP=$(curl -fsS --max-time 2 ifconfig.me 2>/dev/null || hostname -I | awk '{print $1}')

echo
echo "========================================"
echo "  ✅ Remote visible browser is ready"
echo "  noVNC: http://${IP}:${NOVNC_PORT}/vnc.html"
echo "  CDP:   http://${IP}:${CDP_PORT}/json"
echo "  Local CDP endpoint: http://127.0.0.1:${CDP_PORT}/json"
echo "  Display: ${DISPLAY}"
echo "  Profile: ${CHROME_PROFILE}"
echo "========================================"
EOF

chmod +x /root/start-remote-browser.sh
```

## Start the Browser

```bash
bash /root/start-remote-browser.sh
```

Optional custom start URL:

```bash
START_URL="https://example.com" bash /root/start-remote-browser.sh
```

## Verify Setup

```bash
# CDP version endpoint should return JSON
curl -s http://127.0.0.1:9222/json/version | jq .

# noVNC page should be reachable locally
curl -s -o /dev/null -w "%{http_code}\n" http://127.0.0.1:6080/vnc.html

# Ports should be listening
ss -tlnp | grep -E '5900|6080|9222' || netstat -tlnp | grep -E '5900|6080|9222'
```

Expected:

- `/json/version` returns browser/version info
- noVNC HTTP status is `200`
- ports `6080`, `9222`, and local `5900` are listening

Then tell the user:

```text
Open: http://<SERVER_IP>:6080/vnc.html
```

If noVNC asks for connection details, use:

- Host: current host
- Port: `6080`
- Path: usually `websockify` default works from `vnc.html`; if needed use `?host=<SERVER_IP>&port=6080`

Common direct URL:

```text
http://<SERVER_IP>:6080/vnc.html?host=<SERVER_IP>&port=6080&autoconnect=true&resize=scale
```

## Control the Visible Browser via CDP

### List tabs

```bash
curl -s http://127.0.0.1:9222/json | jq .
```

### Navigate to a URL

Use Python with `websocket-client`:

```bash
python3 - <<'PY'
import json, time, urllib.request
try:
    import websocket
except ImportError:
    raise SystemExit('Install dependency: pip3 install websocket-client --break-system-packages')

tabs = json.load(urllib.request.urlopen('http://127.0.0.1:9222/json'))
ws_url = tabs[0]['webSocketDebuggerUrl']
ws = websocket.create_connection(
    ws_url,
    header={'Origin': 'http://127.0.0.1:9222'},
    timeout=20,
)

def call(method, params=None, id=1):
    ws.send(json.dumps({'id': id, 'method': method, 'params': params or {}}))
    while True:
        msg = json.loads(ws.recv())
        if msg.get('id') == id:
            return msg

call('Page.navigate', {'url': 'https://example.com'}, 1)
time.sleep(3)
resp = call('Runtime.evaluate', {'expression': 'document.title', 'returnByValue': True}, 2)
print(resp.get('result', {}).get('result', {}).get('value'))
ws.close()
PY
```

### Evaluate JavaScript

```bash
python3 - <<'PY'
import json, urllib.request
import websocket

tabs = json.load(urllib.request.urlopen('http://127.0.0.1:9222/json'))
ws = websocket.create_connection(
    tabs[0]['webSocketDebuggerUrl'],
    header={'Origin': 'http://127.0.0.1:9222'},
    timeout=20,
)

def call(method, params=None, id=1):
    ws.send(json.dumps({'id': id, 'method': method, 'params': params or {}}))
    while True:
        msg = json.loads(ws.recv())
        if msg.get('id') == id:
            return msg

expr = "({title: document.title, url: location.href, text: document.body.innerText.slice(0, 500)})"
resp = call('Runtime.evaluate', {'expression': expr, 'returnByValue': True}, 1)
print(json.dumps(resp['result']['result'].get('value'), ensure_ascii=False, indent=2))
ws.close()
PY
```

### Screenshot with CDP

```bash
python3 - <<'PY'
import base64, json, urllib.request
import websocket

tabs = json.load(urllib.request.urlopen('http://127.0.0.1:9222/json'))
ws = websocket.create_connection(
    tabs[0]['webSocketDebuggerUrl'],
    header={'Origin': 'http://127.0.0.1:9222'},
    timeout=30,
)
ws.send(json.dumps({'id': 1, 'method': 'Page.captureScreenshot', 'params': {'format': 'jpeg', 'quality': 60}}))
while True:
    msg = json.loads(ws.recv())
    if msg.get('id') == 1:
        data = msg['result']['data']
        path = '/tmp/remote-browser-screenshot.jpg'
        open(path, 'wb').write(base64.b64decode(data))
        print(path)
        break
ws.close()
PY
```

For a raw X11 screenshot, use:

```bash
DISPLAY=:99 import -window root /tmp/remote-browser-x11.png
```

`import` comes from ImageMagick. Install if needed:

```bash
apt install -y imagemagick
```

## Systemd Service Optional

If the user wants it persistent after reboot, create a systemd service:

```bash
cat > /etc/systemd/system/remote-browser.service <<'EOF'
[Unit]
Description=Remote Visible Chromium Browser via noVNC and CDP
After=network.target

[Service]
Type=simple
Environment=DISPLAY_NUM=99
Environment=WIDTH=1920
Environment=HEIGHT=1080
Environment=CDP_PORT=9222
Environment=NOVNC_PORT=6080
Environment=VNC_PORT=5900
ExecStart=/root/start-remote-browser.sh
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable --now remote-browser
systemctl status remote-browser --no-pager -l
```

Note: the startup script backgrounds several processes and then exits, so for production-grade systemd you may prefer a supervisor script that waits on child processes. For most agent tasks, running the startup script manually or via tmux is enough.

## Cloud Security Group Reminder

If the local service is running but the user cannot open noVNC:

1. Confirm local noVNC works:
   ```bash
   curl -I http://127.0.0.1:6080/vnc.html
   ```
2. Confirm port is listening on `0.0.0.0`:
   ```bash
   ss -tlnp | grep 6080
   ```
3. Open server firewall:
   ```bash
   ufw allow 6080/tcp
   ```
4. Open cloud provider security group inbound rule for TCP 6080.

For Tencent Cloud, add inbound rule in the instance security group:

```text
Protocol: TCP
Port: 6080
Source: your IP or 0.0.0.0/0 if temporary
```

## Clean Restart

```bash
pkill -9 -f 'remote-debugging-port=9222' 2>/dev/null || true
pkill -9 -f 'Xvfb :99' 2>/dev/null || true
pkill -9 -f 'x11vnc.*:99' 2>/dev/null || true
pkill -9 -f 'websockify.*6080' 2>/dev/null || true
bash /root/start-remote-browser.sh
```

Fresh profile reset:

```bash
rm -rf /root/.chromium-remote
bash /root/start-remote-browser.sh
```

Only do this if the user does not need existing login cookies.

## Common Pitfalls

1. **Using the wrong browser.** Agent browser tools often control a separate headless browser. Use CDP port `9222` for the visible noVNC browser.

2. **noVNC opens but screen is blank.** Check Xvfb, Chromium, x11vnc:
   ```bash
   ps -ef | grep -E 'Xvfb|chromium|x11vnc|websockify' | grep -v grep
   ss -tlnp | grep -E '5900|6080|9222'
   ```

3. **CDP WebSocket returns 403.** Add Chrome flag `--remote-allow-origins='*'` and connect with header `Origin: http://127.0.0.1:9222`.

4. **Remote noVNC inaccessible.** Usually cloud security group or UFW is blocking port `6080`.

5. **Chromium fails as root.** Include `--no-sandbox`.

6. **Profile lock / Chromium already running.** Kill old Chromium or use a different `CHROME_PROFILE`.

7. **Port already in use.** Change `CDP_PORT`, `NOVNC_PORT`, or `VNC_PORT`, or kill old processes.

8. **High CPU from captcha pages.** Captcha iframes can burn CPU. Kill the high-CPU Chromium renderer or restart the browser stack.

9. **User needs login persistence.** Do not delete `/root/.chromium-remote`; that directory stores cookies and sessions.

10. **Public CDP exposure is dangerous.** If `9222` is open to the internet, anyone who can reach it can control the browser. Prefer localhost CDP and only expose noVNC temporarily.

## Verification Checklist

- [ ] Dependencies installed: `xvfb`, `x11vnc`, Chromium, `websockify`, noVNC.
- [ ] `/root/start-remote-browser.sh` exists and is executable.
- [ ] `bash /root/start-remote-browser.sh` completes without fatal errors.
- [ ] `curl http://127.0.0.1:9222/json/version` returns JSON.
- [ ] `curl http://127.0.0.1:6080/vnc.html` returns HTTP 200.
- [ ] `ss -tlnp` shows ports `6080`, `9222`, `5900`.
- [ ] User can open `http://<SERVER_IP>:6080/vnc.html`.
- [ ] Agent can navigate the visible browser via CDP.
- [ ] Screenshot can be captured and shared back to user.

## Quick One-Shot Install

For a fresh Debian/Ubuntu server as root:

```bash
apt update && apt install -y xvfb x11vnc chromium git python3 python3-pip python3-websockify curl jq imagemagick
[ -d /opt/noVNC ] || git clone https://github.com/novnc/noVNC.git /opt/noVNC
ufw allow 6080/tcp || true
ufw allow 9222/tcp || true
ufw reload || true
# then create /root/start-remote-browser.sh from this skill and run it
bash /root/start-remote-browser.sh
```

## For OpenClaw / SkillHub Style Agents

If the agent uses OpenClaw-style workspace skills, place this folder at:

```text
~/.openclaw/workspace/skills/remote-browser-cdp/SKILL.md
```

If the agent uses Hermes local skills, place it at:

```text
~/.hermes/skills/software-development/remote-browser-cdp/SKILL.md
```

Then start a new agent session or reload skills so the skill becomes available.
