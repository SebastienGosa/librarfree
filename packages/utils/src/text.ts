/**
 * Quick, cheap mojibake detector used by the ingestion pipeline to score
 * imported text files (0 = broken, 100 = clean). Looks for the most common
 * UTF-8-read-as-Latin1 artefacts (Ã©, Â, â€™, …).
 *
 * Not a linguistic analysis — a first-line filter. Workers can layer a
 * heavier check later (ftfy-equivalent) if needed.
 */
const MOJIBAKE_PATTERNS: RegExp[] = [
  /Ã[©¨ª«¢¤¦¯°¬®¶¹¼¾ƒ]/g, // Ã© etc.
  /Â[\xA0-\xFF]/g,         // non-breaking space garbage
  /â€[\x80-\x9F™œžšœ\u201C\u201D]/g,
  /â€/g,
  /Ã‚/g,
  /ï»¿/g,                  // BOM rendered
];

/** Detect broken encoding. Returns the count of suspicious matches. */
export function mojibakeMatches(text: string): number {
  let count = 0;
  for (const pattern of MOJIBAKE_PATTERNS) {
    const m = text.match(pattern);
    if (m) count += m.length;
  }
  return count;
}

/**
 * Score a text 0..100. Subtracts from 100 based on mojibake density
 * (matches per 10k characters). Below 40 ⇒ file is likely broken.
 */
export function qualityScore(text: string): number {
  if (!text || text.length < 100) return 0;
  const density = (mojibakeMatches(text) / text.length) * 10_000;
  const score = Math.round(100 - Math.min(100, density * 15));
  return Math.max(0, Math.min(100, score));
}

/** Count words using a unicode-friendly tokenizer (works for EN/FR/DE/ES/IT/PT/NL). */
export function wordCount(text: string): number {
  if (!text) return 0;
  const matches = text.match(/[\p{L}\p{N}\p{M}]+/gu);
  return matches ? matches.length : 0;
}

/**
 * Flesch reading ease (English-tuned) — higher = easier.
 * Returns a value typically between 0 and 100, clamped.
 */
export function fleschEase(text: string): number {
  const words = wordCount(text);
  if (words === 0) return 0;
  const sentences = Math.max(1, (text.match(/[.!?]+/g) ?? []).length);
  const syllables = countSyllables(text);
  const wps = words / sentences;
  const spw = syllables / words;
  const score = 206.835 - 1.015 * wps - 84.6 * spw;
  return Math.max(0, Math.min(100, Math.round(score * 10) / 10));
}

function countSyllables(text: string): number {
  const tokens = text.toLowerCase().match(/[a-z]+/g) ?? [];
  let total = 0;
  for (const word of tokens) total += estimateSyllablesForWord(word);
  return total;
}

function estimateSyllablesForWord(word: string): number {
  if (word.length <= 3) return 1;
  const simplified = word
    .replace(/(?:[^laeiouy]es|ed|[^laeiouy]e)$/, "")
    .replace(/^y/, "");
  const groups = simplified.match(/[aeiouy]+/g);
  return groups ? groups.length : 1;
}
