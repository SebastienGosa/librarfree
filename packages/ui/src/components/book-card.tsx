import * as React from "react";
import { cn } from "../lib/cn";
import { LanguageBadge, type TranslationQualityTone } from "./language-badge";

export type BookCardVariant = "default" | "editorial-hero";

export interface BookCardProps extends React.HTMLAttributes<HTMLElement> {
  title: string;
  authorName: string;
  coverUrl?: string;
  language: string;
  translationQuality?: TranslationQualityTone;
  year?: number;
  readingTimeLabel?: string;
  href?: string;
  /**
   * Visual variant:
   * - `default` — grid cell (aspect 2/3 cover + 3-line metadata)
   * - `editorial-hero` — full-width editorial hero, horizontal on md+,
   *   enriched metadata (origin, century, #languages available, excerpt)
   */
  variant?: BookCardVariant;
  /** Editorial-only: short pitch or excerpt shown below the metadata. */
  excerpt?: string;
  /** Editorial-only: country / origin label (e.g. "France · 19e siècle"). */
  origin?: string;
  /** Editorial-only: number of translations available. */
  translationCount?: number;
  /** Editorial-only: eyebrow label (e.g. "Livre du jour"). */
  eyebrow?: string;
}

/**
 * Signature book card — cover-forward, typography-first, language+quality
 * always visible (manifeste : transparence radicale).
 *
 * Two variants:
 * - `default`: browsing grids, carousels, recommendation rails.
 * - `editorial-hero`: front-page feature ("Livre du jour", collections hero),
 *   horizontal layout on md+, larger cover, Literata display size, richer
 *   metadata. Uses the gold `accent` token on the eyebrow for editorial feel.
 */
export function BookCard({
  title,
  authorName,
  coverUrl,
  language,
  translationQuality,
  year,
  readingTimeLabel,
  href,
  variant = "default",
  excerpt,
  origin,
  translationCount,
  eyebrow,
  className,
  ...rest
}: BookCardProps) {
  if (variant === "editorial-hero") {
    return (
      <EditorialHero
        title={title}
        authorName={authorName}
        coverUrl={coverUrl}
        language={language}
        translationQuality={translationQuality}
        year={year}
        readingTimeLabel={readingTimeLabel}
        href={href}
        excerpt={excerpt}
        origin={origin}
        translationCount={translationCount}
        eyebrow={eyebrow}
        className={className}
        {...rest}
      />
    );
  }

  const Wrapper = (href ? "a" : "article") as React.ElementType;
  return (
    <Wrapper
      href={href}
      className={cn(
        "group relative block overflow-hidden rounded-xl border border-border bg-card transition-transform hover:-translate-y-0.5 hover:border-primary/60 hover:shadow-lg",
        className,
      )}
      {...rest}
    >
      <div className="aspect-[2/3] w-full overflow-hidden bg-muted">
        {coverUrl ? (
          // eslint-disable-next-line @next/next/no-img-element
          <img
            src={coverUrl}
            alt=""
            loading="lazy"
            className="h-full w-full object-cover transition-transform duration-300 group-hover:scale-[1.02]"
          />
        ) : (
          <PlaceholderCover title={title} />
        )}
      </div>
      <div className="flex flex-col gap-1.5 p-3">
        <h3 className="font-serif text-sm font-semibold leading-tight text-foreground line-clamp-2">
          {title}
        </h3>
        <p className="text-xs text-muted-foreground">
          {authorName}
          {year ? <span className="opacity-70"> · {year}</span> : null}
        </p>
        <div className="mt-1 flex flex-wrap items-center gap-1.5">
          <LanguageBadge language={language} quality={translationQuality} />
          {readingTimeLabel ? (
            <span className="text-xs text-muted-foreground">· {readingTimeLabel}</span>
          ) : null}
        </div>
      </div>
    </Wrapper>
  );
}

interface EditorialHeroProps extends Omit<BookCardProps, "variant"> {}

function EditorialHero({
  title,
  authorName,
  coverUrl,
  language,
  translationQuality,
  year,
  readingTimeLabel,
  href,
  excerpt,
  origin,
  translationCount,
  eyebrow,
  className,
  ...rest
}: EditorialHeroProps) {
  const Wrapper = (href ? "a" : "article") as React.ElementType;
  return (
    <Wrapper
      href={href}
      className={cn(
        "group relative grid gap-8 overflow-hidden rounded-2xl border border-border bg-card/40 p-6 transition-colors hover:border-primary/40 md:grid-cols-[minmax(220px,280px)_1fr] md:gap-10 md:p-10",
        className,
      )}
      {...rest}
    >
      <div className="aspect-[2/3] w-full max-w-[280px] overflow-hidden rounded-lg bg-muted shadow-2xl shadow-black/40 md:max-w-none">
        {coverUrl ? (
          // eslint-disable-next-line @next/next/no-img-element
          <img
            src={coverUrl}
            alt=""
            loading="lazy"
            className="h-full w-full object-cover transition-transform duration-500 group-hover:scale-[1.02]"
          />
        ) : (
          <PlaceholderCover title={title} />
        )}
      </div>
      <div className="flex flex-col justify-center gap-4">
        {eyebrow ? (
          <p className="font-mono text-xs uppercase tracking-[0.2em] text-accent">
            {eyebrow}
          </p>
        ) : null}
        <h3 className="font-serif text-3xl leading-[1.1] text-foreground md:text-5xl md:leading-[1.05]">
          {title}
        </h3>
        <p className="text-base text-muted-foreground md:text-lg">
          {authorName}
          {year ? <span className="opacity-70"> · {year}</span> : null}
          {origin ? <span className="opacity-70"> · {origin}</span> : null}
        </p>
        {excerpt ? (
          <p className="max-w-xl font-serif text-lg leading-relaxed text-foreground/90 md:text-xl">
            {excerpt}
          </p>
        ) : null}
        <div className="mt-2 flex flex-wrap items-center gap-3 text-sm text-muted-foreground">
          <LanguageBadge language={language} quality={translationQuality} />
          {typeof translationCount === "number" && translationCount > 0 ? (
            <span>
              <span className="font-mono text-foreground">{translationCount}</span>
              {" "}translations available
            </span>
          ) : null}
          {readingTimeLabel ? <span>{readingTimeLabel}</span> : null}
        </div>
      </div>
    </Wrapper>
  );
}

function PlaceholderCover({ title }: { title: string }) {
  const initials = title
    .split(/\s+/)
    .slice(0, 3)
    .map((w) => w[0]?.toUpperCase())
    .filter(Boolean)
    .join("");
  return (
    <div
      className="flex h-full w-full items-center justify-center bg-gradient-to-br from-primary/25 via-muted to-accent/20 font-serif text-3xl text-muted-foreground"
      aria-hidden="true"
    >
      {initials || "…"}
    </div>
  );
}
