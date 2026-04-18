import { test, expect } from "@playwright/test";

test.describe("Homepage golden path", () => {
  test("root redirects to default locale", async ({ page }) => {
    const response = await page.goto("/");
    expect(response?.status(), "HTTP status of final response").toBeLessThan(400);
    await expect(page).toHaveURL(/\/en(\/|$)/);
  });

  test("English homepage renders hero + search + top books + dewey + stats", async ({ page }) => {
    await page.goto("/en");
    await expect(page.getByRole("heading", { level: 1 })).toContainText(/public library|internet/i);
    await expect(page.getByRole("search")).toBeVisible();
    await expect(page.getByPlaceholder(/search.*books.*authors/i)).toBeVisible();
    await expect(page.getByRole("heading", { name: /most borrowed/i })).toBeVisible();
    await expect(page.getByText(/War and Peace/i).first()).toBeVisible();
    await expect(page.getByRole("heading", { name: /dewey/i })).toBeVisible();
    await expect(page.getByText(/volumes on the shelves/i)).toBeVisible();
  });

  test("French homepage responds under /fr", async ({ page }) => {
    const response = await page.goto("/fr");
    expect(response?.ok()).toBeTruthy();
    await expect(page).toHaveURL(/\/fr(\/|$)/);
    await expect(page.getByRole("heading", { level: 1 })).toBeVisible();
  });

  test("sitemap.xml returns XML with alternates", async ({ request }) => {
    const res = await request.get("/sitemap.xml");
    expect(res.status()).toBe(200);
    const body = await res.text();
    expect(body).toContain("<urlset");
    expect(body).toContain("/en");
    expect(body).toContain("/fr");
    expect(body).toContain("hreflang");
  });

  test("robots.txt declares sitemap", async ({ request }) => {
    const res = await request.get("/robots.txt");
    expect(res.status()).toBe(200);
    const body = await res.text();
    expect(body).toMatch(/Sitemap:/i);
    expect(body).toMatch(/sitemap\.xml/);
  });

  test("llms.txt is served", async ({ request }) => {
    const res = await request.get("/llms.txt");
    expect(res.status()).toBe(200);
    expect(res.headers()["content-type"]).toContain("text/plain");
    const body = await res.text();
    expect(body).toContain("Librarfree");
  });
});
