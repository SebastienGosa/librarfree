import createNextIntlPlugin from "next-intl/plugin";

const withNextIntl = createNextIntlPlugin("./i18n/request.ts");

/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  poweredByHeader: false,
  transpilePackages: [
    "@librarfree/brand",
    "@librarfree/db",
    "@librarfree/ui",
    "@librarfree/utils",
  ],
  typedRoutes: true,
  images: {
    remotePatterns: [
      { protocol: "https", hostname: "www.gutenberg.org" },
      { protocol: "https", hostname: "covers.openlibrary.org" },
      { protocol: "https", hostname: "upload.wikimedia.org" },
      { protocol: "http", hostname: "localhost" },
    ],
  },
};

export default withNextIntl(nextConfig);
