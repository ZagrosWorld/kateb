// LOCAL-ONLY one-off module. Lives outside tgcloud/ so it is never deployed.
// scripts/setup-config.sh copies it into tgcloud/endpoints/ temporarily, runs it
// with `tgcloud run`, then removes it.
import { db } from 'sdk';
import { config } from '../schema.js';

export default async function (input) {
  for (const k of ['webhook_url', 'webhook_key']) {
    if (!input[k]) throw new Error('missing ' + k);
    await db.insert(config).values({ key: k, value: input[k] })
      .onConflictDoUpdate({ target: config.key, set: { value: input[k] } }).run();
  }
  return { ok: true, keys: ['webhook_url', 'webhook_key'] };
}
