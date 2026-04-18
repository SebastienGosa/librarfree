# Contributing to Librarfree

Thank you for your interest in contributing! 🙏

## Quick Start

1. Fork & clone: `git clone https://github.com/SebastienGosa/librarfree.git`
2. Create branch: `git checkout -b feature/my-feature`
3. Make changes, test locally
4. Submit PR with clear description

## Code Style

- TypeScript (frontend), Python (workers)
- ESLint + Prettier formatting
- 2 spaces indent, semicolons required
- Snake_case for database columns

## Commit Messages

Format: `type(scope): description`

Examples:
- `feat(import): add Gutenberg German mirror`
- `fix(affiliate): correct Amazon FR URL template`
- `docs: update IMPORTS_PLAN with Gallica info`

Types: feat, fix, docs, style, refactor, test, chore, import, translation, affiliate

## Importing Books

See `docs/IMPORTS_PLAN.md` for source list. To add a new source:

1. Create worker in `workers/importers/`
2. Inherit from `BaseImporter`
3. Implement `fetch_metadata()` and `download_content()`
4. Test with `pnpm --filter workers run import-test --source=yoursource --limit=10`

## Adding Translations

**CRITICAL RULE**: Only use AI translation (NLLB) as FALLBACK when NO public domain human translation exists.

Priority order:
1. Standard Ebooks (if available in target language)
2. Wikisource translations
3. National library editions (Gallica, etc.)
4. **ONLY THEN** → NLLB automatic translation (mark as "machine_translated")

## Affiliate Retailers

To add a new retailer:

1. Register for their affiliate program (Amazon Associates, Fnac, etc.)
2. Add to `database/affiliate_retailers_seed.sql`
3. Update `AFFILIATE_RETAILERS_CONFIG.md` with details
4. Test URL generation
5. Submit PR

## Need Help?

- Discord: [link to come]
- Issues: https://github.com/SebastienGosa/librarfree/issues
- Email: hello@librarfree.com

**Thank you for helping build a free library for everyone! 📚**
