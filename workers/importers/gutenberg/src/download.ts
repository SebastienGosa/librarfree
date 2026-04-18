/**
 * Gutenberg text file download with fallback URL chain.
 */
import { fetch } from "undici";

const MIRROR_DEFAULT = "https://www.gutenberg.org";

/**
 * Tries multiple known URL shapes in order:
 *   1. /cache/epub/{id}/pg{id}.txt     (newer canonical UTF-8)
 *   2. /files/{id}/{id}-0.txt          (legacy UTF-8)
 *   3. /files/{id}/{id}.txt            (legacy ASCII)
 *
 * Returns text + actual URL used so the importer can record provenance.
 */
export async function downloadGutenbergText(
  id: number,
  mirror: string = MIRROR_DEFAULT,
): Promise<{ text: string; sourceUrl: string; byteSize: number }> {
  const candidates = [
    `${mirror}/cache/epub/${id}/pg${id}.txt`,
    `${mirror}/files/${id}/${id}-0.txt`,
    `${mirror}/files/${id}/${id}.txt`,
  ];

  let lastErr: Error | null = null;
  for (const url of candidates) {
    try {
      const res = await fetch(url, {
        headers: {
          "User-Agent": "Librarfree-Importer/0.1 (+https://librarfree.com)",
          "Accept": "text/plain",
        },
      });
      if (!res.ok) {
        lastErr = new Error(`${res.status} ${res.statusText} at ${url}`);
        continue;
      }
      const buf = Buffer.from(await res.arrayBuffer());
      const text = buf.toString("utf8");
      return { text, sourceUrl: url, byteSize: buf.byteLength };
    } catch (err) {
      lastErr = err instanceof Error ? err : new Error(String(err));
    }
  }

  throw new Error(
    `All download candidates failed for Gutenberg #${id}: ${lastErr?.message ?? "unknown error"}`,
  );
}

/**
 * Strips the Project Gutenberg header/footer boilerplate. Gutenberg wraps
 * every text with `*** START OF THE PROJECT GUTENBERG EBOOK ... ***` and a
 * matching END marker — we remove both so analytics/search only see the work
 * itself. If markers are missing we return text as-is rather than guessing.
 */
export function stripBoilerplate(raw: string): string {
  const startRe = /^\s*\*{3}\s*START OF TH(?:E|IS) PROJECT GUTENBERG EBOOK[^*]*\*{3}\s*$/im;
  const endRe = /^\s*\*{3}\s*END OF TH(?:E|IS) PROJECT GUTENBERG EBOOK[^*]*\*{3}\s*$/im;

  const startMatch = startRe.exec(raw);
  const endMatch = endRe.exec(raw);

  if (startMatch && endMatch && endMatch.index > startMatch.index) {
    const startOffset = startMatch.index + startMatch[0].length;
    return raw.slice(startOffset, endMatch.index).trim();
  }
  return raw.trim();
}
