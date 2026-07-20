import { createRouter, createWebHistory } from 'vue-router'

import HomeView from '@/views/HomeView.vue'

export const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: '/',
      name: 'home',
      component: HomeView,
      meta: { title: 'HSclubs Guide' },
    },
    {
      path: '/schools/:slug',
      name: 'school',
      component: () => import('@/views/SchoolPlaceholderView.vue'),
      meta: { title: 'School | HSclubs Guide' },
    },
    {
      path: '/:pathMatch(.*)*',
      name: 'not-found',
      component: () => import('@/views/NotFoundView.vue'),
      meta: { title: 'Page not found | HSclubs Guide' },
    },
  ],
  scrollBehavior: () => ({ top: 0 }),
})

router.afterEach((to) => {
  document.title = String(to.meta.title ?? 'HSclubs Guide')
})
