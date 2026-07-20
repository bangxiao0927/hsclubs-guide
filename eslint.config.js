import eslint from '@eslint/js'
import eslintPluginVue from 'eslint-plugin-vue'
import globals from 'globals'
import tseslint from 'typescript-eslint'

export default tseslint.config(
  {
    ignores: [
      'dist',
      'coverage',
      'playwright-report',
      'test-results',
      'public/mockServiceWorker.js',
    ],
  },
  eslint.configs.recommended,
  ...tseslint.configs.recommended,
  ...eslintPluginVue.configs['flat/recommended'],
  {
    languageOptions: {
      globals: globals.browser,
    },
    rules: {
      'vue/html-closing-bracket-newline': 'off',
      'vue/max-attributes-per-line': 'off',
      'vue/multi-word-component-names': 'off',
      'vue/singleline-html-element-content-newline': 'off',
    },
  },
)
