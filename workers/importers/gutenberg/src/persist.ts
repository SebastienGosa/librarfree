/**
 * Persistence layer: Author → Book → BookTranslation → BookFile.
 *
 * Idempotent: re-running the importer for the same Gutenberg ID is a no-op
 * at each level — we look up by business keys (gutenbergId, sourceIdentifier)
 * before inserting.
 */
import { prisma } from "@librarfree/db";
import { slugify, uniqueSlug } from "@librarfree/utils";
import type { GutenbergRow, AuthorRef } from "./catalog.js";

export interface PersistInput {
  row: GutenbergRow;
  sourceUrl: string;
  storageUrl: string;
  byteSize: number;
  wordCount: number;
  readingTimeMinutes: number;
  readabilityScore: number;
  qualityScore: number;
}

export interface PersistResult {
  bookId: string;
  translationId: string;
  fileId: string;
  created: boolean;
}

async function upsertAuthor(ref: AuthorRef): Promise<string> {
  const existing = await prisma.author.findFirst({
    where: { name: ref.name },
    select: { id: true },
  });
  if (existing) return existing.id;

  const baseSlug = slugify(ref.name) || "anonymous";
  const used = await prisma.author.findMany({
    where: { slug: { startsWith: baseSlug } },
    select: { slug: true },
  });
  const slug = uniqueSlug(baseSlug, new Set(used.map((a) => a.slug)));

  const created = await prisma.author.create({
    data: {
      slug,
      name: ref.name,
      birthYear: ref.birthYear ?? null,
      deathYear: ref.deathYear ?? null,
    },
    select: { id: true },
  });
  return created.id;
}

async function allocateBookSlug(title: string): Promise<string> {
  const baseSlug = slugify(title) || "untitled";
  const used = await prisma.book.findMany({
    where: { slug: { startsWith: baseSlug } },
    select: { slug: true },
  });
  return uniqueSlug(baseSlug, new Set(used.map((b) => b.slug)));
}

export async function persistBook(input: PersistInput): Promise<PersistResult> {
  const { row } = input;

  // ─── Book (dedup on gutenbergId, which is UNIQUE) ───────────────
  let bookId: string;
  let bookCreated = false;
  const existingBook = await prisma.book.findUnique({
    where: { gutenbergId: row.id },
    select: { id: true },
  });

  if (existingBook) {
    bookId = existingBook.id;
  } else {
    const authorRef = row.authors[0];
    const authorId = authorRef ? await upsertAuthor(authorRef) : null;
    const created = await prisma.book.create({
      data: {
        slug: await allocateBookSlug(row.title),
        gutenbergId: row.id,
        titleOriginal: row.title,
        authorId,
        originalLanguage: row.language,
        sourceProject: "gutenberg",
        sourceIdentifier: String(row.id),
        sourceUrl: input.sourceUrl,
        qualityScore: input.qualityScore,
        license: "public_domain",
      },
      select: { id: true },
    });
    bookId = created.id;
    bookCreated = true;
  }

  // ─── Translation (original language, dedup on business key) ─────
  const existingTranslation = await prisma.bookTranslation.findFirst({
    where: {
      bookId,
      languageCode: row.language,
      sourceProject: "gutenberg",
      sourceIdentifier: String(row.id),
    },
    select: { id: true },
  });

  const translation = existingTranslation
    ? await prisma.bookTranslation.update({
        where: { id: existingTranslation.id },
        data: {
          wordCount: input.wordCount,
          readingTimeMinutes: input.readingTimeMinutes,
          readabilityScore: input.readabilityScore,
          qualityCheckScore: input.qualityScore,
        },
        select: { id: true },
      })
    : await prisma.bookTranslation.create({
        data: {
          bookId,
          languageCode: row.language,
          titleTranslated: row.title,
          isMachineTranslated: false,
          translationQuality: "human_unknown",
          sourceProject: "gutenberg",
          sourceIdentifier: String(row.id),
          sourceUrl: input.sourceUrl,
          wordCount: input.wordCount,
          readingTimeMinutes: input.readingTimeMinutes,
          readabilityScore: input.readabilityScore,
          qualityCheckScore: input.qualityScore,
        },
        select: { id: true },
      });

  // ─── TXT file record (EPUB/PDF derived Phase 2) ─────────────────
  const existingFile = await prisma.bookFile.findFirst({
    where: { bookTranslationId: translation.id, format: "txt" },
    select: { id: true },
  });

  const file = existingFile
    ? await prisma.bookFile.update({
        where: { id: existingFile.id },
        data: {
          fileUrl: input.storageUrl,
          fileSizeBytes: BigInt(input.byteSize),
        },
        select: { id: true },
      })
    : await prisma.bookFile.create({
        data: {
          bookTranslationId: translation.id,
          format: "txt",
          fileUrl: input.storageUrl,
          fileSizeBytes: BigInt(input.byteSize),
          isOriginal: true,
          generator: "gutenberg",
        },
        select: { id: true },
      });

  return { bookId, translationId: translation.id, fileId: file.id, created: bookCreated };
}
