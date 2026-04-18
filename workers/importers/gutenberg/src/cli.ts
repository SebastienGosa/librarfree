#!/usr/bin/env -S tsx
/**
 * CLI entry point.
 *
 *   pnpm --filter=@librarfree/importer-gutenberg start \
 *     --limit=100 --language=en --min-quality=40
 */
import { runImport } from "./index.js";

interface Args {
  language?: string;
  limit?: number;
  minQuality?: number;
  mirror?: string;
  skipSearch?: boolean;
  help?: boolean;
}

function parseArgs(argv: string[]): Args {
  const args: Args = {};
  for (const raw of argv.slice(2)) {
    if (raw === "-h" || raw === "--help") {
      args.help = true;
      continue;
    }
    if (raw === "--skip-search") {
      args.skipSearch = true;
      continue;
    }
    const eq = raw.indexOf("=");
    if (eq === -1) continue;
    const key = raw.slice(0, eq);
    const value = raw.slice(eq + 1);
    switch (key) {
      case "--language":
        args.language = value;
        break;
      case "--limit":
        args.limit = Number(value);
        break;
      case "--min-quality":
        args.minQuality = Number(value);
        break;
      case "--mirror":
        args.mirror = value;
        break;
    }
  }
  return args;
}

function printHelp(): void {
  const lines = [
    "Librarfree — Gutenberg importer",
    "",
    "Usage:",
    "  pnpm --filter=@librarfree/importer-gutenberg start \\",
    "    --limit=100 --language=en [--min-quality=40] [--skip-search] [--mirror=URL]",
    "",
    "Flags:",
    "  --language=<iso2>        Filter to a single language (default: all)",
    "  --limit=<N>              Max books to import",
    "  --min-quality=<0-100>    Skip books below this mojibake-derived score (default: 40)",
    "  --skip-search            Don't push to Meilisearch (useful for dry-runs)",
    "  --mirror=<url>           Alternate Gutenberg mirror (default: gutenberg.org)",
    "",
    "Env vars (see .env.example): DATABASE_URL, S3_*, MEILI_URL, MEILI_ADMIN_KEY",
  ];
  for (const line of lines) console.log(line);
}

async function main(): Promise<void> {
  const args = parseArgs(process.argv);
  if (args.help) {
    printHelp();
    return;
  }

  const started = Date.now();
  console.log(`[gutenberg] import started — language=${args.language ?? "all"} limit=${args.limit ?? "∞"}`);

  const summary = await runImport({
    language: args.language,
    limit: args.limit,
    minQuality: args.minQuality,
    mirror: args.mirror,
    skipSearch: args.skipSearch,
    onProgress: (event) => {
      if (event.phase === "catalog") {
        console.log(`[gutenberg] catalog loaded: ${event.total} rows`);
        return;
      }
      const { index, total, row, status, detail } = event;
      const prefix = `[${index + 1}/${total}]`;
      if (status === "ok") {
        console.log(`${prefix} ✓ #${row.id} ${row.title.slice(0, 60)}`);
      } else if (status === "skip") {
        console.log(`${prefix} – skip #${row.id} (${detail ?? "skip"})`);
      } else {
        console.log(`${prefix} ✗ fail #${row.id} — ${detail ?? "unknown"}`);
      }
    },
  });

  const elapsed = ((Date.now() - started) / 1000).toFixed(1);
  console.log("");
  console.log(`[gutenberg] done in ${elapsed}s — imported=${summary.imported} skipped=${summary.skipped} failed=${summary.failed}`);
  if (summary.failures.length > 0) {
    console.log(`[gutenberg] failures:`);
    for (const f of summary.failures.slice(0, 10)) {
      console.log(`  #${f.id}: ${f.reason.slice(0, 120)}`);
    }
    if (summary.failures.length > 10) console.log(`  … ${summary.failures.length - 10} more`);
  }
}

main().catch((err) => {
  console.error("[gutenberg] fatal:", err);
  process.exit(1);
});
