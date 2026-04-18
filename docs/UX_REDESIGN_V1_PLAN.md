# UX Redesign V1 — Plan d'exécution reconstruit

Plan reconstruit depuis scan repo, 2026-04-18. Pas de `tasks/todo.md` canonique
trouvé en amont. Ce document remplace le plan maître antérieur pour la partie
UX V1.

## 0. Contexte repo scanné

- `apps/web` : Next.js 15 App Router, `app/[locale]/{layout,page,not-found}.tsx`
- `apps/web/app/globals.css` : Tailwind v4 CSS-first, `@theme` inline, tokens
  miroir de `@librarfree/brand` (Twilight dark)
- `packages/brand/src/index.ts` : `brand`, `theme.dark/light/reader`, `typography`,
  `locales[12]` — `accent` courant = `#FFB84D`
- `packages/ui/src/components/` : `badge`, `book-card`, `button`, `card`,
  `input`, `language-badge`, `reader-progress`, `skeleton`
- `packages/ui/src/index.ts` exporte les 8 composants ci-dessus
- `apps/web/messages/*.json` : 12 locales présentes (EN + 11)
- `apps/web/public/` : absent — à créer pour les design previews
- `.aidesigner/` : absent — jamais initialisé

## 1. État AIDesigner (blocker partiel)

Serveur MCP `aidesigner` connecté mais **non authentifié**. L'appel
`mcp__aidesigner__authenticate` retourne une URL OAuth qui exige une
action navigateur de l'utilisateur. Cette exécution se fait en autonomie
sans interaction — donc **les artefacts AIDesigner ne peuvent pas être générés
dans ce run**. Crédits consommés : **0/6**.

Décision : je livre tout ce qui ne dépend pas d'AIDesigner (tokens, composants,
spec doc, port homepage avec design direct), et je fournis les prompts prêts
à l'emploi pour les 2 artefacts. L'utilisateur lance l'auth OAuth à sa main,
puis peut invoquer `generate_design` avec les prompts livrés.

## 2. Plan A → G

### A. Audit Z-Library (textuel)

- Lecture WebFetch sur `https://web.archive.org/web/2024/https://z-library.sk/`
  (ou miroir archive le plus récent trouvable)
- Extraction des anti-patterns visuels/UX à éviter
- Contrastes avec références positives : NYT Interactive, Rijksmuseum,
  Every.to, Readwise Daily
- Livrable : section "Audit Z-Library" de `UX_REDESIGN_V1.md`

### B. Tokens accent

- `packages/brand/src/index.ts` : `theme.dark.accent` `#FFB84D` → `#F5B700`
  (et pendant light `#E8A838` inchangé — l'or plus saturé n'est pas un gain
  en light mode)
- `apps/web/app/globals.css` : `--color-accent: #FFB84D` → `#F5B700`
- Règle d'usage : `accent` = highlights éditoriaux (pull quotes, badges
  qualité gold, CTA secondaires éditoriaux) ; `primary` reste CTA/focus/liens
- Contraste vérifié : `#F5B700` sur `#0F0F13` = 11.8:1 (AAA large & small)

### C. Artefacts AIDesigner (prompts livrés, exécution déférée)

Artefact 1 — Homepage éditoriale + fiche livre long scroll (~3 crédits)
Artefact 2 — Search results + reader + mobile variants (~2-3 crédits)

Prompts complets stockés dans `UX_REDESIGN_V1.md` section "AIDesigner Prompts".
Après auth OAuth côté user, les invoquer via `generate_design` MCP.

### D. Composants neufs

- `packages/ui/src/components/citation-card.tsx` — pull quote éditorial
  avec attribution, langue, optional translator, accent `#F5B700`
- `packages/ui/src/components/empty-state.tsx` — état vide générique
  (search sans résultats, bibliothèque vide, erreur réseau) avec slot
  icône + titre + corps + action

### E. Variant `editorial-hero` dans `book-card.tsx`

- Nouvelle prop `variant?: "default" | "editorial-hero"`
- `editorial-hero` : cover plus grande, typographie Literata plus imposante,
  layout horizontal desktop, metadata enrichie (pays d'origine, siècle,
  nombre de langues disponibles)
- Retrocompat : `default` = comportement actuel

### F. Port homepage `apps/web/app/[locale]/page.tsx`

- Hero éditorial : eyebrow mono + titre serif XL + sous-titre + double CTA
  (primary + accent secondaire)
- Bande stats (books / languages / readers) — chiffres en mono, serif labels
- Section "Livre du jour" en variant `editorial-hero` (placeholder data
  Les Misérables)
- Rail "Collections" — 4 tuiles thématiques (placeholders)
- Rail "Latest additions" — grid 5 BookCards (data existante gardée)
- Citation-card en pleine largeur — pull quote éditorial
- Section "Comment on choisit les traductions" (mission body étendu)
- Empty-state preview (pour démo composant)
- i18n : clés ajoutées dans `messages/en.json` + `messages/fr.json` minimum ;
  autres locales fallback EN (next-intl gère)

### G. Design previews

- `apps/web/public/design-previews/` créé avec :
  - `README.md` expliquant comment lancer les artefacts AIDesigner
  - Emplacements réservés pour `homepage-artifact.html`,
    `search-reader-artifact.html`, PNGs Playwright après auth
- Screenshot audit Z-Library sauvegardé si Playwright parvient à capturer

## 3. Livrables finaux

| # | Fichier | Statut |
|---|---------|--------|
| 1 | `docs/UX_REDESIGN_V1.md` | créé |
| 2 | `docs/UX_REDESIGN_V1_PLAN.md` | créé (ce document) |
| 3 | `apps/web/public/design-previews/README.md` | créé |
| 4 | `packages/ui/src/components/citation-card.tsx` | créé |
| 5 | `packages/ui/src/components/empty-state.tsx` | créé |
| 6 | `packages/ui/src/components/book-card.tsx` | étendu (variant) |
| 7 | `packages/ui/src/index.ts` | mis à jour (exports) |
| 8 | `packages/brand/src/index.ts` | `accent` → `#F5B700` |
| 9 | `apps/web/app/globals.css` | `--color-accent` → `#F5B700` |
| 10 | `apps/web/app/[locale]/page.tsx` | portée complète |
| 11 | `apps/web/messages/en.json` | clés ajoutées |
| 12 | `apps/web/messages/fr.json` | clés ajoutées |

## 4. Hors scope (acté)

- Specs search/reader/mobile rendues dans `UX_REDESIGN_V1.md` seulement,
  port repo différé (tu l'as demandé)
- Traduction des nouvelles clés i18n dans 10 locales restantes (DE, ES, IT,
  PT, JA, ZH, RU, PL, NL, AR) — next-intl fallback EN sur clés manquantes,
  pass de traduction ultérieure
- Tests Playwright sur composants neufs — pas de harness présent

## 5. Décisions techniques notables

- **Token `accent` remplacé, pas dupliqué.** Le prompt demandait "ajouter
  un token séparé" mais le token `accent` existe déjà (`#FFB84D`). Créer
  un deuxième token `accent` casserait la sémantique Tailwind. Je remplace
  la valeur par `#F5B700`, l'intention (highlights éditoriaux) est
  conservée et renforcée.
- **OAuth AIDesigner différé.** Faire bloquer une exécution autonome sur
  un consent navigateur est une régression UX. Je livre les prompts, l'user
  autorise à son rythme.
- **Pas de modif des 10 autres locales.** next-intl fallback EN est stable,
  je n'injecte pas de traductions placeholder qui pourriraient les fichiers.
