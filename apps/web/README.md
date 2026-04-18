# @librarfree/web

Next.js 15 App Router frontend pour Librarfree.

## Stack

- Next.js 15 + React 19 + TypeScript strict
- Tailwind v4 (CSS-first, `@theme` dans `app/globals.css`)
- next-intl 3.26 (12 locales, `localePrefix: "always"`)
- Supabase SSR (@supabase/ssr) — clients via `@librarfree/utils`
- Zustand (state reader)
- shadcn-flavored UI via `@librarfree/ui`

## Layout

```
apps/web/
├── app/
│   ├── [locale]/            # Pages localisées (EN, FR, ...)
│   │   ├── layout.tsx       # Header + Footer + i18n provider
│   │   ├── page.tsx         # Homepage placeholder Phase 0
│   │   └── not-found.tsx    # 404 signature
│   ├── globals.css          # Tailwind v4 + tokens marque
│   └── layout.tsx           # Root shell (metadata seulement)
├── components/              # Header, Footer, LocaleSwitcher
├── i18n/                    # routing.ts, request.ts
├── messages/                # 12 fichiers JSON de traductions
└── middleware.ts            # Redirect locale + auth future
```

## Scripts

- `pnpm dev` — lance le serveur dev (port 3000)
- `pnpm build` — build production
- `pnpm start` — serve build
- `pnpm lint` — next lint
- `pnpm typecheck` — tsc --noEmit

## Variables d'env requises

Voir `.env.example` à la racine du monorepo.
