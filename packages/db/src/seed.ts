/**
 * Minimal dev seed, 5 authors / 5 canonical books.
 * Ships real data via the Gutenberg importer (workers/importers/gutenberg).
 */
import { prisma } from "./index.js";

const authors = [
  {
    slug: "victor-hugo",
    name: "Victor Hugo",
    birthYear: 1802,
    deathYear: 1885,
    nationality: "French",
    bio: "Écrivain français. Les Misérables, Notre Dame de Paris.",
  },
  {
    slug: "leo-tolstoy",
    name: "Leo Tolstoy",
    birthYear: 1828,
    deathYear: 1910,
    nationality: "Russian",
    bio: "Romancier russe. Guerre et Paix, Anna Karénine.",
  },
  {
    slug: "jane-austen",
    name: "Jane Austen",
    birthYear: 1775,
    deathYear: 1817,
    nationality: "British",
    bio: "Romancière anglaise. Orgueil et Préjugés.",
  },
  {
    slug: "mark-twain",
    name: "Mark Twain",
    birthYear: 1835,
    deathYear: 1910,
    nationality: "American",
    bio: "Écrivain américain. Huckleberry Finn, Tom Sawyer.",
  },
  {
    slug: "william-shakespeare",
    name: "William Shakespeare",
    birthYear: 1564,
    deathYear: 1616,
    nationality: "British",
    bio: "Dramaturge anglais.",
  },
] as const;

const books = [
  {
    slug: "les-miserables",
    gutenbergId: 174,
    title: "Les Misérables",
    authorSlug: "victor-hugo",
    language: "fr",
    year: 1862,
    qualityScore: 95,
  },
  {
    slug: "war-and-peace",
    gutenbergId: 2600,
    title: "War and Peace",
    authorSlug: "leo-tolstoy",
    language: "ru",
    year: 1869,
    qualityScore: 98,
  },
  {
    slug: "pride-and-prejudice",
    gutenbergId: 161,
    title: "Pride and Prejudice",
    authorSlug: "jane-austen",
    language: "en",
    year: 1813,
    qualityScore: 96,
  },
  {
    slug: "huckleberry-finn",
    gutenbergId: 76,
    title: "Adventures of Huckleberry Finn",
    authorSlug: "mark-twain",
    language: "en",
    year: 1884,
    qualityScore: 94,
  },
  {
    slug: "shakespeare-complete",
    gutenbergId: 100,
    title: "The Complete Works of William Shakespeare",
    authorSlug: "william-shakespeare",
    language: "en",
    year: 1623,
    qualityScore: 100,
  },
] as const;

async function main() {
  console.log("Seeding authors…");
  for (const a of authors) {
    await prisma.author.upsert({
      where: { slug: a.slug },
      create: a,
      update: {},
    });
  }

  console.log("Seeding books…");
  for (const b of books) {
    const author = await prisma.author.findUnique({ where: { slug: b.authorSlug } });
    if (!author) continue;
    await prisma.book.upsert({
      where: { slug: b.slug },
      create: {
        slug: b.slug,
        gutenbergId: b.gutenbergId,
        titleOriginal: b.title,
        authorId: author.id,
        originalLanguage: b.language,
        firstPublicationYear: b.year,
        sourceProject: "gutenberg",
        qualityScore: b.qualityScore,
      },
      update: {},
    });
  }

  const counts = await Promise.all([
    prisma.author.count(),
    prisma.book.count(),
  ]);
  console.log(`Seeded: authors=${counts[0]}, books=${counts[1]}`);
}

main()
  .catch((err) => {
    console.error(err);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
