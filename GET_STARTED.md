# 🚀 Librarfree – Get Started

Bienvenue ! Ce dossier contient **le projet complet** de la mégabibliothèque légale.

## 📖 Documentation essentielle

1. **`PLAN_MAITRE_LIBRARFREE.md`** → **LIRE EN PREMIER**  
   Plan opérationnel complet : vision, architecture, roadmap 24 mois, budget, sources, traductions, affiliation.

2. **`AFFILIATE_RETAILERS_CONFIG.md`** → Configuration affiliation multilingue  
   Tous les retailers par langue (Amazon, Fnac, Thalia, etc.) + code SQL + API.

3. **`database/schema.sql`** → Schéma base de données complet  
   12 tables, indexes, pgvector, views, fonctions PostgreSQL.

4. **`docs/IMPORTS_PLAN.md`** → Guide d'import des sources livres  
   Order recommandé : PG → Standard Ebooks → Gallica → Wikisource → etc.

5. **`DEVELOPMENT.md`** → Guide technique complet  
   Setup, commands, debugging, structure du code.

6. **`CONTRIBUTING.md`** → Comment contribuer  
   Code style, commit messages, ajout sources/translations/retailers.

## ⚡ Quick Start (5 minutes)

```bash
# 1. Setup environnement
./scripts/setup_dev.sh

# 2. Démarrer Docker (Postgres + Meilisearch)
docker-compose up -d

# 3. Installer dépendances
pnpm install

# 4. Lancer dev (2 terminaux)
pnpm --filter web dev  # http://localhost:3000
pnpm --filter api dev  # http://localhost:3333

# 5. Premier import (test)
pnpm --filter workers run import-gutenberg --limit 1000
```

## 📂 Structure du projet

```
librarfree/
├── 📄 PLAN_MAITRE_LIBRARFREE.md     ← START HERE
├── 📄 AFFILIATE_RETAILERS_CONFIG.md
├── 📄 README.md
├── 📄 DEVELOPMENT.md
├── 📄 CONTRIBUTING.md
├── 📄 LICENSE (MIT)
├── 📄 .env.example
├── 📄 docker-compose.yml
├── 📄 package.json
├── 📁 database/
│   └── 📄 schema.sql
├── 📁 scripts/
│   └── 📄 setup_dev.sh
├── 📁 docs/
│   └── 📄 IMPORTS_PLAN.md
├── 📁 apps/          (à développer)
│   ├── web/          (Next.js frontend)
│   └── api/          (tRPC backend)
├── 📁 packages/      (à développer)
│   ├── db/
│   ├── ui/
│   └── utils/
└── 📁 workers/       (à développer)
    ├── importers/
    ├── translators/
    ├── embedders/
    └── isbn-lookup/
```

## 🎯 Prochaines étapes

### Phase 1 – Setup (Aujourd'hui)
- [x] Tous les fichiers sont dans ce dossier `librarfree/`
- [ ] Lancer `./scripts/setup_dev.sh`
- [ ] Créer repo GitHub et pousser
- [ ] Obtenir clés API (Amazon PAAPI, etc.)

### Phase 2 – Import (Semaine 1)
- [ ] Importer Project Gutenberg (70K EN)
- [ ] Importer Standard Ebooks (7K EN quality)
- [ ] Vérifier imports

### Phase 3 – Dev Frontend (Semaines 2-4)
- [ ] Créer Next.js app dans `apps/web/`
- [ ] Implémenter homepage + search
- [ ] Book reader (mobile-first)
- [ ] Meilisearch integration

### Phase 4 – Multilingue (Mois 2-3)
- [ ] Gallica (FR)
- [ ] Projekt Gutenberg-DE
- [ ] Biblioteca Virtual (ES)
- [ ] Affiliation retailers FR/DE/ES

## 🆘 Aide

- **Questions** : Voir `DEVELOPMENT.md`
- **Bug** : Ouvrir issue sur GitHub
- **Contribution** : Lire `CONTRIBUTING.md`
- **Communauté** : Discord (à venir)

---

**"La connaissance doit être libre."** – Librarfree Team 📚
