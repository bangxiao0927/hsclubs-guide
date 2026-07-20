<script setup lang="ts">
import { useRoute } from 'vue-router'

const route = useRoute()
</script>

<template>
  <section class="route-message" aria-labelledby="school-title">
    <p class="eyebrow">School profile</p>
    <h1 id="school-title">Discovery profiles are coming next.</h1>
    <p>
      The requested school slug is <code>{{ route.params.slug }}</code
      >. School details will remain fixture-driven until the public API is ready.
    </p>
    <RouterLink class="text-link" to="/"> Return home </RouterLink>
  </section>
</template>
