/** Drop trailing slashes (but keep `/`). */
export function stripTrailingSlash(url: string): string {
  if (url === "/" || url === "") return url;
  return url.replace(/\/+$/, "");
}

/** Safely join path segments, collapsing duplicate slashes. */
export function joinPath(...parts: ReadonlyArray<string | undefined | null>): string {
  return parts
    .filter((p): p is string => Boolean(p))
    .map((p, i) => (i === 0 ? p.replace(/\/+$/, "") : p.replace(/^\/+|\/+$/g, "")))
    .filter(Boolean)
    .join("/");
}

/** Absolute URL from `NEXT_PUBLIC_APP_URL` + path. */
export function absoluteUrl(path = "/", baseOverride?: string): string {
  const base =
    baseOverride ??
    process.env.NEXT_PUBLIC_APP_URL ??
    "http://localhost:3000";
  return `${stripTrailingSlash(base)}${path.startsWith("/") ? path : `/${path}`}`;
}
