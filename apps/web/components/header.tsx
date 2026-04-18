import { getTranslations } from "next-intl/server";
import { brand } from "@librarfree/brand";
import { Link } from "@/i18n/routing";
import { LocaleSwitcher } from "./locale-switcher";

export async function Header() {
  const t = await getTranslations("nav");
  return (
    <header className="sticky top-0 z-40 border-b border-border bg-background/80 backdrop-blur-md">
      <div className="container-editorial flex h-14 items-center justify-between gap-4">
        <Link href="/" className="flex items-center gap-2 font-serif text-lg font-semibold">
          <span aria-hidden="true" className="inline-block size-2 rounded-full bg-primary" />
          {brand.name}
        </Link>
        <nav className="flex items-center gap-5 text-sm">
          <Link href="/library" className="text-muted-foreground hover:text-foreground">
            {t("library")}
          </Link>
          <Link href="/collections" className="text-muted-foreground hover:text-foreground">
            {t("collections")}
          </Link>
          <Link href="/about" className="text-muted-foreground hover:text-foreground">
            {t("about")}
          </Link>
          <LocaleSwitcher />
        </nav>
      </div>
    </header>
  );
}
