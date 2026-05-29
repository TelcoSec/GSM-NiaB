import { defineEventHandler } from 'h3';
import os from 'os';
import { execSync } from 'child_process';
import fs from 'fs';

// Store previous CPU tick state for differential CPU calculation
let lastCpu = { idle: 0, total: 0 };

function calculateCpuUsage() {
  const cpus = os.cpus();
  if (!cpus || cpus.length === 0) return 0;
  
  let user = 0, nice = 0, sys = 0, idle = 0, irq = 0;
  for (const cpu of cpus) {
    user += cpu.times.user;
    nice += cpu.times.nice;
    sys += cpu.times.sys;
    idle += cpu.times.idle;
    irq += cpu.times.irq;
  }
  const total = user + nice + sys + idle + irq;
  
  const diffIdle = idle - lastCpu.idle;
  const diffTotal = total - lastCpu.total;
  
  lastCpu = { idle, total };
  
  if (diffTotal === 0) return 0;
  return Math.round((1 - diffIdle / diffTotal) * 100);
}

function getDiskUsage() {
  try {
    const output = execSync('df -h /').toString();
    const lines = output.trim().split('\n');
    if (lines.length > 1) {
      const parts = lines[1].split(/\s+/);
      const percentStr = parts[4].replace('%', '');
      return parseInt(percentStr, 10) || 0;
    }
  } catch (e) {}
  return 0;
}

function getServiceStatus(service: string) {
  try {
    const activeState = execSync(`systemctl is-active ${service}`).toString().trim();
    return activeState;
  } catch (e) {
    return 'inactive';
  }
}

export default defineEventHandler(async () => {
  const totalMem = os.totalmem();
  const freeMem = os.freemem();
  const ramPercent = totalMem > 0 ? Math.round(((totalMem - freeMem) / totalMem) * 100) : 0;

  let netSent = 0;
  let netRecv = 0;
  try {
    const netDev = fs.readFileSync('/proc/net/dev', 'utf8');
    for (const line of netDev.split('\n')) {
      if (line.includes(':')) {
        const parts = line.split(':')[1].trim().split(/\s+/);
        netRecv += parseInt(parts[0], 10) || 0;
        netSent += parseInt(parts[8], 10) || 0;
      }
    }
  } catch (e) {}

  const services = [
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

  const serviceStatuses: Record<string, string> = {};
  for (const svc of services) {
    serviceStatuses[svc] = getServiceStatus(svc);
  }

  return {
    cpu: calculateCpuUsage(),
    ram: ramPercent,
    disk: getDiskUsage(),
    network: {
      bytesSent: netSent,
      bytesRecv: netRecv
    },
    services: serviceStatuses
  };
});
