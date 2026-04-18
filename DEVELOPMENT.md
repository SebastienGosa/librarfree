# Librarfree Development Setup

## Quick Start (5 minutes)

```bash
# 1. Clone & install
git clone https://github.com/SebastienGosa/librarfree.git
cd librarfree
./scripts/setup_dev.sh

# 2. Start Docker services
docker-compose up -d

# 3. Run database migrations
psql $DATABASE_URL -f database/schema.sql

# 4. Install dependencies
pnpm install

# 5. Start dev servers
pnpm --filter web dev  # http://localhost:3000
pnpm --filter api dev  # http://localhost:3333
```

## Project Structure

```
librarfree/
├── apps/
│   ├── web/              # Next.js frontend
│   └── api/              # tRPC backend
├── packages/
│   ├── db/               # Database client + schema
│   ├── ui/               # Shared components (shadcn)
│   └── utils/            # Shared utilities
├── workers/
│   ├── importers/        # Book import scripts (PG, IA, etc.)
│   ├── translators/      # NLLB translation service
│   ├── embedders/        # Ollama embedding generation
│   └── isbn-lookup/      # ISBN enrichment
├── database/
│   └── schema.sql        # Full PostgreSQL schema
├── scripts/              # Helper scripts
├── docs/                 # Documentation
└── docker-compose.yml    # Local dev environment
```

## Common Commands

```bash
# Import Project Gutenberg (1000 books)
pnpm --filter workers run import-gutenberg --limit 1000

# Generate embeddings (requires Ollama)
docker run -d -p 11434:11434 ollama/ollama
ollama pull nomic-embed-text:v1.5
pnpm --filter workers run generate-embeddings --batch-size 100

# Search Meilisearch
curl 'http://localhost:7700/indexes/books/search' \
  -H 'Content-Type: application/json' \
  -d '{"q":"war and peace","limit":5}'

# Database queries
psql $DATABASE_URL -c "SELECT COUNT(*) FROM books;"
psql $DATABASE_URL -c "SELECT * FROM v_translation_quality_dashboard;"

# View logs
docker-compose logs -f postgres
docker-compose logs -f meilisearch
```

## Environment Variables

Copy `.env.example` to `.env.local` and fill in:
- `DATABASE_URL` – PostgreSQL connection
- `MEILISEARCH_HOST` – http://localhost:7700
- `OLLAMA_BASE_URL` – http://localhost:11434
- `AMAZON_PAAPI_ACCESS_KEY` – (optional) for affiliate links
- `AMAZON_ASSOCIATE_TAG_*` – your affiliate tags by region

## Adding a New Book Source

1. Create `workers/importers/your_source.py`
2. Inherit from `BaseImporter`
3. Implement `fetch_metadata()` and `download_content()`
4. Test: `pnpm --filter workers run import-test --source=your_source --limit=10`
5. Submit PR with sample output

## Database Migrations

Changes to schema go in `database/schema.sql`. To apply:

```bash
# Apply full schema
psql $DATABASE_URL -f database/schema.sql

# Or just migrations (future)
pnpm db:migrate
```

## Testing

```bash
# All tests
pnpm test

# Specific package
pnpm --filter api test
pnpm --filter web test
pnpm --filter workers test

# With coverage
pnpm test -- --coverage
```

## Debugging

### VSCode
`.vscode/launch.json` is configured for:
- Next.js frontend attach
- tRPC backend attach
- Worker debug

### Docker logs
```bash
docker-compose logs -f [service]
docker-compose ps  # status
docker-compose down  # stop all
```

### Database
```bash
# Connect
docker-compose exec postgres psql -U postgres -d librarfree

# View size
SELECT pg_size_pretty(pg_database_size('librarfree'));

# List tables
\dt
```

## Performance Tips

- **Meilisearch**: index rebuild for 100K books ~30s
- **Embeddings**: GPU recommended (NLLB ~2s/book on CPU)
- **Import speed**: Parallelize with `--workers=10`
- **Storage**: Plain text ~1KB/book → 1M books = ~1GB

## Troubleshooting

### Database connection refused
```bash
docker-compose up -d postgres
# Wait 10s, then retry
```

### Meilisearch not responding
```bash
docker-compose restart meilisearch
curl http://localhost:7700/health
```

### Out of disk space
Importing 500K books needs ~50-100GB. Use external storage:
```
ls -lh /data/gutenberg/  # your mirror location
docker volume ls  # check docker volumes
docker volume prune  # cleanup unused
```

### Import stuck / slow
- Check rate limits (don't overwhelm source servers)
- Use throttling: `--rate-limit 1` (1 req/sec per source)
- Run overnight – imports can take hours

## Deployment

See `docs/DEPLOYMENT.md` for production deployment:
- Vercel (frontend) + Railway (backend)
- Hetzner VPS (all-in-one)
- Kubernetes (enterprise)

## Need Help?

- Discord: [to come]
- GitHub Issues: https://github.com/SebastienGosa/librarfree/issues
- Email: hello@librarfree.com

**Happy coding! 📚✨**
