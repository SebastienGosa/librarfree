import type { MetadataRoute } from "next";
import { brand } from "@librarfree/brand";

const STATIC_PATHS = ["", "/library", "/about", "/transparency"] as const;

/**
 * Phase 0 sitemap: static routes × 12 locales with hreflang alternates.
 * DB-driven entries (books, authors, collections) will be added in Phase 1
 * via split sitemaps (sitemap-books.xml, sitemap-authors.xml) when volume
 * exceeds the 50k URL / 50 MB per-file limit.
 */
export default function sitemap(): MetadataRoute.Sitemap {
  const now = new Date();
  return STATIC_PATHS.flatMap((path) =>
    brand.locales.map((locale) => ({
      url: `${brand.url}/${locale}${path}`,
      lastModified: now,
      changeFrequency: "weekly" as const,
      priority: path === "" ? 1.0 : 0.7,
      alternates: {
        languages: Object.fromEntries(
          brand.locales.map((l) => [l, `${brand.url}/${l}${path}`]),
        ),
      },
    })),
  );
}
