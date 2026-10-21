import { table, text } from 'sdk/db';

// Runtime config (webhook URL + key). Set via scripts/setup-config.sh, never committed.
export const config = table('config', {
  key: text('key').primaryKey(),
  value: text('value').notNull(),
});
