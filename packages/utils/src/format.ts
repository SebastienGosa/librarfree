/** Words per minute used by `formatReadingTime` — calibrated on French prose. */
export const WORDS_PER_MINUTE = 230;

/**
 * Compute reading time from a word count.
 * Returns minutes rounded up to the nearest minute.
 */
export function readingTimeMinutes(wordCount: number, wpm = WORDS_PER_MINUTE): number {
  if (!Number.isFinite(wordCount) || wordCount <= 0) return 0;
  return Math.max(1, Math.ceil(wordCount / wpm));
}

/**
 * Human-readable reading-time string.
 *   120 min → "2 h"
 *   45 min  → "45 min"
 *   260 min → "4 h 20 min"
 */
export function formatReadingTime(
  wordCount: number,
  locale: "en" | "fr" | "de" | "es" | "it" | "pt" = "en",
  wpm = WORDS_PER_MINUTE,
): string {
  const minutes = readingTimeMinutes(wordCount, wpm);
  if (minutes === 0) return "";
  const hours = Math.floor(minutes / 60);
  const mins = minutes % 60;
  const labels: Record<string, { h: string; m: string }> = {
    en: { h: "h", m: "min" },
    fr: { h: "h", m: "min" },
    de: { h: "Std", m: "Min" },
    es: { h: "h", m: "min" },
    it: { h: "h", m: "min" },
    pt: { h: "h", m: "min" },
  };
  const { h, m } = labels[locale] ?? labels.en!;
  if (hours === 0) return `${mins} ${m}`;
  if (mins === 0) return `${hours} ${h}`;
  return `${hours} ${h} ${mins} ${m}`;
}

/** Human-readable file size — 1536 → "1.5 KB". */
export function formatFileSize(bytes: number, decimals = 1): string {
  if (!Number.isFinite(bytes) || bytes <= 0) return "0 B";
  const units = ["B", "KB", "MB", "GB", "TB"];
  const idx = Math.min(units.length - 1, Math.floor(Math.log(bytes) / Math.log(1024)));
  const value = bytes / Math.pow(1024, idx);
  const fixed = idx === 0 ? value.toFixed(0) : value.toFixed(decimals);
  return `${fixed} ${units[idx]}`;
}

/** Locale-aware date — respects the `Intl.DateTimeFormat` default for the given locale. */
export function formatDate(
  value: Date | string | number,
  locale = "en",
  options: Intl.DateTimeFormatOptions = { year: "numeric", month: "long", day: "numeric" },
): string {
  const date = value instanceof Date ? value : new Date(value);
  if (Number.isNaN(date.getTime())) return "";
  return new Intl.DateTimeFormat(locale, options).format(date);
}

/** Compact number: 1234 → "1.2K", 1_500_000 → "1.5M". */
export function formatCompact(value: number, locale = "en"): string {
  if (!Number.isFinite(value)) return "";
  return new Intl.NumberFormat(locale, {
    notation: "compact",
    maximumFractionDigits: 1,
  }).format(value);
}
