<template>
  <div>
    <header class="page-header">
      <h2>Telecom Console & Diagnostic Tools</h2>
      <p>Interactive diagnostics, VTY client consoles, and frequency calculators</p>
    </header>

    <div class="tools-layout">
      <!-- Left side: ARFCN Calculator and Gr-GSM Runner -->
      <div class="side-tools">
        <!-- ARFCN Calculator -->
        <div class="glass-panel tool-card">
          <h3>ARFCN Frequency Calculator</h3>
          <p class="tool-desc">Calculate GSM uplink and downlink carrier frequencies</p>
          <div class="calculator-inputs">
            <div class="form-group">
              <label for="band">Band Standard</label>
              <select v-model="arfcnBand" id="band" class="select-input" @change="calculateArfcn">
                <option value="gsm900">GSM 900</option>
                <option value="dcs1800">DCS 1800 (GSM 1800)</option>
                <option value="pcs1900">PCS 1900 (GSM 1900)</option>
              </select>
            </div>
            <div class="form-group">
              <label for="arfcn">ARFCN Number</label>
              <input 
                v-model.number="arfcnNumber" 
                type="number" 
                id="arfcn" 
                class="text-input" 
                placeholder="e.g. 21"
                @input="calculateArfcn"
              />
            </div>
          </div>

          <div v-if="arfcnResult" class="calc-result">
            <div class="freq-result">
              <span class="label">Uplink Frequency</span>
              <span class="value">{{ arfcnResult.uplink }} MHz</span>
            </div>
            <div class="freq-result">
              <span class="label">Downlink Frequency</span>
              <span class="value">{{ arfcnResult.downlink }} MHz</span>
            </div>
          </div>
          <div v-else-if="arfcnError" class="calc-error">
            {{ arfcnError }}
          </div>
        </div>

        <!-- GR-GSM Runner -->
        <div class="glass-panel tool-card">
          <h3>Gr-GSM Scanner & Capture</h3>
          <p class="tool-desc">Trigger RF scans and frame capture on connected SDRs</p>
          
          <div class="grgsm-inputs">
            <div class="form-group">
              <label>Action</label>
              <select v-model="grgsmAction" class="select-input">
                <option value="scan">GSM Scan (Frequency Search)</option>
                <option value="info">Show SDR Device Info</option>
                <option value="capture">Capture Raw Burst Frames</option>
                <option value="decode">Decode Control Channels</option>
              </select>
            </div>
            <div class="form-group">
              <label>Additional Command Arguments</label>
              <input 
                v-model="grgsmArgs" 
                type="text" 
                class="text-input" 
                placeholder="e.g. --args='lms=0' -a 21"
              />
            </div>
          </div>

          <button @click="runGrgsm" class="btn btn-primary btn-run" :disabled="grgsmRunning">
            <Icon name="lucide:zap" /> {{ grgsmRunning ? 'Executing Scanner...' : 'Execute Command' }}
          </button>

          <div v-if="grgsmOutput" class="console-output">
            <div class="console-header">Scanner Terminal Output</div>
            <pre class="console-pre">{{ grgsmOutput }}</pre>
          </div>
        </div>
      </div>

      <!-- Right side: Telnet Client -->
      <div class="telnet-tool">
        <div class="glass-panel telnet-card">
          <div class="telnet-header">
            <h3>Osmocom VTY Interactive Console</h3>
            <div class="target-selectors">
              <select v-model="telnetTarget" class="select-input" @change="updateTelnetPort">
                <option value="4258">OsmoHLR (Port 4258)</option>
                <option value="4254">OsmoMSC (Port 4254)</option>
                <option value="4242">OsmoBSC (Port 4242)</option>
                <option value="4241">OsmoBTS (Port 4241)</option>
                <option value="4237">OsmoTRX (Port 4237)</option>
                <option value="4264">OsmoCBC (Port 4264)</option>
                <option value="custom">Custom Address</option>
              </select>
              <div v-if="telnetTarget === 'custom'" class="custom-target">
                <input v-model="customHost" type="text" class="text-input host" placeholder="127.0.0.1" />
                <input v-model="customPort" type="number" class="text-input port" placeholder="Port" />
              </div>
            </div>
          </div>

          <div class="telnet-terminal">
            <div class="terminal-logs" ref="terminalLogs">
              <div v-for="(log, idx) in telnetLogs" :key="idx" :class="['terminal-line', log.type]">
                <span class="prompt-symbol" v-if="log.type === 'cmd'">$ </span>
                <span>{{ log.text }}</span>
              </div>
            </div>
            <form @submit.prevent="sendTelnetCommand" class="terminal-input-form">
              <span class="terminal-prompt">></span>
              <input 
                v-model="telnetCommand" 
                type="text" 
                class="terminal-input" 
                placeholder="Enter VTY command (e.g. show subscriber imsi 00101...)"
                :disabled="telnetSending"
                ref="cmdInput"
              />
            </form>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, nextTick } from 'vue';

// ARFCN
const arfcnBand = ref('gsm900');
const arfcnNumber = ref('');
const arfcnResult = ref(null);
const arfcnError = ref('');

const calculateArfcn = () => {
  arfcnResult.value = null;
  arfcnError.value = '';
  const arf = arfcnNumber.value;
  if (arf === '' || arf === null) return;

  if (arfcnBand.value === 'gsm900') {
    if (arf >= 0 && arf <= 124) {
      const up = 890 + 0.2 * arf;
      arfcnResult.value = {
        uplink: up.toFixed(2),
        downlink: (up + 45).toFixed(2)
      };
    } else {
      arfcnError.value = 'GSM 900 ARFCN must be between 0 and 124';
    }
  } else if (arfcnBand.value === 'dcs1800') {
    if (arf >= 512 && arf <= 885) {
      const up = 1710.2 + 0.2 * (arf - 512);
      arfcnResult.value = {
        uplink: up.toFixed(2),
        downlink: (up + 95).toFixed(2)
      };
    } else {
      arfcnError.value = 'DCS 1800 ARFCN must be between 512 and 885';
    }
  } else if (arfcnBand.value === 'pcs1900') {
    if (arf >= 512 && arf <= 810) {
      const up = 1850.2 + 0.2 * (arf - 512);
      arfcnResult.value = {
        uplink: up.toFixed(2),
        downlink: (up + 80).toFixed(2)
      };
    } else {
      arfcnError.value = 'PCS 1900 ARFCN must be between 512 and 810';
    }
  }
};

// Gr-GSM
const grgsmAction = ref('scan');
const grgsmArgs = ref('');
const grgsmOutput = ref('');
const grgsmRunning = ref(false);

const runGrgsm = async () => {
  grgsmRunning.value = true;
  grgsmOutput.value = `Invoking SDR receiver. Running scan command...`;
  try {
    const res = await $fetch('/api/grgsm', {
      method: 'POST',
      body: { action: grgsmAction.value, args: grgsmArgs.value }
    });
    grgsmOutput.value = res.output;
  } catch (e) {
    grgsmOutput.value = `Execution error: ${e.message}`;
  } finally {
    grgsmRunning.value = false;
  }
};

// Telnet Console
const telnetTarget = ref('4258');
const customHost = ref('127.0.0.1');
const customPort = ref('');
const telnetCommand = ref('');
const telnetSending = ref(false);
const telnetLogs = ref([
  { type: 'info', text: 'Select a target Port to initiate telnet connection.' }
]);

const terminalLogs = ref(null);

const scrollToBottom = async () => {
  await nextTick();
  if (terminalLogs.value) {
    terminalLogs.value.scrollTop = terminalLogs.value.scrollHeight;
  }
};

const sendTelnetCommand = async () => {
  const cmd = telnetCommand.value.trim();
  if (!cmd) return;

  let host = '127.0.0.1';
  let port = telnetTarget.value;

  if (telnetTarget.value === 'custom') {
    host = customHost.value.trim() || '127.0.0.1';
    port = customPort.value;
  }

  telnetLogs.value.push({ type: 'cmd', text: cmd });
  telnetCommand.value = '';
  telnetSending.value = true;
  await scrollToBottom();

  try {
    const res = await $fetch('/api/telnet', {
      method: 'POST',
      body: { host, port, command: cmd }
    });
    telnetLogs.value.push({ type: 'response', text: res.output });
  } catch (e) {
    telnetLogs.value.push({ type: 'error', text: `Console connection failed: ${e.message}` });
  } finally {
    telnetSending.value = false;
    await scrollToBottom();
  }
};

const updateTelnetPort = () => {
  telnetLogs.value.push({ type: 'info', text: `Target port changed to ${telnetTarget.value}.` });
  scrollToBottom();
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

.tools-layout {
  display: grid;
  grid-template-columns: 1fr 1.25fr;
  gap: 1.5rem;
}

.side-tools {
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
}

.tool-card h3, .telnet-card h3 {
  font-size: 1.1rem;
  margin-bottom: 0.25rem;
  color: var(--text-primary);
}

.tool-desc {
  font-size: 0.8rem;
  color: var(--text-secondary);
  margin-bottom: 1.5rem;
}

.calculator-inputs, .grgsm-inputs {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 1rem;
  margin-bottom: 1rem;
}

.form-group {
  display: flex;
  flex-direction: column;
  gap: 0.4rem;
}

.form-group label {
  font-size: 0.8rem;
  color: var(--text-secondary);
  font-weight: 600;
}

.select-input, .text-input {
  background: rgba(4, 8, 16, 0.6);
  border: 1px solid var(--border-color);
  border-radius: 8px;
  color: var(--text-primary);
  padding: 0.55rem 0.8rem;
  outline: none;
  font-size: 0.9rem;
  transition: var(--transition-smooth);
}
.select-input:focus, .text-input:focus {
  border-color: var(--accent-cyan);
}

.calc-result {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 1rem;
  border-top: 1px solid var(--border-color);
  padding-top: 1rem;
  margin-top: 1rem;
}

.freq-result {
  background: rgba(255, 255, 255, 0.02);
  border: 1px solid var(--border-color);
  border-radius: 8px;
  padding: 0.75rem;
  text-align: center;
}

.freq-result .label {
  display: block;
  font-size: 0.7rem;
  color: var(--text-secondary);
  text-transform: uppercase;
  letter-spacing: 0.05em;
  margin-bottom: 0.25rem;
}

.freq-result .value {
  font-size: 1.1rem;
  font-weight: 700;
  color: var(--accent-cyan);
}

.calc-error {
  margin-top: 1rem;
  font-size: 0.8rem;
  color: var(--status-inactive);
  background: var(--status-inactive-glow);
  padding: 0.5rem;
  border-radius: 6px;
  text-align: center;
}

.btn-run {
  width: 100%;
}

.console-output {
  margin-top: 1.5rem;
  border-top: 1px solid var(--border-color);
  padding-top: 1rem;
}

.console-header {
  font-size: 0.75rem;
  text-transform: uppercase;
  color: var(--text-secondary);
  font-weight: 700;
  margin-bottom: 0.5rem;
}

.console-pre {
  background: #040810;
  border: 1px solid var(--border-color);
  border-radius: 8px;
  padding: 1rem;
  font-family: monospace;
  font-size: 0.8rem;
  color: #38bdf8;
  max-height: 200px;
  overflow-y: auto;
  white-space: pre-wrap;
}

.telnet-card {
  height: 100%;
  display: flex;
  flex-direction: column;
}

.telnet-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 1.5rem;
  flex-wrap: wrap;
  gap: 1rem;
}

.target-selectors {
  display: flex;
  gap: 0.5rem;
  align-items: center;
}

.custom-target {
  display: flex;
  gap: 0.35rem;
}
.custom-target .host {
  width: 120px;
}
.custom-target .port {
  width: 80px;
}

.telnet-terminal {
  flex-grow: 1;
  background: #040810;
  border: 1px solid var(--border-color);
  border-radius: 12px;
  display: flex;
  flex-direction: column;
  min-height: 480px;
  max-height: 600px;
}

.terminal-logs {
  flex-grow: 1;
  padding: 1.25rem;
  overflow-y: auto;
  font-family: monospace;
  font-size: 0.85rem;
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.terminal-line {
  white-space: pre-wrap;
  word-break: break-all;
}
.terminal-line.info {
  color: var(--text-secondary);
  font-style: italic;
}
.terminal-line.cmd {
  color: var(--accent-cyan);
}
.terminal-line.response {
  color: #a7f3d0;
}
.terminal-line.error {
  color: var(--status-inactive);
}

.prompt-symbol {
  color: var(--accent-purple);
  font-weight: 700;
}

.terminal-input-form {
  border-top: 1px solid var(--border-color);
  padding: 0.75rem 1.25rem;
  display: flex;
  align-items: center;
  gap: 0.5rem;
  background: rgba(255, 255, 255, 0.01);
  border-bottom-left-radius: 12px;
  border-bottom-right-radius: 12px;
}

.terminal-prompt {
  color: var(--accent-cyan);
  font-weight: 700;
  font-family: monospace;
}

.terminal-input {
  background: transparent;
  border: none;
  color: var(--text-primary);
  outline: none;
  font-family: monospace;
  font-size: 0.85rem;
  flex-grow: 1;
}

@media (max-width: 1024px) {
  .tools-layout {
    grid-template-columns: 1fr;
  }
}
</style>
