import { publicSchoolListSchema, publicSchoolSchema } from '@/contracts'

const apiBaseUrl = import.meta.env.VITE_DIRECTORY_API_BASE_URL?.replace(/\/$/, '') ?? ''

async function getJson(path: string): Promise<unknown> {
  const response = await fetch(`${apiBaseUrl}${path}`, {
    headers: { Accept: 'application/json' },
  })

  if (!response.ok) {
    throw new Error(`Directory request failed with status ${response.status}`)
  }

  return response.json()
}

export async function getSchools() {
  return publicSchoolListSchema.parse(await getJson('/api/v1/schools'))
}

export async function getSchool(slug: string) {
  return publicSchoolSchema.parse(await getJson(`/api/v1/schools/${encodeURIComponent(slug)}`))
}
