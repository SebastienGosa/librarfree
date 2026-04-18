/**
 * Lightweight GeoIP helpers — uses Vercel Edge Network headers when available.
 * Falls back to a best-guess default country used by the affiliate router.
 *
 * Works in: middleware, Server Components, Route Handlers, Edge Functions.
 */

export interface GeoInfo {
  /** ISO 3166-1 alpha-2, uppercase. Example: "FR", "US". */
  country: string;
  /** ISO 3166-2 subdivision or the Vercel-reported region ("CA", "IL", …). May be empty. */
  region: string;
  /** Human city name (Vercel fills this at the edge). May be empty. */
  city: string;
  /** Did we actually pull this from real headers, or is it a default? */
  fallback: boolean;
}

interface HeaderLike {
  get(name: string): string | null;
}

const DEFAULT_GEO: GeoInfo = {
  country: "US",
  region: "",
  city: "",
  fallback: true,
};

/** Parse Vercel / Cloudflare geo headers from a `Request`/`Headers`-shaped object. */
export function geoFromHeaders(headers: HeaderLike | Headers): GeoInfo {
  const h: HeaderLike = (headers as HeaderLike).get ? (headers as HeaderLike) : (headers as unknown as HeaderLike);
  const country =
    h.get("x-vercel-ip-country") ??
    h.get("cf-ipcountry") ??
    h.get("x-country-code") ??
    "";
  const region =
    h.get("x-vercel-ip-country-region") ??
    h.get("cf-region-code") ??
    "";
  const city =
    h.get("x-vercel-ip-city") ??
    h.get("cf-ipcity") ??
    "";
  if (!country) return DEFAULT_GEO;
  return {
    country: country.toUpperCase(),
    region: decodeURIComponent(region || ""),
    city: decodeURIComponent(city || ""),
    fallback: false,
  };
}

/** Suggested default retailer locale based on user country. */
export function preferredRetailerLocale(country: string): string {
  const map: Record<string, string> = {
    US: "en", CA: "en", GB: "en", IE: "en", AU: "en", NZ: "en",
    FR: "fr", BE: "fr", CH: "fr", LU: "fr",
    DE: "de", AT: "de",
    ES: "es", MX: "es", AR: "es", CL: "es", CO: "es",
    IT: "it",
    PT: "pt", BR: "pt",
    NL: "nl",
    PL: "pl",
    JP: "ja",
    CN: "zh", TW: "zh", HK: "zh",
    RU: "ru",
    SA: "ar", AE: "ar", EG: "ar",
  };
  return map[country.toUpperCase()] ?? "en";
}
