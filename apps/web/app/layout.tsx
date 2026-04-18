import type { ReactNode } from "react";
import type { Metadata, Viewport } from "next";
import { brand } from "@librarfree/brand";
import "./globals.css";

export const metadata: Metadata = {
  metadataBase: new URL(brand.url),
  title: {
    default: brand.seo.defaultTitle,
    template: brand.seo.titleTemplate,
  },
  description: brand.description,
  applicationName: brand.name,
  authors: [{ name: "Sebastien Gosa" }],
  openGraph: {
    title: brand.seo.defaultTitle,
    description: brand.description,
    type: "website",
    siteName: brand.name,
    url: brand.url,
  },
  twitter: {
    card: "summary_large_image",
    site: brand.social.twitter,
    title: brand.seo.defaultTitle,
    description: brand.description,
  },
  icons: {
    icon: "/favicon.ico",
  },
};

export const viewport: Viewport = {
  themeColor: "#0F0F13",
  colorScheme: "dark",
  width: "device-width",
  initialScale: 1,
};

/**
 * Root layout — locale-agnostic. next-intl's middleware routes all paths
 * under `/[locale]/...`, so the actual `<html>` element with `lang` lives
 * in `app/[locale]/layout.tsx`.
 */
export default function RootLayout({ children }: { children: ReactNode }) {
  return children;
}
