import { clsx, type ClassValue } from "clsx";
import { twMerge } from "tailwind-merge";

/** Classic shadcn helper. Conditional class resolution + Tailwind conflict merge. */
export function cn(...inputs: ClassValue[]): string {
  return twMerge(clsx(inputs));
}
