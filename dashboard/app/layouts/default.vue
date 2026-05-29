<template>
  <div class="layout-wrapper">
    <aside class="sidebar">
      <div class="brand-section">
        <div class="brand-logo">G</div>
        <h1 class="brand-name">GSM-In-a-B0x</h1>
      </div>
      
      <nav class="nav-menu">
        <div class="nav-section-title">Telemetry</div>
        <NuxtLink to="/" class="nav-link">
          <Icon name="lucide:layout-dashboard" class="nav-icon" />
          <span>Dashboard</span>
        </NuxtLink>

        <div class="nav-section-title">Core Services</div>
        <div class="services-list-container">
          <NuxtLink to="/services/osmo-hlr" class="nav-link">
            <Icon name="lucide:database" class="nav-icon" />
            <span>OsmoHLR</span>
          </NuxtLink>
          <NuxtLink to="/services/osmo-msc" class="nav-link">
            <Icon name="lucide:git-commit" class="nav-icon" />
            <span>OsmoMSC</span>
          </NuxtLink>
          <NuxtLink to="/services/osmo-bsc" class="nav-link">
            <Icon name="lucide:cpu" class="nav-icon" />
            <span>OsmoBSC</span>
          </NuxtLink>
          <NuxtLink to="/services/osmo-bts" class="nav-link">
            <Icon name="lucide:radio" class="nav-icon" />
            <span>OsmoBTS</span>
          </NuxtLink>
          <NuxtLink to="/services/osmo-mgw" class="nav-link">
            <Icon name="lucide:shuffle" class="nav-icon" />
            <span>OsmoMGW</span>
          </NuxtLink>
          <NuxtLink to="/services/osmo-ggsn" class="nav-link">
            <Icon name="lucide:arrow-left-right" class="nav-icon" />
            <span>OsmoGGSN</span>
          </NuxtLink>
          <NuxtLink to="/services/osmo-sgsn" class="nav-link">
            <Icon name="lucide:route" class="nav-icon" />
            <span>OsmoSGSN</span>
          </NuxtLink>
          <NuxtLink to="/services/osmo-stp" class="nav-link">
            <Icon name="lucide:server" class="nav-icon" />
            <span>OsmoSTP</span>
          </NuxtLink>
          <NuxtLink to="/services/asterisk" class="nav-link">
            <Icon name="lucide:phone-call" class="nav-icon" />
            <span>Asterisk</span>
          </NuxtLink>
        </div>

        <div class="nav-section-title">Management</div>
        <NuxtLink to="/subscribers" class="nav-link">
          <Icon name="lucide:users" class="nav-icon" />
          <span>Subscribers</span>
        </NuxtLink>
        <NuxtLink to="/repos" class="nav-link">
          <Icon name="lucide:package-open" class="nav-icon" />
          <span>Repositories</span>
        </NuxtLink>
        <NuxtLink to="/tools" class="nav-link">
          <Icon name="lucide:terminal" class="nav-icon" />
          <span>Console & Tools</span>
        </NuxtLink>
      </nav>
    </aside>

    <main class="main-content">
      <slot />
    </main>
  </div>
</template>

<style scoped>
.nav-section-title {
  font-size: 0.75rem;
  text-transform: uppercase;
  color: var(--text-secondary);
  letter-spacing: 0.05em;
  margin-top: 1.25rem;
  margin-bottom: 0.4rem;
  padding-left: 1rem;
  font-weight: 700;
}
.services-list-container {
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
  max-height: 42vh;
  overflow-y: auto;
  padding-right: 0.25rem;
}
.services-list-container::-webkit-scrollbar {
  width: 4px;
}
.services-list-container::-webkit-scrollbar-thumb {
  background: var(--border-color);
  border-radius: 4px;
}
</style>
