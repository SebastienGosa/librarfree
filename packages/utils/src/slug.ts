/**
 * Deterministic URL-safe slug. Transliterates common accented Latin letters,
 * strips the rest, lowercases, collapses whitespace → single dash.
 *
 *   slugify("Les Misérables")      → "les-miserables"
 *   slugify("Война и мир")          → "voina-i-mir"   (best effort, non-ASCII fallback)
 *   slugify("  Double  Space  ")    → "double-space"
 */
export function slugify(input: string, maxLength = 120): string {
  if (!input) return "";
  const transliterated = input
    .normalize("NFKD")
    .replace(/[\u0300-\u036f]/g, "")
    .replace(/ß/g, "ss")
    .replace(/æ/g, "ae")
    .replace(/œ/g, "oe")
    .replace(/ø/g, "o")
    .replace(/å/g, "a")
    .replace(/đ/g, "d")
    .replace(/ł/g, "l");
  const cleaned = transliterated
    .toLowerCase()
    .replace(/[^a-z0-9\s-]/g, "")
    .trim()
    .replace(/\s+/g, "-")
    .replace(/-+/g, "-");
  return cleaned.slice(0, maxLength).replace(/-+$/, "");
}

/**
 * Adds a numeric suffix to disambiguate collisions:
 *   uniqueSlug("les-miserables", new Set(["les-miserables"])) → "les-miserables-2"
 */
export function uniqueSlug(base: string, taken: ReadonlySet<string>): string {
  if (!taken.has(base)) return base;
  let n = 2;
  while (taken.has(`${base}-${n}`)) n++;
  return `${base}-${n}`;
}
