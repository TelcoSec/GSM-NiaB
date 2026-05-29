<template>
  <div>
    <header class="page-header">
      <h2>System Repositories</h2>
      <p>Configure package sources and repositories file (/etc/apt/sources.list)</p>
    </header>

    <div class="glass-panel repos-card">
      <div class="repos-meta">
        <h3>sources.list Configuration</h3>
        <span class="file-path">/etc/apt/sources.list</span>
      </div>

      <form @submit.prevent="saveRepos" class="repos-form">
        <div class="textarea-container">
          <textarea 
            v-model="repoContent" 
            class="repos-textarea" 
            rows="18"
            placeholder="Loading repositories content..."
          ></textarea>
        </div>
        <div class="form-actions">
          <button type="submit" class="btn btn-primary" :disabled="saving">
            <Icon name="lucide:save" /> {{ saving ? 'Saving & Updating...' : 'Save & Update Packages' }}
          </button>
        </div>
      </form>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import { useToast } from '#imports';

const repoContent = ref('');
const saving = ref(false);
const toast = useToast();

const loadRepos = async () => {
  try {
    const res = await $fetch('/api/repos');
    if (res.success) {
      repoContent.value = res.content;
    } else {
      repoContent.value = res.error || '# Failed to load repositories file';
    }
  } catch (e) {
    repoContent.value = `# Error fetching repositories: ${e.message}`;
  }
};

const saveRepos = async () => {
  saving.value = true;
  try {
    const res = await $fetch('/api/repos', {
      method: 'POST',
      body: { content: repoContent.value }
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

onMounted(() => {
  loadRepos();
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

.repos-meta {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1.5rem;
}

.repos-meta h3 {
  font-size: 1.1rem;
  color: var(--text-secondary);
}

.file-path {
  font-family: monospace;
  font-size: 0.75rem;
  color: var(--accent-cyan);
  background: var(--bg-secondary);
  padding: 0.25rem 0.5rem;
  border-radius: 4px;
}

.textarea-container {
  border: 1px solid var(--border-color);
  border-radius: 8px;
  overflow: hidden;
  background: #040810;
}

.repos-textarea {
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
</style>
