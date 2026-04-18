/**
 * Re-exports of Prisma-generated model types for consumers
 * that want types without pulling the client runtime.
 */
export type {
  Author,
  Book,
  BookTranslation,
  BookFile,
  BookIsbn,
  Category,
  BookCategory,
  Collection,
  CollectionBook,
  AffiliateRetailer,
  AffiliateClick,
  User,
  UserLibraryEntry,
  ReadingList,
  ReadingListBook,
  Annotation,
  ReadingSession,
  PremiumSubscription,
  Donation,
  SearchQuery,
  SystemJob,
  Prisma,
} from "@prisma/client";

/** Canonical translation-quality enum (mirrors schema.sql allowed values). */
export const TranslationQuality = {
  HumanProfessional: "human_professional",
  HumanVolunteer: "human_volunteer",
  MachineNllb: "machine_nllb",
  MachineM2m100: "machine_m2m100",
  MachineOther: "machine_other",
  HumanUnknown: "human_unknown",
} as const;
export type TranslationQuality =
  (typeof TranslationQuality)[keyof typeof TranslationQuality];

/** Canonical file format enum. */
export const BookFileFormat = {
  Epub: "epub",
  Pdf: "pdf",
  Mobi: "mobi",
  Azw3: "azw3",
  Txt: "txt",
  Html: "html",
  Mp3: "mp3",
  M4b: "m4b",
} as const;
export type BookFileFormat =
  (typeof BookFileFormat)[keyof typeof BookFileFormat];

/** Canonical library status enum. */
export const LibraryStatus = {
  Reading: "reading",
  Finished: "finished",
  Planned: "planned",
  Dropped: "dropped",
} as const;
export type LibraryStatus = (typeof LibraryStatus)[keyof typeof LibraryStatus];
