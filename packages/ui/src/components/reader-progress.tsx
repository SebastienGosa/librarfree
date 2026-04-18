import * as React from "react";
import { cn } from "../lib/cn";

export interface ReaderProgressProps extends React.HTMLAttributes<HTMLDivElement> {
  /** 0–100 */
  value: number;
  /** Optional minutes-to-finish. Renders "~4h of reading left" if provided. */
  minutesRemaining?: number;
  /** Optional chapter position hint. Renders "Chapter 8 of 24" if provided. */
  chapterLabel?: string;
}

/**
 * Narrative progress bar — per plan §5 "Progress poétique":
 * show meaning, not just "42%". Falls back gracefully when no hints exist.
 */
export function ReaderProgress({
  value,
  minutesRemaining,
  chapterLabel,
  className,
  ...rest
}: ReaderProgressProps) {
  const pct = Math.max(0, Math.min(100, value));
  const poetic = chapterLabel ? chapterLabel : `${Math.round(pct)}% read`;
  return (
    <div
      role="progressbar"
      aria-valuenow={pct}
      aria-valuemin={0}
      aria-valuemax={100}
      aria-label={chapterLabel ?? `Reading progress ${Math.round(pct)}%`}
      className={cn("flex flex-col gap-1.5", className)}
      {...rest}
    >
      <div className="h-1.5 w-full overflow-hidden rounded-full bg-muted">
        <div
          className="h-full rounded-full bg-primary transition-[width] duration-300 ease-out"
          style={{ width: `${pct}%` }}
        />
      </div>
      <div className="flex justify-between text-xs text-muted-foreground">
        <span>{poetic}</span>
        {minutesRemaining !== undefined ? (
          <span>~{formatMinutes(minutesRemaining)} left</span>
        ) : null}
      </div>
    </div>
  );
}

function formatMinutes(minutes: number): string {
  if (minutes < 60) return `${minutes} min`;
  const h = Math.floor(minutes / 60);
  const m = minutes % 60;
  return m === 0 ? `${h}h` : `${h}h ${m}min`;
}
