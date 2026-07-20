import { http, HttpResponse } from 'msw'

import directorySchoolsFixture from '@/fixtures/directory-schools.valid.json'

export const handlers = [
  http.get('*/api/v1/schools', () => HttpResponse.json(directorySchoolsFixture)),
  http.get('*/api/v1/schools/:slug', ({ params }) => {
    const school = directorySchoolsFixture.schools.find(({ slug }) => slug === params.slug)

    return school
      ? HttpResponse.json(school)
      : HttpResponse.json({ message: 'School not found' }, { status: 404 })
  }),
]
