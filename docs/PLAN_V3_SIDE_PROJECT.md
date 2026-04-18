# Librarfree — Plan V3 : Side Project Éthique

**Date** : 2026-04-18
**Statut** : Source de vérité post-pivot. Remplace les ambitions financières du plan master tout en gardant la vision "bibliothèque publique mondiale".
**Effort** : ~15h/semaine Sebastien + agents IA en levier.

---

## 1. Positionnement (non négociable)

Librarfree est un **side-project** qui doit simultanément :

1. **Faire du bien au monde** — mission éducative, domaine public, accessible partout, 12 langues, aucun paywall sur les livres.
2. **Améliorer la situation financière de Sebastien** sans prétendre la sauver — revenu complémentaire éthique, pas remplacement salaire.
3. **Servir de portfolio / karma** — référence open-source publique, crédibilité technique, potentiellement levier pour d'autres opportunités.

**Ce qu'on n'est PAS** :
- Une startup VC qui cherche un exit
- Un SaaS B2B à scaling agressif
- Une fondation non-profit bénévole
- Un clone légal de Z-Library (on dépasse, on ne copie pas)

---

## 2. Trajectoire revenus réaliste

| Horizon | Cible | Sources dominantes |
|---------|-------|---------------------|
| M6 (Phase 2 terminée) | **€100-300/mo** | Affiliation Amazon/Fnac + donations ponctuelles |
| M12 (Phase 4 terminée) | **€500-1500/mo** | Premium $4.99/mo (~100 users) + affiliation + donations |
| M18-24 (Phase 5-6) | **€2000-4000/mo** | + API B2B modeste + grants ponctuels (NLnet, Mozilla) |

Ces cibles sont **planchers réalistes**, pas objectifs VC. Si ça dépasse tant mieux, mais le projet reste viable à ces niveaux.

### Streams autorisés (tous éthiques)
1. **Affiliation retailers** — Amazon, Fnac, Thalia, Casa del Libro, transparence totale, GeoIP
2. **Premium $4.99/mo ou $39.99/an** — débloque TTS voice premium, bulk download, API key perso, badge supporter. **Jamais** gating des livres.
3. **Donations** — Stripe one-shot + mensuelles, thermomètre Wikipedia-style sans harcèlement
4. **API B2B** — tier payant pour accès haute-fréquence (API CC0 de base reste gratuite)
5. **Grants** — NLnet, Mozilla, Ford, Sloan — appoint non-dilutif, pas dépendance

### Lignes rouges (inchangées)
- ❌ Publicité display même "non-invasive"
- ❌ Vente data user même anonymisée
- ❌ Paywall sur les livres eux-mêmes
- ❌ Dark patterns (forced continuity, misdirection, roach motel)
- ❌ Newsletter unsubscribe caché
- ❌ Corporate Libraries B2B avec SSO SAML enterprise (out of scope side-project)

---

## 3. Scope : ce qu'on garde, ce qu'on promeut, ce qu'on tue

### 3.1 — Tué définitivement (trop coûteux pour le ROI side-project)

| Feature | Raison |
|---------|--------|
| Bibliothèque 3D WebGL Three.js | Effort énorme, impact marginal. 2D suffit. |
| Federation ActivityPub | Protocole complexe, audience réelle <1%. |
| Dream Reader VR/AR | Démo presse sympa, zéro valeur utilisateur réel. |
| Print On Demand couvertures | Logistique + SAV = non-side-project. |
| Corporate Libraries B2B SSO SAML | Cycle vente enterprise incompatible avec 15h/semaine. |
| Patron feature (don fondations auteurs) | Administratif infernal pour impact symbolique. |

### 3.2 — Promu (features cool qu'on garde malgré le pivot)

| Feature | Phase | Raison |
|---------|-------|--------|
| **Socratic Tutor** (fin de chapitre, 3-5 questions IA) | Phase 4 | Signature éducative unique, Ollama local, coût marginal |
| **Reading DNA simple** (profil radar basé temps + annotations) | Phase 4 | Viralité sociale, pgvector déjà dans stack |
| **TTS neural** EN/FR/ES (Piper self-host) | Phase 4 | Accessibilité mal-voyants + apprentissage langues, 3 langues pivot |
| **Parcours d'apprentissage auto-générés** | Phase 5 | Unique différenciateur éducatif |
| **Auto-Anki Export** | Phase 4 | Viralité étudiants, trivial technique |
| **Raspberry Pi Box ISO** | Phase 6 optionnel | Bas effort, énorme symbolique, mirror IPFS+Torrent inclus |
| **Dataset HuggingFace CC0** | Phase 5 | Signal GEO/LLM fort, alignement éthique |
| **Wander mode** (collage flottant serendipity) | Phase 5 | Différenciation UX signature |

### 3.3 — Core Phase 1-3 (inchangé)

Homepage éditoriale + Search Meili + Book Detail + Reader signature typo pro + Auth + Library perso + Annotations + Book clubs + Download multi-format + Send-to-Kindle/Kobo/reMarkable + Version Lite 2G + Affiliation + GDPR/COPPA + SEO pSEO 500K pages + hreflang 12 langues.

---

## 4. Langues : rollout phasé (12 langues maintenues partout)

Non négociable : l'infrastructure i18n supporte les 12 locales dès Phase 1. L'activation UI + contenu curé est phasée :

| Phase | Langues activées | Raison |
|-------|------------------|--------|
| **Phase 1** (S3-6) | **EN, FR** | Gutenberg + Gallica disponibles, marchés affiliation prioritaires |
| **Phase 2** (S7-12) | + **ES, DE, IT, PT** | Marchés affiliation locaux ouverts (Amazon.es/de/it, Fnac.pt) |
| **Phase 3** (S13-20) | + **NL, PL** | Corpus Wolnelektury + DBNL, communautés actives |
| **Phase 4** (S21-28) | + **RU, JA, ZH, AR** | Runeberg/Aozora/Chinese Text Project + Hindawi, complexité RTL+CJK |

**Principe** : Les 12 locales restent accessibles dès Phase 1 via fallback EN, mais le contenu éditorial curé arrive progressivement. hreflang complet dès J1.

---

## 5. Roadmap phasée révisée (side-project rythme)

| Phase | Durée **révisée** | Focus | Livrable |
|-------|-------------------|-------|----------|
| **0 — Fondations** | ✅ 2 semaines | Monorepo + Prisma + Next.js + Gutenberg importer + CI | **TERMINÉE 2026-04-18** |
| **1 — MVP Core EN/FR** | 6 sem → **10 sem** | Homepage UX refondue + Search + Book Detail + Reader signature + SEO + Gutenberg 70K + Gallica seed | 77K livres EN/FR live |
| **2 — Comptes + Download + Affiliation** | 6 sem → **10 sem** | Supabase Auth + library perso + annotations + download multi-format Calibre + Send-to-Kindle + affiliation 6 langues + Version Lite | Premiers revenus €100-300/mo |
| **3 — Multilingue UI + Institutionnel** | 8 sem → **12 sem** | UI 6 langues + Mode Dyslexie + Traduction hover + HTML snapshots failover + partenariats signés (IA + Wikimedia + Open Library) | 200K livres, 6 langues UI |
| **4 — IA éducative + Premium + Accessibilité** | 8 sem → **12 sem** | Embeddings pgvector + Socratic Tutor + Reading DNA + Auto-Anki + TTS Piper 3 langues + Stripe premium + donations + Mode Dyslexie + 4 langues de plus (RU/JA/ZH/AR) | Premium live + features signatures, €500-1500/mo |
| **5 — Scale + Communauté + API** | 12 sem → **16 sem** | Parcours apprentissage auto + API CC0 GraphQL + Scholar Program + Curator + Translation Volunteers + pSEO 500K pages + Dataset HuggingFace + Wander mode | 400K livres, communauté active |
| **6 — Mouvement** | 12 sem → **16 sem** | IPFS + Torrent mensuel + Raspberry Pi Box + Graphe prérequis + Scholar Badges + candidature UNESCO + Carbon dashboard + dream-mode | Librarfree = référence mondiale |

**Durée totale indicative** : ~14 mois au lieu de 10, pour absorber le rythme 15h/semaine.

---

## 6. UX : refonte en cours (aidesigner)

Un agent aidesigner est en cours (background) pour :
1. Audit textuel Z-Library (ce qu'ils font mal, à éviter)
2. 2 artefacts AIDesigner denses : homepage + fiche livre ; search + reader + mobile
3. Composants signature `citation-card` et `empty-state`
4. Port homepage dans `apps/web/app/[locale]/page.tsx`
5. Spec complète dans `docs/UX_REDESIGN_V1.md`

Références de vibe : **NYT Interactive**, **Rijksmuseum**, **Every.to**, **Readwise Daily**. Pas SaaS corpo.

Token accent ajouté : `--color-accent: #F5B700` (à côté du `primary #6C9CFF`) pour highlights éditoriaux.

---

## 7. Ce qui reste valide du plan master

- Stack technique (Next.js 15 + Prisma 6 + Supabase + Meilisearch + R2 + pgvector + Ollama + Stripe)
- Manifeste produit (7 principes)
- Architecture antifragile (IPFS + Torrent + snapshots)
- Audit schema.sql (bugs fixés en Phase 0)
- Brand tokens + typographie (Literata + Inter + JetBrains Mono)
- Sources domaine public par langue
- Métriques d'impact (livres terminés, pas vanity)
- Growth éthique (Show HN, Product Hunt, Reddit légal framing, UNESCO Memory of the World)

---

## 8. Ce qu'on abandonne du plan master

- Ambition €3000/mo net dès M12 → remplacée par €500-1500/mo réaliste
- €15k+/mo M24 → remplacée par €2-4k/mo réaliste
- "Je vis de Librarfree à temps plein dès M12" → jamais
- 15+ langues → 12 (déjà ambitieux)
- Rythme sprints 7 jours → rythme soutenable 2 semaines/sprint
- Corporate B2B + POD + Patron + VR/AR + ActivityPub + 3D WebGL
