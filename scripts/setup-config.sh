#!/usr/bin/env bash
# Writes KATEB_WEBHOOK_URL / KATEB_WEBHOOK_KEY from the env into the serverless DB config table.
set -euo pipefail
cd "$(dirname "$0")/.."
: "${KATEB_WEBHOOK_URL:?}" "${KATEB_WEBHOOK_KEY:?}"
mkdir -p tgcloud/endpoints
cp setup/setConfig.js tgcloud/endpoints/setConfig.js
trap 'rm -f tgcloud/endpoints/setConfig.js; rmdir tgcloud/endpoints 2>/dev/null || true' EXIT
ARGS=$(node -e 'process.stdout.write(JSON.stringify({webhook_url:process.env.KATEB_WEBHOOK_URL,webhook_key:process.env.KATEB_WEBHOOK_KEY}))')
npx tgcloud run endpoints/setConfig "$ARGS" 2>&1 | sed -e "s#${KATEB_WEBHOOK_KEY}#***#g" -e "s#${KATEB_WEBHOOK_URL}#***#g"
