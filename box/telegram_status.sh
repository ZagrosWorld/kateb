#!/usr/bin/env bash
# usage: telegram_status.sh <chat_id> <old_status_id|""> <reply_to_message_id> <emoji>
# deletes old status msg, sends new standalone emoji (animated), prints new message_id
set -u
API="https://api.telegram.org/bot${TELEGRAM_KATEB_BOT_TOKEN}"
[ -n "$2" ] && curl -sf "$API/deleteMessage" -d chat_id="$1" -d message_id="$2" >/dev/null || true
curl -sf "$API/sendMessage" -d chat_id="$1" -d reply_to_message_id="$3" --data-urlencode text="$4" \
 | python3 -c "import sys,json;print(json.load(sys.stdin)['result']['message_id'])" 2>/dev/null || { echo "status failed" >&2; exit 1; }
