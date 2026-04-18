/**
 * Project Gutenberg catalog parsing.
 *
 * We use the CSV feed (`pg_catalog.csv`) rather than the RDF tarball:
 * smaller, faster to parse, sufficient for Phase 0 metadata (Title, Authors,
 * Language). RDF can be re-introduced Phase 2 if we need subjects/LoCC/bookshelves.
 *
 * @see https://www.gutenberg.org/cache/epub/feeds/
 */
import { fetch } from "undici";

const CATALOG_URL = "https://www.gutenberg.org/cache/epub/feeds/pg_catalog.csv";

export interface GutenbergRow {
  id: number;
  title: string;
  language: string;
  authors: AuthorRef[];
}

export interface AuthorRef {
  name: string;
  birthYear: number | null;
  deathYear: number | null;
}

/**
 * Parses a single line from pg_catalog.csv.
 *
 * Columns (0-indexed):
 *   0 Text#       1 Type       2 Issued      3 Title       4 Language
 *   5 Authors     6 Subjects   7 LoCC        8 Bookshelves
 */
function parseRow(row: string[]): GutenbergRow | null {
  const id = Number(row[0]);
  const type = row[1];
  if (!Number.isFinite(id) || type !== "Text") return null;

  const title = (row[3] ?? "").trim();
  if (!title) return null;

  // Gutenberg uses semicolon-separated ISO codes, e.g. "en" or "en; fr".
  // Take the first declared language — cross-language books are edge cases.
  const lang = (row[4] ?? "").split(";")[0]?.trim().toLowerCase();
  if (!lang) return null;

  return {
    id,
    title,
    language: lang,
    authors: parseAuthors(row[5] ?? ""),
  };
}

/**
 * Authors field format: "Last, First, YYYY-YYYY; Last2, First2, YYYY-YYYY".
 * Birth/death years may be missing or BCE (ignored for Phase 0).
 */
function parseAuthors(raw: string): AuthorRef[] {
  if (!raw) return [];
  return raw
    .split(";")
    .map((chunk) => chunk.trim())
    .filter(Boolean)
    .map(parseSingleAuthor)
    .filter((a): a is AuthorRef => a !== null);
}

function parseSingleAuthor(raw: string): AuthorRef | null {
  // Strip trailing ", YYYY-YYYY" life-span if present.
  const match = raw.match(/^(.+?)(?:,\s*(-?\d{1,4})\??-(-?\d{1,4})\??)?$/);
  if (!match) return null;
  const namePart = match[1]?.trim();
  if (!namePart) return null;

  // "Last, First" → "First Last"
  const parts = namePart.split(",").map((s) => s.trim()).filter(Boolean);
  const name = parts.length >= 2 ? `${parts[1]} ${parts[0]}` : parts[0] ?? namePart;

  const birthYear = match[2] ? Number(match[2]) : null;
  const deathYear = match[3] ? Number(match[3]) : null;

  return {
    name,
    birthYear: Number.isFinite(birthYear) ? birthYear : null,
    deathYear: Number.isFinite(deathYear) ? deathYear : null,
  };
}

/**
 * Minimal RFC-4180-ish CSV parser. Gutenberg's CSV is well-behaved — we just
 * need to handle quoted fields that may contain commas or newlines.
 */
function parseCSV(text: string): string[][] {
  const rows: string[][] = [];
  let field = "";
  let row: string[] = [];
  let inQuotes = false;

  for (let i = 0; i < text.length; i++) {
    const c = text[i];
    if (inQuotes) {
      if (c === "\"") {
        if (text[i + 1] === "\"") {
          field += "\"";
          i++;
        } else {
          inQuotes = false;
        }
      } else {
        field += c;
      }
      continue;
    }
    if (c === "\"") {
      inQuotes = true;
    } else if (c === ",") {
      row.push(field);
      field = "";
    } else if (c === "\n") {
      row.push(field);
      rows.push(row);
      row = [];
      field = "";
    } else if (c === "\r") {
      // swallow — handled by \n
    } else {
      field += c;
    }
  }
  if (field.length || row.length) {
    row.push(field);
    rows.push(row);
  }
  return rows;
}

export interface FetchCatalogOptions {
  language?: string;
  limit?: number;
  mirror?: string;
}

/**
 * Fetches and filters the Gutenberg catalog.
 *
 * @returns rows ordered by ascending ID (reproducible imports)
 */
export async function fetchCatalog(opts: FetchCatalogOptions = {}): Promise<GutenbergRow[]> {
  const { language, limit, mirror } = opts;
  const url = mirror ? `${mirror}/cache/epub/feeds/pg_catalog.csv` : CATALOG_URL;

  const res = await fetch(url, {
    headers: {
      "User-Agent": "Librarfree-Importer/0.1 (+https://librarfree.com)",
      "Accept": "text/csv",
    },
  });
  if (!res.ok) {
    throw new Error(`Catalog fetch failed: ${res.status} ${res.statusText}`);
  }
  const text = await res.text();

  const rawRows = parseCSV(text);
  // First line is a header — drop it.
  rawRows.shift();

  const parsed: GutenbergRow[] = [];
  for (const row of rawRows) {
    const parsedRow = parseRow(row);
    if (!parsedRow) continue;
    if (language && parsedRow.language !== language) continue;
    parsed.push(parsedRow);
  }

  parsed.sort((a, b) => a.id - b.id);

  if (limit && limit > 0) return parsed.slice(0, limit);
  return parsed;
}
