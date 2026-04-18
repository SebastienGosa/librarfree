/**
 * Tailwind v4 CSS-first config lives in `apps/web/app/globals.css` using
 * `@theme`. This file keeps a tiny typed helper available to any package
 * that wants the canonical color tokens without importing brand directly.
 */
import { theme as brandTheme } from "@librarfree/brand";

export const tokens = {
  dark: brandTheme.dark,
  light: brandTheme.light,
  reader: brandTheme.reader,
} as const;

export type Tokens = typeof tokens;
