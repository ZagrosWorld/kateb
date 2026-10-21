#!/usr/bin/env bash
# Usage: fetch_slack_file.sh <slack_file_id> [out_dir]  -> prints saved path
set -euo pipefail
FID="$1"; OUT="${2:-/workspace/kateb/inbox}"; mkdir -p "$OUT"
INFO=$(curl -sf -H "Authorization: Bearer $SLACK_KATEB_USER_TOKEN" "https://slack.com/api/files.info?file=$FID")
URL=$(echo "$INFO" | python3 -c "import sys,json;d=json.load(sys.stdin);assert d.get('ok'),d.get('error');print(d['file']['url_private_download'])")
NAME=$(echo "$INFO" | python3 -c "import sys,json;print(json.load(sys.stdin)['file']['name'])")
DEST="$OUT/${FID}_${NAME}"
curl -sf -L -H "Authorization: Bearer $SLACK_KATEB_USER_TOKEN" -o "$DEST" "$URL"
echo "$DEST"
