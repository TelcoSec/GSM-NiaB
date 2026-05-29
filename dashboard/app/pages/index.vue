<template>
  <div>
    <header class="page-header">
      <h2>Network Status & Telemetry</h2>
      <p>Real-time system telemetry and core GSM service monitoring</p>
    </header>

    <div class="dashboard-grid">
      <!-- CPU Gauge -->
      <div class="glass-panel gauge-card">
        <h3>CPU Usage</h3>
        <div class="gauge-container">
          <svg viewBox="0 0 100 100" class="gauge-svg">
            <circle cx="50" cy="50" r="40" class="gauge-bg" />
            <circle cx="50" cy="50" r="40" class="gauge-fill cpu-fill" :style="cpuStyle" />
            <text x="50" y="55" class="gauge-text">{{ stats.cpu }}%</text>
          </svg>
        </div>
      </div>

      <!-- RAM Gauge -->
      <div class="glass-panel gauge-card">
        <h3>RAM Usage</h3>
        <div class="gauge-container">
          <svg viewBox="0 0 100 100" class="gauge-svg">
            <circle cx="50" cy="50" r="40" class="gauge-bg" />
            <circle cx="50" cy="50" r="40" class="gauge-fill ram-fill" :style="ramStyle" />
            <text x="50" y="55" class="gauge-text">{{ stats.ram }}%</text>
          </svg>
        </div>
      </div>

      <!-- Disk Gauge -->
      <div class="glass-panel gauge-card">
        <h3>Disk Space</h3>
        <div class="gauge-container">
          <svg viewBox="0 0 100 100" class="gauge-svg">
            <circle cx="50" cy="50" r="40" class="gauge-bg" />
            <circle cx="50" cy="50" r="40" class="gauge-fill disk-fill" :style="diskStyle" />
            <text x="50" y="55" class="gauge-text">{{ stats.disk }}%</text>
          </svg>
        </div>
      </div>
    </div>

    <div class="network-and-services">
      <!-- Network Stats -->
      <div class="glass-panel network-panel">
        <h3>Network Bandwidth</h3>
        <div class="net-metrics">
          <div class="net-metric">
            <Icon name="lucide:arrow-up-circle" class="net-icon sent" />
            <div>
              <span class="label">Total Sent</span>
              <span class="value">{{ formatBytes(stats.network.bytesSent) }}</span>
            </div>
          </div>
          <div class="net-metric">
            <Icon name="lucide:arrow-down-circle" class="net-icon recv" />
            <div>
              <span class="label">Total Received</span>
              <span class="value">{{ formatBytes(stats.network.bytesRecv) }}</span>
            </div>
          </div>
        </div>
      </div>

      <!-- Services Grid -->
      <div class="glass-panel services-panel">
        <h3>GSM Core Services</h3>
        <div class="services-status-grid">
          <div v-for="(status, name) in stats.services" :key="name" class="service-status-card">
            <div class="service-meta">
              <span :class="['led-indicator', status === 'active' ? 'led-active' : 'led-inactive']"></span>
              <span class="service-name">{{ getFriendlyName(name) }}</span>
            </div>
            <div class="service-actions">
              <button @click="controlService(name, 'start')" class="btn-icon start" title="Start">
                <Icon name="lucide:play" />
              </button>
              <button @click="controlService(name, 'stop')" class="btn-icon stop" title="Stop">
                <Icon name="lucide:square" />
              </button>
              <button @click="controlService(name, 'restart')" class="btn-icon restart" title="Restart">
                <Icon name="lucide:rotate-cw" />
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue';

const stats = ref({
  cpu: 0,
  ram: 0,
  disk: 0,
  network: { bytesSent: 0, bytesRecv: 0 },
  services: {}
});

let intervalId = null;

const fetchStats = async () => {
  try {
    const data = await $fetch('/api/stats');
    stats.value = data;
  } catch (e) {
    console.error('Failed to fetch stats:', e);
  }
};

onMounted(() => {
  fetchStats();
  intervalId = setInterval(fetchStats, 2000);
});

onUnmounted(() => {
  if (intervalId) clearInterval(intervalId);
});

const getCircleStrokeDash = (percentage) => {
  const radius = 40;
  const circumference = 2 * Math.PI * radius;
  const strokeDashoffset = circumference - (percentage / 100) * circumference;
  return {
    strokeDasharray: `${circumference} ${circumference}`,
    strokeDashoffset
  };
};

const cpuStyle = computed(() => getCircleStrokeDash(stats.value.cpu));
const ramStyle = computed(() => getCircleStrokeDash(stats.value.ram));
const diskStyle = computed(() => getCircleStrokeDash(stats.value.disk));

const formatBytes = (bytes) => {
  if (bytes === 0) return '0 Bytes';
  const k = 1024;
  const sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB'];
  const i = Math.floor(Math.log(bytes) / Math.log(k));
  return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
};

const getFriendlyName = (name) => {
  const map = {
    'osmo-hlr': 'Home Location Register (HLR)',
    'osmo-msc': 'Mobile Switching Center (MSC)',
    'osmo-mgw': 'Media Gateway (MGW)',
    'osmo-ggsn': 'GGSN (GPRS Gateway Support Node)',
    'osmo-sgsn': 'SGSN (Serving GPRS Support Node)',
    'osmo-stp': 'Signaling Transfer Point (STP)',
    'osmo-bsc': 'Base Station Controller (BSC)',
    'osmo-bts': 'Base Transceiver Station (BTS)',
    'asterisk': 'Asterisk PBX'
  };
  return map[name] || name;
};

const controlService = async (service, action) => {
  try {
    const res = await $fetch('/api/services', {
      method: 'POST',
      body: { service, action }
    });
    if (res.success) {
      fetchStats();
    }
  } catch (e) {
    console.error(e);
  }
};
</script>

<style scoped>
.page-header {
  margin-bottom: 2rem;
}
.page-header h2 {
  font-size: 1.75rem;
  margin-bottom: 0.25rem;
}
.page-header p {
  font-size: 0.95rem;
}

.gauge-card {
  text-align: center;
}
.gauge-card h3 {
  font-size: 1.05rem;
  color: var(--text-secondary);
  margin-bottom: 1rem;
}

.gauge-svg {
  width: 140px;
  height: 140px;
  transform: rotate(-90deg);
}
.gauge-bg {
  fill: none;
  stroke: rgba(255, 255, 255, 0.03);
  stroke-width: 8;
}
.gauge-fill {
  fill: none;
  stroke-width: 8;
  stroke-linecap: round;
  transition: stroke-dashoffset 0.6s ease;
}
.cpu-fill {
  stroke: var(--accent-cyan);
  filter: drop-shadow(0 0 4px var(--accent-cyan-glow));
}
.ram-fill {
  stroke: var(--accent-purple);
  filter: drop-shadow(0 0 4px var(--accent-purple-glow));
}
.disk-fill {
  stroke: var(--accent-amber);
  filter: drop-shadow(0 0 4px var(--accent-amber-glow));
}

.gauge-text {
  fill: var(--text-primary);
  font-size: 1.15rem;
  font-weight: 700;
  text-anchor: middle;
  transform: rotate(90deg);
  transform-origin: 50px 50px;
}

.network-and-services {
  display: grid;
  grid-template-columns: 1fr 2fr;
  gap: 1.5rem;
  margin-top: 1.5rem;
}

.net-metrics {
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
  margin-top: 1.5rem;
}

.net-metric {
  display: flex;
  align-items: center;
  gap: 1rem;
}
.net-icon {
  font-size: 2.2rem;
}
.net-icon.sent {
  color: var(--accent-cyan);
}
.net-icon.recv {
  color: var(--accent-purple);
}

.net-metric .label {
  display: block;
  font-size: 0.8rem;
  color: var(--text-secondary);
  text-transform: uppercase;
  letter-spacing: 0.05em;
}
.net-metric .value {
  font-size: 1.3rem;
  font-weight: 700;
}

.services-status-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 1rem;
  margin-top: 1rem;
}

.service-status-card {
  background: rgba(255, 255, 255, 0.02);
  border: 1px solid var(--border-color);
  border-radius: 10px;
  padding: 1rem;
  display: flex;
  align-items: center;
  justify-content: space-between;
  transition: var(--transition-smooth);
}
.service-status-card:hover {
  border-color: rgba(255, 255, 255, 0.1);
  background: rgba(255, 255, 255, 0.03);
}

.service-meta {
  display: flex;
  align-items: center;
}
.service-name {
  font-weight: 600;
  font-size: 0.9rem;
}

.service-actions {
  display: flex;
  gap: 0.4rem;
}

.btn-icon {
  width: 28px;
  height: 28px;
  border-radius: 6px;
  border: 1px solid var(--border-color);
  background: transparent;
  color: var(--text-secondary);
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  font-size: 0.8rem;
  transition: var(--transition-smooth);
}
.btn-icon:hover {
  color: var(--text-primary);
  background: rgba(255, 255, 255, 0.05);
}
.btn-icon.start:hover {
  color: var(--status-active);
  border-color: var(--status-active);
}
.btn-icon.stop:hover {
  color: var(--status-inactive);
  border-color: var(--status-inactive);
}
.btn-icon.restart:hover {
  color: var(--accent-amber);
  border-color: var(--accent-amber);
}

@media (max-width: 1024px) {
  .network-and-services {
    grid-template-columns: 1fr;
  }
}
</style>
