# Plan d'import des sources – Ordre recommandé

## Phase 1: Core Anglophone (semaines 1-2)

### Project Gutenberg (70K+ livres)
- **Méthode**: rsync miroir officiel
- Commande: `rsync -avz rsync://mirrors.ibiblio.org/pub/archives/gutenberg/ /data/gutenberg/`
- Durée: 2-3h | Espace: ~40GB total
- Script: `scripts/import_gutenberg.sh` (à créer)

### Standard Ebooks (7K livres haute qualité)
- Méthode: Git clone
- `git clone https://github.com/standardebooks/standardebooks.git`
- Éditions soignées, priorité qualité absolue

---

## Phase 2: Multilingue (semaines 3-8)

### Français (FR) – ~25K livres
1. **Gallica (BnF)** – ~50K – OAI-PMH harvester
2. **Wikisource FR** – ~18K – Dumps Wikimedia
3. **Feedbooks FR** – ~2K – API

### Allemand (DE) – ~20K
1. **Projekt Gutenberg-DE** – ~13K – Mirror Spiegel
2. **Project Runeberg** – ~7K – Bulk download

### Espagnol (ES) – ~15K
1. **Biblioteca Virtual Cervantes**
2. **Wikisource ES**

---

## Contrôle qualité par langue

Avant "go live":
- [ ] Sources PD vérifiées
- [ ] Import 100% terminé
- [ ] Deduplication
- [ ] Métadonnées complètes
- [ ] Nettoyage encoding UTF-8
- [ ] Index search (Meilisearch)
- [ ] Affiliation configurée (3+ retailers)
- [ ] ISBN lookup 70%+
- [ ] Fallback traduction IA fonctionnel
- [ ] UI traduite (next-intl)

Voir PLAN_MAITRE_LIBRARFREE.md pour spécifications complètes.
