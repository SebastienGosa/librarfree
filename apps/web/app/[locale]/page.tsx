import { getTranslations, setRequestLocale } from "next-intl/server";
import { Search, ArrowUpRight, Download } from "lucide-react";
import { Link } from "@/i18n/routing";

interface HomePageProps {
  params: Promise<{ locale: string }>;
}

const TOP_BOOKS = [
  { slug: "war-and-peace", title: "War and Peace", author: "Lev Tolstoy", year: 1869, lang: "RU", size: "3.2 MB" },
  { slug: "les-miserables", title: "Les Misérables", author: "Victor Hugo", year: 1862, lang: "FR", size: "2.8 MB" },
  { slug: "crime-and-punishment", title: "Crime and Punishment", author: "Fyodor Dostoyevsky", year: 1866, lang: "RU", size: "1.4 MB" },
  { slug: "pride-and-prejudice", title: "Pride and Prejudice", author: "Jane Austen", year: 1813, lang: "EN", size: "680 KB" },
  { slug: "moby-dick", title: "Moby-Dick", author: "Herman Melville", year: 1851, lang: "EN", size: "1.1 MB" },
  { slug: "the-brothers-karamazov", title: "The Brothers Karamazov", author: "Fyodor Dostoyevsky", year: 1880, lang: "RU", size: "2.3 MB" },
  { slug: "anna-karenina", title: "Anna Karenina", author: "Lev Tolstoy", year: 1877, lang: "RU", size: "1.9 MB" },
  { slug: "don-quixote", title: "Don Quixote", author: "Miguel de Cervantes", year: 1605, lang: "ES", size: "2.1 MB" },
  { slug: "faust", title: "Faust", author: "Johann Wolfgang von Goethe", year: 1808, lang: "DE", size: "490 KB" },
  { slug: "the-divine-comedy", title: "La Divina Commedia", author: "Dante Alighieri", year: 1320, lang: "IT", size: "780 KB" },
  { slug: "madame-bovary", title: "Madame Bovary", author: "Gustave Flaubert", year: 1856, lang: "FR", size: "710 KB" },
  { slug: "the-iliad", title: "The Iliad", author: "Homer", year: -750, lang: "EL", size: "890 KB" },
  { slug: "the-count-of-monte-cristo", title: "Le Comte de Monte-Cristo", author: "Alexandre Dumas", year: 1844, lang: "FR", size: "2.5 MB" },
  { slug: "walden", title: "Walden", author: "Henry David Thoreau", year: 1854, lang: "EN", size: "520 KB" },
  { slug: "the-republic", title: "Politeia", author: "Plato", year: -375, lang: "EL", size: "680 KB" },
  { slug: "meditations", title: "Meditations", author: "Marcus Aurelius", year: 180, lang: "LA", size: "210 KB" },
  { slug: "alice-in-wonderland", title: "Alice's Adventures in Wonderland", author: "Lewis Carroll", year: 1865, lang: "EN", size: "180 KB" },
  { slug: "the-odyssey", title: "The Odyssey", author: "Homer", year: -700, lang: "EL", size: "880 KB" },
  { slug: "hamlet", title: "Hamlet", author: "William Shakespeare", year: 1603, lang: "EN", size: "220 KB" },
  { slug: "narrow-road", title: "Oku no Hosomichi", author: "Matsuo Bashō", year: 1702, lang: "JA", size: "140 KB" },
] as const;

const DEWEY_CLASSES = [
  { code: "000", key: "000", count: "4 820" },
  { code: "100", key: "100", count: "28 413" },
  { code: "200", key: "200", count: "19 076" },
  { code: "300", key: "300", count: "41 290" },
  { code: "400", key: "400", count: "12 554" },
  { code: "500", key: "500", count: "33 602" },
  { code: "600", key: "600", count: "26 188" },
  { code: "700", key: "700", count: "47 921" },
  { code: "800", key: "800", count: "218 340" },
  { code: "900", key: "900", count: "69 805" },
] as const;

const DAILY = [
  {
    slug: "les-miserables",
    title: "Les Misérables",
    author: "Victor Hugo",
    year: 1862,
    excerpt:
      "Un juste habitait là. Il se nommait M. Myriel. C'était un vieillard d'environ soixante quinze ans ; il occupait le siège épiscopal de Digne depuis 1806.",
    note: "Livre premier, chapitre I. Édition Gallica 1862, scannée et réalignée avec le manuscrit d'Albert Savine.",
  },
  {
    slug: "anna-karenina",
    title: "Anna Karenina",
    author: "Lev Tolstoy",
    year: 1877,
    excerpt:
      "All happy families are alike ; each unhappy family is unhappy in its own way. Everything was in confusion in the Oblonskys' house.",
    note: "Part One, chapter I. Maude translation (1918), reviewed against the 1920 Moscow critical edition.",
  },
  {
    slug: "meditations",
    title: "Ta eis heauton (Meditations)",
    author: "Marcus Aurelius",
    year: 180,
    excerpt:
      "Commence chaque journée en te disant : je vais rencontrer un indiscret, un ingrat, un insolent, un fourbe, un envieux, un insociable.",
    note: "Livre II, 1. Traduction Pierron (1877), domaine public, relue sur le texte grec de Casaubon.",
  },
] as const;

function formatYear(y: number) {
  return y < 0 ? `${Math.abs(y)} BCE` : `${y}`;
}

export default async function HomePage({ params }: HomePageProps) {
  const { locale } = await params;
  setRequestLocale(locale);
  const t = await getTranslations("home");

  return (
    <>
      {/* HERO, cream reading room, search as the centerpiece */}
      <section
        className="relative overflow-hidden border-b border-border"
        style={{ backgroundColor: "var(--color-ivory)", color: "var(--color-ink)" }}
      >
        <div
          aria-hidden="true"
          className="pointer-events-none absolute inset-0 opacity-[0.18]"
          style={{
            backgroundImage:
              "repeating-linear-gradient(180deg, rgba(42,31,18,0) 0 34px, rgba(42,31,18,0.6) 34px 35px), radial-gradient(ellipse 60% 50% at 20% 0%, rgba(245,183,0,0.18) 0%, transparent 60%)",
          }}
        />
        <div className="container-editorial relative flex flex-col gap-10 py-16 sm:py-24 md:py-28">
          <p className="font-mono text-[11px] uppercase tracking-[0.32em] text-[color:var(--color-oak)]">
            {t("hero.kicker")}
          </p>
          <h1
            className="max-w-3xl font-serif text-[clamp(2.5rem,5.5vw,4.75rem)] leading-[1.02]"
            style={{ color: "var(--color-ink)" }}
          >
            {t("hero.title")}
          </h1>
          <form
            method="GET"
            action={`/${locale}/library`}
            role="search"
            aria-label="Search the library catalogue"
            className="flex w-full max-w-4xl items-stretch gap-0 rounded-sm border-2 shadow-[0_2px_0_rgba(42,31,18,0.1),0_18px_44px_-24px_rgba(42,31,18,0.55)]"
            style={{ borderColor: "var(--color-ink)", backgroundColor: "#fbf6e7" }}
          >
            <label htmlFor="catalogue-search" className="sr-only">
              {t("search.placeholder")}
            </label>
            <span
              aria-hidden="true"
              className="flex items-center pl-5"
              style={{ color: "var(--color-oak)" }}
            >
              <Search className="size-5" strokeWidth={2} />
            </span>
            <input
              id="catalogue-search"
              name="q"
              type="search"
              autoComplete="off"
              placeholder={t("search.placeholder")}
              className="min-w-0 flex-1 bg-transparent px-4 py-5 text-base outline-none placeholder:text-[color:var(--color-oak)]/70 md:text-lg"
              style={{ color: "var(--color-ink)" }}
            />
            <button
              type="submit"
              className="shrink-0 px-6 text-sm font-semibold uppercase tracking-[0.2em] transition-colors sm:px-8 sm:text-base"
              style={{ backgroundColor: "var(--color-ink)", color: "var(--color-ivory)" }}
            >
              {t("search.submit")}
            </button>
          </form>
          <p
            className="max-w-3xl text-sm"
            style={{ color: "color-mix(in srgb, var(--color-ink) 75%, transparent)" }}
          >
            {t("search.hint")}
          </p>
          <div
            className="flex flex-wrap items-center gap-x-6 gap-y-2 border-t pt-5 font-mono text-[11px] uppercase tracking-[0.18em]"
            style={{
              borderColor: "color-mix(in srgb, var(--color-ink) 30%, transparent)",
              color: "var(--color-oak)",
            }}
          >
            <span>{t("search.trustBand")}</span>
          </div>
        </div>
      </section>

      {/* MOST BORROWED, dense table, dark reading hall */}
      <section className="border-b border-border bg-background">
        <div className="container-editorial py-16 md:py-20">
          <div className="mb-8 flex flex-col gap-3 sm:flex-row sm:items-end sm:justify-between">
            <div>
              <p className="mb-2 font-mono text-[11px] uppercase tracking-[0.3em] text-accent">
                {t("top.kicker")}
              </p>
              <h2 className="font-serif text-[clamp(1.875rem,3.2vw,2.75rem)] leading-[1.05] text-foreground">
                {t("top.title")}
              </h2>
              <p className="mt-2 max-w-xl text-sm text-muted-foreground">{t("top.subtitle")}</p>
            </div>
            <Link
              href="/library"
              className="group inline-flex items-center gap-1.5 font-mono text-xs uppercase tracking-[0.22em] text-accent hover:text-foreground"
            >
              {t("top.viewAll")}
              <ArrowUpRight className="size-4 transition-transform group-hover:-translate-y-0.5 group-hover:translate-x-0.5" />
            </Link>
          </div>

          <div className="overflow-x-auto rounded-sm border border-border">
            <table className="w-full border-collapse text-sm">
              <thead>
                <tr
                  className="border-b border-border bg-card font-mono text-[10px] uppercase tracking-[0.18em] text-muted-foreground"
                >
                  <th className="w-10 py-3 pl-4 text-left font-normal">#</th>
                  <th className="py-3 text-left font-normal">{t("top.columns.title")}</th>
                  <th className="hidden py-3 text-left font-normal md:table-cell">
                    {t("top.columns.author")}
                  </th>
                  <th className="hidden w-20 py-3 text-left font-normal sm:table-cell">
                    {t("top.columns.year")}
                  </th>
                  <th className="w-16 py-3 text-left font-normal">{t("top.columns.language")}</th>
                  <th className="hidden w-24 py-3 text-left font-normal md:table-cell">
                    {t("top.columns.size")}
                  </th>
                  <th className="w-28 py-3 pr-4 text-right font-normal">
                    <span className="sr-only">{t("top.columns.action")}</span>
                  </th>
                </tr>
              </thead>
              <tbody>
                {TOP_BOOKS.map((b, i) => (
                  <tr
                    key={b.slug}
                    className="border-b border-border/60 transition-colors last:border-b-0 hover:bg-card/50"
                  >
                    <td className="py-3 pl-4 font-mono text-[11px] text-muted-foreground">
                      {String(i + 1).padStart(2, "0")}
                    </td>
                    <td className="py-3 pr-3">
                      <Link
                        href={{ pathname: "/library" }}
                        className="font-serif text-[15px] leading-tight text-foreground hover:text-accent"
                      >
                        {b.title}
                      </Link>
                      <div className="mt-0.5 text-xs text-muted-foreground md:hidden">
                        {b.author}, {formatYear(b.year)}
                      </div>
                    </td>
                    <td className="hidden py-3 pr-3 text-muted-foreground md:table-cell">
                      {b.author}
                    </td>
                    <td className="hidden py-3 pr-3 font-mono text-xs text-muted-foreground sm:table-cell">
                      {formatYear(b.year)}
                    </td>
                    <td className="py-3 pr-3">
                      <span className="inline-flex items-center rounded-full border border-border px-2 py-0.5 font-mono text-[10px] uppercase tracking-wider text-muted-foreground">
                        {b.lang}
                      </span>
                    </td>
                    <td className="hidden py-3 pr-3 font-mono text-xs text-muted-foreground md:table-cell">
                      {b.size}
                    </td>
                    <td className="py-3 pr-4 text-right">
                      <Link
                        href={{ pathname: "/library" }}
                        className="inline-flex items-center gap-1.5 rounded-sm border border-border bg-card px-3 py-1.5 font-mono text-[11px] uppercase tracking-wider text-foreground transition-colors hover:border-accent hover:text-accent"
                      >
                        <Download className="size-3.5" />
                        <span className="hidden sm:inline">{t("top.download")}</span>
                      </Link>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      </section>

      {/* DEWEY, browse by floor, dark on dark with signage tiles */}
      <section className="border-b border-border bg-background">
        <div className="container-editorial py-16 md:py-20">
          <div className="mb-8 max-w-2xl">
            <p className="mb-2 font-mono text-[11px] uppercase tracking-[0.3em] text-accent">
              {t("dewey.kicker")}
            </p>
            <h2 className="font-serif text-[clamp(1.875rem,3.2vw,2.75rem)] leading-[1.05] text-foreground">
              {t("dewey.title")}
            </h2>
            <p className="mt-2 text-sm text-muted-foreground">{t("dewey.subtitle")}</p>
          </div>
          <ul className="grid grid-cols-2 gap-2 sm:grid-cols-3 md:grid-cols-5">
            {DEWEY_CLASSES.map((c) => (
              <li key={c.code}>
                <Link
                  href={{ pathname: "/library" }}
                  className="group flex h-full flex-col justify-between gap-4 rounded-sm border border-border bg-card p-4 transition-colors hover:border-accent hover:bg-card/80"
                >
                  <div className="flex items-baseline justify-between">
                    <span className="font-mono text-2xl font-semibold tracking-tight text-accent">
                      {c.code}
                    </span>
                    <ArrowUpRight className="size-3.5 text-muted-foreground transition-colors group-hover:text-accent" />
                  </div>
                  <div>
                    <p className="font-serif text-sm leading-tight text-foreground">
                      {t(`dewey.classes.${c.key}` as "dewey.classes.000")}
                    </p>
                    <p className="mt-1.5 font-mono text-[10px] uppercase tracking-[0.14em] text-muted-foreground">
                      {c.count} {t("dewey.countLabel")}
                    </p>
                  </div>
                </Link>
              </li>
            ))}
          </ul>
        </div>
      </section>

      {/* READING ROOM, cream paper, three real excerpts */}
      <section
        className="border-b border-border"
        style={{ backgroundColor: "var(--color-cream)", color: "var(--color-ink)" }}
      >
        <div className="container-editorial py-16 md:py-20">
          <div className="mb-10 flex flex-col gap-3 md:flex-row md:items-end md:justify-between">
            <div className="max-w-2xl">
              <p
                className="mb-2 font-mono text-[11px] uppercase tracking-[0.3em]"
                style={{ color: "var(--color-burgundy)" }}
              >
                {t("readingRoom.kicker")}
              </p>
              <h2 className="font-serif text-[clamp(1.875rem,3.2vw,2.75rem)] leading-[1.05]">
                {t("readingRoom.title")}
              </h2>
              <p className="mt-2 text-sm" style={{ color: "var(--color-oak)" }}>
                {t("readingRoom.subtitle")}
              </p>
            </div>
            <p
              className="font-mono text-[10px] uppercase tracking-[0.24em]"
              style={{ color: "var(--color-oak)" }}
            >
              {new Date().toISOString().slice(0, 10)}
            </p>
          </div>
          <div className="grid gap-6 md:grid-cols-3">
            {DAILY.map((d) => (
              <article
                key={d.slug}
                className="flex flex-col gap-5 rounded-sm border bg-[#fbf6e7] p-6 shadow-[0_1px_0_rgba(42,31,18,0.08)]"
                style={{ borderColor: "color-mix(in srgb, var(--color-ink) 22%, transparent)" }}
              >
                <div>
                  <p
                    className="font-mono text-[10px] uppercase tracking-[0.2em]"
                    style={{ color: "var(--color-oak)" }}
                  >
                    {d.author}, {formatYear(d.year)}
                  </p>
                  <h3
                    className="mt-1 font-serif text-2xl leading-tight"
                    style={{ color: "var(--color-ink)" }}
                  >
                    {d.title}
                  </h3>
                </div>
                <blockquote
                  className="flex-1 border-l-2 pl-4 font-serif text-[15px] italic leading-relaxed"
                  style={{
                    borderColor: "var(--color-burgundy)",
                    color: "color-mix(in srgb, var(--color-ink) 88%, transparent)",
                  }}
                >
                  {d.excerpt}
                </blockquote>
                <p className="text-xs" style={{ color: "var(--color-oak)" }}>
                  {d.note}
                </p>
                <Link
                  href={{ pathname: "/library" }}
                  className="inline-flex items-center gap-1.5 self-start border-b pb-0.5 font-mono text-[11px] uppercase tracking-[0.18em] transition-colors"
                  style={{ borderColor: "var(--color-ink)", color: "var(--color-ink)" }}
                >
                  {t("readingRoom.openBook")}
                  <ArrowUpRight className="size-3.5" />
                </Link>
              </article>
            ))}
          </div>
        </div>
      </section>

      {/* STATS band, back to dark */}
      <section className="bg-background">
        <div className="container-editorial py-12 md:py-16">
          <dl className="grid grid-cols-2 gap-x-6 gap-y-8 md:grid-cols-4">
            {[
              { value: "501 042", label: t("stats.books") },
              { value: "15", label: t("stats.languages") },
              { value: "14", label: t("stats.sources") },
              { value: "0 €", label: t("stats.cost") },
            ].map((s, i) => (
              <div
                key={i}
                className="flex flex-col gap-1 border-l-2 border-accent pl-4"
              >
                <dt className="font-mono text-[10px] uppercase tracking-[0.2em] text-muted-foreground">
                  {s.label}
                </dt>
                <dd className="font-serif text-3xl text-foreground md:text-4xl">{s.value}</dd>
              </div>
            ))}
          </dl>
        </div>
      </section>
    </>
  );
}
