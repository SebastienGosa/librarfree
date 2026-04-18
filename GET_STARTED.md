# Librarfree — Get Started

Bienvenue. Ce guide vous amène de 0 à "homepage tournante avec 100 livres Gutenberg indexés" en ~15 minutes.

## Lecture d'abord (~30 min cumulés)

1. **`docs/PLAN_V2_REFONTE.md`** — vision 2026, refonte V2, wireframes, direction UX
2. **`PLAN_MAITRE_LIBRARFREE.md`** — plan opérationnel historique 24 mois
3. **`AFFILIATE_RETAILERS_CONFIG.md`** — retailers par langue pour la Phase 2
4. **`database/schema.sql`** — schéma canonique (UUIDs, RLS, 20 tables)
5. **`DEVELOPMENT.md`** — commandes dev, debug, structure code

## Stack

- **Monorepo** : pnpm 9 + Turborepo 2
- **Frontend** : Next.js 15 + React 19 + Tailwind v4 + next-intl (12 locales)
- **DB** : Postgres 16 (Supabase) + pgvector + pg_trgm via Prisma 6
- **Search** : Meilisearch 1.7 (self-host VPS Hetzner en prod, Docker en dev)
- **Storage** : MinIO local (émule S3/R2)
- **Importers** : TypeScript + tsx, queue BullMQ à venir Phase 1

## Prérequis

- Node ≥ 20
- pnpm ≥ 9 (`corepack enable`)
- Docker + Docker Compose
- Un projet Supabase (ou Postgres local)

## Quick start

```bash
# 1. Cloner + installer
git clone https://github.com/SebastienGosa/librarfree.git
cd librarfree
pnpm install

# 2. Config env
cp .env.example .env.local
# → remplir NEXT_PUBLIC_SUPABASE_URL, ANON_KEY, SERVICE_ROLE_KEY, DATABASE_URL

# 3. Démarrer l'infra locale (Postgres + Meilisearch + MinIO + Redis)
docker compose up -d

# 4. Générer + pousser le schéma
pnpm --filter=@librarfree/db exec prisma generate
pnpm --filter=@librarfree/db exec prisma db push

# 5. Premier import (100 livres anglais depuis Gutenberg)
pnpm import:gutenberg --limit=100 --language=en

# 6. Lancer le dev server
pnpm dev
# → http://localhost:3000
```

## Checklist Phase 0 (Definition of Done)

- [ ] Homepage affiche le nom + tagline depuis `@librarfree/brand`
- [ ] Prisma Studio (`pnpm --filter=@librarfree/db exec prisma studio`) montre 100 livres
- [ ] Meilisearch (`http://localhost:7700`) retourne des résultats sur "Dickens" / "Shakespeare"
- [ ] MinIO console (`http://localhost:9001`) montre 100 fichiers `.txt` dans `books-content/gutenberg/`
- [ ] `pnpm lint && pnpm typecheck && pnpm build` passent
- [ ] CI GitHub verte sur premier push

## Structure du projet

```
librarfree/
├── apps/
│   └── web/                  # Next.js 15 App Router
├── packages/
│   ├── brand/                # Single source of truth (couleurs, fonts, locales)
│   ├── db/                   # Prisma schema + client
│   ├── ui/                   # shadcn-flavored + composants Librarfree
│   └── utils/                # format, slug, text quality, geoip, supabase
├── workers/
│   ├── importers/
│   │   └── gutenberg/        # ✅ Phase 0
│   ├── embedders/            # Phase 4
│   ├── isbn-lookup/          # Phase 2
│   └── translators/          # Phase 4
├── database/
│   └── schema.sql            # Canonical SQL
├── docs/                     # Plans détaillés, specs
└── .github/workflows/        # CI
```

## Dépannage

**`ERR_PNPM_WORKSPACE_PROJECTS`** → lancer `corepack enable` puis `corepack prepare pnpm@9.12.3 --activate`.

**`prisma not found`** → Prisma s'installe au niveau `packages/db`. Utiliser `pnpm --filter=@librarfree/db exec prisma ...`.

**`Can't resolve '@librarfree/...'`** → `pnpm install` depuis la racine pour recréer les symlinks workspace.

**MinIO refuse les uploads** → ouvrir `http://localhost:9001` (login `librarfree` / `librarfree-dev-password`) et créer les buckets `books-content`, `books-covers`, `books-exports`.
