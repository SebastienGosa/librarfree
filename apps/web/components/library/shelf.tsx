import * as React from "react";
import { BookSpine, type BookSpineProps } from "./book-spine";

export interface ShelfProps {
  dewey: string;
  label: string;
  books: Array<Pick<BookSpineProps, "title" | "author" | "href">>;
  height?: "sm" | "md" | "lg";
}

/**
 * A single library shelf — horizontal row of book spines sitting on a
 * wooden shelf rail, with a Dewey call-number marker on the left.
 *
 * Server component: no interactivity beyond native hover/focus.
 */
export function Shelf({ dewey, label, books, height = "md" }: ShelfProps) {
  return (
    <div className="group/shelf relative">
      {/* Shelf marker (dewey + label) */}
      <div className="mb-2 flex items-baseline gap-3">
        <span className="inline-flex items-center gap-2 rounded-sm border border-[#8f7a4e]/40 bg-[#1a140a]/60 px-2 py-0.5 font-mono text-[10px] uppercase tracking-[0.18em] text-accent/90">
          {dewey}
        </span>
        <span className="font-serif text-sm italic text-muted-foreground">
          {label}
        </span>
      </div>

      {/* Books row — horizontal scroll on mobile, full width on md+ */}
      <div className="relative">
        <div className="flex items-end gap-[3px] overflow-x-auto pb-3 pl-1 [scrollbar-width:thin] md:overflow-x-visible">
          {books.map((book, i) => (
            <BookSpine key={`${book.title}-${i}`} {...book} height={height} />
          ))}
        </div>

        {/* Shelf rail (wooden plank) */}
        <div
          aria-hidden="true"
          className="absolute inset-x-0 -bottom-px h-2 rounded-[2px] shadow-[0_2px_6px_rgba(0,0,0,0.4)]"
          style={{
            background:
              "linear-gradient(180deg, #6b553a 0%, #4f3e28 50%, #3a2d1d 100%)",
          }}
        />
        <div
          aria-hidden="true"
          className="absolute inset-x-0 -bottom-3 h-1 bg-black/40 blur-[3px]"
        />
      </div>
    </div>
  );
}
