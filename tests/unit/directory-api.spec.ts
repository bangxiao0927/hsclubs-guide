import { describe, expect, it } from 'vitest'

import { getSchool, getSchools } from '@/api/directory'

describe('directory API', () => {
  it('parses the fixture-backed school list', async () => {
    const directory = await getSchools()

    expect(directory.schools.map(({ slug }) => slug)).toContain('mountain-view')
  })

  it('parses a fixture-backed school detail', async () => {
    const school = await getSchool('mountain-view')

    expect(school.name).toBe('Mountain View High School')
  })
})
