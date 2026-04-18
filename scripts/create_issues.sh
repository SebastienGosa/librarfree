#!/bin/bash
# Bulk issue creation for Librarfree phases 0-6
# Generated 2026-04-18 from the chef d'oeuvre plan
# Usage: bash scripts/create_issues.sh

set -e
REPO="SebastienGosa/librarfree"

# Helper: create_issue "title" "body" "phase_num" "type_label" "milestone_num"
create_issue() {
  local title="$1"
  local body="$2"
  local phase="$3"
  local type="$4"
  local ms="$5"
  gh issue create --repo "$REPO" \
    --title "$title" \
    --body "$body" \
    --label "phase-$phase,type:$type" \
    --milestone "$ms" 2>&1 | tail -1
  sleep 0.4
}

echo "=== Phase 0 — Fondations ==="
create_issue "[P0] Corriger database/schema.sql — supprimer 4 index GIN sur colonne \`content\` inexistante" \
"Lignes 132-135 de \`database/schema.sql\` : CREATE INDEX ... gin(to_tsvector('...', content)) référence une colonne qui n'existe pas (la table stocke \`content_url\`). Meilisearch gère le full-text. Supprimer ces 4 index." \
"0" "infra" "Phase 0 — Fondations"

create_issue "[P0] Corriger v_affiliate_performance — remplacer \`LEFT JOIN book_isbns bi ON true\` (produit cartésien)" \
"Ligne 554 de \`database/schema.sql\` : la vue \`v_affiliate_performance\` fait \`LEFT JOIN book_isbns bi ON true\` = produit cartésien qui explose à l'échelle. Réécrire avec jointure sur \`language_code\` + \`isbn_13\`." \
"0" "infra" "Phase 0 — Fondations"

create_issue "[P0] Ajouter index composite non-unique sur book_translations" \
"Empêcher doublons non-intentionnels : \`CREATE INDEX book_translations_dedup_idx ON book_translations(book_id, language_code, source_project, source_identifier);\`" \
"0" "infra" "Phase 0 — Fondations"

create_issue "[P0] Activer RLS Supabase sur 6 tables sensibles" \
"Activer Row Level Security sur : \`users\`, \`user_library\`, \`annotations\`, \`reading_sessions\`, \`premium_subscriptions\`, \`donations\`. Policies : user peut seulement voir/modifier ses propres rows." \
"0" "infra" "Phase 0 — Fondations"

create_issue "[P0] Ajouter 8 tables manquantes au schema" \
"Ajouter : \`categories\`, \`book_categories\`, \`collections\`, \`collection_books\`, \`book_files\` (multi-format EPUB/PDF/TXT/HTML), \`premium_subscriptions\`, \`donations\`, \`reading_lists\` + \`reading_list_books\`." \
"0" "infra" "Phase 0 — Fondations"

create_issue "[P0] Migrer schema de SERIAL vers UUID" \
"Multi-tenant ready (Phase 6 Corporate Libraries). Toutes les PK en UUID avec \`gen_random_uuid()\`. Ajouter colonne \`organization_id UUID NULL\` sur tables scoped." \
"0" "infra" "Phase 0 — Fondations"

create_issue "[P0] Migrer monorepo npm → pnpm + Turbo v1 → v2" \
"Créer \`pnpm-workspace.yaml\`, \`turbo.json\` v2, \`.npmrc\`. Supprimer la section \`workspaces\` du package.json. Mettre à jour scripts dev/build/lint." \
"0" "infra" "Phase 0 — Fondations"

create_issue "[P0] Mettre à jour docker-compose.yml — ajouter MinIO + Redis + init extensions" \
"Ajouter services : \`minio\` (émule R2, ports 9000/9001), \`redis\` (7-alpine, port 6379). Init auto des extensions Postgres : \`vector\`, \`pg_trgm\` via fichier SQL monté." \
"0" "infra" "Phase 0 — Fondations"

create_issue "[P0] Compléter .env.example" \
"Ajouter : SUPABASE_URL, SUPABASE_ANON_KEY, SUPABASE_SERVICE_ROLE_KEY, R2_ACCOUNT_ID, R2_ACCESS_KEY, R2_SECRET_KEY, R2_BUCKET_BOOKS, UPSTASH_REDIS_REST_URL, UPSTASH_REDIS_REST_TOKEN, STRIPE_SECRET, STRIPE_WEBHOOK_SECRET, SENTRY_DSN, POSTHOG_KEY, PLAUSIBLE_DOMAIN, AMAZON_PAAPI_* (12 locales)." \
"0" "infra" "Phase 0 — Fondations"

create_issue "[P0] Créer packages/brand/ — exporter brand.config.ts" \
"Nouveau package \`@librarfree/brand\` avec src/index.ts qui ré-exporte brand.config.ts. package.json, tsconfig.json, types auto. Utilisé par apps/web + packages/ui + workers." \
"0" "infra" "Phase 0 — Fondations"

create_issue "[P0] Créer packages/db/ — Prisma 6 + client singleton" \
"Traduire schema.sql corrigé en schema.prisma (~18 modèles). Client singleton pour éviter les multiples instances en dev (Next.js HMR). Scripts db:push, db:migrate, db:studio, db:seed." \
"0" "infra" "Phase 0 — Fondations"

create_issue "[P0] Scaffold apps/web/ Next.js 15 App Router" \
"TypeScript strict, Tailwind 4, ESLint. Deps : next-intl, @supabase/ssr, zustand, framer-motion, meilisearch, epubjs, zod, lucide-react, @librarfree/brand, @librarfree/ui, @librarfree/db." \
"0" "infra" "Phase 0 — Fondations"

create_issue "[P0] Structure apps/web/app/[locale]/" \
"layout.tsx (providers Supabase + Theme + i18n + header + footer placeholder), page.tsx (homepage placeholder brand.name + tagline), middleware.ts (next-intl + auth)." \
"0" "feature" "Phase 0 — Fondations"

create_issue "[P0] Setup i18n next-intl — scaffold 12 langues" \
"routing.ts (locales depuis brand.config.ts), request.ts (getRequestConfig avec requestLocale), messages/{en,fr,de,es,it,pt,ja,zh,ru,pl,nl,ar}.json (vides sauf EN qui est complet)." \
"0" "i18n" "1"

create_issue "[P0] Créer packages/ui/ — shadcn/ui + palette dark premium" \
"Init shadcn/ui avec theme depuis brand.config.ts. Composants : Button, Card, Input, Dialog, DropdownMenu, Tabs, Badge, Skeleton, Toast, Accordion + 3 customs : BookCard, LanguageBadge (quality 🟢/🟡), ReaderProgress." \
"0" "ux" "Phase 0 — Fondations"

create_issue "[P0] Créer packages/utils/ — helpers partagés" \
"Formatters (reading time, file size, locale date), GeoIP helper (Vercel headers), Supabase client factories (server + client + service role)." \
"0" "infra" "Phase 0 — Fondations"

create_issue "[P0] Supprimer apps/api/ — fusion dans Server Actions Next.js" \
"Décision architecturale : tRPC séparé supprimé, tout fusionne dans apps/web/ via Server Actions." \
"0" "infra" "Phase 0 — Fondations"

create_issue "[P0] Worker importers/gutenberg — 100 livres EN test" \
"TypeScript + tsx runtime. Télécharge catalogue RDF Gutenberg (~70K livres), parse métadonnées, pour 100 premiers EN télécharge TXT UTF-8, calcule word_count + reading_time + Flesch-Kincaid, upload R2/MinIO, insert Prisma (authors/books/book_translations/book_files), indexe Meilisearch." \
"0" "content" "Phase 0 — Fondations"

create_issue "[P0] CLI script pnpm import:gutenberg --limit=N --language=L" \
"Interface CLI avec arguments : limit, language, dry-run, resume-from. Logs colorés, progress bar, retry exponentiel." \
"0" "content" "Phase 0 — Fondations"

create_issue "[P0] Pipeline qualité v1 — détection mojibake + score 0-100" \
"Heuristique ratio chars non-ASCII vs déclaré UTF-8, détection patterns broken encoding (â€™, Ã©, etc), Flesch-Kincaid sanity check. Score stocké dans book_files." \
"0" "content" "Phase 0 — Fondations"

create_issue "[P0] CI GitHub Actions — lint + typecheck + build + tests + Playwright smoke" \
"Workflow .github/workflows/ci.yml : Node 20, pnpm 9, cache turbo. Jobs : lint, typecheck, build, vitest, Playwright smoke (homepage 200 OK)." \
"0" "infra" "Phase 0 — Fondations"

create_issue "[P0] Sync README.md + GET_STARTED.md avec stack réelle" \
"clone → .env.local → docker compose up → pnpm install → pnpm db:push → pnpm import:gutenberg --limit=100 → pnpm dev. Screenshots, troubleshooting." \
"0" "docs" "Phase 0 — Fondations"

create_issue "[P0] Backup offsite Borg → Hetzner Storagebox €3/mois" \
"Setup borg avec Hetzner Storagebox. Chiffré, incrémental, retention 30 jours. Cron quotidien. Script scripts/backup.sh." \
"0" "infra" "Phase 0 — Fondations"

create_issue "[P0] Acheter le nom de domaine final" \
"Après validation du top 3 recommandé par l'agent de recherche domaine. Registrar : Cloudflare (prix coûtant). Defensive : .com + .org + .app." \
"0" "infra" "Phase 0 — Fondations"

create_issue "[P0] Configurer Vercel Pro — lier repo librarfree" \
"Connect repo, branch main = prod, branch preview/* = previews. Variables d'env secretisées. Domaine custom quand acheté." \
"0" "infra" "Phase 0 — Fondations"

create_issue "[P0] Créer compte Upstash Redis (free tier)" \
"10K req/jour gratuit. Variables d'env UPSTASH_REDIS_REST_URL + TOKEN. Test ping + rate-limit helper." \
"0" "infra" "Phase 0 — Fondations"

create_issue "[P0] Créer compte Sentry (free tier 5K events/mois)" \
"Projet Librarfree, DSN généré. Integration Next.js + @sentry/nextjs. Filter noisy errors (bot, rate-limited)." \
"0" "infra" "Phase 0 — Fondations"

create_issue "[P0] Setup VPS Hetzner CX11 €4/mois — Meilisearch self-host" \
"Serveur Nuremberg, Ubuntu 22.04, Docker, Meilisearch 1.7. HTTPS via Caddy. Backup volumes. Monitoring health." \
"0" "infra" "Phase 0 — Fondations"

create_issue "[P0] Docs/ADR-0001 — architecture decisions records" \
"Documenter décisions Phase 0 : pnpm over npm, Server Actions vs tRPC, R2 vs Postgres TEXT, HNSW vs IVFFlat, Meilisearch vs Typesense." \
"0" "docs" "Phase 0 — Fondations"

create_issue "[P0] Checklist validation Phase 0" \
"Homepage affiche brand.name + tagline, Prisma Studio 100 livres, Meilisearch retourne Dickens/Shakespeare, MinIO 100 .txt, pnpm lint + typecheck pass, CI verte, Playwright smoke vert, Carbon <0.5g/page." \
"0" "docs" "Phase 0 — Fondations"

echo "=== Phase 1 — MVP Core ==="
create_issue "[P1] Homepage éditoriale scrollytelling" \
"Pas de search bar + carousel générique. 3-4 écrans narratifs (\"In 1455, Gutenberg printed the first book. 570 years later, anyone with a phone should read them all. Free.\"). Section mission sobre, stats impact temps réel, CTA \"Start reading\". Section \"This week's library\" éditorial curé." \
"1" "ux" "Phase 1 — MVP Core"

create_issue "[P1] Search Meilisearch — filtres + instant results" \
"Composant SearchBar avec autocomplete Meilisearch. Filtres : langue, époque, genre, longueur. Résultats instant <100ms. Query analytics saved dans search_queries." \
"1" "feature" "Phase 1 — MVP Core"

create_issue "[P1] Page Book Detail — hero riche + accordéons thématiques" \
"Cover + titre + 1-phrase definition + 4 quick facts + CTA Read/Listen. Accordéons : About, Historical context, Key themes, Publication history, Similar books (pgvector). Pull quotes, did-you-know blocks." \
"1" "ux" "Phase 1 — MVP Core"

create_issue "[P1] Reader world-class — typographie pro" \
"Hyphenation CSS4, kerning, ligatures, drop caps auto, pull quotes rendus beaux, widow/orphan control, leading optimisé. Objectif : rivaliser avec iA Writer et Kindle Oasis." \
"1" "ux" "Phase 1 — MVP Core"

create_issue "[P1] Reader — 4 thèmes dark + sepia + light + OLED" \
"Twilight (#0F0F13), Midnight (#0A0A12), Deep Space (#000510), Black Library (#000000). Sepia (#F4ECD8). Light (#FAFAF8). Basculement depuis brand.config.theme." \
"1" "ux" "Phase 1 — MVP Core"

create_issue "[P1] Reader — Focus mode (paragraphes non-courants 20% opacité)" \
"Le paragraphe courant à 100%, les autres à 20%. Toggle on/off. Bionic Reading optionnel." \
"1" "ux" "Phase 1 — MVP Core"

create_issue "[P1] Reader — Dictionnaire inline (Wiktionary hover)" \
"Click mot = tooltip Wiktionary + Wikipedia résumé sans quitter la page. Mémorise mots consultés pour export Anki Phase 4." \
"1" "feature" "Phase 1 — MVP Core"

create_issue "[P1] Reader — Annotations surlignées 4 couleurs + notes marges" \
"Surlignages persistés. Notes inline dans marges (desktop), sheet mobile. Export JSON + Readwise compatible." \
"1" "feature" "Phase 1 — MVP Core"

create_issue "[P1] Reader — Page-turn signature SVG morphing 200-300ms" \
"Animation subtile, pas Flash 2008. Toggle \"instant\" pour users qui préfèrent." \
"1" "ux" "Phase 1 — MVP Core"

create_issue "[P1] Reader — Progress poétique (pas %)" \
"\"You're 3 chapters deep\" / \"120 pages left, ~4h\" / \"Halfway through — Vronsky just arrived\". Contextualisé, pas chiffre brut." \
"1" "ux" "Phase 1 — MVP Core"

create_issue "[P1] Typography as product — settings/reading" \
"Page où l'user choisit parmi 30+ Google Fonts premium avec preview inline. Persisté. Rendu serverside pour pas de FOUT." \
"1" "ux" "Phase 1 — MVP Core"

create_issue "[P1] Keyboard shortcuts mappables — palette Cmd+K style Linear" \
"Toutes les actions accessibles par palette. Mappable dans settings. Affichage en overlay." \
"1" "ux" "Phase 1 — MVP Core"

create_issue "[P1] SEO — JSON-LD Book, Person, WebSite, Organization" \
"Schémas structurés sur toutes les pages. BreadcrumbList sur navigation. BookSeries sur collections. Validated via Google Rich Results Test." \
"1" "growth" "Phase 1 — MVP Core"

create_issue "[P1] SEO — sitemap.xml segmenté par langue + index parent" \
"Un sitemap par langue (max 50K URLs), index pointant vers tous. hreflang dans chaque URL. Soumis à Google Search Console + Bing Webmaster." \
"1" "growth" "Phase 1 — MVP Core"

create_issue "[P1] GEO — structure definition-first (150-200 tokens top)" \
"Toutes les pages commencent par définition claire + stats + citations dans les 150 premiers mots. LLM summarization step favorise cet incipit." \
"1" "growth" "Phase 1 — MVP Core"

create_issue "[P1] GEO — quick answer blocks above-the-fold" \
"Toute query transactionnelle (\"Free download of [Book]\") → encadré réponse direct 1-2 phrases visible sans scroll." \
"1" "growth" "Phase 1 — MVP Core"

create_issue "[P1] GEO — FAQ 5-8 Q&A par page livre" \
"\"What is [Book] about?\", \"Who wrote?\", \"Is it public domain?\", \"Where to read free legally?\", \"Translations available?\", etc. Visible en accordéons." \
"1" "growth" "Phase 1 — MVP Core"

create_issue "[P1] GEO — llms.txt à la racine" \
"Manifeste autorisation indexation IA + liens clés. Comme robots.txt mais pour LLM." \
"1" "growth" "Phase 1 — MVP Core"

create_issue "[P1] Import Gutenberg 70K livres complet" \
"Pipeline durci, idempotent, resumable. BullMQ queue + Redis. Dedup via source_project + source_identifier. 15 langues ciblées." \
"1" "content" "Phase 1 — MVP Core"

create_issue "[P1] Import Standard Ebooks 7K livres (qualité éditoriale)" \
"Quality badge 🟢 vs Gutenberg. Fichiers EPUB natifs (pas juste TXT). Métadonnées enrichies." \
"1" "content" "Phase 1 — MVP Core"

create_issue "[P1] pSEO patterns — accordions + tabs + progressive disclosure" \
"Chaque page pSEO (livre, auteur, collection) : hero riche + tabs Overview/Chapters/Annotations/Reviews/Quotes/Related + accordéons dépliables. Jamais \"wall of text\"." \
"1" "ux" "Phase 1 — MVP Core"

create_issue "[P1] Playwright tests E2E — golden paths" \
"Tests : homepage load, search \"Dickens\" returns results, open book detail, start reading, change theme, toggle focus mode, logout/login (quand Phase 2)." \
"1" "infra" "Phase 1 — MVP Core"

create_issue "[P1] Accessibility baseline WCAG AAA" \
"Audit Lighthouse + axe-core. prefers-reduced-motion respecté, keyboard nav complète, focus visible signature, skip-to-content, high contrast mode, screen reader NVDA + VoiceOver testé." \
"1" "a11y" "2"

create_issue "[P1] Core Web Vitals AAA — LCP <1.2s, INP <150ms, CLS <0.05" \
"SSG + ISR agressif, image optimization, font preload, critical CSS inline. Monitored Vercel Analytics + Sentry." \
"1" "infra" "Phase 1 — MVP Core"

create_issue "[P1] Sound design discret — page turn, bookmark, achievement" \
"Sons ≤-24dB. Toggle \"silence mode\" pour bibliothèques. Web Audio API. Fichiers < 5KB chacun." \
"1" "ux" "Phase 1 — MVP Core"

create_issue "[P1] Ambient colors par genre/époque (subtil)" \
"Philosophie antique = bleu nuit + or, romantisme = bordeaux, SF = cyan, poésie = violet. Appliqué au body background avec 5% opacity overlay. Toggle off." \
"1" "ux" "Phase 1 — MVP Core"

create_issue "[P1] OpenGraph riches Satori — cover + quote + author" \
"Génération dynamique via @vercel/og. Format 1200x630. Cache edge 30 jours." \
"1" "growth" "Phase 1 — MVP Core"

create_issue "[P1] Empty states illustrés originaux" \
"Pas \"No results\" générique. Illustrations custom + message ton juste. Ex: \"This corner of the library is still quiet — be the first to fill it.\"" \
"1" "ux" "Phase 1 — MVP Core"

echo "=== Phase 2 — Comptes & Affiliation & Social ==="
create_issue "[P2] Supabase Auth — signup/login/magic link/OAuth" \
"Email + password + magic link + Google/GitHub OAuth. Middleware protégé. Session SSR via @supabase/ssr." \
"2" "feature" "Phase 2 — Comptes & Affiliation & Social"

create_issue "[P2] Bibliothèque perso /library — saved books" \
"Sauvegarde user_library. Filtres : reading/finished/want-to-read. Grid ou list view. Sync multi-device." \
"2" "feature" "Phase 2 — Comptes & Affiliation & Social"

create_issue "[P2] Progression sync reading_sessions" \
"Time, scroll %, chapter, device. Realtime sync Supabase. Reprendre exactement où on s'est arrêté." \
"2" "feature" "Phase 2 — Comptes & Affiliation & Social"

create_issue "[P2] Book clubs virtuels — clubs publics/privés" \
"Supabase Realtime. Clubs par langue/genre. Rythmage 1 chapitre/semaine, fil séparé anti-spoiler." \
"2" "feature" "Phase 2 — Comptes & Affiliation & Social"

create_issue "[P2] Lecture synchrone — Google Docs for reading" \
"Session live, curseurs visibles sur le texte, chat latéral, audio optionnel (WebRTC Phase 3)." \
"2" "feature" "Phase 2 — Comptes & Affiliation & Social"

create_issue "[P2] Citations cards partageables — Satori" \
"Sélection passage → image générée Satori (thème époque), watermark Librarfree, partage natif OS." \
"2" "growth" "Phase 2 — Comptes & Affiliation & Social"

create_issue "[P2] Affiliation Amazon PAAPI — 12 locales" \
"US, UK, FR, DE, ES, IT, JA, CA, AU, IN, BR, MX. GeoIP → locale appropriée. Partner ID par locale dans env." \
"2" "monetization" "Phase 2 — Comptes & Affiliation & Social"

create_issue "[P2] Affiliation retailers locaux (Fnac, Thalia, Casa del Libro, Kobo, etc.)" \
"Seed depuis AFFILIATE_RETAILERS_CONFIG.md. Service lookup avec fallback chain. Tracking clicks dans affiliate_clicks." \
"2" "monetization" "Phase 2 — Comptes & Affiliation & Social"

create_issue "[P2] Worker isbn-lookup — Open Library + Google Books" \
"Enrichit livres sans ISBN via matching titre+auteur. Idempotent, résumable." \
"2" "content" "Phase 2 — Comptes & Affiliation & Social"

create_issue "[P2] Version Lite — sous-domaine lite.{domain}" \
"Plain HTML, CSS inline, 0 JS, <10KB/page. Pour 2G Afrique, Chine, Iran. Sous Cloudflare Pages failover." \
"2" "a11y" "3"

create_issue "[P2] Fichiers TXT ultra-légers <50KB" \
"Export TXT compressé pour chaque livre. Sert 2 milliards humains à faible connexion. Trivial technique, énorme symbolique." \
"2" "a11y" "3"

create_issue "[P2] GDPR — DSAR tooling, export data, delete account" \
"Page /settings/privacy avec : export all my data (JSON), delete my account (hard delete avec grace 30 jours). Documentation publique /legal/gdpr." \
"2" "monetization" "Phase 2 — Comptes & Affiliation & Social"

create_issue "[P2] COPPA — signup <13 ans consentement parental" \
"Check age à signup. Si <13, bloque ou demande email parental + double opt-in. Documentation /legal/coppa." \
"2" "a11y" "3"

create_issue "[P2] Age-gating — warning 18+ sur DP sensibles (Sade, Crébillon)" \
"Flag \"mature\" dans books. Warning + login requis pour accéder. Settings user peut masquer entièrement." \
"2" "content" "Phase 2 — Comptes & Affiliation & Social"

create_issue "[P2] Reading lists — créer + partager + forker" \
"Listes custom user. Publiques ou privées. Fork (copie) + comments. Embed widget Phase 4." \
"2" "feature" "Phase 2 — Comptes & Affiliation & Social"

create_issue "[P2] Profil public /u/username" \
"Bio + currently reading + finished + annotations publiques + lists publiques. Option private." \
"2" "feature" "Phase 2 — Comptes & Affiliation & Social"

create_issue "[P2] Follow system — users se suivent" \
"Feed timeline (lectures amis, annotations partagées). Opt-in." \
"2" "feature" "Phase 2 — Comptes & Affiliation & Social"

create_issue "[P2] Dashboard transparence /transparency (public)" \
"Revenus mensuels par stream, coûts infra, salaire Sebastien, grants reçus, roadmap finance 6 mois. Radical transparency." \
"2" "monetization" "Phase 2 — Comptes & Affiliation & Social"

create_issue "[P2] Download multi-format — EPUB, PDF, MOBI, AZW3, TXT" \
"Chaque livre proposé en 5 formats téléchargeables : EPUB (standard), PDF (mise en page), MOBI (anciens Kindle), AZW3 (Kindle moderne), TXT (ultra-léger). Conversion via Calibre ebook-convert CLI (worker dédié). Stockage R2 avec cache. Bouton Download visible sur page livre + reader, avec taille fichier affichée. Feature indispensable (comparable à Z-Library)." \
"2" "feature" "Phase 2 — Comptes & Affiliation & Social"

create_issue "[P2] Send-to-Kindle via email" \
"Feature killer comme Z-Library : user entre son adresse Kindle @kindle.com, clic 'Send to Kindle', Librarfree envoie le fichier AZW3/EPUB directement sur la liseuse via SMTP transactionnel (Resend ou SES). Whitelist domaine expéditeur requis côté Amazon — doc d'aide intégrée (/help/send-to-kindle). Rate limit 10 envois/jour/user anti-abuse." \
"2" "feature" "Phase 2 — Comptes & Affiliation & Social"

create_issue "[P2] Send-to-ereader générique — Kobo / PocketBook / Onyx Boox / reMarkable" \
"Support e-readers non-Amazon. Kobo : integration Dropbox/Google Drive (user relie son cloud, on dépose le fichier). PocketBook/Boox/reMarkable : email-to-device ou URL cloud. Documentation /help/send-to-ereader par modèle. Phase 2 = Kindle only, élargi Phase 3." \
"2" "feature" "Phase 2 — Comptes & Affiliation & Social"

create_issue "[P2] Worker format-converter — Calibre headless" \
"Conteneur Docker avec Calibre headless. Job BullMQ : EPUB → MOBI/AZW3/PDF à la demande + cache R2. Fallback si format existe déjà. Monitoring temps de conversion." \
"2" "infra" "Phase 2 — Comptes & Affiliation & Social"

create_issue "[P2] Dedup entre sources — livre canonique 1 entrée + 3 fichiers" \
"Gutenberg + Standard Ebooks + Faded Page = même œuvre → 1 book_translation canonique, 3 book_files (quality badges distinctes)." \
"2" "content" "Phase 2 — Comptes & Affiliation & Social"

create_issue "[P2] Newsletter The Open Page — Resend + signup double opt-in" \
"Weekly, voice signature (Morning Brew littéraire noble). Embed curation de la semaine." \
"2" "growth" "Phase 2 — Comptes & Affiliation & Social"

create_issue "[P2] Content pillars v1 — 20 articles long-form EN" \
"\"Best books on philosophy\", \"Where to start with Dostoevsky\", etc. Auteur humain signé. Bio + links." \
"2" "content" "Phase 2 — Comptes & Affiliation & Social"

create_issue "[P2] Wikipedia edits stratégiques — 100 articles auteurs/livres DP" \
"Lien Librarfree comme source externe valide. Pas spam : valeur ajoutée éditoriale (meilleure traduction, annotations éclaircies)." \
"2" "growth" "Phase 2 — Comptes & Affiliation & Social"

create_issue "[P2] Launch Show HN \"World's largest legal free library in 15 languages\"" \
"Mardi 9h ET. Framing humble. Réponse 48h non-stop. Email respectueux mainteneurs Standard Ebooks + Project Gutenberg avant." \
"2" "growth" "Phase 2 — Comptes & Affiliation & Social"

create_issue "[P2] Launch Product Hunt semaine suivante" \
"Hunter Pieter Levels ou Tony Dinh. 15 commentaires communauté pré-positionnés." \
"2" "growth" "Phase 2 — Comptes & Affiliation & Social"

create_issue "[P2] Launch Reddit + Mastodon + Twitter" \
"r/books + r/opensource + r/selfhosted + r/52book + r/printSF + r/AskHistorians + r/piracy (framing légal). Compte @librarfree@fosstodon.org. Twitter thread 12 tweets." \
"2" "growth" "Phase 2 — Comptes & Affiliation & Social"

create_issue "[P2] Launch podcast tour — Changelog, Console.dev, Indie Hackers, Latent Space, SE Daily" \
"Outreach. Pitch personnalisé. Essai blog crosspost dev.to + Medium + Substack." \
"2" "growth" "Phase 2 — Comptes & Affiliation & Social"

create_issue "[P2] Discord officiel structuré" \
"#book-club-{lang}, #curators, #translators, #tech-contributors, #impact-stories. Règles claires, modération volontaires." \
"2" "growth" "Phase 2 — Comptes & Affiliation & Social"

create_issue "[P2] Discourse self-hosted (long-form + Google-indexable)" \
"Hetzner VPS + Postgres. Archives publiques. Complément Discord (archives éphémères)." \
"2" "growth" "Phase 2 — Comptes & Affiliation & Social"

create_issue "[P2] Grants application Mozilla + NLnet + Knight" \
"€10k-100k par grant. Dossier milestones spécifiques : accessibilité, multilingue, dataset CC0." \
"2" "monetization" "Phase 2 — Comptes & Affiliation & Social"

echo "=== Phase 3 — Multilingue & Institutionnel ==="
create_issue "[P3] next-intl complet — FR, DE, ES, IT, PT, NL (+ EN)" \
"UI traduite 100%. Messages JSON maintenus. Fallback EN. Plural rules, ICU syntax." \
"3" "i18n" "4"

create_issue "[P3] URLs localisées /fr/livres/ /en/books/" \
"Routes traduites via next-intl Pathnames. hreflang alternate dans <head>. Canonical correct." \
"3" "i18n" "4"

create_issue "[P3] Import Gallica — BNF corpus FR" \
"API Gallica. ~500K documents DP français. Prioriser livres complets vs articles de presse." \
"3" "content" "Phase 3 — Multilingue & Institutionnel"

create_issue "[P3] Import Wikisource multi-langue" \
"Corpus CC-SA textes vérifiés par communauté. Métadonnées enrichies (droits traducteurs)." \
"3" "content" "Phase 3 — Multilingue & Institutionnel"

create_issue "[P3] Import Cervantes (ES) + Runeberg (DE/nordiques)" \
"Sources nationales reconnues. Qualité éditoriale." \
"3" "content" "Phase 3 — Multilingue & Institutionnel"

create_issue "[P3] Import Feedbooks — corpus PD international" \
"Couverture complémentaire, EPUB natifs." \
"3" "content" "Phase 3 — Multilingue & Institutionnel"

create_issue "[P3] Mode Dyslexie complet" \
"OpenDyslexic/Lexend/Atkinson Hyperlegible. Espacement augmenté, césure colorée. Réécriture IA \"niveau simplifié\" (Phase 4). Toggle settings/reading." \
"3" "a11y" "4"

create_issue "[P3] Traduction hover mot — Wiktionary + Ollama fallback" \
"Hover mot dans reader = tooltip Wiktionary (dump indexé Meilisearch) + Ollama si absent. Mémorise pour flashcards Phase 4." \
"3" "feature" "Phase 3 — Multilingue & Institutionnel"

create_issue "[P3] Partenariat Internet Archive — mirror + échange métadonnées" \
"Contact email formel. Mirror technique bilatéral. Co-signature blog post." \
"3" "growth" "Phase 3 — Multilingue & Institutionnel"

create_issue "[P3] Partenariat Wikimedia/Wikisource" \
"Compatibilité formats, import réciproque. Formalisation via Wikimedia Foundation." \
"3" "growth" "Phase 3 — Multilingue & Institutionnel"

create_issue "[P3] Partenariat Open Library — ISBN + covers + métadonnées" \
"API integration. Lookup worker utilise Open Library en première source." \
"3" "growth" "Phase 3 — Multilingue & Institutionnel"

create_issue "[P3] HTML static snapshots Cloudflare Pages (failover Vercel)" \
"Hebdomadaire, mirror read-only complet. Si Vercel tombe, Cloudflare Pages sert la lecture." \
"3" "infra" "Phase 3 — Multilingue & Institutionnel"

create_issue "[P3] OpenTelemetry — traces + logs + metrics" \
"Tempo (Grafana Cloud free), Axiom logs (free), Grafana metrics. Dashboards publics partiels." \
"3" "infra" "Phase 3 — Multilingue & Institutionnel"

create_issue "[P3] Affiliations locales Fnac + Thalia + Casa del Libro + Kobo + Bol.com" \
"Onboarding programmes affiliés. Commissions configurables. Transparence Supporter banner." \
"3" "monetization" "Phase 3 — Multilingue & Institutionnel"

create_issue "[P3] DMCA process — escalation documentée" \
"Fausses traductions, éditions récentes non-DP. Workflow : takedown → review 48h → décision → contre-notice. Page /legal/dmca publique." \
"3" "docs" "Phase 3 — Multilingue & Institutionnel"

create_issue "[P3] Bug bounty — Huntr ou GitHub Security" \
"Scope : auth, RLS, XSS, CSRF. Rewards €50-500. Hall of Fame security." \
"3" "infra" "Phase 3 — Multilingue & Institutionnel"

create_issue "[P3] Curator Program — rôle officiel communauté" \
"Créer collections éditoriales (\"Existentialism 101\", \"Women writers 19th century\") = playlists Spotify du livre. Badge public. Contributions listées." \
"3" "growth" "Phase 3 — Multilingue & Institutionnel"

create_issue "[P3] Translation Volunteers — Weblate self-host" \
"Leaderboard. Traductions humaines priorisées sur NLLB-200 (Phase 4). Credits dans UI." \
"3" "i18n" "4"

create_issue "[P3] Scholar Program — 100 étudiants ambassadeurs" \
"Sélection essai 300 mots. Badge public. Accès beta. Un Scholar par université cible (Sorbonne, MIT, Harvard, LMU, etc.)." \
"3" "growth" "Phase 3 — Multilingue & Institutionnel"

create_issue "[P3] Email 50 bibliothécaires universitaires nominatif" \
"Outreach personnalisé. MIT, Harvard, Sorbonne, LMU, UCL, Oxford, ETH, Tokyo U, IIT. Script template + personnalisation." \
"3" "growth" "Phase 3 — Multilingue & Institutionnel"

create_issue "[P3] Candidature UNESCO Memory of the World" \
"Process 2 ans. Dossier : mission, corpus, impact. 10 ans d'accélération si retenu." \
"3" "growth" "Phase 3 — Multilingue & Institutionnel"

create_issue "[P3] Backlinks universités (.edu) + bibliothèques nationales" \
"20 outreach/semaine. Value-add : \"we link to your digital collection from our author pages\"." \
"3" "growth" "Phase 3 — Multilingue & Institutionnel"

create_issue "[P3] \"What [famous person] reads\" — social proof + SEO" \
"Obama, Buffett, Natalie Portman, etc. 50 pages curées. Sources citées, embeds Librarfree." \
"3" "content" "Phase 3 — Multilingue & Institutionnel"

create_issue "[P3] Internal linking dense — livres ↔ auteurs ↔ époques ↔ thèmes" \
"Script build-time qui génère automatiquement liens contextuels. Cohérence vérifiée." \
"3" "growth" "Phase 3 — Multilingue & Institutionnel"

create_issue "[P3] Author pages enrichies Wikipedia-grade" \
"Bio longue, bibliographie, époque, influences, citations, traductions, éditions. Hub SEO par auteur." \
"3" "content" "Phase 3 — Multilingue & Institutionnel"

create_issue "[P3] Programmatic SEO 10K pages \"[Title] free download\"" \
"Pages optimisées pour queries transactionnelles qui trouvent Z-Library en 1er. On surclasse en légalité. Génération build-time." \
"3" "growth" "Phase 3 — Multilingue & Institutionnel"

echo "=== Phase 4 — IA & Premium & Accessibilité ==="
create_issue "[P4] Embeddings Ollama nomic-embed-text v1.5 — Similar books" \
"Pipeline batch tous les livres. HNSW index pgvector. Section \"Similar books\" sur book detail. Cache edge." \
"4" "ai" "Phase 4 — IA & Premium & Accessibilité"

create_issue "[P4] Semantic search — query naturelle → vecteurs" \
"\"Book about loss and memory\" → résultats pertinents même sans keyword match. Hybrid avec Meilisearch (BM25 + vector)." \
"4" "ai" "Phase 4 — IA & Premium & Accessibilité"

create_issue "[P4] Socratic Tutor — fin chapitre, IA pose 3-5 questions creusantes" \
"Pas résumé. Questions qui forcent compréhension. Ollama Llama 3.2 3B. Opt-in par livre." \
"4" "ai" "Phase 4 — IA & Premium & Accessibilité"

create_issue "[P4] Auto-Anki Export — flashcards .apkg" \
"Depuis surlignages + passages clés. Format APKG natif. Viralité communautés étudiantes." \
"4" "ai" "Phase 4 — IA & Premium & Accessibilité"

create_issue "[P4] Reading DNA — profil vectoriel pgvector" \
"Temps, annotations, relectures → vecteur user. Radar partageable style Last.fm. Privacy opt-in." \
"4" "ai" "Phase 4 — IA & Premium & Accessibilité"

create_issue "[P4] Parcours apprentissage auto-générés" \
"\"Comprendre Kant\" → 5-15 livres ordonnés avec prérequis + estimation heures. LLM + graphe prérequis." \
"4" "ai" "Phase 4 — IA & Premium & Accessibilité"

create_issue "[P4] Contexte historique dynamique" \
"Carte, timeline, figures de l'époque, mœurs. IA générée (Ollama) + révisée communauté. Cache long." \
"4" "ai" "Phase 4 — IA & Premium & Accessibilité"

create_issue "[P4] Références intertextuelles détectées" \
"Pipeline NLP détecte citations/allusions. \"Ce passage fait écho à Iliade XVI\". Affichage subtle dans reader." \
"4" "ai" "Phase 4 — IA & Premium & Accessibilité"

create_issue "[P4] TTS Piper — 15 langues, export MP3, offline" \
"Voix neurales par langue. Export MP3 pour écouter offline. Accessibilité mal-voyants + illettrés + conduite." \
"4" "a11y" "5"

create_issue "[P4] Audio+texte synchronisé karaoke-style" \
"Mot courant s'illumine pendant TTS. Parfait apprentissage langue. Timestamps générés batch." \
"4" "a11y" "5"

create_issue "[P4] Résumés Llama 3.2 par chapitre (opt-in)" \
"Bouton \"Summarize\" par chapitre. 3-5 bullet points. Cached. Ethical: ne remplace pas lecture, aide review." \
"4" "ai" "Phase 4 — IA & Premium & Accessibilité"

create_issue "[P4] Stripe Premium \$4.99/mois ou \$39.99/an" \
"Débloquer : TTS premium voice, bulk download, API key perso, early access, badge Supporter. Jamais gating des livres." \
"4" "monetization" "Phase 4 — IA & Premium & Accessibilité"

create_issue "[P4] Stripe Donations — one-shot + mensuelles" \
"Thermomètre transparent public. Open Collective intégration. Pas popup harcelant. Seal Supporter profile." \
"4" "monetization" "Phase 4 — IA & Premium & Accessibilité"

create_issue "[P4] Navigation 100% voix — Web Speech API + Whisper local" \
"\"Go to next chapter\", \"Search Dostoevsky\", \"Start reading War and Peace\". Inclusion + différentiation." \
"4" "a11y" "5"

create_issue "[P4] Speed reading RSVP — mode optionnel" \
"Mots défilent au centre, 200-800 WPM configurable. Toggle reader settings." \
"4" "ux" "Phase 4 — IA & Premium & Accessibilité"

create_issue "[P4] TOR onion version — librarfreeXXX.onion" \
"Pays censurés. Version Lite servie. Documentation publique." \
"4" "a11y" "5"

create_issue "[P4] PostHog self-hosted — analytics éthique" \
"Replays off, autocapture off, COPPA-safe. Feature flags pour A/B testing. Docker Hetzner." \
"4" "infra" "Phase 4 — IA & Premium & Accessibilité"

create_issue "[P4] EN 301 549 compliance (accessibilité EU)" \
"Obligatoire pour partenariats bibliothèques publiques EU. Audit externe. Fixes." \
"4" "a11y" "5"

create_issue "[P4] ML classification genres/époques/topics" \
"Zero-shot bart-large-mnli. Révisé par communauté (wiki-style). Facettes search." \
"4" "ai" "Phase 4 — IA & Premium & Accessibilité"

create_issue "[P4] Reading Wrapped annuel — décembre shareable sobre" \
"Pas Spotify Wrapped hystérique. \"You read 42 books in 2026. Most intense month: November. DNA evolved toward Russian realism.\"" \
"4" "ux" "Phase 4 — IA & Premium & Accessibilité"

create_issue "[P4] Wander mode — collage animé couvertures flottantes" \
"Alternative à search. Click = zoom livre. Serendipity. Three.js léger." \
"4" "ux" "Phase 4 — IA & Premium & Accessibilité"

create_issue "[P4] Data versioning DVC — datasets d'entraînement" \
"Reproductibilité. Git-like pour gros fichiers. Versionning datasets HuggingFace." \
"4" "infra" "Phase 4 — IA & Premium & Accessibilité"

create_issue "[P4] Migration GPU cloud — Hetzner GPU €30/mois ou Runpod" \
"Décision : dedicated (Hetzner AX41 + GPU) ou à-la-demande (Runpod). Estimation workload Phase 4-5." \
"4" "infra" "Phase 4 — IA & Premium & Accessibilité"

create_issue "[P4] API B2B tier — \$9.99 indie + \$99 startup + custom enterprise" \
"Rate limit, priority, SLA. Portal self-service. API CC0 publique reste gratuite." \
"4" "monetization" "Phase 4 — IA & Premium & Accessibilité"

create_issue "[P4] Widget \"Embed Librarfree\" — blogs, papers, edX" \
"iframe lazy-load. Cover + title + CTA Read. Tracking anonyme. Moodle/Canvas integration Phase 5." \
"4" "growth" "Phase 4 — IA & Premium & Accessibilité"

create_issue "[P4] Referral éthique — invite ami → on offre 10 livres via ONG partenaire" \
"Pas de cash/discount. Solidarité réelle. Partenariats Teach For All, Room to Read." \
"4" "growth" "Phase 4 — IA & Premium & Accessibilité"

echo "=== Phase 5 — Scale & Communauté ==="
create_issue "[P5] Import langues restantes — JA, ZH, RU, PL, AR, KO" \
"Aozora (JA), 中国哲学书电子化计划 (ZH), ruslit (RU), Wolnelektury (PL), Al Waraq (AR), 디지털한글박물관 (KO). Coordination communauté locale." \
"5" "content" "Phase 5 — Scale & Communauté"

create_issue "[P5] Audiobooks batch — TTS Piper + SSML + chapitrage" \
"Génère audiobook pour tous les top 10K livres. Hébergé R2. Streaming + download premium." \
"5" "ai" "Phase 5 — Scale & Communauté"

create_issue "[P5] API publique CC0 GraphQL" \
"Catalogue + métadonnées + embeddings. REST + GraphQL. Docs Stoplight. Rate limit 1K/jour free, paid tiers." \
"5" "monetization" "Phase 5 — Scale & Communauté"

create_issue "[P5] Contributions wiki-style métadonnées" \
"Utilisateurs éditent : résumés, bios, liens. Versioning. Modération async. Moat concurrentiel." \
"5" "feature" "Phase 5 — Scale & Communauté"

create_issue "[P5] Cover Artist Community — licence CC-BY" \
"50K+ livres sans cover = opportunité. Artists uploadent, communauté vote, top 3 retenus. Credits bio." \
"5" "growth" "Phase 5 — Scale & Communauté"

create_issue "[P5] 3D library WebGL — Three.js + fallback 2D" \
"Galaxies = langues, étoiles = livres. Hover = metadata. Click = zoom. Fallback 2D obligatoire mobile." \
"5" "ux" "Phase 5 — Scale & Communauté"

create_issue "[P5] Time Machine — timeline interactive lecture chronologique" \
"Mode \"je lis tout 1850-1870 dans l'ordre\". Timeline zoomable. Recommendations contextuelles." \
"5" "ux" "Phase 5 — Scale & Communauté"

create_issue "[P5] Dataset HuggingFace Librarfree-Corpus v1 CC0" \
"Annotations, métadonnées enrichies, embeddings. Référence éthique entraînement IA." \
"5" "growth" "Phase 5 — Scale & Communauté"

create_issue "[P5] IPFS pinning via web3.storage" \
"Snapshot mensuel catalogue + métadonnées. Magnet public. Antifragile." \
"5" "infra" "Phase 5 — Scale & Communauté"

create_issue "[P5] Librarfree Scholars Program — 20 universités × 5 fellows rémunérés" \
"MIT, Stanford, Oxford, ETH, Tokyo U, IIT, USP, etc. €50k grant Mozilla/Sloan. Contribue content premium." \
"5" "growth" "Phase 5 — Scale & Communauté"

create_issue "[P5] Partenariat Wikipedia/Khan Academy embed" \
"\"Read free on Librarfree\" CTA sur pages livres DP Wikipedia. Trafic massif perpétuel." \
"5" "growth" "Phase 5 — Scale & Communauté"

create_issue "[P5] Multi-tenant B2B ready — organization_id scoping" \
"Architecture prête pour Phase 6 Corporate Libraries. RLS par org. UUID depuis Phase 0 donc OK." \
"5" "monetization" "Phase 5 — Scale & Communauté"

create_issue "[P5] Carbon dashboard public — websitecarbon.com tracking" \
"CO2/pageview par langue. Transparence radicale. <0.5g baseline." \
"5" "growth" "Phase 5 — Scale & Communauté"

create_issue "[P5] Print On Demand covers signature — Lulu/BookVault" \
"Série unifiée Librarfree (cohérence visuelle). User achat physique = nouveau revenue stream minoritaire." \
"5" "monetization" "Phase 5 — Scale & Communauté"

create_issue "[P5] Adopt a book — crowdfunding numérisation DP rares" \
"Livres papier DP non-numérisés. Contributeur listé éternellement sur la fiche." \
"5" "monetization" "Phase 5 — Scale & Communauté"

create_issue "[P5] Patron feature — don fondations liées auteur" \
"Alliance Française pour Hugo, Académie Russe pour Tolstoï. Librarfree prend 0%. Pur geste." \
"5" "growth" "Phase 5 — Scale & Communauté"

create_issue "[P5] Pipeline qualité auto Phase 2 — ML-based" \
"Classifier détection OCR fautif, pages manquantes, formatting broken. Score qualité recalculé." \
"5" "content" "Phase 5 — Scale & Communauté"

create_issue "[P5] 200 articles éditoriaux long-form — humains signés" \
"\"Best books on economics\", \"Where to start with Kant\", \"History of Romantisme\", etc. 10 auteurs contributeurs payés." \
"5" "content" "Phase 5 — Scale & Communauté"

create_issue "[P5] Share handler OS natif + Twitter cards premium" \
"Web Share API fallback. OG tags optimisés pour LinkedIn/Twitter/Mastodon/Threads." \
"5" "growth" "Phase 5 — Scale & Communauté"

create_issue "[P5] Moodle/Canvas plugin — widget profs \"Assigned via Librarfree\"" \
"LTI 1.3 integration. Enterprise play." \
"5" "growth" "Phase 5 — Scale & Communauté"

echo "=== Phase 6 — Mouvement ==="
create_issue "[P6] Federation ActivityPub — protocole Librarfree Exchange" \
"Spec publique. SDK TypeScript. N'importe qui self-host son instance, elles se fédèrent. Mastodon model." \
"6" "infra" "Phase 6 — Mouvement"

create_issue "[P6] Torrent mensuel magnet public" \
"Snapshot complet catalogue + fichiers. Sebastien seed + communauté seed. Survie éternelle." \
"6" "infra" "Phase 6 — Mouvement"

create_issue "[P6] Librarfree Box — Raspberry Pi ISO" \
"Image avec 10K livres essentiels + Meilisearch + UI offline. 50€ pour servir école entière wifi local. Impact Afrique/zones sans internet." \
"6" "a11y" "7"

create_issue "[P6] Graphe prérequis entre livres — DAG éditable wiki-style" \
"Visualisation prérequis. Base parcours + certifications. Éditable communauté, versionné." \
"6" "feature" "Phase 6 — Mouvement"

create_issue "[P6] Scholar Badges — Mozilla Open Badges exportables" \
"Certifications non-officielles. LinkedIn integration. \"Completed Philosophy 101 on Librarfree\"." \
"6" "feature" "Phase 6 — Mouvement"

create_issue "[P6] Corporate Libraries B2B — SSO SAML + branding" \
"Entreprises sponsorisent langue (\"Siemens finance corpus DE\") ou accès employés. €500-5000/an par client." \
"6" "monetization" "Phase 6 — Mouvement"

create_issue "[P6] ONG partnerships — Teach For All, Room to Read, Pratham, ALP" \
"Distribution Raspberry Pi boxes. Content pédagogique embarqué. Impact stories." \
"6" "growth" "Phase 6 — Mouvement"

create_issue "[P6] Dream Reader VR/AR (pilote presse)" \
"Scènes générées IA en fond pendant lecture (bibliothèque victorienne pour Dickens). Demo. WebXR. Opt-in opt-out strict." \
"6" "ux" "Phase 6 — Mouvement"

create_issue "[P6] Print On Demand intégration Lulu + BookVault" \
"User clique \"Buy physical copy\" sur n'importe quel livre DP → POD service livre monde entier. Petite marge." \
"6" "monetization" "Phase 6 — Mouvement"

create_issue "[P6] Candidature UNESCO phase finale" \
"Dossier complet. Interviews. Éventuelle acceptation 2027-2028." \
"6" "growth" "Phase 6 — Mouvement"

create_issue "[P6] Consolidation 15K contributeurs actifs" \
"Curator + Translator + Cover artist + Scholar + Developer + Editorial. Hall of Fame. Annuel awards." \
"6" "growth" "Phase 6 — Mouvement"

create_issue "[P6] Open Data full dump — CC0 1-click download catalogue" \
"Format parquet + SQLite + JSON. 500GB+. Mensuel auto." \
"6" "infra" "Phase 6 — Mouvement"

create_issue "[P6] Programmatic SEO 500K pages complet" \
"Génération on-demand ISR. Priority queue top 10K titres. Programmatic SEO peer-reviewed par éditorial humain." \
"6" "growth" "Phase 6 — Mouvement"

create_issue "[P6] Sound design voix — voix unique \"le Bibliothécaire\"" \
"Voix de narration Piper/ElevenLabs fine-tuned. Brand voice audio cohérente." \
"6" "ux" "Phase 6 — Mouvement"

create_issue "[P6] Hackathons trimestriels — tech + éditorial" \
"Bounties spécifiques. Prix finalistes. Recrutement contributeurs long-terme." \
"6" "growth" "Phase 6 — Mouvement"

echo ""
echo "=== Done. All issues created. ==="
