import { z } from 'zod'

const httpsUrlSchema = z
  .url()
  .refine((value) => new URL(value).protocol === 'https:', 'URL must use HTTPS')

const categoryCountsSchema = z.record(z.string().trim().min(1), z.int().nonnegative())

export const sourceSummarySchema = z
  .object({
    schemaVersion: z.string().regex(/^1\.\d+$/, 'Only source contract v1 is supported'),
    schoolName: z.string().trim().min(1),
    shortName: z.string().trim().min(1),
    slug: z.string().regex(/^[a-z0-9]+(?:-[a-z0-9]+)*$/),
    canonicalUrl: httpsUrlSchema,
    status: z.enum(['active', 'maintenance', 'inactive']),
    clubCount: z.int().nonnegative(),
    categories: categoryCountsSchema,
    memberCount: z.int().nonnegative().optional(),
    lastUpdatedAt: z.iso.datetime({ offset: true }).nullable(),
    generatedAt: z.iso.datetime({ offset: true }),
    dataHash: z.string().regex(/^[a-f0-9]{64}$/),
  })
  .strict()
  .superRefine((summary, context) => {
    const categoryTotal = Object.values(summary.categories).reduce(
      (total, count) => total + count,
      0,
    )

    if (categoryTotal > summary.clubCount) {
      context.addIssue({
        code: 'custom',
        path: ['categories'],
        message: 'Category counts cannot exceed the total club count',
      })
    }
  })

export type SourceSummary = z.infer<typeof sourceSummarySchema>
