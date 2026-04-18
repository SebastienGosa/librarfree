import { Button } from "@librarfree/ui";
import { Link } from "@/i18n/routing";

export default function NotFound() {
  return (
    <section className="container-editorial flex min-h-[50vh] flex-col items-start justify-center gap-6 py-20">
      <p className="font-mono text-xs uppercase tracking-[0.2em] text-muted-foreground">
        404
      </p>
      <h1 className="max-w-2xl font-serif text-4xl leading-tight md:text-5xl">
        This corner of the library is still quiet.
      </h1>
      <p className="max-w-xl text-muted-foreground">
        The page you were looking for doesn&rsquo;t exist, or hasn&rsquo;t been written yet. Every page here started empty once.
      </p>
      <Button asChild>
        <Link href="/">Take me home</Link>
      </Button>
    </section>
  );
}
