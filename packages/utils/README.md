# @librarfree/utils

Framework-agnostic helpers used across `apps/web` and `workers/*`.

## Exports

```ts
import {
  formatReadingTime,
  formatFileSize,
  formatDate,
  slugify,
  qualityScore,
  wordCount,
  fleschEase,
} from "@librarfree/utils";

import { geoFromHeaders, preferredRetailerLocale } from "@librarfree/utils/geoip";
import { browserClient, serverClient, adminClient } from "@librarfree/utils/supabase";
```

## Modules

- **`format.ts`** — `formatReadingTime`, `formatFileSize`, `formatDate`, `formatCompact`, `readingTimeMinutes`.
- **`slug.ts`** — `slugify`, `uniqueSlug`. Transliteration for common accented Latin letters.
- **`text.ts`** — `qualityScore`, `mojibakeMatches`, `wordCount`, `fleschEase`. Used by the ingestion pipeline.
- **`uri.ts`** — `absoluteUrl`, `joinPath`, `stripTrailingSlash`.
- **`geoip.ts`** — `geoFromHeaders`, `preferredRetailerLocale`. Reads Vercel/Cloudflare edge headers.
- **`supabase.ts`** — `browserClient`, `serverClient(cookieStore)`, `adminClient`. Zero-config factories.

`@supabase/ssr` is a runtime dependency (used by all three client factories). `next` is an optional peer — importing `supabase.ts` from a worker (no Next.js) still works, it just never calls `cookieStore`.
