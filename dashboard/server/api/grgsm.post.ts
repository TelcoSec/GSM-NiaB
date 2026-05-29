import { defineEventHandler, readBody, createError } from 'h3';
import { exec } from 'child_process';

export default defineEventHandler(async (event) => {
  const body = await readBody(event);
  const { action, args } = body || {};

  const allowedActions = ['scan', 'info', 'capture', 'decode'];
  if (!action || !allowedActions.includes(action)) {
    throw createError({
      statusCode: 400,
      statusMessage: 'Invalid action'
    });
  }

  const sanitizedArgs = (args || '').replace(/[^a-zA-Z0-9\s\-_]/g, '');

  return new Promise((resolve) => {
    const cmd = `/usr/bin/osmo-stp ${action} ${sanitizedArgs}`.trim();

    exec(cmd, { timeout: 10000 }, (error, stdout, stderr) => {
      resolve({
        success: !error,
        output: stdout + stderr + (error ? `\n[Error: ${error.message}]` : '')
      });
    });
  });
});
