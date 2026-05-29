import { defineEventHandler, readBody, createError } from 'h3';
import net from 'net';

export default defineEventHandler(async (event) => {
  const body = await readBody(event);
  const { host, port, command } = body || {};

  if (!host || !port || command === undefined) {
    throw createError({
      statusCode: 400,
      statusMessage: 'Missing host, port, or command'
    });
  }

  const portInt = parseInt(port, 10);
  if (isNaN(portInt)) {
    throw createError({
      statusCode: 400,
      statusMessage: 'Port must be a valid number'
    });
  }

  return new Promise((resolve) => {
    const socket = new net.Socket();
    let dataBuffer = '';

    socket.setTimeout(4000);

    socket.connect(portInt, host, () => {
      setTimeout(() => {
        socket.write(command + '\r\n');
      }, 300);
    });

    socket.on('data', (data) => {
      dataBuffer += data.toString();
      if (dataBuffer.includes('\n') && dataBuffer.trim().endsWith('>')) {
        socket.end();
      }
    });

    socket.on('timeout', () => {
      socket.destroy();
      resolve({ success: false, output: dataBuffer + '\n[Connection Timeout]' });
    });

    socket.on('error', (err) => {
      resolve({ success: false, output: `Connection error: ${err.message}` });
    });

    socket.on('close', () => {
      resolve({ success: true, output: dataBuffer });
    });
  });
});
