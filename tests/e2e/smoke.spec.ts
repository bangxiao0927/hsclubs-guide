import { expect, test } from '@playwright/test'

test('loads the fixture-driven application shell', async ({ page }) => {
  await page.goto('/')

  await expect(page.getByRole('heading', { level: 1 })).toHaveText(
    "Find your school's club directory.",
  )
  await expect(page.getByText('Frontend foundation ready')).toBeVisible()
})

test('renders a route-level not-found page', async ({ page }) => {
  await page.goto('/missing-page')

  await expect(page.getByRole('heading', { level: 1 })).toHaveText('We could not find that page.')
  await expect(page.getByRole('link', { name: 'Return home' })).toBeVisible()
})
