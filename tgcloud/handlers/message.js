import { api, db, fetch } from 'sdk';
import { inArray } from 'sdk/db';
import { config } from '../schema.js';

async function loadConfig() {
  const rows = await db.select().from(config)
    .where(inArray(config.key, ['webhook_url', 'webhook_key'])).all();
  const c = {};
  for (const r of rows) c[r.key] = r.value;
  return c;
}

export default async function (message) {
  const chatId = message.chat?.id;
  const media = message.voice || message.audio || null;

  let statusMessageId = null;
  if (chatId && !message.__test) {
    try { await api.setMessageReaction({ chat_id: chatId, message_id: message.message_id, reaction: [{ type: 'emoji', emoji: '👀' }] }); } catch (e) { console.warn('reaction failed', e?.description); }
    try {
      const m = await api.sendMessage({ chat_id: chatId, text: '✍️', reply_parameters: { message_id: message.message_id, allow_sending_without_reply: true } });
      statusMessageId = m?.message_id ?? null;
    } catch (e) { console.warn('status msg failed', e?.description); }
    try { await api.sendChatAction({ chat_id: chatId, action: 'typing' }); } catch (e) { console.warn('typing failed', e?.description); }
  }

  const voice = media ? {
    file_id: media.file_id,
    file_unique_id: media.file_unique_id ?? null,
    mime: media.mime_type || (message.voice ? 'audio/ogg' : 'application/octet-stream'),
    duration: media.duration ?? null,
  } : null;

  const payload = {
    chat_id: chatId,
    message_id: message.message_id,
    from_id: message.from?.id ?? null,
    username: message.from?.username ?? null,
    text: message.text ?? null,
    voice,
    caption: message.caption ?? null,
    status_message_id: statusMessageId,
  };

  const c = await loadConfig();
  if (!c.webhook_url || !c.webhook_key) {
    console.error('config missing: run scripts/setup-config.sh');
    return { ok: false, reason: 'no-config' };
  }

  const res = await fetch(c.webhook_url, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${c.webhook_key}` },
    body: JSON.stringify(payload),
  });
  console.log('webhook status', res.status);
  return { ok: res.ok, status: res.status };
}
