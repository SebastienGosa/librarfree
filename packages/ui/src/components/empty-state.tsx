import * as React from "react";
import { cn } from "../lib/cn";

export interface EmptyStateProps extends React.HTMLAttributes<HTMLDivElement> {
  /** Primary heading — short, sentence case. */
  title: string;
  /** Supporting paragraph — one or two sentences, no more. */
  description?: string;
  /** Optional icon or illustration slot (rendered above the title). */
  icon?: React.ReactNode;
  /** Primary call to action (usually a Button / Link). */
  action?: React.ReactNode;
  /** Secondary link, rendered as muted text below the primary action. */
  secondaryAction?: React.ReactNode;
  /** Visual density. `compact` for inline empty lists, `default` for page-level. */
  variant?: "default" | "compact";
}

/**
 * Generic empty state — search with no results, empty shelves, offline
 * fallback, error boundary. Calm, editorial, never accusatory.
 *
 * Zero dark patterns: no "upgrade to unlock", no manufactured urgency.
 * Just a clear explanation and a next step.
 */
export function EmptyState({
  title,
  description,
  icon,
  action,
  secondaryAction,
  variant = "default",
  className,
  ...rest
}: EmptyStateProps) {
  const isCompact = variant === "compact";
  return (
    <div
      role="status"
      aria-live="polite"
      className={cn(
        "flex flex-col items-center text-center",
        isCompact ? "gap-3 py-8" : "gap-5 py-16 md:py-24",
        className,
      )}
      {...rest}
    >
      {icon ? (
        <div
          aria-hidden="true"
          className={cn(
            "flex items-center justify-center rounded-full border border-border bg-card/60 text-muted-foreground",
            isCompact ? "size-10" : "size-14",
          )}
        >
          {icon}
        </div>
      ) : null}
      <h3
        className={cn(
          "font-serif text-foreground",
          isCompact ? "text-lg" : "text-2xl md:text-3xl",
        )}
      >
        {title}
      </h3>
      {description ? (
        <p
          className={cn(
            "max-w-md text-muted-foreground",
            isCompact ? "text-sm" : "text-base md:text-lg",
          )}
        >
          {description}
        </p>
      ) : null}
      {action ? <div className="mt-2">{action}</div> : null}
      {secondaryAction ? (
        <div className="text-sm text-muted-foreground">{secondaryAction}</div>
      ) : null}
    </div>
  );
}
