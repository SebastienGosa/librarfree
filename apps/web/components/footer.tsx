import { getTranslations } from "next-intl/server";
import { brand } from "@librarfree/brand";

export async function Footer() {
  const t = await getTranslations("footer");
  const year = new Date().getFullYear();
  return (
    <footer className="border-t border-border py-10">
      <div className="container-editorial flex flex-col gap-6 md:flex-row md:items-start md:justify-between">
        <div className="max-w-sm">
          <p className="font-serif text-lg">{brand.name}</p>
          <p className="mt-1 text-sm text-muted-foreground">{t("tagline")}</p>
          <p className="mt-4 text-xs text-muted-foreground">{t("openSource")}</p>
        </div>
        <div className="text-xs text-muted-foreground">
          <p>{t("builtBy")}</p>
          <p className="mt-1">
            © {year} {brand.legalName} · <a href={brand.github} className="hover:text-foreground">GitHub</a>
          </p>
        </div>
      </div>
    </footer>
  );
}
