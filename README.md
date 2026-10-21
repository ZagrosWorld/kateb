# Kateb — Telegram bot (@zagrosworld_kateb_bot)

Kateb (کاتب) is a Persian book writer/editor assistant. This repo holds its Telegram front end.

## Architecture

```
Telegram user ──► Telegram Serverless (tgcloud/)  ──HTTPS POST──►  Grok Bot webhook routine "Kateb on Telegram" (box)
                   • 👀 reaction                                       • access check (allowlist / invites)
                   • ✍️ status message                                  • voice → transcript (box/transcribe.*)
                   • forwards JSON payload                              • Kateb work (books repo, approvals)
                                                                        • stage emojis + final reply via Bot API (box/telegram_*.sh)
```

- **`tgcloud/`** — Telegram Serverless (JavaScript only). `handlers/message.js` receives every message, reacts 👀, sends an animated ✍️ status message, shows "typing", and POSTs to the routine webhook:
  `{chat_id, message_id, from_id, username, text, voice:{file_id,file_unique_id,mime,duration}|null, caption, status_message_id}`
  (`Authorization: Bearer <webhook key>`). It never writes the real reply itself. The webhook URL/key live only in the serverless DB table `config` (`tgcloud/schema.js`).
- **`box/`** — scripts the routine runs on the box (Python STT can't run in the serverless sandbox).

## Working indicators

1. 👀 reaction on the user's message, immediately.
2. A standalone animated emoji message that changes with the stage (only emojis from Telegram's animated set):
   🎙️ transcribing · 🔍 reading books · ✍️ writing · 📚 saving to repo · 🔭 web research · 🗂️ managing invites.
3. The status message is deleted and replaced by the reply, prefixed 🤔 question · 💡 proposal · 📖 answer · ✅ done.

## Invites / access

Handled by the box routine; allowed user ids are in `/workspace/kateb/telegram_allowlist.txt` (one per line, owner first).

- `/start` — first sender becomes the owner (locks the bot).
- `/invite` — single-use deep link, valid 7 days; whoever opens it gets full access (including approvals). Owner is notified.
- `/members` — list who has access.
- `/remove @username` — revoke access (the owner can't be removed).

Commands are registered in the bot menu (Persian descriptions) via `setMyCommands`.

## Voice pipeline

Telegram voice/audio → handler forwards `file_id` → `box/telegram_fetch_voice.sh` downloads via Bot API `getFile` → `box/transcribe.sh` / `transcribe.py` (faster-whisper, Persian, VAD off; venv `/workspace/kateb/venv`, models `/workspace/kateb/models`, needs ffmpeg) → transcript. See `box/README-stt.md`.

## Box scripts

| Script | Usage |
| --- | --- |
| `telegram_send.sh` | `<chat_id> <reply_to_message_id\|""> <text>` — send a message |
| `telegram_status.sh` | `<chat_id> <old_status_id\|""> <reply_to_message_id> <emoji>` — swap the stage emoji, prints new message id |
| `telegram_finish.sh` | `<chat_id> <status_message_id\|""> <reply_to_message_id> <text\|"">` — delete status, send reply |
| `telegram_fetch_voice.sh` | `<file_id> [out_dir]` — download a voice file, prints path |
| `transcribe.sh` / `transcribe.py` | Persian speech-to-text |
| `fetch_slack_file.sh` | `<file_id> [out_dir]` — download a Slack file (Slack voice notes) |

## Secrets (env vars, never committed)

| Name | Used by | What |
| --- | --- | --- |
| `TGCLOUD_TOKEN` | tgcloud CLI | BotFather → Serverless → CLI Access token |
| `TELEGRAM_KATEB_BOT_TOKEN` | `box/telegram_*.sh` | Bot API token |
| `KATEB_WEBHOOK_URL` | `scripts/setup-config.sh` | routine webhook URL |
| `KATEB_WEBHOOK_KEY` | `scripts/setup-config.sh` | routine webhook key |
| `SLACK_KATEB_USER_TOKEN` | `box/fetch_slack_file.sh` | Slack user token (files:read) |

## Deploy

```bash
npm install
npx tgcloud push              # deploy modules
npx tgcloud migrate --safe    # create/upgrade tables
./scripts/setup-config.sh     # write webhook URL+key into the DB (re-run on key rotation)
npx tgcloud run handlers/message '{ __test: true, message_id: 1, chat: { id: 1 }, from: { id: 1 }, text: "test" }'
npx tgcloud webhook           # check Telegram webhook is in sync
```

`scripts/setup-config.sh` copies `setup/setConfig.js` into `tgcloud/endpoints/` temporarily, runs it with `tgcloud run`, then deletes it, so the setter is never deployed. `__test: true` skips the reaction/status messages in manual runs.
