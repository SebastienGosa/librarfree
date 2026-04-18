import { brand } from "@librarfree/brand";

type Thing = Record<string, unknown>;

export interface JsonLdAuthor {
  name: string;
  slug?: string;
  birthYear?: number;
  deathYear?: number;
  wikidataId?: string;
}

export interface JsonLdBookInput {
  title: string;
  slug: string;
  language: string;
  author: JsonLdAuthor;
  originalPublicationYear?: number;
  description?: string;
  wordCount?: number;
  coverUrl?: string;
  isbn?: string;
  inLanguage?: string[];
  locale?: string;
}

const stripUndefined = (obj: Thing): Thing => {
  const out: Thing = {};
  for (const [k, v] of Object.entries(obj)) {
    if (v !== undefined && v !== null && v !== "") out[k] = v;
  }
  return out;
};

const absoluteUrl = (path: string): string => {
  if (path.startsWith("http")) return path;
  return `${brand.url}${path.startsWith("/") ? path : `/${path}`}`;
};

export function jsonLdOrganization(): Thing {
  return stripUndefined({
    "@context": "https://schema.org",
    "@type": "Organization",
    name: brand.name,
    legalName: brand.legalName,
    url: brand.url,
    logo: absoluteUrl("/logo.png"),
    email: brand.email,
    sameAs: [brand.github, `https://twitter.com/${brand.social.twitter.replace("@", "")}`],
  });
}

export function jsonLdWebsite(): Thing {
  return stripUndefined({
    "@context": "https://schema.org",
    "@type": "WebSite",
    name: brand.name,
    url: brand.url,
    description: brand.description,
    inLanguage: brand.locales,
    potentialAction: {
      "@type": "SearchAction",
      target: {
        "@type": "EntryPoint",
        urlTemplate: `${brand.url}/search?q={search_term_string}`,
      },
      "query-input": "required name=search_term_string",
    },
  });
}

export function jsonLdPerson(author: JsonLdAuthor): Thing {
  return stripUndefined({
    "@context": "https://schema.org",
    "@type": "Person",
    name: author.name,
    url: author.slug ? absoluteUrl(`/authors/${author.slug}`) : undefined,
    birthDate: author.birthYear ? String(author.birthYear) : undefined,
    deathDate: author.deathYear ? String(author.deathYear) : undefined,
    sameAs: author.wikidataId ? [`https://www.wikidata.org/wiki/${author.wikidataId}`] : undefined,
  });
}

export function jsonLdBook(book: JsonLdBookInput): Thing {
  const locale = book.locale ?? book.language;
  return stripUndefined({
    "@context": "https://schema.org",
    "@type": "Book",
    name: book.title,
    url: absoluteUrl(`/${locale}/books/${book.slug}`),
    inLanguage: book.inLanguage ?? [book.language],
    author: jsonLdPerson(book.author),
    bookFormat: "EBook",
    isAccessibleForFree: true,
    license: "https://creativecommons.org/publicdomain/mark/1.0/",
    datePublished: book.originalPublicationYear ? String(book.originalPublicationYear) : undefined,
    description: book.description,
    numberOfPages: book.wordCount ? Math.max(1, Math.round(book.wordCount / 300)) : undefined,
    image: book.coverUrl ? absoluteUrl(book.coverUrl) : undefined,
    isbn: book.isbn,
    publisher: jsonLdOrganization(),
  });
}

export interface BreadcrumbItem {
  name: string;
  url: string;
}

export function jsonLdBreadcrumbs(items: BreadcrumbItem[]): Thing {
  return {
    "@context": "https://schema.org",
    "@type": "BreadcrumbList",
    itemListElement: items.map((it, i) => ({
      "@type": "ListItem",
      position: i + 1,
      name: it.name,
      item: absoluteUrl(it.url),
    })),
  };
}

export interface FaqItem {
  question: string;
  answer: string;
}

export function jsonLdFaq(items: FaqItem[]): Thing {
  return {
    "@context": "https://schema.org",
    "@type": "FAQPage",
    mainEntity: items.map((q) => ({
      "@type": "Question",
      name: q.question,
      acceptedAnswer: {
        "@type": "Answer",
        text: q.answer,
      },
    })),
  };
}

/**
 * Render a JSON-LD object as a string ready to embed in
 * `<script type="application/ld+json" dangerouslySetInnerHTML={{ __html: renderJsonLd(x) }} />`.
 * Strips `<` to defeat trivial XSS injection into structured data.
 */
export function renderJsonLd(obj: Thing): string {
  return JSON.stringify(obj).replace(/</g, "\\u003c");
}
