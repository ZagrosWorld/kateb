#!/usr/bin/env bash
# Usage: telegram_send.sh <chat_id> <reply_to_message_id|""> <text>
set -euo pipefail
: "${TELEGRAM_KATEB_BOT_TOKEN:?TELEGRAM_KATEB_BOT_TOKEN not set}"
[ $# -eq 3 ] || { echo "usage: $0 chat_id reply_to_message_id text" >&2; exit 2; }
BODY=$(CHAT="$1" REPLY="$2" TEXT="$3" node -e '
const b={chat_id:process.env.CHAT,text:process.env.TEXT};
if(process.env.REPLY) b.reply_parameters={message_id:Number(process.env.REPLY),allow_sending_without_reply:true};
process.stdout.write(JSON.stringify(b))')
curl -sf -X POST -H 'Content-Type: application/json' -d "$BODY" \
  "https://api.telegram.org/bot${TELEGRAM_KATEB_BOT_TOKEN}/sendMessage" >/dev/null && echo sent
