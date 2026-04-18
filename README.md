# Librarfree – Mégabibliothèque Légale & Gratuite

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Status: In Development](https://img.shields.io/badge/status-alpha-orange)]()

> **"Tous les livres du domaine public, enfin accessibles."**

Librarfree est une plateforme open-source visant à devenir **la plus grande bibliothèque numérique légale et gratuite au monde**. Elle agrège l'ensemble du domaine public et des ressources open-source avec une expérience utilisateur moderne, multilingue, et des fonctionnalités avancées.

---

## 📋 Table des matières

- [Vision & Concept](#-vision--concept)
- [État du projet](#-état-du-projet)
- [Stack technique](#-stack-technique)
- [Sources de contenu](#-sources-de-contenu)
- [Traductions & Affiliation](#-traductions--affiliation)
- [Installation & Démarrage](#-installation--démarrage)
- [Roadmap](#-roadmap)
- [Contribuer](#-contribuer)
- [License](#-license)

---

## 🌟 Vision & Concept

### Mission
Créer une bibliothèque universelle, gratuite et légale, accessible à tous, partout, dans toutes les langues.

### Différenciation
- ✅ **100% légal** : Uniquement domaine public + open-source
- ✅ **Multilingue natif** : 15+ langues dès le départ
- ✅ **UX premium** : Mobile-first, design élégant, rapide
- ✅ **IA responsable** : Traductions automatiques UNIQUEMENT si pas de traduction PD existante
- ✅ **Transparence** : Toutes les sources documentées, licences claires
- ✅ **Open-source** : Code 100% open, MIT licence

### Business model éthique
- 📖 **Gratuit pour tous** –aucune restriction d'accès
- 💰 **Revenus** via affiliation (Amazon, retailers locaux), dons, et premium IA
- 🎯 **Pas de pubs intrusives** –ads discrètes seulement

---

## 🚀 État du projet

### Phase actuelle : **Phase 0 – Préparation**
**Statut** : En construction (avril 2026)

- [x] Plan d'action complet rédigé
- [x] Recherche sources légales exhaustive
- [x] Architecture BDD définie
- [x] Stratégie traductions et affiliation validée
- [ ] Setup infrastructure dev (en cours)
- [ ] Import Project Gutenberg (70K EN)
- [ ] MVP frontend (à faire)

**Prochain jalon** : MVP fonctionnel avec 70K livres EN + search + reader (Mois 3)

---

## 🛠 Stack technique

### Frontend
- **Framework** : Next.js 14+ (App Router) – TypeScript
- **UI** : Tailwind CSS + shadcn/ui (design system)
- **Animations** : Framer Motion
- **i18n** : next-intl (FR/NL/EN → extensible)
- **PWA** : next-pwa pour offline reading

### Backend & Data
- **API** : tRPC (full typesafe)
- **Base** : Supabase PostgreSQL (+ pgvector pour embeddings)
- **Search** : Meilisearch (full-text) + pgvector (sémantique)
- **Auth** : Supabase Auth (email + OAuth)
- **Cache** : Redis (Upstash) ou in-app

### Infrastructure
- **Hosting** : Hetzner VPS (low-cost, performant)
- **CDN** : Cloudflare (global, gratuit)
- **Storage** : Cloudflare R2 (S3-compatible, pas d'egress fees)
- **CI/CD** : GitHub Actions
- **Monitoring** : UptimeRobot, Sentry, PostHog (self-hosted)

### IA & Enrichissement
- **Embeddings** : Ollama + nomic-embed-text (local)
- **Résumés** : Llama 3.2 3B (via Ollama)
- **Traductions fallback** : NLLB-200 (Meta) UNIQUEMENT si pas de traduction PD
- **Audio** : Coqui TTS (génération audiobooks)
- **Images** : Stable Diffusion XL (couvertures auto)

---

## 📚 Sources de contenu

### Sources légales confirmées (bulk access)

| Source | Langues | Volume | Méthode d'accès | Priorité |
|--------|---------|--------|-----------------|----------|
| Project Gutenberg | EN, FR, DE, ES, etc. | ~70K | rsync / HTTP download | 🟢 IMMÉDIATE |
| Standard Ebooks | EN, FR, DE, IT, ES | ~7K | GitHub clone | 🟢 IMMÉDIATE |
| Wikisource | 71 langues | ~180K | Database dumps | 🟢 PHASE 2 |
| Internet Archive | 400+ | ~1M+ | API / S3 | 🟢 PHASE 2 |
| Gallica (BnF) | FR | ~50K | OAI-PMH | 🟢 PHASE 2 |
| Projekt Gutenberg-DE | DE | ~20K | HTTP mirror | 🟢 PHASE 2 |
| Aozora Bunko | JA | ~15K | ZIP download | 🟡 PHASE 3 |
| Wolne Lektury | PL | ~6K | Direct download | 🟡 PHASE 3 |
| Biblioteca Virtual Cervantes | ES | ~15K | Scraping autorisé | 🟢 PHASE 2 |
| Lib.ru | RU | ~12K | FTP public | 🟡 PHASE 3 |
| Project Runeberg | SV, NO, DA, FI | ~10K | HTTP | 🟡 PHASE 3 |

**Total estimé** : **500,000+ livres** en phase complète

---

## 🌐 Traductions & Affiliation intelligente

### Priorisation traductions (RÈGLE D'OR)

```
Traduction PD existante ? → OUI = Priorité ABSOLUE
                              NON = Fallback IA (NLLB) UNIQUEMENT
```

- ✅ **Priorité 1** : Éditions existantes (Standard Ebooks, Wikisource, Gallica, etc.)
- ⚠️ **Priorité 2** : Traduction IA UNIQUEMENT si aucune traduction PD
- ❌ Jamais remplacer une trad humaine par IA
- 🔖 Marquage clair : "⚠️ Traduction automatique" pour les livres IA

### Affiliation par langue

Chaque traduction a ses propres liens d'affiliation **spécifiques à sa langue** :

- **EN** : Amazon US/UK/CA/AU + Barnes & Noble + Kobo
- **FR** : Amazon FR + Fnac + Cultura + Decitre
- **DE** : Amazon DE + Thalia + Weltbild
- **ES** : Amazon ES + Casa del Libro
- **IT** : Amazon IT + IBS.it + Feltrinelli
- **JA** : Amazon JP + Rakuten Books + BookWalker
- **PT** : Amazon BR + Saraiva
- **NL** : Bol.com + Amazon NL
- **PL** : Empik + Amazon PL
- **RU** : Ozon.ru + Amazon RU
- **AR** : Neelwafurat + Jamalon + Amazon AE

**Détection géo automatique** : Priorise les retailers locaux du pays de l'utilisateur

---

## 📁 Structure du projet

```
librarfree/
├── apps/
│   ├── web/                    # Next.js frontend (App Router)
│   │   ├── app/(lang)/         # Pages i18n
│   │   ├── components/         # UI components
│   │   └── lib/               # Utilities
│   └── api/                   # tRPC backend (co-located)
├── packages/
│   ├── db/                    # Database schema + migrations
│   ├── ui/                    # Shared UI components (shadcn)
│   └── utils/                 # Shared utilities
├── workers/
│   ├── importers/             # Scrapers/importers (PG, IA, etc.)
│   ├── translators/           # NLLB translation service
│   ├── embedders/             # Ollama embedding generation
│   └── isbn-lookup/           # ISBN enrichment workers
├── docker/
│   ├── docker-compose.yml     # Local dev environment
│   ├── postgres/              # PostgreSQL config
│   └── meilisearch/           # Search config
├── docs/
│   ├── PLAN_MAITRE_LIBRARFREE.md      # Ce document
│   ├── AFFILIATE_RETAILERS_CONFIG.md  # Config affiliation
│   └── API.md                           # API documentation
├── scripts/
│   ├── import_gutenberg.sh            # Bulk import script
│   ├── import_wikisource.py           # Wiki import
│   ├── generate_embeddings.py          # Embeddings IA
│   └── setup_initial_data.sql          # DB seeding
└── README.md
```

---

## 🚦 Installation & Démarrage

### Prérequis
- Node.js 18+
- PostgreSQL 14+ (ou Supabase)
- Docker & Docker Compose (optionnel mais recommandé)
- Git

### 1. Cloner le dépôt

```bash
git clone https://github.com/SebastienGosa/librarfree.git
cd librarfree
```

### 2. Installer les dépendances

```bash
# Installer toutes les apps/workspaces
pnpm install

# Ou yarn
yarn install
```

### 3. Configuration environnement

```bash
# Copier .env.example vers .env.local
cp .env.example .env.local

# Éditer .env.local avec vos clés:
# - DATABASE_URL=postgresql://...
# - SUPABASE_URL=...
# - SUPABASE_ANON_KEY=...
# - MEILISEARCH_HOST=http://localhost:7700
# - OLLAMA_BASE_URL=http://localhost:11434
# - AMAZON_PAAPI_ACCESS_KEY=...
# - AMAZON_PAAPI_SECRET_KEY=...
```

### 4. Setup base de données

```bash
# Option A: Avec Docker (recommande)
docker-compose up -d postgres meilisearch redis

# Option B: Supabase cloud (géré)
# Créer projet sur supabase.com, récupérer connection string

# Appliquer schéma
psql $DATABASE_URL -f database/schema.sql

# Charger données initiales (auteurs exemples)
psql $DATABASE_URL -f scripts/setup_initial_data.sql
```

### 5. Lancer le développement

```bash
# Terminal 1: Base de données + services
docker-compose up -d

# Terminal 2: Backend API (tRPC)
pnpm --filter api dev

# Terminal 3: Frontend Next.js
pnpm --filter web dev
```

Accès :
- Frontend : http://localhost:3000
- API : http://localhost:3333
- Meilisearch : http://localhost:7700
- pgAdmin : http://localhost:5050 (optionnel)

### 6. Premier import (Project Gutenberg)

```bash
# Import complet PG (70K livres) – peut prendre plusieurs heures
pnpm --filter workers run import-gutenberg --full

# Import partiel (test 1000 livres)
pnpm --filter workers run import-gutenberg --limit 1000

# Vérifier import
psql $DATABASE_URL -c "SELECT COUNT(*) FROM books;"
```

### 7. Générer embeddings (IA)

```bash
# Démarrer Ollama local
docker run -d -p 11434:11434 ollama/ollama
ollama pull nomic-embed-text

# Générer embeddings pour tous les livres (batch)
pnpm --filter workers run generate-embeddings --batch-size 100
```

### 8. Lancer en production

```bash
# Build
pnpm --filter web build
pnpm --filter api build

# Déployer sur Vercel/Railway (recommandé)
# Voir docs/deployment.md pour instructions détaillées
```

---

## 🗺 Roadmap

### Phase 0 – Préparation (Mois 1-2) ✅ En cours
- [x] Plan d'action complet
- [x] Architecture BDD
- [x] Research sources légales
- [ ] Infrastructure dev setup
- [ ] Import PG core (70K EN)
- [ ] MVP frontend (home, search, reader)

### Phase 1 – MVP (Mois 3-4)
- [ ] Core fonctionnel : search + reader + mobile
- [ ] 70K livres EN + 7K Standard Ebooks
- [ ] SEO base (sitemap, meta)
- [ ] Legal pages (terms, privacy)
- [ ] Beta interne (friends & family)

### Phase 2 – Multilingue & IA (Mois 5-8)
- [ ] FR : Gallica + Wikisource FR + affiliation Fnac
- [ ] DE : Projekt Gutenberg-DE + Runeberg + Thalia
- [ ] ES : Biblioteca Virtual + affiliation Casa del Libro
- [ ] IT/Libraries italiennes
- [ ] JA : Aozora Bunko + Amazon JP
- [ ] Embeddings vectoriels + search sémantique
- [ ] Résumés automatiques (Llama)
- [ ] User accounts (optionnel)

### Phase 3 – Scale & Growth (Mois 9-18)
- [ ] RU/PL/Nordic languages
- [ ] Audiobooks générés (Coqui TTS)
- [ ] Traductions automatiques (NLLB fallback)
- [ ] Freemium model (€4.99/mois)
- [ ] Affiliation 15+ retailers
- [ ] Marketing / SEO massif (25K pages)
- [ ] Mobile app (React Native PWA)
- [ ] API publique (REST + GraphQL)
- [ ] Scaling infrastructure (1M+ visites/mois)

### Phase 4 – Maturité (Mois 19-24)
- [ ] 500K+ livres, 15+ langues
- [ ] Community features (annotations, book clubs)
- [ ] Partnerships bibliothèques (B2B)
- [ ] Revenus stables €10K–50K/mois
- [ ] Statut "référence mondiale domaine public"

---

## 🤝 Contribuer

Nous accueillons les contributions ! 🎉

### Comment contribuer
1. **Fork** le dépôt
2. **Crée une branche** (`git checkout -b feature/amazing-feature`)
3. **Commit** tes changements (`git commit -m 'Add amazing feature'`)
4. **Push** (`git push origin feature/amazing-feature`)
5. **Open a Pull Request**

### Besoins urgents
- 🐛 **Scrapers** : Implémenter scraper pour Gallica, Biblioteca Virtual, Aozora Bunko
- 🌐 **Traductions UI** : Aider à traduire l'interface dans nouvelles langues
- 📖 **Curation** : Identifier livres PD manquants, vérifier qualité
- 🎨 **Design** : Améliorer UI/UX, particularly mobile
- 🔍 **SEO** : Optimiser pages, structurer sitemaps
- 📝 **Documentation** : Améliorer docs, guides contributeurs

[Voir CONTRIBUTING.md pour guidelines détaillées]

---

## 📄 License

Ce projet est sous licence **MIT** – voir [LICENSE](LICENSE) pour détails.

**Exceptions** :
- Le contenu des livres (textes) est domaine public ou CC0 – respecter les licences originales des sources
- Le code de Librarfree est libre et open-source
- Les marques des retailers (Amazon, Fnac, etc.) sont propriété de leurs détenteurs respectifs

---

## 🙏 Remerciements

- **Project Gutenberg** – inspiration et contenu fondateur
- **Standard Ebooks** – qualité d'édition exemplaire
- **Wikisource** – multilingue communautaire
- **Internet Archive** – archive massive
- **Meta (NLLB)** – traduction open-source
- **Ollama** – IA locale accessible
- **Supabase** – backend modern & open
- **Meilisearch** – search lightning fast

---

## 📞 Contact & Community

- **Site web** : https://librarfree.com (à venir)
- **Discord** : [Lien à venir]
- **Telegram** : @librarfree
- **Email** : hello@librarfree.com
- **GitHub** : https://github.com/SebastienGosa/librarfree

---

**"La connaissance doit être libre. Les livres appartiennent à l'humanité."**

Built with ❤️ and ☕ by Sebastien Gosa and contributors worldwide.
