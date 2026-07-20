import { mount } from '@vue/test-utils'
import { describe, expect, it } from 'vitest'

import HomeView from '@/views/HomeView.vue'

describe('HomeView', () => {
  it('explains the discovery-only product boundary', () => {
    const wrapper = mount(HomeView)

    expect(wrapper.get('h1').text()).toBe("Find your school's club directory.")
    expect(wrapper.text()).toContain('school-owned club sites')
    expect(wrapper.text()).not.toContain('ownerEmail')
  })
})
