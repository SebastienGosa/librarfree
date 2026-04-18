# @librarfree/importer-gutenberg

Imports Project Gutenberg into the Librarfree catalog.

## Pipeline

1. **Fetch catalog RDF** — downloads `rdf-files.tar.bz2` from `https://www.gutenberg.org/cache/epub/feeds/` (or local cache)
2. **Parse metadata** — extracts title, author, language, license (filter PD only)
3. **Download text** — UTF-8 plain text from `https://www.gutenberg.org/files/{id}/{id}-0.txt`
4. **Quality score** — mojibake detection, word count, Flesch-Kincaid readability
5. **Upload to S3/MinIO** — bucket `books-content`, key `gutenberg/{id}.txt`
6. **Persist Prisma** — `authors` → `books` → `book_translations` → `book_files`
7. **Index Meilisearch** — per-language index `books_{lang}`

## Usage

```bash
# From monorepo root
pnpm --filter=@librarfree/importer-gutenberg start --limit=100 --language=en
```

## Env vars

See `.env.example` at repo root:

- `DATABASE_URL` — Prisma connection string
- `S3_ENDPOINT` / `S3_ACCESS_KEY` / `S3_SECRET_KEY` / `S3_BUCKET_CONTENT` (defaults: MinIO local)
- `MEILI_URL` / `MEILI_ADMIN_KEY`
- `GUTENBERG_MIRROR` (default: `https://www.gutenberg.org`)

## Idempotency

Uses `book_translations.source_project='gutenberg'` + `source_identifier=<gutenberg_id>`
as the dedup key. Re-running is safe — existing rows are skipped.
