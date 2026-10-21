#!/usr/bin/env bash
# Usage: telegram_finish.sh <chat_id> <status_message_id|""> <reply_to_message_id> <text|"">
# Deletes the ✍️ status message (if any), then sends the reply. Empty text = delete only.
set -euo pipefail
: "${TELEGRAM_KATEB_BOT_TOKEN:?TELEGRAM_KATEB_BOT_TOKEN not set}"
[ $# -eq 4 ] || { echo "usage: $0 chat_id status_message_id reply_to_message_id text" >&2; exit 2; }
API="https://api.telegram.org/bot${TELEGRAM_KATEB_BOT_TOKEN}"
if [ -n "$2" ]; then
  curl -sf -X POST -H 'Content-Type: application/json' \
    -d "{\"chat_id\":$1,\"message_id\":$2}" "$API/deleteMessage" >/dev/null || echo "delete failed" >&2
fi
[ -n "$4" ] || { echo "deleted"; exit 0; }
BODY=$(CHAT="$1" REPLY="$3" TEXT="$4" node -e '
const b={chat_id:process.env.CHAT,text:process.env.TEXT};
if(process.env.REPLY) b.reply_parameters={message_id:Number(process.env.REPLY),allow_sending_without_reply:true};
process.stdout.write(JSON.stringify(b))')
curl -sf -X POST -H 'Content-Type: application/json' -d "$BODY" "$API/sendMessage" >/dev/null && echo sent
