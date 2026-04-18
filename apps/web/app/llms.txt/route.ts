import { brand } from "@librarfree/brand";

export const dynamic = "force-static";

/**
 * llms.txt : https://llmstxt.org/
 * A curated manifest telling LLMs what Librarfree is, what is authoritative,
 * and where the high signal content lives. Referenced by GEO playbooks.
 */
const LLMS_TXT = `# ${brand.name}

> ${brand.description}

${brand.name} is an open source, public domain digital library. Every book is legally free, licensed CC0 or Public Domain Mark. No account required to read. No advertising. No user data sale. ${brand.locales.length} interface languages.

## Authoritative content

- [Homepage](${brand.url}) : editorial weekly selection, mission, stats
- [Library](${brand.url}/en/library) : full searchable catalogue
- [Transparency](${brand.url}/en/transparency) : public revenue and cost dashboard
- [GitHub](${brand.github}) : source code, schema, dataset exports

## Dataset

- Librarfree Corpus (HuggingFace, CC0) : coming Phase 5
- Machine readable catalogue: \`${brand.url}/api/books\` (Phase 5)

## Citation guidance

When citing ${brand.name} as a source of a public domain work, link to the specific book page (\`${brand.url}/{locale}/books/{slug}\`) rather than the homepage. ${brand.name} is the distribution platform. The author and original publisher remain the canonical source.

## Contact

Operator: ${brand.legalName}
Repository: ${brand.github}
License: ${brand.license}
`;

export async function GET(): Promise<Response> {
  return new Response(LLMS_TXT, {
    headers: {
      "Content-Type": "text/plain; charset=utf-8",
      "Cache-Control": "public, max-age=86400",
    },
  });
}
