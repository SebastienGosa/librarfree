# @librarfree/brand

Single source of truth for all Librarfree branding. Zero runtime deps, pure TypeScript constants.

## Usage

```ts
import { brand, theme, typography, type Locale } from "@librarfree/brand";

console.log(brand.name);              // "Librarfree"
console.log(brand.pricing.premium);   // { monthly: 4.99, yearly: 39.99, currency: "EUR" }
console.log(theme.dark.primary);      // "#6C9CFF"
```

Change the name, tagline, colors, or pricing in `src/index.ts` and it propagates across the entire monorepo (`apps/web`, workers, scripts, emails, OG images, etc.).

## What's inside

- `brand` — name, tagline, description, domain, URLs, social, SEO defaults, pricing, locales
- `theme` — dark/light/reader color tokens (Twilight palette by default)
- `typography` — font families (Literata for headings, Inter for UI, JetBrains Mono for code)
- `Locale` — union type of supported locales

## When to touch this

Only when a **global brand decision** changes (rename, new pricing tier, new locale launched, palette shift). Do not import component styles or UI tokens here — those live in `@librarfree/ui`.
