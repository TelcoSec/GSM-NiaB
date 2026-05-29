import { defineEventHandler, readBody, createError } from 'h3';
import { execSync } from 'child_process';

const ALLOWED_SERVICES = [
  'osmo-hlr',
  'osmo-msc',
  'osmo-mgw',
  'osmo-ggsn',
  'osmo-sgsn',
  'osmo-stp',
  'osmo-bsc',
  'osmo-bts',
  'asterisk'
];

const ALLOWED_ACTIONS = ['start', 'stop', 'restart', 'enable', 'disable', 'status'];

export default defineEventHandler(async (event) => {
  const body = await readBody(event);
  const { service, action } = body || {};

  if (!service || !ALLOWED_SERVICES.includes(service)) {
    throw createError({
      statusCode: 400,
      statusMessage: 'Invalid or missing service name'
    });
  }

  if (!action || !ALLOWED_ACTIONS.includes(action)) {
    throw createError({
      statusCode: 400,
      statusMessage: 'Invalid or missing action'
    });
  }

  try {
    let output = '';
    if (action === 'status') {
      output = execSync(`systemctl status ${service}`).toString();
    } else {
      execSync(`sudo systemctl ${action} ${service}`);
      output = `Service ${service} successfully ${action}ed.`;
    }
    return {
      success: true,
      output
    };
  } catch (error: unknown) {
    const err = error as { stdout?: Buffer; stderr?: Buffer; message?: string };
    return {
      success: false,
      output: err.stdout?.toString() || err.stderr?.toString() || err.message || 'Unknown error'
    };
  }
});
