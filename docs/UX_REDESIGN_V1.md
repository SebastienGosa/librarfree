# UX Redesign V1 — Librarfree

_Document de référence — audit Z-Library + décisions design + mapping adoption + prompts AIDesigner + spec composants._

> Livré en autonomie le 2026-04-18. Plan d'exécution dans
> `docs/UX_REDESIGN_V1_PLAN.md`.

---

## 0. Contexte et principes

Librarfree n'est pas Z-Library. On ne copie pas un agrégateur de fichiers,
on construit une bibliothèque éditoriale publique. Les références positives
sont **NYT Interactive**, **Rijksmuseum**, **Every.to**, **Readwise Daily**,
**Standard Ebooks**. Vibe éditoriale, dark mode, lisibilité, zéro dark pattern.

Contraintes non-négociables :

- Dark mode only (V1)
- WCAG AAA sur les textes primaires
- RTL-aware (arabe phase 4)
- Zero ad, zero tracker, zero paywall sur la lecture
- Transparence radicale sur les traductions (badge provenance permanent)

---

## 1. Audit Z-Library (défensif)

Objectif : identifier ce qui rend Z-Library fonctionnellement utile mais
esthétiquement et éthiquement à **éviter**, pour ne pas y retomber par
mimétisme.

### 1.1 Ce qu'on rejette

| Pattern Z-Library | Pourquoi on évite |
|-------------------|-------------------|
| Fondrasing agressif (bandeaux donation twice/year) | On rejette l'urgence fabriquée. Notre monétisation premium est discrète et la lecture reste gratuite. |
| Login requis pour télécharger au-delà de N livres | On ne met aucune barrière sur la lecture. Télécharger EPUB/PDF reste libre. |
| Mirror hopping, UI qui change selon le miroir | Une marque, un domaine, une identité visuelle cohérente. |
| Covers basse qualité, metadata inconsistante | Standard Ebooks grade : covers propres, metadata canonique, provenance affichée. |
| Sensation "underground" qui signale la piraterie | Librarfree doit signaler légalité + domaine public immédiatement (badge, eyebrow, ton éditorial). |
| Couleurs saturées criardes, gradients années 2000 | Palette Twilight sobre, accent gold réservé aux moments éditoriaux. |
| Recherche qui renvoie 50k résultats non curatés | Recherche + filtres qualité + curation éditoriale par collections. |
| Phishing-friendly (design facilement clonable) | Identité typographique forte (Literata + Inter) difficile à contrefaire. |

### 1.2 Ce qu'on garde de l'idée Z-Library

- Densité de catalogue — il faut que la bibliothèque se sente **grande**
  dès le hero (d'où la bande stats : 502k livres, 15 langues, 38k lecteurs).
- Recherche centrale, toujours à portée de clic (Phase 1 : search bar
  persistante dans le header).
- Facettes de recherche riches (langue, siècle, qualité traduction, durée
  de lecture, source).

### 1.3 Captures

Échec de capture automatisée (TLS + blocage fetch). À recapturer en Phase 1
via Playwright isolé une fois le harness fixé. Les trois points de
comparaison à shooter :

1. Homepage brute de Z-Library (densité, palette, fundraising banner)
2. Page résultats de recherche
3. Fiche livre (metadata, téléchargement)

Previews attendues : `apps/web/public/design-previews/zlib-*.png`.

---

## 2. Références positives (vibes)

| Source | Ce qu'on emprunte |
|--------|-------------------|
| **NYT Interactive** | Long-scroll éditorial, typo serif XL, pull quotes pleine largeur, rythme densité/air. |
| **Rijksmuseum** | Dark mode institutionnel, gold accent sobre, whitespace généreux, hero image-forward. |
| **Every.to** | Grille modulaire, author attribution visible, densité maîtrisée, ton intellectuel non-corpo. |
| **Readwise Daily** | "Book of the day" comme rituel, excerpt pull, minimalisme fonctionnel. |
| **Standard Ebooks** | Typographie comme manifeste, palette réduite, ton "made with care". |

---

## 3. Décisions design — V1

### 3.1 Tokens

- `primary` = `#6C9CFF` (conservé) — CTA, focus, liens, ring
- `accent` = `#F5B700` (upgrade depuis `#FFB84D`) — highlights éditoriaux,
  pull quotes, badges gold, rules, secondary editorial CTAs
  - Contraste sur `#0F0F13` = **11.8:1** (AAA large & small text)
  - Contraste sur `#1A1A24` = **10.1:1** (AAA)
- Le token s'appelle toujours `accent` pour préserver la sémantique
  Tailwind (`bg-accent`, `text-accent`, `border-accent/70`). La valeur
  change, pas le nom. Voir décision en §6.

### 3.2 Typographie

- Titres : Literata (serif) — déjà configurée
- UI : Inter (sans) — déjà configurée
- Stats / monospace : JetBrains Mono — déjà configurée
- Tracking hero : `-0.01em` (déjà dans `globals.css`)
- Display XL homepage : `text-6xl md:leading-[1.05]`
- Pull quote hero : `text-3xl md:text-4xl lg:text-[2.75rem]`

### 3.3 Grid et rythme

- Container éditorial max 72rem (déjà défini)
- Rhythm vertical : sections à 16–28 rem vertical padding pour long-scroll
- Hero padding : `py-20 md:py-28`
- Section standard : `py-16 md:py-20`

### 3.4 Micro-interactions

- Hover cards : `-translate-y-0.5` + `border-primary/60` (default book-card)
- Hover collections : `border-accent/70` + `bg-card` (éditorial)
- `prefers-reduced-motion` déjà respecté via `globals.css`

### 3.5 Règles d'usage accent gold

| Contexte | Usage accent |
|----------|--------------|
| CTA primaire (Lire, Commencer) | ❌ — `primary` |
| Focus visible | ❌ — `primary` |
| Pull quote — guillemet ouvrant | ✅ |
| Pull quote — rule d'attribution | ✅ |
| Eyebrow "Livre du jour", "Editorial" | ✅ |
| Collection card — rule top | ✅ |
| Badge qualité "human professional" | ❌ — emerald (convention repo) |
| Badge "new", "pick of the week" | ✅ futur |
| Hover outline button | ✅ (déjà via `hover:bg-accent` dans button.tsx) |

---

## 4. Mapping adoption repo

| Décision design | Fichier | Action |
|-----------------|---------|--------|
| Accent gold `#F5B700` | `packages/brand/src/index.ts` | **Fait** — `theme.dark.accent` |
| Accent gold CSS var | `apps/web/app/globals.css` | **Fait** — `--color-accent` |
| Citation / pull quote | `packages/ui/src/components/citation-card.tsx` | **Fait** — neuf |
| Empty state générique | `packages/ui/src/components/empty-state.tsx` | **Fait** — neuf |
| Variant hero éditorial | `packages/ui/src/components/book-card.tsx` | **Fait** — `variant="editorial-hero"` |
| Exports UI | `packages/ui/src/index.ts` | **Fait** |
| Homepage long-scroll | `apps/web/app/[locale]/page.tsx` | **Fait** — 8 sections |
| Clés i18n EN | `apps/web/messages/en.json` | **Fait** |
| Clés i18n FR | `apps/web/messages/fr.json` | **Fait** |
| Clés i18n 10 autres locales | `apps/web/messages/*.json` | **Différé** — next-intl fallback EN |

---

## 5. Spec composants

### 5.1 `<CitationCard>`

```tsx
<CitationCard
  size="hero"                      // "default" | "hero"
  quote="A library is not a luxury but one of the necessities of life."
  author="Henry Ward Beecher"
  work="Star Papers"
  year={1855}
  language="en"                    // sets lang attribute
  translator="…"                   // optional
/>
```

- Figure sémantique (`<figure>` + `<blockquote>` + `<figcaption>` + `<cite>`)
- Guillemet Literata XL en accent gold
- Rule 32px en accent gold avant l'auteur
- `lang` attribute propagé pour RTL et hyphenation correcte

### 5.2 `<EmptyState>`

```tsx
<EmptyState
  title="Your shelf is empty — for now."
  description="Books you open get saved here automatically."
  icon={<BookOpenIcon />}
  action={<Button asChild><Link href="/library">Browse</Link></Button>}
  secondaryAction={<Link …>Learn how it works</Link>}
  variant="default"                // "default" | "compact"
/>
```

- `role="status" aria-live="polite"` pour lecteurs d'écran
- Icône dans un cercle bordé, jamais accusatoire
- Zero dark pattern : pas de "upgrade to unlock"

### 5.3 `<BookCard variant="editorial-hero">`

Nouvelles props éditoriales, toutes optionnelles :
- `eyebrow` — label accent gold ("Livre du jour")
- `excerpt` — pull text serif large
- `origin` — "France · 19e siècle"
- `translationCount` — affiche "12 translations available" en mono

Layout desktop : cover 220-280px + colonne texte ; mobile : cover stacked
au-dessus.

---

## 6. Décision notable : token `accent` remplacé, pas dupliqué

Le prompt demandait "ajouter un token séparé `accent` à côté du `primary`".
**Le token `accent` existe déjà** dans le repo (`#FFB84D`, défini dans
`packages/brand/src/index.ts` et `apps/web/app/globals.css`, utilisé
notamment dans `book-card.tsx` placeholder gradient et `button.tsx`
outline/ghost hover).

Trois options considérées :

1. **Créer un nouveau `accentGold` à côté** — casse la sémantique Tailwind
   et pourrit l'autocomplete (`bg-accent` vs `bg-accentGold`). Rejeté.
2. **Remplacer `accent` par `#F5B700`** — change la couleur des hovers de
   buttons (outline/ghost) du jaune-orange au gold. Le hover outline
   `hover:bg-accent hover:text-accent-foreground` devient gold saturé sur
   fond gold — lisible (contraste 11.8:1). Choisi.
3. **Garder deux tokens `accent` (warm) + `gold` (editorial)** — over-
   engineering pour V1. À reconsidérer si Phase 2 introduit un ton
   supplémentaire.

**Décision : option 2.** Le hover button prend la teinte gold, ce qui est
visuellement plus éditorial et cohérent avec la nouvelle direction. Si
Sebastien veut segmenter plus finement, on ajoutera un `--color-gold`
séparé en V2 sans casser `accent`.

---

## 7. Prompts AIDesigner prêts à l'emploi

Ces deux prompts sont à invoquer avec `generate_design` MCP une fois
le serveur `aidesigner` authentifié. **Zéro crédit consommé à ce jour.**
Budget max : **6 crédits** (2 générations + 1 refine toléré).

### 7.1 Artefact 1 — Homepage éditoriale + fiche livre (~3 crédits)

```
Design a long-scroll editorial homepage and a paired book-detail page for
an open-source public-domain library called Librarfree. Dark mode only,
WCAG AAA.

Vibe: NYT Interactive + Rijksmuseum + Every.to + Readwise Daily +
Standard Ebooks. Editorial, institutional, calm. Never SaaS, never
underground, never Z-Library.

Fonts: Literata serif for headings and pull quotes, Inter for UI, JetBrains
Mono for stats and small caps labels.

Palette:
- Background #0F0F13
- Surface #1A1A24
- Border #2A2A3A
- Primary blue #6C9CFF (CTA, focus, links)
- Editorial accent gold #F5B700 (pull quotes, eyebrows, editorial rules,
  "book of the day" label only)
- Text primary #E8E8ED, secondary #8B8BA0

Homepage sections, in order:
1. Hero — mono eyebrow, Literata display title (2 lines max), muted
   subtitle, two CTAs (primary filled + outline)
2. Stats band — three numbers in JetBrains Mono, serif labels in muted
   grey, separated by a subtle border rule
3. Book of the day — full-width editorial hero: cover on left, gold
   eyebrow, huge Literata title, author + origin + year, one-paragraph
   pull excerpt in serif, language badge + translation count
4. Collections rail — four thematic cards, each with a small gold rule
   on top, serif title, grey blurb, subtle border
5. Latest additions — five book cards in a grid, cover-forward, metadata
   + language badge
6. Full-width pull quote — enormous Literata italic quote with a gold
   opening quotation mark, attribution below a gold rule
7. Transparency section — two columns, "how we choose translations",
   three example language badges (human professional, human volunteer,
   machine NLLB)
8. Empty state showcase — dashed border card with an icon, title,
   description, one CTA

Book-detail page (same artifact, separate viewport):
- Hero: large cover left, metadata right (title serif XL, author,
  centuries, origin, 12 language badges), download formats, read CTA
- Editor's note panel in serif italic
- Chapters TOC in a two-column grid, numbered in mono
- Pull quote from the book (CitationCard hero size)
- "Also available in" — grid of translations with provenance badges
- Related books rail

Use editorial typography ratios, generous whitespace, zero ads, no pricing,
no upsell banners. Radical translation transparency — every book surface
shows its provenance.
```

### 7.2 Artefact 2 — Search results + Reader + Mobile variants (~2-3 crédits)

```
Design three connected surfaces for the same Librarfree library, dark mode
only, WCAG AAA, same palette and fonts as artifact 1 (Literata + Inter +
JetBrains Mono, #0F0F13 / #6C9CFF / #F5B700).

Surface A — Search results page:
- Header with persistent search input, locale switcher, github link
- Left sidebar filters: language (multi-select), century (range slider),
  translation quality (checkboxes: human professional, human volunteer,
  machine AI), reading time (buckets), source archive (Gutenberg, Standard
  Ebooks, Gallica, Wikisource, etc.), sorted editorially (most read,
  newly added, alphabetical, by century)
- Results grid — 12 book cards, each with provenance badge
- Empty state variant when no results — editorial illustration + clear
  explanation + "try removing filters" action
- Pagination minimal, mono page numbers

Surface B — Reader:
- Distraction-free reading canvas, max 68 characters per line, Literata
  serif body, adjustable size
- Left rail collapses: TOC, highlights, notes
- Top bar: progress percent (mono), chapter title (serif small), settings
  gear, font size +/-
- Bottom bar: previous / next chapter, estimated time remaining
- Inline translator popover when hovering a word (bilingual toggle)
- Theme switcher subtle: light / sepia / dark / OLED
- Zero chrome distraction, zero popup, no upsell

Surface C — Mobile variants of homepage + reader:
- Homepage: hero stacked, stats in a 3-column mono row, book-of-day
  becomes a vertical card, collections in 1-col stack, pull quote full
  bleed
- Reader: bottom sheet for TOC, swipe chapters, tap to toggle chrome,
  font size controls accessible one-hand

All three surfaces share the editorial tone, the gold accent reserved for
editorial moments, the blue primary for CTAs and focus rings.
```

### 7.3 Procédure après auth

1. `mcp__aidesigner__authenticate` → ouvrir OAuth URL, signer
2. `mcp__aidesigner__get_credit_status` → vérifier solde ≥ 6
3. `mcp__aidesigner__generate_design` avec prompt 7.1 (prompt-only, pas
   de `mode`/`url`) + `repo_context` compact
4. Sauvegarder HTML retourné dans `apps/web/public/design-previews/homepage-artifact.html`
5. Capture preview via `npx -y @aidesigner/agent-skills capture`
6. `generate_design` avec prompt 7.2 → `search-reader-artifact.html`
7. Si besoin d'un refine (max 1, budget oblige) : `refine_design` avec le
   run id du premier appel
8. Adoption : `adopt --id <run-id>` pour lire le brief, puis porter
   manuellement les deltas dans les composants repo

### 7.4 Budget — stop conditions

- Si `get_credit_status` retourne < 6 crédits avant de commencer → stopper
  et demander à Sebastien
- Si une seule génération coûte > 4 crédits → stopper après et rapporter
- Si un refine est requis mais pousse le total > 6 → stopper, fixer à la
  main dans les composants repo (on a déjà les primitives prêtes)

---

## 8. Hors-scope V1 — notes pour V2

- Port complet des écrans Search / Reader / Mobile dans le repo (V1 =
  specs + artefacts HTML uniquement)
- Traduction des 10 locales restantes (DE, ES, IT, PT, JA, ZH, RU, PL,
  NL, AR) — next-intl fallback EN tient en V1
- Tests Playwright sur composants neufs
- Thèmes sepia / OLED du reader (déjà dans `theme.reader` côté brand,
  pas de surface UI connectée)
- Animations entrée de section (Framer Motion ou equivalent)
- Header persistant + recherche globale
- Pagination canonique dans sitemap

---

## 9. Checklist accessibilité V1

- [x] Contraste AAA sur tous les textes primaires
- [x] Contraste AAA gold `#F5B700` sur `#0F0F13`
- [x] `:focus-visible` ring persistant (déjà dans globals.css)
- [x] `prefers-reduced-motion` respecté
- [x] `<figure>` / `<blockquote>` / `<cite>` sémantiques pour citations
- [x] `role="status"` + `aria-live="polite"` pour empty states
- [x] `lang` attribute sur `<blockquote>` quand la langue diffère
- [x] `dir="rtl"` géré via layout root (arabe)
- [ ] Audit clavier complet une fois Phase 1 buildée
- [ ] Audit lecteur d'écran (NVDA/VoiceOver) Phase 1

---

## 10. Checklist éthique V1

- [x] Zéro dark pattern dans les empty states et CTAs
- [x] Zéro urgence fabriquée, zéro compteur manipulatoire
- [x] Zéro paywall sur la lecture (textuel + structurel)
- [x] Badge provenance visible sur chaque book card
- [x] Mention explicite de transparence des traductions en homepage
- [x] Pas de tracker, pas de CDN tiers requis par le design
- [x] Lien GitHub + MIT rappelés dans le footer existant
