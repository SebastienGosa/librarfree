/**
 * BRAND CONFIGURATION
 * ===================
 * Single source of truth for all branding.
 * Change the name here and it propagates everywhere.
 *
 * Current name: "Librarfree" (not final — see docs/PLAN_V2_REFONTE.md §9)
 * Candidates: librarfree.com, openreader.com, openlibra.com
 */

export const brand = {
  /** Display name used in UI, emails, meta tags */
  name: "Librarfree",

  /** Short tagline (homepage hero) */
  tagline: "500,000+ Free Legal Books. Every Language. Forever.",

  /** Longer description (meta, about page) */
  description:
    "The world's largest free, legal, open-source digital library. Public domain books in 15+ languages with AI-powered search, a beautiful reader, and zero restrictions.",

  /** Primary domain (without protocol) */
  domain: "librarfree.com",

  /** Full URL */
  url: "https://librarfree.com",

  /** GitHub repo */
  github: "https://github.com/SebastienGosa/librarfree",

  /** Contact email */
  email: "hello@librarfree.com",

  /** Social links */
  social: {
    twitter: "@librarfree",
    discord: "", // TODO: create Discord server
    telegram: "@librarfree",
  },

  /** Legal */
  license: "MIT",
  legalName: "Librarfree",

  /** SEO defaults */
  seo: {
    titleTemplate: "%s | Librarfree",
    defaultTitle: "Librarfree — Free Legal Books for Everyone",
    ogImage: "/og-default.png",
  },

  /** Pricing */
  pricing: {
    premium: {
      monthly: 4.99,
      yearly: 39.99,
      currency: "EUR",
    },
    apiAccess: {
      monthly: 9.99,
      currency: "EUR",
    },
  },

  /** Supported locales (order = priority) */
  locales: ["en", "fr", "de", "es", "it", "pt", "ja", "zh", "ru", "pl", "nl", "ar"] as const,
  defaultLocale: "en" as const,
} as const;

export type Locale = (typeof brand.locales)[number];

/**
 * Theme tokens — Dark Premium palette
 * Used by Tailwind config and components
 */
export const theme = {
  dark: {
    background: "#0F0F13",
    surface: "#1A1A24",
    surfaceHover: "#252532",
    border: "#2A2A3A",
    primary: "#6C9CFF",
    accent: "#FFB84D",
    success: "#4ADE80",
    warning: "#FB923C",
    error: "#F87171",
    textPrimary: "#E8E8ED",
    textSecondary: "#8B8BA0",
    textMuted: "#5C5C72",
  },
  light: {
    background: "#FAFAF8",
    surface: "#FFFFFF",
    surfaceHover: "#F3F3F0",
    border: "#E5E5E0",
    primary: "#1E3A5F",
    accent: "#E8A838",
    success: "#2D8B5E",
    warning: "#D4762C",
    error: "#C7384F",
    textPrimary: "#1A1A2E",
    textSecondary: "#6B7280",
    textMuted: "#9CA3AF",
  },
  reader: {
    light: { bg: "#FAFAF8", text: "#1A1A2E" },
    sepia: { bg: "#F4ECD8", text: "#5B4636" },
    dark: { bg: "#1A1A24", text: "#E5E5E5" },
    oled: { bg: "#000000", text: "#CCCCCC" },
  },
} as const;

/**
 * Typography configuration
 */
export const typography = {
  headings: "Literata",
  body: "Inter",
  mono: "JetBrains Mono",
  reader: {
    serif: "Literata",
    sans: "Inter",
    mono: "JetBrains Mono",
  },
} as const;
