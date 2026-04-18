/**
 * @librarfree/db — Prisma client singleton
 * ----------------------------------------
 * Usage (server-only):
 *
 *   import { prisma } from "@librarfree/db";
 *   const books = await prisma.book.findMany({ take: 10 });
 *
 * Never import this from client components.
 */
import { PrismaClient } from "@prisma/client";

const globalForPrisma = globalThis as unknown as {
  prisma: PrismaClient | undefined;
};

export const prisma: PrismaClient =
  globalForPrisma.prisma ??
  new PrismaClient({
    log: process.env.NODE_ENV === "development" ? ["warn", "error"] : ["error"],
  });

if (process.env.NODE_ENV !== "production") {
  globalForPrisma.prisma = prisma;
}

export * from "@prisma/client";
export type { PrismaClient } from "@prisma/client";
