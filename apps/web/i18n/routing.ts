import { defineRouting } from "next-intl/routing";
import { createNavigation } from "next-intl/navigation";
import { brand } from "@librarfree/brand";

export const routing = defineRouting({
  locales: brand.locales,
  defaultLocale: brand.defaultLocale,
  localePrefix: "always",
});

export type AppLocale = (typeof routing.locales)[number];

export const { Link, redirect, usePathname, useRouter, getPathname } =
  createNavigation(routing);
