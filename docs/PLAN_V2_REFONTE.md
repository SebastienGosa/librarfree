# Plan Librarfree - Refonte Complete

## Contexte

Librarfree est un projet ambitieux de **megabibliotheque open-source, 100% legale et gratuite**, visant a devenir la reference mondiale des livres du domaine public. Le dossier `C:\Users\Sebas\librarfree` contient actuellement **95% de documentation et 0% de code** : un plan maitre, un schema SQL complet (12 tables), une config Docker, et un squelette monorepo vide.

**Pourquoi cette refonte** : Le travail existant (fait par d'autres IA) pose plusieurs problemes architecturaux critiques, un schema DB avec des bugs, et zero implementation concrete. Ce plan corrige les erreurs, simplifie l'architecture, et definit une roadmap actionnable pour construire le produit.

---

## 1. Audit critique de l'existant

### Ce qui est solide (a garder)
- Vision et strategie de contenu (sources PD par langue, regle d'or traductions)
- Config affiliation retailers (20+ retailers, 12 langues) 
- Docker Compose (Postgres 16 + Meilisearch 1.7)
- Squelette monorepo Turborepo

### Bugs et problemes a corriger

| # | Probleme | Impact | Fix |
|---|----------|--------|-----|
| 1 | `content TEXT` dans `book_translations` = 500K livres x ~75KB = **37GB dans Postgres** | DB inutilisable, backup/vacuum catastrophiques | Deplacer le contenu vers Cloudflare R2, stocker seulement `content_url` |
| 2 | `CREATE EXTENSION pg_trgm` manquant | Les index trigram (`gin_trgm_ops`) echouent sur DB vide | Ajouter l'extension avant les index |
| 3 | `UNIQUE(book_id, language_code)` sur `book_translations` | Interdit les multiples traductions dans la meme langue (ex: 5 traductions anglaises d'Homere) | Remplacer par index composite non-unique |
| 4 | Index `IVFFlat` sur embeddings (nul sur table vide) | IVFFlat necessite des donnees d'entrainement, inutile au demarrage | Utiliser HNSW a la place |
| 5 | Index full-text GIN sur `content` (texte complet des livres) | Index enormes, inutiles si on utilise Meilisearch | Supprimer, deleguer a Meilisearch |
| 6 | `v_affiliate_performance` fait un `LEFT JOIN ... ON true` | Produit cartesien = requete qui ne terminera jamais a l'echelle | Corriger les conditions de jointure |
| 7 | Architecture tRPC + API separee | Over-engineering pour ce projet | Supprimer, utiliser Server Actions Next.js |
| 8 | Tables manquantes | Pas de categories, collections, subscriptions, donations, fichiers... | Ajouter 8 nouvelles tables |

---

## 2. Decisions architecturales

### Stack finale

| Couche | Technologie | Justification |
|--------|-------------|---------------|
| **Framework** | Next.js 15 (App Router) | Server Components pour SEO 500K pages, Server Actions remplacent tRPC |
| **ORM** | Prisma 6 | Type-safe, migrations auto, remplace le SQL brut applicatif |
| **UI** | shadcn/ui + Tailwind CSS 4 | Composable, accessible, zero runtime |
| **i18n** | next-intl | Routes localisees `/en/book/...`, `/fr/livre/...` |
| **Auth** | Supabase Auth | Social login, magic link, tier gratuit genereux |
| **State client** | Zustand | Minimal: settings reader, filtres recherche |
| **Animations** | Framer Motion | Transitions pages, micro-interactions |
| **DB** | PostgreSQL 16 (Supabase) | Metadata + users + affiliates |
| **Search** | Meilisearch 1.7 | Recherche instantanee, tolerante aux typos, < 50ms |
| **Semantic** | pgvector (HNSW) | "Livres similaires" via embeddings |
| **Stockage** | Cloudflare R2 | Fichiers livres (EPUB, TXT, PDF). Zero frais d'egress |
| **Cache** | Upstash Redis | Rate limiting, cache metadata, sessions |
| **Embeddings** | Ollama + nomic-embed-text v1.5 | Self-hosted, 768 dims |
| **Resumes** | Ollama + Llama 3.2 3B | Resumes livres (premium) |
| **Traductions** | NLLB-200 (Meta) | Fallback uniquement si aucune trad PD |
| **Hosting app** | Vercel | Natif Next.js, CDN global, Edge functions |
| **Hosting workers** | Hetzner CAX41 | Serveur ARM pour inference IA, 30 EUR/mois |
| **CDN** | Cloudflare | DNS, DDoS, edge caching |
| **Paiements** | Stripe | Subscriptions premium + donations |
| **Analytics** | PostHog (self-hosted) ou Plausible | GDPR-compliant |
| **Monitoring** | Sentry | Error tracking |

### Ce qui est supprime vs l'ancien plan
- ~~tRPC~~ → Server Actions + Route Handlers
- ~~apps/api/~~ → fusionne dans apps/web/
- ~~Redis self-hosted~~ → Upstash (serverless)
- ~~content TEXT dans Postgres~~ → Cloudflare R2
- ~~IVFFlat~~ → HNSW
- ~~Full-text GIN sur contenu livres~~ → Meilisearch seul

---

## 3. Direction Artistique — "Z-Library 2.0 Premium"

### Philosophie: Z-Library comme base, mais en 10x mieux

**Ce qu'on garde de Z-Library** (ce qui fonctionne):
- Design **dark-first** (confort oculaire, impression de bibliotheque nocturne)
- **Search bar geante centree** sur la homepage (approche Google-like)
- Resultats avec **couvertures + metadata** a la volée
- **Telechargement multi-format** (EPUB, PDF, MOBI, TXT)
- **Booklists** communautaires et personnelles
- Interface **simple et directe** — zero friction vers le contenu

**Ce qu'on ameliore radicalement** (la version 2.0):
- Z-Library est **utilitaire et laid** → on fait du **premium dark** (think Spotify/Netflix for books)
- Z-Library a un **reader basique** → on construit un **reader world-class immersif**
- Z-Library n'a **aucune IA** → semantic search, "livres similaires", resumes IA, chat with book
- Z-Library n'a **pas de tracking lecture** → progression, streaks, stats, gamification
- Z-Library n'a **pas de curation** → collections editoriales, thematiques, saisonnieres
- Z-Library a un **mobile faible** → mobile-first PWA installable
- Z-Library a des **limites de download** → on est 100% illimite et legal
- Z-Library n'a **pas de reader en ligne digne de ce nom** → "Read Now" est le CTA principal (pas download)
- Z-Library n'a **aucune transparence** → tout est open-source, legal, clairement marque

### Palette de couleurs — Dark Premium

```
-- DARK THEME (DEFAULT, comme Z-Library mais premium)
Background:     #0F0F13 (Deep Black)     -- fond principal (plus profond que Z-Library)
Surface:        #1A1A24 (Dark Surface)   -- cartes, panneaux, navbar
Surface Hover:  #252532 (Elevated)       -- hover states, active elements
Border:         #2A2A3A (Subtle Border)  -- separateurs discrets

Primary:        #6C9CFF (Electric Blue)  -- liens, CTAs secondaires, elements interactifs
Accent:         #FFB84D (Warm Gold)      -- CTAs principaux, badges premium, highlights
Success:        #4ADE80 (Mint Green)     -- badge "Traduction humaine", statuts positifs
Warning:        #FB923C (Amber)          -- badge "Traduction IA"
Error:          #F87171 (Soft Red)       -- erreurs

Text Primary:   #E8E8ED (Off White)      -- titres, corps de texte
Text Secondary: #8B8BA0 (Muted Lavender) -- metadata, captions, descriptions
Text Muted:     #5C5C72 (Ghost)          -- placeholders, hints

-- LIGHT THEME (toggle disponible)
Background:     #FAFAF8 (Warm White)
Surface:        #FFFFFF
Text Primary:   #1A1A2E
Text Secondary: #6B7280
```

**Themes lecteur** : Light (#FAFAF8), Sepia (#F4ECD8), Dark (#1A1A24), OLED (#000000)

### Typographie

| Usage | Police | Raison |
|-------|--------|--------|
| Titres | **Literata** (Google Fonts) | Concue pour la lecture numerique, signal "plateforme de lecture" |
| Interface | **Inter** (Google Fonts) | Propre, tres lisible, standard UI moderne |
| Lecteur | Au choix: Literata (serif) / Inter (sans) / JetBrains Mono | Personnalisable |
| Monospace | **JetBrains Mono** | Blocs code, contenu technique |

### Ton
- **Premium mais accessible** — pas elitiste, pas enfantin
- Respectueux de la litterature
- Transparent: "Lien affilie" marque, "Traduction IA" marque
- Zero emoji dans l'UI
- Dark aesthetic = impression de calme, sophistication, lecture nocturne

---

## 4. UX — Z-Library 2.0 (Copycat ameliore)

### Mapping Z-Library → Librarfree 2.0

| Feature Z-Library | Notre version 2.0 |
|-------------------|--------------------|
| Homepage avec search bar | Homepage dark premium + search bar geante + hero anime + trending carousels |
| Resultats en liste basique | Grille responsive avec covers HD + preview au hover + filtres instantanes |
| Page livre: metadata + download | Page livre riche: cover, traductions multiples, reader inline, affilies, IA summary, similar books |
| Reader online basique (2024) | Reader immersif plein ecran: epub.js, 4 themes, custom fonts, annotations, progress sync |
| Download PDF/EPUB/MOBI/TXT | Download identique + "Read Now" comme CTA principal + "Send to Kindle" |
| Booklists communautaires | Collections editoriales curatees + listes utilisateur + challenges de lecture |
| Comptes avec limites download | Comptes sans limites + library perso + stats + streaks + gamification |
| Categories basiques | Categories hierarchiques + genres + epoques + tags + browse semantique |
| Dark theme (beta) | Dark-first par defaut, light toggle, 4 themes reader |
| Pas d'IA | Semantic search, "livres similaires", resumes IA, "Chat with this book" (premium) |
| Pas de mobile app digne | PWA installable, bottom nav, swipe reader, offline sync |
| Pas de monetisation transparente | Affilies geo-detectes, ads ethiques, premium clairement marque |

### Pages detaillees

#### 4.1 Homepage (`/[locale]`)
```
┌─────────────────────────────────────────────────────────────┐
│  [Logo]                    [Login] [Sign Up] [🌐 Lang] [☀️] │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│              ✦ 500,000+ Free Legal Books ✦                  │
│                                                             │
│    ┌─────────────────────────────────────────────────┐      │
│    │  🔍 Search by title, author, ISBN...            │      │
│    └─────────────────────────────────────────────────┘      │
│                                                             │
│    [Fiction] [Science] [Philosophy] [History] [Poetry]      │
│                                                             │
├─────────────────────────────────────────────────────────────┤
│  📈 Trending This Week                          [See All →] │
│  ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐            │
│  │cover │ │cover │ │cover │ │cover │ │cover │  ← scroll   │
│  │      │ │      │ │      │ │      │ │      │             │
│  │Title │ │Title │ │Title │ │Title │ │Title │             │
│  │Author│ │Author│ │Author│ │Author│ │Author│             │
│  └──────┘ └──────┘ └──────┘ └──────┘ └──────┘            │
│                                                             │
│  📚 Classics You Must Read                      [See All →] │
│  ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐            │
│  │ ...  │ │ ...  │ │ ...  │ │ ...  │ │ ...  │  ← scroll   │
│  └──────┘ └──────┘ └──────┘ └──────┘ └──────┘            │
│                                                             │
│  🆕 Recently Added                              [See All →] │
│  ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐            │
│  │ ...  │ │ ...  │ │ ...  │ │ ...  │ │ ...  │  ← scroll   │
│  └──────┘ └──────┘ └──────┘ └──────┘ └──────┘            │
│                                                             │
│  📋 Popular Collections                                     │
│  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐       │
│  │ French       │ │ Philosophy   │ │ Japanese     │       │
│  │ Romanticism  │ │ Essentials   │ │ Classics     │       │
│  │ 127 books    │ │ 84 books     │ │ 203 books    │       │
│  └──────────────┘ └──────────────┘ └──────────────┘       │
│                                                             │
│  Stats: 500K+ books · 15 languages · 100% legal · FOSS     │
├─────────────────────────────────────────────────────────────┤
│  [About] [API] [Donate] [GitHub] [Languages]    [Dark/Light]│
└─────────────────────────────────────────────────────────────┘
```
- Fond **#0F0F13** avec subtle grain texture
- Search bar centree, focus auto, autocomplete Meilisearch en temps reel
- Categories en chips cliquables sous la search bar
- 3-4 carousels horizontaux avec covers de livres (scroll horizontal tactile)
- Section collections curatees en cards

#### 4.2 Search (`/[locale]/search?q=...`)
```
┌────────────────────────────────────────────────────────────┐
│  [Logo]  [🔍 "war and peace"_____________] [Filters ▼]    │
├────────────┬───────────────────────────────────────────────┤
│ FILTERS    │  Results for "war and peace"  (42 results)    │
│            │                                               │
│ Language   │  ┌──────┐ War and Peace         ★★★★★        │
│ ☑ English  │  │cover │ Leo Tolstoy · 1869    1,225 pages  │
│ ☑ French   │  │      │ 🟢 Human · EN FR DE ES IT RU       │
│ ☐ German   │  │      │ [Read Now] [Download ▼]            │
│ ☐ Spanish  │  └──────┘                                     │
│            │                                               │
│ Genre      │  ┌──────┐ War and Peace (Maude transl.)      │
│ ☐ Fiction  │  │cover │ Leo Tolstoy · Standard Ebooks      │
│ ☐ Non-fic  │  │      │ 🟢 Human · EN only                 │
│ ☐ Poetry   │  │      │ [Read Now] [Download ▼]            │
│            │  └──────┘                                     │
│ Era        │                                               │
│ ☐ Ancient  │  ┌──────┐ La Guerre et la Paix               │
│ ☑ 19th c   │  │cover │ Tolstoi · Trad. Bienstock · 1902  │
│ ☐ 20th c   │  │      │ 🟢 Humaine · FR                    │
│            │  │      │ [Lire] [Telecharger ▼]             │
│ Quality    │  └──────┘                                     │
│ ◉ All      │                                               │
│ ○ Human    │  ── 💡 AI Suggestion ──────────────────      │
│ ○ AI only  │  "Readers who enjoyed War and Peace           │
│            │   also liked Anna Karenina, The Brothers      │
│ Format     │   Karamazov, and Doctor Zhivago"              │
│ ☐ EPUB     │  ──────────────────────────────────────      │
│ ☐ PDF      │                                               │
│ ☐ TXT      │  [Load More...]                               │
└────────────┴───────────────────────────────────────────────┘
```
- Resultats en temps reel pendant la frappe (Meilisearch < 50ms)
- Chaque resultat montre: cover, titre, auteur, annee, pages, badges langues dispo, badge qualite traduction
- Filtres sidebar (desktop) ou drawer (mobile): langue, genre, epoque, qualite traduction, format
- Banniere "AI Suggestion" entre resultats (semantic search pgvector)
- Compteur resultats + tri (pertinence, popularite, date)

#### 4.3 Book Detail (`/[locale]/book/[slug]`)
```
┌────────────────────────────────────────────────────────────┐
│  [← Back]  [Logo]  [Search]         [Library] [Profile]   │
├────────────────────────────────────────────────────────────┤
│                                                            │
│  ┌──────────┐   War and Peace                              │
│  │          │   by Leo Tolstoy · 1869 · Russian            │
│  │  COVER   │                                              │
│  │  IMAGE   │   ★★★★★ (2,341 ratings) · 45K reads         │
│  │          │                                              │
│  │          │   ┌──────────────────────────────────┐       │
│  │          │   │  ▶ READ NOW   │  ⬇ Download ▼  │       │
│  │          │   └──────────────────────────────────┘       │
│  │          │                                              │
│  └──────────┘   📖 1,225 pages · ~20h read time            │
│                 🏷️ Fiction, War, Historical, Romance        │
│                                                            │
│  ── Available Translations ──────────────────────────      │
│  [EN 🟢] [FR 🟢] [DE 🟢] [ES 🟢] [IT 🟡] [RU 🟢]      │
│                                                            │
│  Selected: English — Aylmer & Louise Maude translation     │
│  Source: Standard Ebooks · 🟢 Human Professional           │
│  Formats: [EPUB] [PDF] [TXT] [MOBI]                       │
│                                                            │
│  ── Buy a Physical Copy ─── (affiliate, supports us) ──   │
│  [🛒 Amazon $12.99] [📚 Barnes & Noble] [📖 Book Dep.]   │
│                                                            │
│  ── AI Summary ──────────── 🔒 Premium ─────────────      │
│  War and Peace follows several Russian aristocratic        │
│  families through the Napoleonic Wars... [Unlock →]        │
│                                                            │
│  ── About the Author ───────────────────────────────      │
│  Leo Tolstoy (1828-1910) Russian writer...  [See all →]   │
│                                                            │
│  ── Similar Books ───────────────────────────────────      │
│  ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐           │
│  │Anna K│ │Bros K│ │Dr Zhi│ │Crime │ │Fath& │           │
│  └──────┘ └──────┘ └──────┘ └──────┘ └──────┘           │
│                                                            │
│  ── Reviews ─────────────────────────────────────────      │
│  ★★★★★ "A masterpiece..." — @reader42                     │
│  ★★★★☆ "Dense but rewarding..." — @bookworm              │
└────────────────────────────────────────────────────────────┘
```
- **"Read Now" est le CTA principal** (pas download comme Z-Library)
- Onglets traductions: cliquer une langue charge la traduction correspondante
- Badge qualite: vert = humaine, orange = IA, avec tooltip explicatif
- Panel affilie: geo-detecte (Amazon FR pour un user francais, etc.)
- Resume IA sous paywall premium (teaser visible)
- Carousel "Similar Books" alimente par pgvector
- Section reviews/ratings communautaires
- JSON-LD Schema.org (SEO)
- **Send to Kindle** button (via email SMTP)

#### 4.4 Reader (`/[locale]/book/[slug]/read`)
```
┌────────────────────────────────────────────────────────────┐
│  [← Back] War and Peace — Ch. 3          42% ⚙️            │
├────────────────────────────────────────────────────────────┤
│                                                            │
│                                                            │
│         "Well, Prince, so Genoa and Lucca are now          │
│     just family estates of the Buonapartes. But I          │
│     warn you, if you don't tell me that this means         │
│     war, if you still try to defend the infamies           │
│     and horrors perpetrated by that Antichrist — I          │
│     really believe he is Antichrist — I will have          │
│     nothing more to do with you and you are no             │
│     longer my friend, no longer my 'faithful slave,'       │
│     as you call yourself! But how do you do? I see         │
│     I have frightened you — sit down and tell me           │
│     all the news."                                         │
│                                                            │
│     It was in July, 1805, and the speaker was the          │
│     well-known Anna Pavlovna Scherer, maid of honor       │
│     and favorite of the Empress Maria Feodorovna.          │
│                                                            │
│                                                            │
├────────────────────────────────────────────────────────────┤
│  ◀ Prev │ ■■■■■■■■■■■■░░░░░░░░░ 42% │ Ch.3/361 │ Next ▶  │
└────────────────────────────────────────────────────────────┘

  Settings Drawer (⚙️):
  ┌──────────────────────────────┐
  │ Font:    [Literata ▼]        │
  │ Size:    [─────●──] 18px     │
  │ Spacing: [────●───] 1.6      │
  │ Width:   [──────●─] 680px    │
  │ Theme:   [☀️] [📜] [🌙] [⚫] │
  │ View:    [Paginated] [Scroll]│
  └──────────────────────────────┘
```
- **Plein ecran immersif** — barres auto-hide (apparaissent au tap/hover haut/bas)
- epub.js pour EPUB, renderer HTML custom pour TXT
- **4 themes**: Light, Sepia, Dark, OLED Black
- Settings: police (Literata/Inter/Mono), taille 14-28, interligne, largeur, marges
- **Selection texte** → popup: Surligner (couleurs), Ajouter note, Copier, Rechercher
- **Bookmarks** par chapitre
- **Barre de progression** avec slider, chapitre courant, temps restant estime
- **Mode pagine ou scroll** au choix
- Progression auto-sauvegardee (Supabase si connecte, localStorage sinon)
- **Raccourcis clavier**: ←/→ pages, Esc fermer, F plein ecran
- **Swipe** gauche/droite sur mobile

#### 4.5 Author (`/[locale]/author/[slug]`)
- Portrait (Wikipedia ou genere), bio, dates, nationalite
- Stats: total livres, lectures, langues disponibles
- Oeuvres completes en grille (triables: popularite/chronologie)
- Lien Wikipedia

#### 4.6 Collections (`/[locale]/collections`)
- Grille de collections curatees: "Romantisme francais", "Philosophie grecque", "Japanese Classics"
- Chaque card: image cover composite, titre, description courte, nombre de livres
- Collections sponsorisees marquees "Presented by [Sponsor]"
- Collections utilisateur publiques

#### 4.7 Explore (`/[locale]/explore`)
- **"Surprise Me"** — bouton qui ouvre un livre aleatoire de qualite
- "Ceux qui ont aime [X] ont aussi aime..." (pgvector)
- Carte visuelle genres/epoques (interactive, cliquable)
- "Nouveautes de la semaine" feed
- Challenges de lecture saisonniers ("Summer Reading Challenge: 10 books")
- **Browse par categorie** avec sous-categories hierarchiques

#### 4.8 Library (`/[locale]/library`) — connecte
- **Onglets**: En cours (avec barre progression), Termines, A lire, Abandonnes
- Stats dashboard: livres ce mois, pages cette semaine, streak jours consecutifs
- **Annotations**: tous les surlignages/notes, filtrable par livre
- **Booklists perso**: creer des listes thematiques, partageables
- Export CSV/JSON historique lecture
- **Send to Kindle** depuis la library

#### 4.9 Profile (`/[locale]/profile/[username]`)
- Avatar, username, bio, stats lecture publiques
- **Badges/achievements**: "10 livres lus", "Polyglotte (3+ langues)", "Critique litteraire (50+ reviews)"
- Etageres publiques
- Reviews et ratings de l'utilisateur
- Followers/following (futur)

#### 4.10 Pricing (`/[locale]/pricing`)
- Comparison table 2 colonnes: Free vs Premium ($4.99/mo ou $39.99/an)
- Free: tout le catalogue, reader, telechargements, library perso, ads legeres
- Premium: + resumes IA, chat with book, audiobooks generes, offline sync, zero ads, stats avancees
- Option donation ponctuelle en bas

#### 4.11 Donate (`/[locale]/donate`)
- Message transparent sur les couts
- Stripe one-time (montants suggeres: 5/10/25/50 EUR)
- Widget Ko-fi
- Lien GitHub Sponsors
- "Wall of donors" optionnel

### Navigation

**Desktop**: Header sticky avec logo, search bar, navigation (Explore, Collections, Library, Profile), theme toggle, lang switcher
**Mobile**: Bottom tab bar (Home, Search, Library, Profile) + header minimaliste
**Reader**: Chrome minimal, auto-hide, gestures swipe

---

## 5. Monetisation - Architecture technique

### 7 flux de revenus

| # | Source | Implementation | Phase |
|---|--------|----------------|-------|
| 1 | **Affiliation** (Amazon + retailers locaux) | Click tracking server-side, GeoIP via header Vercel, `affiliate_clicks` table | Phase 2 |
| 2 | **Ads non-intrusives** (EthicalAds / Carbon) | Composant `<AdSlot />`, masque pour premium, 1 slot search + 1 slot book detail | Phase 4 |
| 3 | **Donations** (Stripe + Ko-fi) | Page `/donate`, widget Ko-fi footer, webhook Stripe → `donations` table | Phase 4 |
| 4 | **Premium** ($4.99/mo) | Stripe Billing, `premium_subscriptions` table, middleware `isPremium` | Phase 4 |
| 5 | **Sponsoring collections** | Champ `sponsor_name/logo` sur `collections`, admin dashboard | Phase 5 |
| 6 | **Print-on-demand** (Lulu API) | Bouton "Commander en papier" → redirect Lulu, lien affilie | Phase 5 |
| 7 | **API payante** ($9.99/mo dev tier) | Rate limiting Upstash, cles API dans settings, `/api/v1/` | Phase 5 |

### Features Premium
- Resumes IA generes a la demande (Llama 3.2)
- "Chat with this book" (RAG: chunks livre + embeddings)
- Audiobooks generes (Coqui TTS, file d'attente)
- Sync hors-ligne (PWA Service Worker cache livres)
- Zero pubs
- Stats lecture avancees
- Support prioritaire

---

## 6. Pipeline de contenu

```
[Source PD] → [Download] → [Parse] → [Clean] → [Enrich] → [Index] → [Store R2]
```

### Etapes detaillees

1. **Download**: workers par source (Gutenberg rsync, Gallica OAI-PMH, Wikisource dumps, etc.)
2. **Parse**: extraction metadata (titre, auteur, annee, langue), strip headers/footers source
3. **Clean**: normalisation Unicode NFC, fix encodage, suppression whitespace excessif, decoupe chapitres
4. **Enrich**: detection langue (fasttext), lookup ISBN (Open Library/Google Books API), dedup auteurs, word count, temps lecture, score lisibilite
5. **Generate files**: conversion EPUB/TXT via Pandoc, upload formats vers R2, enregistrement `book_files` table
6. **Index**: push metadata vers Meilisearch, generation embedding (nomic-embed-text, 2000 premiers tokens), stockage vecteur dans `book_translations.embedding`

### Sources par phase

| Phase | Sources | Volume estime |
|-------|---------|---------------|
| 1 | Project Gutenberg + Standard Ebooks | ~77K livres EN |
| 3 | Gallica, Wikisource FR, Feedbooks, Gutenberg-DE, Cervantes | +100K (FR/DE/ES) |
| 5 | Aozora Bunko, Lib.ru, Wolne Lektury, Runeberg, IA, + 10 sources | +300K (15 langues) |

---

## 7. Schema DB ameliore

### Corrections sur schema existant
1. Ajouter `CREATE EXTENSION IF NOT EXISTS pg_trgm;`
2. Remplacer `content TEXT` par `content_url VARCHAR(500)` + `content_format` + `content_size_bytes`
3. Supprimer `UNIQUE(book_id, language_code)` → index composite non-unique
4. Remplacer IVFFlat par HNSW pour l'index embeddings
5. Supprimer les index GIN full-text sur `content` (lignes 133-136)
6. Corriger `v_affiliate_performance` (supprimer le cross join)

### 8 nouvelles tables a ajouter

| Table | But |
|-------|-----|
| `categories` | Categories hierarchiques (parent_id, slug, name JSONB multilingue) |
| `book_categories` | Jointure N:N livres ↔ categories |
| `collections` | Collections curatees (slug, titre JSONB, sponsor_name/logo) |
| `collection_books` | Livres ordonnes dans une collection |
| `book_files` | Fichiers par traduction (format, file_url R2, taille, checksum) |
| `premium_subscriptions` | Abonnements Stripe (plan, status, period) |
| `donations` | Dons (montant, provider, message) |
| `reading_lists` | Listes utilisateur (titre, public/prive) |

---

## 8. SEO pour 500K+ pages

### Structure URLs
```
/{locale}/book/{slug}          -- detail livre (SSG + ISR 24h)
/{locale}/author/{slug}        -- page auteur
/{locale}/collection/{slug}    -- collection curatee
/{locale}/genre/{slug}         -- listing genre
/{locale}/search               -- recherche (noindex)
/{locale}/book/{slug}/read     -- reader (noindex)
```

### Technique
- **SSG + ISR**: toutes les pages livres generees statiquement, revalidation 24h
- **JSON-LD**: schema `Book` sur chaque page (titre, auteur, ISBN, offers affilies, ratings)
- **Sitemaps dynamiques**: index → sitemaps par langue → max 50K URLs chacun
- **hreflang**: liens croises entre traductions d'un meme livre
- **Canonical**: reader → canonicalise vers book detail
- **OG/Twitter Cards**: image couverture + titre + description par livre
- **robots.txt**: allow /book/, /author/, /collection/ ; disallow /search, /read, /api/, /settings

---

## 9. Nom et domaine

### Recherche effectuee: 40+ domaines testes par DNS lookup

**Tous pris**: openshelf.com, freereads.com, readfree.com, libris.io, bookfree.com, allbooks.com, 
pagefree.com, openreads.com, freeverse.com, biblioverse.com, freelibrary.org, librafree.com, 
libreads.com, bookopia.com, libverse.com, bookhaven.com, freelibra.com, allreads.com, 
readpublic.com, lexifree.com, bookpublic.com, freebound.io, freeverse.io, libratory.com, openlibra.io

### 3 Finalistes (potentiellement disponibles)

| # | Domaine | Pour | Contre |
|---|---------|------|--------|
| 1 | **librarfree.com** | Simple, clair (Library+Free), "libr-" evoque "libre" en FR/ES. Distinctif comme Flickr/Tumblr. Deja choisi. | Ressemble a une faute d'orthographe. Pas premium. |
| 2 | **openreader.com** | "Open" universel (open-source), "Reader" centre sur l'experience lecture (notre differenciateur vs Z-Lib). Propre, moderne. | Plus long (10 chars). "Reader" est anglophone. |
| 3 | **openlibra.com** | "Libra" = livres en latin, compris dans toutes les langues romanes (FR/ES/IT/PT). Court, elegant. "Open" = open-source. | Confusion possible avec la crypto Libra (Meta). |

**Bonus potentiellement dispo**: publicread.com, freeread.io, booksforall.io, publicbooks.io

> **Note**: DNS lookup n'est pas une garantie a 100% — verifier sur un registrar (Namecheap/Porkbun) avant d'acheter.
> Le choix final se fait ensemble avant de commencer le dev.

---

## 10. Phases de developpement

### Phase 0 - Fondations (Semaines 1-2)
- [ ] Initialiser Next.js 15 dans `apps/web/` (App Router, TS, Tailwind, shadcn/ui)
- [ ] Setup Prisma dans `packages/db/` avec schema corrige
- [ ] Migrations Prisma + Docker Compose mis a jour (+ MinIO pour R2 local, + Redis)
- [ ] Config index Meilisearch
- [ ] Importer Gutenberg: parser catalogue RDF, importer 100 livres test
- [ ] Upload fichiers vers MinIO, verifier pipeline complet
- **Livrable**: `pnpm dev` affiche l'app. DB a 100 livres. Meilisearch retourne des resultats.

### Phase 1 - MVP Core (Semaines 3-6)
- [ ] Landing page: hero + search + trending
- [ ] Search page: Meilisearch instant, filtres basiques (langue, genre)
- [ ] Book detail: couverture, metadata, "Lire", download
- [ ] Reader: epub.js, themes, tailles police, progression
- [ ] Layout: header, footer, responsive mobile
- [ ] SEO: sitemap, meta tags, JSON-LD
- [ ] Import complet Gutenberg (70K) + Standard Ebooks (7K)
- **Livrable**: Deploye sur Vercel. 77K livres EN cherchables et lisibles.

### Phase 2 - Comptes & Affiliation (Semaines 7-10)
- [ ] Supabase Auth (email, Google, GitHub)
- [ ] Bibliotheque utilisateur: sauvegarder livres, progression, statut
- [ ] Sync progression reader
- [ ] Annotations: surligner, noter
- [ ] Systeme affiliation: boutons retailers, click tracking, GeoIP
- [ ] Inscription Amazon Associates (US, UK, FR, DE, ES)
- [ ] Stats lecture: livres lus, streak
- **Livrable**: Users peuvent s'inscrire, tracker leur lecture. Clicks affilies traces.

### Phase 3 - Multilingue (Semaines 11-18)
- [ ] next-intl: routes localisees, traductions UI (FR, DE, ES)
- [ ] Import contenu FR (Gallica, Wikisource FR, Feedbooks)
- [ ] Import contenu DE (Gutenberg-DE, Runeberg)
- [ ] Import contenu ES (Cervantes, Wikisource ES)
- [ ] Affiliations localisees (Fnac, Thalia, Casa del Libro)
- [ ] Meilisearch multi-index par langue
- [ ] hreflang cross-langue
- [ ] Collections curatees par langue
- **Livrable**: ~150K livres en 4 langues. i18n complet. Affilies dans 4 marches.

### Phase 4 - IA & Premium (Semaines 19-26)
- [ ] Pipeline embeddings: generer vecteurs via Ollama sur Hetzner
- [ ] Recherche semantique: "Livres similaires" pgvector HNSW
- [ ] Resumes IA: Llama 3.2 (feature premium)
- [ ] Page Explore: decouverte IA
- [ ] Stripe Billing: subscription premium ($4.99/mo, $39.99/an)
- [ ] Paywall premium: middleware isPremium
- [ ] Page donations: Stripe one-time + Ko-fi
- [ ] EthicalAds: pubs non-intrusives pour users gratuits
- **Livrable**: Tier premium live. Features IA fonctionnelles. Multi-revenus actifs.

### Phase 5 - Scale & Polish (Semaines 27-36)
- [ ] Import langues restantes (IT, PT, JA, ZH, RU, PL, NL, nordiques, AR, KO)
- [ ] Audiobooks generes (Premium): Coqui TTS
- [ ] Couvertures generees: SDXL pour livres sans couverture
- [ ] Communaute: etageres publiques, avis, challenges lecture
- [ ] PWA offline: Service Worker cache livres bookmarkes
- [ ] API v1 publique avec rate limiting
- [ ] Print-on-demand (Lulu)
- [ ] Sponsoring collections
- **Livrable**: 500K+ livres, 15+ langues, feature-set complet.

---

## 11. Couts infrastructure

| Phase | Cout/mois | Details |
|-------|-----------|---------|
| MVP (0-1) | ~$1 | Vercel Free, Supabase Free, Meili Free, R2 Free |
| Growth (2-3) | ~$85 | Vercel Pro $20, Supabase Pro $25, Meili $30, R2 $5, Hetzner $4 |
| Scale (4-5) | ~$160 | + Meili custom $60, Hetzner GPU $30, Redis Pro $10 |
| Maturite (6) | ~$500-1100 | Scaling horizontal, DB Team plan ou self-hosted |

### Objectifs revenus

| Phase | Cout | Revenu necessaire | Sources |
|-------|------|-------------------|---------|
| MVP | $0-20 | $0 | Construction |
| Growth | $85 | $100+ | Premiers clics affilies |
| Scale | $160 | $500+ | 100 users premium + affilies + ads |
| Maturite | $500-1100 | $5,000+ | 1000 premium + affilies matures + B2B |

---

## 12. Verification

### Comment tester les changements
- **Schema DB**: `docker compose up postgres` + `prisma migrate dev` + queries test
- **Frontend**: `pnpm dev` + navigation manuelle de chaque page
- **Search**: import 100 livres → recherche dans Meilisearch → verifier resultats
- **Reader**: ouvrir un livre, changer themes/polices, verifier progression sauvegardee
- **Affilies**: cliquer liens → verifier tracking dans `affiliate_clicks`
- **SEO**: Google Lighthouse, verifier JSON-LD, sitemaps, hreflang
- **Premium**: souscrire en mode test Stripe, verifier acces features
- **Mobile**: tester toutes les pages en responsive (Chrome DevTools)

---

## Fichiers critiques a modifier/creer

| Fichier | Action |
|---------|--------|
| `database/schema.sql` | Corriger les 8 bugs identifies + ajouter 8 tables |
| `package.json` | Mettre a jour deps (+ Prisma, shadcn, next-intl, stripe, bullmq) |
| `docker-compose.yml` | Ajouter MinIO + Redis + init pgvector/pg_trgm |
| `apps/web/` | Scaffolder Next.js 15 complet |
| `packages/db/` | Setup Prisma schema + client |
| `packages/ui/` | Init shadcn/ui components |
| `workers/importers/gutenberg/` | Premier importer fonctionnel |
| `PLAN_MAITRE_LIBRARFREE.md` | Mettre a jour avec la nouvelle architecture |
| `README.md` | Mettre a jour stack + instructions |
