import * as React from "react";

export interface CatalogCardProps {
  callNumber: string;
  title: string;
  author: string;
  language: string;
  year?: number;
  translations?: number;
  source?: string;
  cardNumber?: string;
  children?: React.ReactNode;
}

/**
 * Library catalog index card — Courier typeface, ruled lines, punched hole
 * in the top-left corner like the physical bristol cards used in 20th century
 * public libraries before OPAC terminals.
 *
 * Rendered slightly skewed to evoke a stack of hand-filed cards.
 */
export function CatalogCard({
  callNumber,
  title,
  author,
  language,
  year,
  translations,
  source,
  cardNumber,
  children,
}: CatalogCardProps) {
  return (
    <article
      className="relative rounded-[3px] border border-[#c9b48a]/30 bg-[#f5ecd4] p-5 pl-10 text-[#3b2e1a] shadow-[0_10px_22px_-14px_rgba(0,0,0,0.7),inset_0_0_0_1px_rgba(255,255,255,0.4)] transition-transform duration-300 hover:-translate-y-1 hover:rotate-0 sm:p-6 sm:pl-12"
      style={{
        fontFamily: "var(--font-mono), ui-monospace, monospace",
        backgroundImage:
          "repeating-linear-gradient(180deg, rgba(59,46,26,0) 0 30px, rgba(59,46,26,0.08) 30px 31px)",
        transform: "rotate(-0.3deg)",
      }}
    >
      {/* Punched hole */}
      <span
        aria-hidden="true"
        className="absolute left-3 top-4 size-4 rounded-full border border-[#3b2e1a]/30 bg-[#0F0F13] shadow-[inset_0_1px_3px_rgba(0,0,0,0.6)]"
      />

      {/* Card number top right */}
      {cardNumber ? (
        <span
          aria-hidden="true"
          className="absolute right-3 top-3 text-[10px] uppercase tracking-[0.2em] text-[#3b2e1a]/50"
        >
          nº {cardNumber}
        </span>
      ) : null}

      {/* Call number */}
      <div className="mb-3 flex items-baseline justify-between gap-3">
        <span className="font-sans text-[10px] uppercase tracking-[0.3em] text-[#7a5a1f]">
          Cote
        </span>
        <span className="text-sm tracking-wider text-[#3b2e1a]">{callNumber}</span>
      </div>

      <div className="h-px w-full bg-[#3b2e1a]/20" />

      {/* Title */}
      <h3 className="mt-3 font-serif text-xl leading-tight text-[#2a1f10]">
        {title}
      </h3>
      <p className="mt-1 text-sm text-[#3b2e1a]/80">
        {author}
        {year ? `, ${year}` : ""}
      </p>

      <dl className="mt-4 grid grid-cols-[auto_1fr] gap-x-4 gap-y-1.5 text-[11px] uppercase tracking-[0.12em]">
        <dt className="text-[#7a5a1f]">Langue</dt>
        <dd className="text-[#3b2e1a]">{language}</dd>
        {typeof translations === "number" ? (
          <>
            <dt className="text-[#7a5a1f]">Traductions</dt>
            <dd className="text-[#3b2e1a]">{translations}</dd>
          </>
        ) : null}
        {source ? (
          <>
            <dt className="text-[#7a5a1f]">Source</dt>
            <dd className="text-[#3b2e1a]">{source}</dd>
          </>
        ) : null}
      </dl>

      {children ? (
        <div className="mt-4 border-t border-[#3b2e1a]/20 pt-3 text-xs leading-relaxed text-[#3b2e1a]/80">
          {children}
        </div>
      ) : null}
    </article>
  );
}
