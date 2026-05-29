import { defineEventHandler } from 'h3';
import Database from 'better-sqlite3';

export default defineEventHandler(async () => {
  try {
    const db = new Database('/var/lib/osmocom/hlr.db', { readonly: true });
    const stmt = db.prepare('SELECT * FROM subscriber');
    const rows = stmt.all();
    db.close();
    return { success: true, subscribers: rows };
  } catch (error: any) {
    return { success: false, error: error.message };
  }
});
