"use client";

import { useLocale } from "next-intl";
import { usePathname, useRouter } from "@/i18n/routing";
import { brand } from "@librarfree/brand";
import { useTransition } from "react";

const LABELS: Record<string, string> = {
  en: "EN",
  fr: "FR",
  de: "DE",
  es: "ES",
  it: "IT",
  pt: "PT",
  ja: "日本語",
  zh: "中文",
  ru: "RU",
  pl: "PL",
  nl: "NL",
  ar: "AR",
};

export function LocaleSwitcher() {
  const locale = useLocale();
  const router = useRouter();
  const pathname = usePathname();
  const [, start] = useTransition();

  return (
    <label className="sr-only">
      Language
      <select
        className="rounded-md border border-border bg-transparent px-2 py-1 text-xs not-sr-only focus:outline-none focus-visible:ring-2 focus-visible:ring-ring"
        value={locale}
        onChange={(e) => {
          const next = e.target.value;
          start(() => {
            router.replace(pathname, { locale: next });
          });
        }}
      >
        {brand.locales.map((l) => (
          <option key={l} value={l}>
            {LABELS[l] ?? l.toUpperCase()}
          </option>
        ))}
      </select>
    </label>
  );
}
