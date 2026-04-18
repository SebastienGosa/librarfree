import * as React from "react";
import { cn } from "../lib/cn";

export type TranslationQualityTone =
  | "human_professional"
  | "human_volunteer"
  | "machine_nllb"
  | "machine_m2m100"
  | "machine_other"
  | "human_unknown";

export interface LanguageBadgeProps extends React.HTMLAttributes<HTMLSpanElement> {
  /** Two-letter language code (e.g. "en", "fr"). */
  language: string;
  /** Translation quality tier. Drives the dot color. */
  quality?: TranslationQualityTone;
  /** Optional translator / editor name. */
  translator?: string;
}

const TONE: Record<TranslationQualityTone, { dot: string; label: string }> = {
  human_professional: { dot: "bg-emerald-400", label: "Human (professional)" },
  human_volunteer: { dot: "bg-emerald-400", label: "Human (volunteer)" },
  human_unknown: { dot: "bg-amber-400", label: "Human (unverified)" },
  machine_nllb: { dot: "bg-sky-400", label: "AI NLLB 200" },
  machine_m2m100: { dot: "bg-sky-400", label: "AI M2M 100" },
  machine_other: { dot: "bg-sky-400", label: "AI translation" },
};

export function LanguageBadge({
  language,
  quality = "human_unknown",
  translator,
  className,
  ...rest
}: LanguageBadgeProps) {
  const tone = TONE[quality];
  return (
    <span
      className={cn(
        "inline-flex items-center gap-2 rounded-full border border-border bg-card/60 px-2.5 py-0.5 text-xs",
        className,
      )}
      title={translator ? `${tone.label}, ${translator}` : tone.label}
      {...rest}
    >
      <span className="font-mono font-semibold uppercase tracking-wider text-foreground">
        {language}
      </span>
      <span className={cn("size-1.5 rounded-full", tone.dot)} aria-hidden="true" />
      <span className="text-muted-foreground">{tone.label}</span>
      {translator ? (
        <span className="text-muted-foreground/80">, {translator}</span>
      ) : null}
    </span>
  );
}
