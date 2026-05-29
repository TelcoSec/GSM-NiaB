import { defineEventHandler, readBody, createError } from 'h3';
import fs from 'fs';
import { execSync } from 'child_process';

export default defineEventHandler(async (event) => {
  const method = event.node.req.method;

  if (method === 'GET') {
    try {
      const path = '/etc/apt/sources.list';
      if (fs.existsSync(path)) {
        const content = fs.readFileSync(path, 'utf8');
        return { success: true, content };
      } else {
        return { success: false, content: '# Repositories file not found.' };
      }
    } catch (error: any) {
      return { success: false, error: error.message };
    }
  }

  if (method === 'POST') {
    const body = await readBody(event);
    const { content } = body || {};

    if (typeof content !== 'string') {
      throw createError({
        statusCode: 400,
        statusMessage: 'Content must be a string'
      });
    }

    try {
      const tempPath = '/tmp/nuxt_sources.list';
      fs.writeFileSync(tempPath, content);
      execSync('sudo cp /tmp/nuxt_sources.list /etc/apt/sources.list');
      fs.unlinkSync(tempPath);
      
      try {
        execSync('sudo apt update -y');
      } catch (e) {
        // Ignore network or apt locking errors
      }

      return { success: true, message: 'Repositories file updated successfully!' };
    } catch (error: any) {
      return { success: false, error: error.message };
    }
  }

  throw createError({
    statusCode: 405,
    statusMessage: 'Method Not Allowed'
  });
});
