/**
 * Gutenberg import orchestrator — ties catalog, download, quality, storage,
 * persist, and search together.
 */
import { fetchCatalog, type GutenbergRow } from "./catalog.js";
import { downloadGutenbergText, stripBoilerplate } from "./download.js";
import { uploadText } from "./storage.js";
import { persistBook } from "./persist.js";
import { indexDocument } from "./search.js";
import { qualityScore, wordCount, fleschEase, readingTimeMinutes } from "@librarfree/utils";

export interface ImportOptions {
  language?: string;
  limit?: number;
  minQuality?: number;
  mirror?: string;
  skipSearch?: boolean;
  onProgress?: (event: ProgressEvent) => void;
}

export type ProgressEvent =
  | { phase: "catalog"; total: number }
  | { phase: "book"; index: number; total: number; row: GutenbergRow; status: "ok" | "skip" | "error"; detail?: string };

export interface ImportSummary {
  totalCandidates: number;
  imported: number;
  skipped: number;
  failed: number;
  failures: { id: number; reason: string }[];
}

export async function runImport(opts: ImportOptions = {}): Promise<ImportSummary> {
  const { language, limit, minQuality = 40, mirror, skipSearch = false, onProgress } = opts;

  const catalog = await fetchCatalog({ language, limit, mirror });
  onProgress?.({ phase: "catalog", total: catalog.length });

  const summary: ImportSummary = {
    totalCandidates: catalog.length,
    imported: 0,
    skipped: 0,
    failed: 0,
    failures: [],
  };

  for (let i = 0; i < catalog.length; i++) {
    const row = catalog[i]!;
    try {
      const { text, sourceUrl, byteSize } = await downloadGutenbergText(row.id, mirror);
      const cleaned = stripBoilerplate(text);

      // ─── Quality filter ──────────────────────────────────────
      const quality = qualityScore(cleaned);
      if (quality < minQuality) {
        summary.skipped++;
        onProgress?.({ phase: "book", index: i, total: catalog.length, row, status: "skip", detail: `quality ${quality}<${minQuality}` });
        continue;
      }

      const words = wordCount(cleaned);
      const minutes = readingTimeMinutes(words);
      const readability = fleschEase(cleaned);

      // ─── Upload to S3/MinIO ──────────────────────────────────
      const key = `gutenberg/${row.id}.txt`;
      const upload = await uploadText(key, cleaned);

      // ─── Persist to Postgres ────────────────────────────────
      const persisted = await persistBook({
        row,
        sourceUrl,
        storageUrl: upload.url,
        byteSize,
        wordCount: words,
        readingTimeMinutes: minutes,
        readabilityScore: readability,
        qualityScore: quality,
      });

      // ─── Meilisearch ─────────────────────────────────────────
      if (!skipSearch) {
        const primaryAuthor = row.authors[0]?.name ?? "Anonymous";
        await indexDocument({
          id: persisted.translationId,
          bookId: persisted.bookId,
          gutenbergId: row.id,
          title: row.title,
          author: primaryAuthor,
          language: row.language,
          wordCount: words,
          readingTimeMinutes: minutes,
          qualityScore: quality,
        });
      }

      summary.imported++;
      onProgress?.({ phase: "book", index: i, total: catalog.length, row, status: "ok" });
    } catch (err) {
      summary.failed++;
      const reason = err instanceof Error ? err.message : String(err);
      summary.failures.push({ id: row.id, reason });
      onProgress?.({ phase: "book", index: i, total: catalog.length, row, status: "error", detail: reason });
    }
  }

  return summary;
}
