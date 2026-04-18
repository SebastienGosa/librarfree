import * as React from "react";

export interface CoverTileProps {
  title: string;
  author: string;
  year?: number;
  language?: string;
  href?: string;
}

function hashHue(seed: string): number {
  let h = 0;
  for (let i = 0; i < seed.length; i++) h = (h * 31 + seed.charCodeAt(i)) >>> 0;
  return h % 360;
}

/**
 * CSS-generated book cover tile — no external images, fast render, dense grid.
 * Colour is deterministic from title+author so a given book keeps its cover
 * across re-renders. Warm palette (gold + cream accents) to keep library feel.
 */
export function CoverTile({ title, author, year, language, href }: CoverTileProps) {
  const hue = hashHue(title + author);
  const base = `hsl(${hue}deg 30% 22%)`;
  const edge = `hsl(${(hue + 20) % 360}deg 40% 14%)`;
  const bg = `linear-gradient(145deg, ${base} 0%, ${edge} 100%)`;
  const grain =
    "repeating-linear-gradient(120deg, rgba(255,255,255,0.03) 0 2px, rgba(0,0,0,0.05) 2px 4px)";
  const vignette =
    "radial-gradient(ellipse at 30% 0%, rgba(255,235,180,0.18) 0%, rgba(0,0,0,0) 55%)";

  const Wrapper = (href ? "a" : "article") as React.ElementType;

  return (
    <Wrapper
      href={href}
      className="group relative aspect-[2/3] overflow-hidden rounded-[2px] border border-black/40 shadow-[0_6px_14px_-8px_rgba(0,0,0,0.7)] transition-transform duration-200 hover:-translate-y-0.5 hover:shadow-[0_14px_22px_-10px_rgba(0,0,0,0.8)]"
      style={{ backgroundImage: `${vignette}, ${grain}, ${bg}` }}
      title={`${title}, ${author}`}
    >
      {/* Spine shadow on the left edge */}
      <span
        aria-hidden="true"
        className="absolute inset-y-0 left-0 w-[6px] bg-gradient-to-r from-black/60 to-transparent"
      />

      {/* Gold hairline frame */}
      <span
        aria-hidden="true"
        className="absolute inset-[7px] rounded-[1px] border border-[#c9a94a]/30"
      />

      {/* Title block */}
      <div className="absolute inset-x-3 top-4">
        <p className="font-mono text-[9px] uppercase tracking-[0.2em] text-[#f3e4bc]/60">
          {language ? language.toUpperCase() : "·"}
          {year ? ` · ${year}` : ""}
        </p>
      </div>
      <div className="absolute inset-x-3 bottom-3">
        <h3 className="line-clamp-3 font-serif text-[13px] leading-tight text-[#f3e4bc] drop-shadow-[0_1px_0_rgba(0,0,0,0.6)]">
          {title}
        </h3>
        <p className="mt-1 line-clamp-1 font-serif text-[10px] italic text-[#f3e4bc]/65">
          {author}
        </p>
      </div>
    </Wrapper>
  );
}
