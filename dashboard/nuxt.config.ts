const isProd = process.env.NODE_ENV === 'production';

// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  compatibilityDate: '2025-07-15',
  devtools: { enabled: true },
  css: [
    '~/assets/css/main.css'
  ],
  studio: {
    enabled: !isProd,
    repository: {
      owner: 'TelcoSec',
      repo: 'GSM-In-a-B0x',
      branch: 'main'
    }
  },
  modules: [
    '@nuxt/content',
    ...(isProd ? [] : ['nuxt-studio']),
    '@nuxtjs/seo',
    '@nuxt/ui',
    '@nuxt/a11y',
    '@nuxt/hints',
    '@nuxt/scripts',
    '@nuxt/image',
    '@nuxt/fonts',
    '@nuxt/eslint',
    '@nuxt/icon',
    '@nuxtjs/mdc',
    '@dargmuesli/nuxt-cookie-control',
    'nuxt-jsonld',
    'nuxt-charts',
    'nuxt-notify',
    'nuxt-svgo'
  ]
})
