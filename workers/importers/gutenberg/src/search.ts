/**
 * Meilisearch indexing — per-language indexes `books_{lang}`.
 *
 * Indexes are created idempotently on first insert for a language. Phase 0
 * schema is intentionally minimal (title, author, language) — we'll enrich
 * with subjects/genres/readability in Phase 2 once we seed categories.
 */
import { MeiliSearch, type Index } from "meilisearch";

interface MeiliDoc {
  id: string;                  // book_translation_id
  bookId: string;
  gutenbergId: number;
  title: string;
  author: string;
  language: string;
  wordCount: number;
  readingTimeMinutes: number;
  qualityScore: number;
}

let _client: MeiliSearch | null = null;

function client(): MeiliSearch {
  if (_client) return _client;
  _client = new MeiliSearch({
    host: process.env.MEILI_URL ?? "http://localhost:7700",
    apiKey: process.env.MEILI_ADMIN_KEY ?? process.env.MEILI_MASTER_KEY ?? "librarfreeDevKey",
  });
  return _client;
}

const SEARCHABLE = ["title", "author"];
const FILTERABLE = ["language", "qualityScore", "gutenbergId"];
const SORTABLE = ["qualityScore", "wordCount", "readingTimeMinutes"];

const ensured = new Map<string, Index<MeiliDoc>>();

async function ensureIndex(language: string): Promise<Index<MeiliDoc>> {
  const key = `books_${language}`;
  const cached = ensured.get(key);
  if (cached) return cached;

  const m = client();
  try {
    await m.createIndex(key, { primaryKey: "id" });
  } catch (err) {
    // Ignore "index_already_exists" (code 4 or 409).
    const code = (err as { code?: string; httpStatus?: number }).code;
    const status = (err as { httpStatus?: number }).httpStatus;
    if (code !== "index_already_exists" && status !== 409) throw err;
  }

  const idx = m.index<MeiliDoc>(key);
  await idx.updateSearchableAttributes(SEARCHABLE);
  await idx.updateFilterableAttributes(FILTERABLE);
  await idx.updateSortableAttributes(SORTABLE);
  ensured.set(key, idx);
  return idx;
}

export async function indexDocument(doc: MeiliDoc): Promise<void> {
  const idx = await ensureIndex(doc.language);
  await idx.addDocuments([doc]);
}

export async function indexBatch(docs: MeiliDoc[]): Promise<void> {
  const byLang = new Map<string, MeiliDoc[]>();
  for (const d of docs) {
    const bucket = byLang.get(d.language) ?? [];
    bucket.push(d);
    byLang.set(d.language, bucket);
  }
  for (const [lang, batch] of byLang) {
    const idx = await ensureIndex(lang);
    await idx.addDocuments(batch);
  }
}
