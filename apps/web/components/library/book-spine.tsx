import * as React from "react";

export interface BookSpineProps {
  title: string;
  author: string;
  href?: string;
  height?: "sm" | "md" | "lg";
  hue?: number;
}

function hashHue(seed: string): number {
  let h = 0;
  for (let i = 0; i < seed.length; i++) h = (h * 31 + seed.charCodeAt(i)) >>> 0;
  return h % 360;
}

const HEIGHT_CLASS = {
  sm: "h-44 md:h-56",
  md: "h-56 md:h-72",
  lg: "h-64 md:h-80",
};

const WIDTH_JITTER = ["w-10", "w-11", "w-12", "w-[52px]", "w-14"];

export function BookSpine({ title, author, href, height = "md", hue }: BookSpineProps) {
  const h = hue ?? hashHue(title + author);
  const widthClass = WIDTH_JITTER[title.length % WIDTH_JITTER.length];
  const rotateClass = (title.length + author.length) % 3 === 0 ? "-rotate-[0.5deg]" : "";

  const bg = `linear-gradient(92deg, hsl(${h}deg 22% 18%) 0%, hsl(${h}deg 28% 22%) 35%, hsl(${(h + 12) % 360}deg 30% 15%) 100%)`;
  const grain = `repeating-linear-gradient(90deg, rgba(0,0,0,0) 0 6px, rgba(0,0,0,0.14) 6px 7px)`;
  const foil = `linear-gradient(180deg, rgba(245,183,0,0) 0%, rgba(245,183,0,0.32) 45%, rgba(245,183,0,0) 90%)`;

  const Wrapper = (href ? "a" : "div") as React.ElementType;

  return (
    <Wrapper
      href={href}
      aria-label={`${title} by ${author}`}
      title={`${title}, ${author}`}
      className={`group relative ${widthClass} ${HEIGHT_CLASS[height]} ${rotateClass} shrink-0 rounded-[2px] shadow-[inset_0_0_0_1px_rgba(255,255,255,0.05),0_8px_16px_-6px_rgba(0,0,0,0.6)] transition-transform duration-200 ease-out hover:-translate-y-1 hover:shadow-[inset_0_0_0_1px_rgba(245,183,0,0.25),0_14px_22px_-8px_rgba(0,0,0,0.8)] focus-visible:-translate-y-1`}
      style={{ backgroundImage: `${foil}, ${grain}, ${bg}` }}
    >
      {/* Top & bottom caps (pages edge) */}
      <span
        aria-hidden="true"
        className="absolute inset-x-0 top-0 h-1.5 bg-gradient-to-b from-[#e8d9b7] to-[#b79f73] opacity-70"
      />
      <span
        aria-hidden="true"
        className="absolute inset-x-0 bottom-0 h-1.5 bg-gradient-to-t from-[#8f7a4e] to-[#c9b283] opacity-60"
      />

      {/* Title (rotated 90°) */}
      <span
        className="pointer-events-none absolute inset-0 flex items-center justify-center"
        style={{ transform: "rotate(180deg)", writingMode: "vertical-rl" }}
      >
        <span className="font-serif text-[13px] font-medium uppercase tracking-[0.18em] text-[#f3e4bc] drop-shadow-[0_1px_0_rgba(0,0,0,0.5)]">
          {title}
        </span>
      </span>

      {/* Author below title — only on larger spines */}
      <span
        aria-hidden="true"
        className="pointer-events-none absolute bottom-6 left-1/2 -translate-x-1/2 font-mono text-[9px] uppercase tracking-[0.12em] text-[#f3e4bc]/50"
      >
        ·
      </span>
    </Wrapper>
  );
}
