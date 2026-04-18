# @librarfree/db

Prisma 6 client + schema for the Librarfree Postgres database. The canonical schema is `database/schema.sql` (Postgres-first, UUIDs, TIMESTAMPTZ, pgvector, RLS on user-scoped tables); `prisma/schema.prisma` mirrors it for type-safe app access.

## Usage

```ts
import { prisma } from "@librarfree/db";
import type { Book } from "@librarfree/db/types";

const books: Book[] = await prisma.book.findMany({ take: 10 });
```

Server-only — never import from client components.

## Scripts

```bash
pnpm --filter @librarfree/db db:generate     # generate Prisma client
pnpm --filter @librarfree/db db:push         # sync dev DB to schema (no migration)
pnpm --filter @librarfree/db db:migrate      # create + apply a migration (dev)
pnpm --filter @librarfree/db db:studio       # open Prisma Studio
pnpm --filter @librarfree/db db:seed         # insert 5 dev authors/books
```

Root shortcuts are also wired: `pnpm db:push`, `pnpm db:studio`, `pnpm db:seed`.

## Notes

- `pgvector` is declared in `datasource.extensions`; `embedding vector(768)` uses `Unsupported("vector(768)")` (Prisma doesn't yet support vector type). Raw-SQL for HNSW similarity queries.
- `DATABASE_URL` points to Supabase direct (IPv6, local dev) — pass `DATABASE_POOLER_URL` instead on Vercel/GitHub Actions.
- RLS policies live in `database/schema.sql`, not in Prisma. Apply the SQL once (`psql "$DATABASE_URL" -f database/schema.sql`), then `prisma db push` for future schema diffs.
