#!/usr/bin/env bash
# Usage: telegram_fetch_voice.sh <file_id> [out_dir]  -> prints downloaded path
set -euo pipefail
fid="${1:?file_id required}"; out="${2:-/workspace/kateb/inbox}"
: "${TELEGRAM_KATEB_BOT_TOKEN:?TELEGRAM_KATEB_BOT_TOKEN not set}"
mkdir -p "$out"
api="https://api.telegram.org/bot${TELEGRAM_KATEB_BOT_TOKEN}"
info=$(curl -sf --get "$api/getFile" --data-urlencode "file_id=$fid") || { echo "getFile failed" >&2; exit 1; }
read -r path uid < <(python3 -c 'import sys,json;r=json.load(sys.stdin)["result"];print(r["file_path"],r["file_unique_id"])' <<<"$info") || { echo "bad getFile response" >&2; exit 1; }
ext="${path##*.}"; [ "$ext" = "$path" ] && ext=ogg
dest="$out/tg_${uid}.${ext}"
curl -sf -o "$dest" "https://api.telegram.org/file/bot${TELEGRAM_KATEB_BOT_TOKEN}/${path}" || { echo "download failed" >&2; exit 1; }
echo "$dest"
