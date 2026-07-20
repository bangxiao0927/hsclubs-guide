import { z } from 'zod'

const httpsUrlSchema = z
  .url()
  .refine((value) => new URL(value).protocol === 'https:', 'URL must use HTTPS')

export const schoolAvailabilitySchema = z.enum(['fresh', 'stale', 'unavailable', 'suspended'])

export const publicSchoolSchema = z
  .object({
    slug: z.string().regex(/^[a-z0-9]+(?:-[a-z0-9]+)*$/),
    name: z.string().trim().min(1),
    shortName: z.string().trim().min(1),
    canonicalUrl: httpsUrlSchema,
    location: z
      .object({
        city: z.string().trim().min(1),
        region: z.string().trim().min(1),
        country: z.string().trim().length(2),
      })
      .strict(),
    verificationStatus: z.literal('verified'),
    availability: schoolAvailabilitySchema,
    clubCount: z.int().nonnegative().nullable(),
    categories: z.record(z.string().trim().min(1), z.int().nonnegative()),
    sourceUpdatedAt: z.iso.datetime({ offset: true }).nullable(),
    lastSuccessfulCollectionAt: z.iso.datetime({ offset: true }).nullable(),
  })
  .strict()

export const publicSchoolListSchema = z
  .object({
    schemaVersion: z.literal('1.0'),
    generatedAt: z.iso.datetime({ offset: true }),
    schools: z.array(publicSchoolSchema),
  })
  .strict()

export type PublicSchool = z.infer<typeof publicSchoolSchema>
export type PublicSchoolList = z.infer<typeof publicSchoolListSchema>
