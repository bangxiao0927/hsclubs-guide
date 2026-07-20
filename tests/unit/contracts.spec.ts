import { describe, expect, it } from 'vitest'

import { publicSchoolListSchema, sourceSummarySchema } from '@/contracts'
import invalidDirectory from '@/fixtures/directory-schools.invalid.json'
import validDirectory from '@/fixtures/directory-schools.valid.json'
import invalidSourceSummary from '@/fixtures/source-summary.invalid.json'
import validSourceSummary from '@/fixtures/source-summary.valid.json'

describe('contract fixtures', () => {
  it('accepts the reviewed source summary v1 fixture', () => {
    expect(sourceSummarySchema.parse(validSourceSummary).schemaVersion).toBe('1.0')
  })

  it('rejects invalid source data and private fields', () => {
    expect(sourceSummarySchema.safeParse(invalidSourceSummary).success).toBe(false)
  })

  it('accepts the sanitized directory fixture', () => {
    const result = publicSchoolListSchema.parse(validDirectory)

    expect(result.schools).toHaveLength(2)
    expect(JSON.stringify(result)).not.toContain('ownerEmail')
  })

  it('rejects private fields in a public response', () => {
    expect(publicSchoolListSchema.safeParse(invalidDirectory).success).toBe(false)
  })
})
