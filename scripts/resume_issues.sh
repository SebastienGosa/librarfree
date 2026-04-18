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
"6" "a11y" "Phase 6 — Mouvement"

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
