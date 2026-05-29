import { defineEventHandler, getQuery, readBody, createError } from 'h3';
import fs from 'fs';
import { execSync } from 'child_process';

const CONFIG_MAP: Record<string, string> = {
  'osmo-hlr': '/etc/osmocom/osmo-hlr.cfg',
  'osmo-msc': '/etc/osmocom/osmo-msc.cfg',
  'osmo-bsc': '/etc/osmocom/osmo-bsc.cfg',
  'osmo-bts': '/etc/osmocom/osmo-bts.cfg',
  'osmo-ggsn': '/etc/osmocom/osmo-ggsn.cfg',
  'osmo-sgsn': '/etc/osmocom/osmo-sgsn.cfg',
  'osmo-mgw': '/etc/osmocom/osmo-mgw.cfg',
  'osmo-stp': '/etc/osmocom/osmo-stp.cfg',
  'asterisk-sip': '/etc/asterisk/sip.conf',
  'asterisk-rtp': '/etc/asterisk/rtp.conf',
  'asterisk-extensions': '/etc/asterisk/extensions.conf'
};

export default defineEventHandler(async (event) => {
  const method = event.node.req.method;

  if (method === 'GET') {
    const query = getQuery(event);
    const service = query.service as string;

    if (!service || !CONFIG_MAP[service]) {
      throw createError({
        statusCode: 400,
        statusMessage: 'Invalid or missing service config identifier'
      });
    }

    const path = CONFIG_MAP[service];
    try {
      if (fs.existsSync(path)) {
        const content = fs.readFileSync(path, 'utf8');
        return { success: true, content };
      } else {
        return { success: false, content: `# Configuration file not found at ${path}` };
      }
    } catch (error: any) {
      return { success: false, error: error.message };
    }
  }

  if (method === 'POST') {
    const body = await readBody(event);
    const { service, content } = body || {};

    if (!service || !CONFIG_MAP[service]) {
      throw createError({
        statusCode: 400,
        statusMessage: 'Invalid or missing service config identifier'
      });
    }

    if (typeof content !== 'string') {
      throw createError({
        statusCode: 400,
        statusMessage: 'Config content must be a string'
      });
    }

    const path = CONFIG_MAP[service];
    const tempPath = `/tmp/nuxt_config_${service}.cfg`;

    try {
      fs.writeFileSync(tempPath, content);
      execSync(`sudo cp ${tempPath} ${path}`);
      fs.unlinkSync(tempPath);

      if (service.startsWith('asterisk-')) {
        try {
          execSync(`sudo asterisk -rx "reload"`);
        } catch (e) {
          // If asterisk is not running, ignore reload error
        }
      } else {
        try {
          execSync(`sudo systemctl restart ${service}`);
        } catch (e) {
          // If systemd service is inactive, ignore restart error
        }
      }

      return { success: true, message: `Configuration for ${service} updated and service reloaded.` };
    } catch (error: any) {
      return { success: false, error: error.message };
    }
  }

  throw createError({
    statusCode: 405,
    statusMessage: 'Method Not Allowed'
  });
});
