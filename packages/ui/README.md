# @librarfree/ui

Design-system package. Exports React components built on `class-variance-authority`, styled with Tailwind v4 utility classes. Consumes `@librarfree/brand` tokens.

## Primitives (shadcn-flavored)

- `Button`, `buttonVariants`
- `Card`, `CardHeader`, `CardTitle`, `CardDescription`, `CardContent`, `CardFooter`
- `Input`
- `Badge`, `badgeVariants`
- `Skeleton`
- `cn(...)` — `clsx` + `tailwind-merge`

## Librarfree-signature components

- `BookCard` — cover + title + author + `LanguageBadge` + optional reading time. Cover placeholder with initials when no image.
- `LanguageBadge` — language code dot showing human / AI translation quality. Non-negotiable per manifesto.
- `ReaderProgress` — narrative progress bar ("Chapter 8 of 24", "~4h left") per plan §5 "Progress poétique".

## Tailwind v4 wiring

`apps/web/app/globals.css` owns the `@theme` block (imports color tokens from `@librarfree/brand`). `packages/ui` never ships Tailwind config — component classes are discovered via `@source "../../packages/ui/src/**/*.{ts,tsx}"` in the app globals.

## Usage

```tsx
import { Button, BookCard, LanguageBadge } from "@librarfree/ui";

<Button variant="outline" size="lg">Read now</Button>
<BookCard title="Les Misérables" authorName="Victor Hugo" language="fr" translationQuality="human_professional" />
```

More components to come as apps/web pages are built (Phase 1+): Dialog, DropdownMenu, Tabs, Toast, Command (Cmd+K palette), Accordion.
