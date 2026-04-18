import * as React from "react";
import { cn } from "../lib/cn";

export interface CitationCardProps extends React.HTMLAttributes<HTMLElement> {
  /** The quote itself — plain text, no quotes in the string (we add them). */
  quote: string;
  /** Author attribution (e.g. "Victor Hugo"). */
  author: string;
  /** Work title (e.g. "Les Misérables, tome I"). */
  work?: string;
  /** Publication year. */
  year?: number;
  /** Language code — drives dir & lang attributes for correct rendering. */
  language?: string;
  /** Translator credit if the quote is a translation. */
  translator?: string;
  /** Visual emphasis level. `hero` = full-width editorial break. */
  size?: "default" | "hero";
}

/**
 * Editorial pull quote — uses the gold `accent` token for the quotation mark
 * and the rule. Literata serif for the quote body, Inter for attribution.
 *
 * Designed to break up long-form scrolling on the homepage and book detail
 * pages. Intentionally NOT a card — no background, no border on `default`,
 * feels like a printed page callout.
 */
export function CitationCard({
  quote,
  author,
  work,
  year,
  language,
  translator,
  size = "default",
  className,
  ...rest
}: CitationCardProps) {
  const isHero = size === "hero";
  return (
    <figure
      className={cn(
        "relative flex flex-col gap-4",
        isHero ? "py-10 md:py-16" : "py-6",
        className,
      )}
      {...rest}
    >
      <span
        aria-hidden="true"
        className={cn(
          "font-serif leading-none text-accent",
          isHero ? "text-7xl md:text-8xl" : "text-5xl",
        )}
      >
        &ldquo;
      </span>
      <blockquote
        lang={language}
        className={cn(
          "font-serif leading-[1.25] text-foreground",
          isHero
            ? "text-3xl md:text-4xl lg:text-[2.75rem]"
            : "text-xl md:text-2xl",
        )}
      >
        {quote}
      </blockquote>
      <figcaption className="flex flex-wrap items-center gap-x-3 gap-y-1 pt-2 text-sm text-muted-foreground">
        <span
          aria-hidden="true"
          className="inline-block h-px w-8 bg-accent"
        />
        <cite className="not-italic font-medium text-foreground">
          {author}
        </cite>
        {work ? (
          <span className="italic">
            {work}
            {year ? <span className="not-italic opacity-70"> ({year})</span> : null}
          </span>
        ) : year ? (
          <span className="opacity-70">({year})</span>
        ) : null}
        {translator ? (
          <span className="opacity-70">
            · trans. {translator}
          </span>
        ) : null}
      </figcaption>
    </figure>
  );
}
