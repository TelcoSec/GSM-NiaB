<template>
  <div>
    <header class="page-header">
      <h2>Subscriber Register</h2>
      <p>Manage and audit provisioned subscriber profiles on the HLR database</p>
    </header>

    <div class="glass-panel main-panel">
      <div class="panel-header">
        <h3>Provisioned Profiles</h3>
        <div class="search-bar">
          <Icon name="lucide:search" class="search-icon" />
          <input 
            v-model="searchQuery" 
            type="text" 
            placeholder="Search by IMSI or MSISDN..." 
            class="search-input"
          />
        </div>
      </div>

      <div v-if="loading" class="loading-state">
        <Icon name="lucide:loader" class="spinner" />
        <span>Loading subscriber database...</span>
      </div>

      <div v-else-if="error" class="error-state">
        <Icon name="lucide:alert-triangle" class="error-icon" />
        <div class="error-details">
          <h4>Database Read Failure</h4>
          <p>{{ error }}</p>
          <button @click="fetchSubscribers" class="btn btn-secondary btn-retry">
            <Icon name="lucide:refresh-cw" /> Retry Connection
          </button>
        </div>
      </div>

      <div v-else-if="filteredSubscribers.length === 0" class="empty-state">
        <Icon name="lucide:users" class="empty-icon" />
        <p>No subscribers found matching the query.</p>
      </div>

      <div v-else class="data-table-container">
        <table class="data-table">
          <thead>
            <tr>
              <th>ID</th>
              <th>IMSI</th>
              <th>MSISDN</th>
              <th>IMEISV</th>
              <th>Created</th>
              <th>Updated</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="sub in filteredSubscribers" :key="sub.id">
              <td>{{ sub.id }}</td>
              <td class="font-mono text-cyan">{{ sub.imsi }}</td>
              <td class="font-mono text-purple">{{ sub.msisdn }}</td>
              <td class="font-mono text-muted">{{ sub.imeisv || 'N/A' }}</td>
              <td>{{ formatDate(sub.created) }}</td>
              <td>{{ formatDate(sub.updated) }}</td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue';

const subscribers = ref([]);
const loading = ref(true);
const error = ref(null);
const searchQuery = ref('');

const fetchSubscribers = async () => {
  loading.value = true;
  error.value = null;
  try {
    const res = await $fetch('/api/subscribers');
    if (res.success) {
      subscribers.value = res.subscribers;
    } else {
      error.value = res.error || 'Failed to read subscriber data from hlr.db';
    }
  } catch (e) {
    error.value = `API Connection failed: ${e.message}`;
  } finally {
    loading.value = false;
  }
};

const filteredSubscribers = computed(() => {
  const q = searchQuery.value.toLowerCase().trim();
  if (!q) return subscribers.value;
  return subscribers.value.filter(sub => {
    const imsi = (sub.imsi || '').toLowerCase();
    const msisdn = (sub.msisdn || '').toLowerCase();
    return imsi.includes(q) || msisdn.includes(q);
  });
});

const formatDate = (dateStr) => {
  if (!dateStr) return 'N/A';
  try {
    const date = new Date(dateStr);
    if (isNaN(date.getTime())) return dateStr;
    return date.toLocaleString();
  } catch {
    return dateStr;
  }
};

onMounted(() => {
  fetchSubscribers();
});
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

.main-panel h3 {
  font-size: 1.1rem;
  color: var(--text-secondary);
}

.panel-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1.5rem;
  gap: 1rem;
  flex-wrap: wrap;
}

.search-bar {
  display: flex;
  align-items: center;
  background: rgba(4, 8, 16, 0.6);
  border: 1px solid var(--border-color);
  border-radius: 8px;
  padding: 0.4rem 0.8rem;
  width: 320px;
  transition: var(--transition-smooth);
}
.search-bar:focus-within {
  border-color: var(--accent-cyan);
  box-shadow: 0 0 10px var(--accent-cyan-glow);
}

.search-icon {
  color: var(--text-secondary);
  margin-right: 0.5rem;
  font-size: 1rem;
}

.search-input {
  background: transparent;
  border: none;
  color: var(--text-primary);
  outline: none;
  font-size: 0.9rem;
  width: 100%;
}

.loading-state, .empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 5rem 0;
  gap: 1rem;
  color: var(--text-secondary);
}

.spinner {
  font-size: 2rem;
  color: var(--accent-cyan);
  animation: spin 1.5s linear infinite;
}

@keyframes spin {
  from { transform: rotate(0deg); }
  to { transform: rotate(360deg); }
}

.error-state {
  display: flex;
  align-items: flex-start;
  gap: 1.5rem;
  padding: 2rem;
  border: 1px dashed var(--status-inactive);
  border-radius: 10px;
  background: var(--status-inactive-glow);
}

.error-icon {
  font-size: 2.2rem;
  color: var(--status-inactive);
  flex-shrink: 0;
}

.error-details h4 {
  color: var(--status-inactive);
  margin-bottom: 0.5rem;
}

.btn-retry {
  margin-top: 1rem;
  font-size: 0.8rem;
}

.empty-icon {
  font-size: 3rem;
  color: var(--text-secondary);
  opacity: 0.4;
}

.font-mono {
  font-family: monospace;
  font-weight: 500;
}
.text-cyan {
  color: #22d3ee;
}
.text-purple {
  color: #c084fc;
}
.text-muted {
  color: var(--text-secondary);
}
</style>
