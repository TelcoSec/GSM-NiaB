<template>
  <div>
    <header class="page-header">
      <h2>{{ getFriendlyName(serviceId) }}</h2>
      <p>{{ getServiceDescription(serviceId) }}</p>
    </header>

    <div class="service-layout">
      <!-- Left Column: Service Actions & Status -->
      <div class="control-panel">
        <div class="glass-panel card-control">
          <h3>Service Operations</h3>
          <div class="operation-buttons">
            <button @click="runAction('start')" class="btn btn-primary">
              <Icon name="lucide:play" /> Start
            </button>
            <button @click="runAction('stop')" class="btn btn-danger">
              <Icon name="lucide:square" /> Stop
            </button>
            <button @click="runAction('restart')" class="btn btn-secondary">
              <Icon name="lucide:rotate-cw" /> Restart
            </button>
            <button @click="runAction('enable')" class="btn btn-secondary">
              <Icon name="lucide:check-circle" /> Enable
            </button>
            <button @click="runAction('disable')" class="btn btn-secondary">
              <Icon name="lucide:minus-circle" /> Disable
            </button>
            <button @click="runAction('status')" class="btn btn-secondary">
              <Icon name="lucide:activity" /> Log Status
            </button>
          </div>

          <div v-if="actionStatus" class="status-output">
            <div class="status-header">Console Output</div>
            <pre class="status-pre">{{ actionStatus }}</pre>
          </div>
        </div>
      </div>

      <!-- Right Column: Configuration File Editor -->
      <div class="config-panel">
        <div class="glass-panel editor-card">
          <div class="editor-header">
            <h3>Configuration Editor</h3>
            <!-- Tabs for Asterisk -->
            <div v-if="isAsterisk" class="tabs-container">
              <button 
                v-for="tab in asteriskTabs" 
                :key="tab.id" 
                @click="selectAsteriskTab(tab.id)"
                :class="['tab-btn', activeAsteriskTab === tab.id ? 'active' : '']"
              >
                {{ tab.label }}
              </button>
            </div>
            <span v-else class="file-path">{{ getFilePath(serviceId) }}</span>
          </div>

          <form @submit.prevent="saveConfig" class="editor-form">
            <div class="textarea-container">
              <textarea 
                v-model="configContent" 
                class="config-textarea" 
                rows="18"
                placeholder="Loading configuration..."
              ></textarea>
            </div>
            <div class="form-actions">
              <button type="submit" class="btn btn-primary" :disabled="saving">
                <Icon name="lucide:save" /> {{ saving ? 'Saving...' : 'Save Configuration' }}
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, watch, onMounted } from 'vue';
import { useRoute } from 'vue-router';
import { useToast } from '#imports';

const route = useRoute();
const serviceId = ref(route.params.name);

const configContent = ref('');
const actionStatus = ref('');
const saving = ref(false);

const isAsterisk = ref(serviceId.value === 'asterisk');
const activeAsteriskTab = ref('asterisk-sip');
const asteriskTabs = [
  { id: 'asterisk-sip', label: 'sip.conf' },
  { id: 'asterisk-rtp', label: 'rtp.conf' },
  { id: 'asterisk-extensions', label: 'extensions.conf' }
];

const toast = useToast();

const loadConfig = async () => {
  const targetId = isAsterisk.value ? activeAsteriskTab.value : serviceId.value;
  try {
    const res = await $fetch(`/api/config?service=${targetId}`);
    if (res.success) {
      configContent.value = res.content;
    } else {
      configContent.value = res.error || '# Failed to load configuration';
    }
  } catch (e) {
    configContent.value = `# Error fetching configuration: ${e.message}`;
  }
};

const saveConfig = async () => {
  const targetId = isAsterisk.value ? activeAsteriskTab.value : serviceId.value;
  saving.value = true;
  try {
    const res = await $fetch('/api/config', {
      method: 'POST',
      body: { service: targetId, content: configContent.value }
    });
    if (res.success) {
      toast.add({ title: 'Success', description: res.message, color: 'green' });
    } else {
      toast.add({ title: 'Error', description: res.error, color: 'red' });
    }
  } catch (e) {
    toast.add({ title: 'Error', description: e.message, color: 'red' });
  } finally {
    saving.value = false;
  }
};

const runAction = async (action) => {
  actionStatus.value = `Executing sudo systemctl ${action} ${serviceId.value}...`;
  try {
    const res = await $fetch('/api/services', {
      method: 'POST',
      body: { service: serviceId.value, action }
    });
    actionStatus.value = res.output;
  } catch (e) {
    actionStatus.value = `Error running command: ${e.message}`;
  }
};

const selectAsteriskTab = (tabId) => {
  activeAsteriskTab.value = tabId;
  loadConfig();
};

watch(() => route.params.name, (newName) => {
  if (newName) {
    serviceId.value = newName;
    isAsterisk.value = newName === 'asterisk';
    activeAsteriskTab.value = 'asterisk-sip';
    actionStatus.value = '';
    loadConfig();
  }
});

onMounted(() => {
  loadConfig();
});

const getFriendlyName = (name) => {
  const map = {
    'osmo-hlr': 'OsmoHLR (Home Location Register)',
    'osmo-msc': 'OsmoMSC (Mobile Switching Center)',
    'osmo-mgw': 'OsmoMGW (Media Gateway)',
    'osmo-ggsn': 'OsmoGGSN (GPRS Gateway)',
    'osmo-sgsn': 'OsmoSGSN (Serving GPRS Support)',
    'osmo-stp': 'OsmoSTP (Signaling Transfer Point)',
    'osmo-bsc': 'OsmoBSC (Base Station Controller)',
    'osmo-bts': 'OsmoBTS (Base Transceiver Station)',
    'asterisk': 'Asterisk PBX Core'
  };
  return map[name] || name;
};

const getServiceDescription = (name) => {
  const map = {
    'osmo-hlr': 'Database repository storing subscriber identities (IMSIs), MSISDNs, and cryptographic authentication tokens.',
    'osmo-msc': 'Coordinates signaling, manages call connection establish/tear-down, and handles voice call routing.',
    'osmo-mgw': 'Bridges media trunks between GSM air interface and IP-based voice channels.',
    'osmo-ggsn': 'GPRS Gateway routing packages between internal mobile GPRS network and external Internet interfaces.',
    'osmo-sgsn': 'Responsible for the delivery of data packets from and to the mobile stations within its geographical service area.',
    'osmo-stp': 'Handles core SS7/SIGTRAN signaling transfer routes between different telecommunication nodes.',
    'osmo-bsc': 'Controls radio transmitters, schedules timeslots, and handles handovers for base stations.',
    'osmo-bts': 'Base station transceiver managing physical radio links (air interface) with the connected mobile terminals.',
    'asterisk': 'Telephony exchange engine managing SIP routing, SIP client registry, and interactive dialplans.'
  };
  return map[name] || '';
};

const getFilePath = (name) => {
  const map = {
    'osmo-hlr': '/etc/osmocom/osmo-hlr.cfg',
    'osmo-msc': '/etc/osmocom/osmo-msc.cfg',
    'osmo-mgw': '/etc/osmocom/osmo-mgw.cfg',
    'osmo-ggsn': '/etc/osmocom/osmo-ggsn.cfg',
    'osmo-sgsn': '/etc/osmocom/osmo-sgsn.cfg',
    'osmo-stp': '/etc/osmocom/osmo-stp.cfg',
    'osmo-bsc': '/etc/osmocom/osmo-bsc.cfg',
    'osmo-bts': '/etc/osmocom/osmo-bts.cfg'
  };
  return map[name] || '';
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

.service-layout {
  display: grid;
  grid-template-columns: 1fr 2fr;
  gap: 1.5rem;
}

.card-control h3, .editor-card h3 {
  font-size: 1.1rem;
  margin-bottom: 1.5rem;
  color: var(--text-secondary);
}

.operation-buttons {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 0.75rem;
}

.operation-buttons .btn {
  width: 100%;
  font-size: 0.85rem;
}

.status-output {
  margin-top: 1.5rem;
  border-top: 1px solid var(--border-color);
  padding-top: 1.5rem;
}

.status-header {
  font-size: 0.75rem;
  text-transform: uppercase;
  color: var(--text-secondary);
  font-weight: 700;
  margin-bottom: 0.5rem;
}

.status-pre {
  background: #040810;
  border: 1px solid var(--border-color);
  border-radius: 8px;
  padding: 1rem;
  font-family: monospace;
  font-size: 0.8rem;
  color: #38bdf8;
  max-height: 250px;
  overflow-y: auto;
  white-space: pre-wrap;
}

.editor-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1rem;
}

.editor-header h3 {
  margin-bottom: 0;
}

.file-path {
  font-family: monospace;
  font-size: 0.75rem;
  color: var(--accent-cyan);
  background: var(--bg-secondary);
  padding: 0.25rem 0.5rem;
  border-radius: 4px;
}

.tabs-container {
  display: flex;
  gap: 0.5rem;
}

.tab-btn {
  background: transparent;
  color: var(--text-secondary);
  border: 1px solid var(--border-color);
  padding: 0.3rem 0.75rem;
  border-radius: 6px;
  cursor: pointer;
  font-size: 0.8rem;
  transition: var(--transition-smooth);
}
.tab-btn:hover {
  color: var(--text-primary);
  background: rgba(255, 255, 255, 0.05);
}
.tab-btn.active {
  color: var(--accent-cyan);
  border-color: var(--accent-cyan);
  background: var(--accent-cyan-glow);
}

.textarea-container {
  border: 1px solid var(--border-color);
  border-radius: 8px;
  overflow: hidden;
  background: #040810;
}

.config-textarea {
  width: 100%;
  background: transparent;
  border: none;
  color: #38bdf8;
  font-family: monospace;
  font-size: 0.85rem;
  padding: 1rem;
  outline: none;
  resize: vertical;
}

.form-actions {
  margin-top: 1rem;
  display: flex;
  justify-content: flex-end;
}

@media (max-width: 1024px) {
  .service-layout {
    grid-template-columns: 1fr;
  }
}
</style>
