# **PLAN MAÎTRE OPÉRATIONNEL – MÉGABIBLIOTHÈQUE LÉGALE MULTILINGUE**
## **Projet : "Big Big Truc" (Librarfree.com)**
*Document intégré : Sources + Traductions + Affiliation + Architecture*

---

## **SECTION 1 – PRIORITISATION DES TRADUCTIONS (RÈGLE D'OR)**

### **1.1 Philosophie : Qualité d'abord**

**Principe** :
- ✅ **PRIORITÉ 1** : Utiliser les vraies traductions existantes (éditeurs, traducteurs reconnus, domaine public traditionnel)
- ⚠️ **PRIORITÉ 2** : UNIQUEMENT si aucune traduction PD authentique n'existe → génération IA (avec marquage clair "Traduction automatique")
- ❌ **INTERDIT** : Remplacer une traduction humaine de qualité par une traduction IA

### **1.2 Sources de traductions authentiques à prioriser**

| Source | Langues | Type | Qualité | Priorité |
|--------|---------|------|---------|----------|
| **Standard Ebooks** | EN, FR, DE, IT, ES | Éditions PD soignées | ★★★★★ | 1 |
| **Wikisource traductions** | 70+ langues | Traductions PD vérifiées | ★★★★☆ | 1 |
| **Gallica (BnF)** | FR | Éditions originales françaises | ★★★★★ | 1 |
| **Project Gutenberg Hispano** | ES | Traductions espagnoles PD | ★★★★☆ | 1 |
| **Projekt Gutenberg-DE** | DE | Éditions allemandes | ★★★★★ | 1 |
| **Biblioteca Virtual Cervantes** | ES | Éditions espagnoles | ★★★★★ | 1 |
| **Aozora Bunko** | JA | Éditions japonaises | ★★★★★ | 1 |
| **Wolne Lektury** | PL | Éditions polonaises | ★★★★★ | 1 |
| **Project Runeberg** | SV, NO, DA, FI | Éditions nordiques | ★★★★☆ | 1 |
| **Lib.ru** | RU | Éditions russes | ★★★★☆ | 1 |
| **Feedbooks (section PD)** | FR, DE, ES | Éditions multilingues | ★★★★☆ | 1 |
| **Internet Archive (PD scans)** | Multi | Scans d'éditions originales | ★★★★★ | 1 |

### **1.3 Arbre de décision pour les traductions**

```
[Livre détecté]
     ↓
[Traduction PD existante ?]
     ├─ OUI → Priorité absolue
     │   ├─ Multiple versions ?
     │   │   ├─ Meilleure qualité (éditeur reconnu) → Choisir celle-ci
     │   │   └─ Plus récente (révision) → Choisir la plus récente
     │   └─ Stocker métadonnées : translator_name, publisher, year
     │
     └─ NON → Traduction IA automatique
         ├─ Modèle : NLLB-200 (Meta) ou M2M100
         ├─ Marquage obligatoire : "⚠️ Traduction automatique (IA)"
         ├─ Tag dans BDD : is_machine_translated = true
         ├─ Prévenir l'utilisateur avant lecture
         └─ Stocker langue source originale
```

### **1.4 Métadonnées obligatoires par traduction**

```sql
CREATE TABLE book_translations (
    id SERIAL PRIMARY KEY,
    book_id INTEGER REFERENCES books(id),
    language_code VARCHAR(10) NOT NULL,
    is_machine_translated BOOLEAN DEFAULT FALSE,
    translation_quality ENUM('human_professional', 'human_volunteer', 'machine_nllb', 'machine_m2m100'),
    translator_name VARCHAR(255),
    publisher VARCHAR(255),
    publication_year INTEGER,
    source_project VARCHAR(100),
    source_identifier VARCHAR(255),
    content TEXT NOT NULL,
    metadata JSONB,
    created_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(book_id, language_code)
);
```

---

## **SECTION 2 – AFFILIATION MULTILINGUE INTELLIGENTE**

### **2.1 Principe d'affiliation dynamique**

**Règle** : L'affiliation doit être **spécifique à la langue de la traduction**.
Exemple : Un livre en 10 langues → 10 liens différents selon la langue sélectionnée.

### **2.2 Tableau d'affiliation par langue**

| Langue | Amazon | Autres retailers | Programmes recommandés |
|--------|---------|------------------|----------------------|
| EN | .com .co.uk .ca .au | Barnes & Noble, Kobo | Amazon Associates US/UK/CA/AU |
| FR | .fr | Fnac, Cultura, Decitre | Amazon FR + affiliations FR locales |
| DE | .de | Thalia.de, Weltbild.de, Hugendubel | Amazon DE |
| ES | .es | Casa del Libro, El Corte Inglés | Amazon ES |
| IT | .it | IBS.it, Feltrinelli, Mondadori | Amazon IT |
| PT | .br | Saraiva, Submarino | Amazon BR |
| JA | .co.jp | Rakuten Books, BookWalker | Amazon JP |
| ZH | .cn | Dangdang, JD.com | Amazon CN ou alternatives |
| NL | .nl | Bol.com, Proefschriften | Amazon NL + Bol.com |
| PL | .pl | Empik, Książka i Wiedza | Amazon PL |
| RU | .ru | Ozon.ru, Labirint.ru | Amazon RU ou locaux |
| AR | .ae | Neelwafurat.com (MENA) | Amazon AE |

### **2.3 Architecture d'affiliation dynamique**

```sql
CREATE TABLE affiliate_retailers (
    id SERIAL PRIMARY KEY,
    language_code VARCHAR(10) NOT NULL,
    retailer_name VARCHAR(100) NOT NULL,
    retailer_type ENUM('amazon', 'local', 'specialized'),
    country_code VARCHAR(10),
    affiliate_tag VARCHAR(255) NOT NULL,
    url_template TEXT NOT NULL,
    active BOOLEAN DEFAULT TRUE,
    priority INTEGER DEFAULT 1,
    commission_rate DECIMAL(5,2),
    created_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(language_code, retailer_name)
);
```

### **2.4 Service de génération d'affiliation (tRPC)**

```typescript
// server/api/trpc/affiliate.ts
export const affiliateRouter = router({
  getLinks: protectedProcedure
    .input(z.object({
      bookId: z.number(),
      language: z.string().default('en'),
      country: z.string().optional(),
    }))
    .query(async ({ ctx, input }) => {
      const retailers = await ctx.db.affiliateRetailer.findMany({
        where: {
          languageCode: input.language,
          active: true,
          ...(input.country && { countryCode: input.country })
        },
        orderBy: { priority: 'asc' }
      });
      
      const translation = await ctx.db.bookTranslation.findUnique({
        where: { id: input.bookId },
        select: { isbn: true, isMachineTranslated: true }
      });
      
      const links = retailers.map(retailer => ({
        retailer: retailer.retailerName,
        url: retailer.urlTemplate
          .replace('{isbn}', translation?.isbn || ''),
        type: retailer.retailerType,
      }));
      
      return { links };
    }),
});
```

---

## **SECTION 3 – SOURCES PAR LANGUE (DÉTAILLÉ)**

### **3.1 Priorisation des sources**

| Langue | Source #1 | Source #2 | Source #3 | Estimation | Priorité |
|--------|-----------|-----------|-----------|------------|----------|
| EN | Project Gutenberg | Standard Ebooks | Internet Archive | 70,000+ | 🟢 Immédiate |
| FR | Gallica (BnF) | Wikisource FR | Feedbooks FR | 25,000+ | 🟢 Phase 2 |
| DE | Projekt Gutenberg-DE | Project Runeberg | Spiegel PG | 20,000+ | 🟢 Phase 2 |
| ES | Biblioteca Virtual Cervantes | Wikisource ES | PG Hispano | 15,000+ | 🟢 Phase 2 |
| IT | Liberliber | Progetto Manuzio | Wikisource IT | 8,000+ | 🟡 Phase 3 |
| PT | Projecto Gutenberg PT | Wikisource PT | Brazil PD | 5,000+ | 🟡 Phase 3 |
| JA | Aozora Bunko | Wikisource JA | PD Japanese | 15,000+ | 🟡 Phase 3 |
| ZH | Chinese Text Project | Wikisource ZH | Taiwan PD | 8,000+ | 🟡 Phase 3 |
| RU | Lib.ru | Wikisource RU | PD Russian | 12,000+ | 🟡 Phase 3 |
| PL | Wolne Lektury | Wikisource PL | PD Polish | 6,000+ | 🟡 Phase 3 |
| NL | DBNL | Wikisource NL | PG NL | 4,000+ | 🟡 Phase 3 |
| SV/NO/DA/FI | Project Runeberg | Wikisources nordiques | - | 10,000+ | 🟡 Phase 3 |
| AR | Hindawi | Arabic Wikisource | PD Arab | 3,000+ | 🟠 Phase 4 |
| KO | Korean PD texts | Wikisource KO | - | 2,000+ | 🟠 Phase 4 |

---

## **SECTION 4 – WORKFLOW D'IMPORT COMPLET**

### **4.1 Pipeline automatisé**

```python
# jobs/import_pipeline.py
async def import_book_workflow(raw_book, source_name):
    """
    1. Nettoyage du contenu brut
    2. Détection langue
    3. Vérification traduction PD existante (PRIORITÉ)
    4. Si non → traduction IA (fallback UNIQUEMENT)
    5. Enrichissement ISBN
    6. Génération liens affiliés
    7. Stockage final
    """
    
    # Nettoyage
    cleaned = await ContentCleaner.clean(raw_book)
    
    # Langue
    lang = await LanguageDetector.detect(cleaned.content[:1000])
    
    # VÉRIFIER TRADUCTION PD EXISTANTE (PRIORITÉ #1)
    existing = await TranslationFinder.find_best(
        title=cleaned.title,
        author=cleaned.author,
        language=lang
    )
    
    if existing:
        translation = await import_existing_translation(existing)
        quality = 'human_pd'
    else:
        # FALLBACK IA UNIQUEMENT SI PAS DE TRADUCTION PD
        translation = await NLLBTranslator.translate(
            source=cleaned,
            target_lang=lang,
            source_lang=cleaned.original_language
        )
        quality = 'machine_fallback'
        translation.is_machine_translated = True
    
    # ISBN lookup
    isbns = await ISBNEnricher.enrich(translation)
    
    # Affiliation
    affiliate_links = await AffiliateGenerator.generate(
        isbns=isbns,
        language=lang
    )
    
    # Sauvegarde
    await save_all(cleaned, translation, isbns, affiliate_links, quality)
```

### **4.2 Priorisation des traductions**

```python
TRANSLATION_PRIORITY = [
    ('standard_ebooks', 100),      # Best quality
    ('gallica_bnf', 95),
    ('projekt_gutenberg_de', 95),
    ('biblioteca_cervantes', 95),
    ('wolne_lektury', 95),
    ('wikisource', 80),
    ('feedbooks_pd', 80),
    ('internet_archive_scans', 75),
    ('libru', 75),
    ('aozora_bunko', 90),
    ('project_runeberg', 85),
    ('ia_pd_any', 70),
    ('gutenberg_original', 60),   # Only if EN
]

async def find_best_translation(title, author, target_lang):
    """Trouve la meilleure traduction PD disponible"""
    candidates = []
    
    for source, priority in TRANSLATION_PRIORITY:
        found = await search_source(source, title, author, target_lang)
        if found:
            found['priority'] = priority
            candidates.append(found)
    
    # Sort: priority DESC, year DESC (most recent)
    candidates.sort(key=lambda x: (-x['priority'], -(x.get('year') or 1900)))
    
    return candidates[0] if candidates else None
```

---

## **SECTION 5 – AFFILIATION : MISE EN ŒUVRE**

### **5.1 Configuration retailers ( seeding SQL )**

```sql
INSERT INTO affiliate_retailers VALUES
-- FRENCH
('fr', 'amazon_fr', 'amazon', 'fr', 'YOURTAG-FR', 
 'https://www.amazon.fr/dp/{isbn}?tag={tag}', 1, 4.5),
('fr', 'fnac', 'local', 'fr', 'FNAC_ID',
 'https://www.fnac.com/Interface/Affiliation/GetProductUrl?productId={isbn}&affiliate={affiliate_id}',
 2, 3.0),
('fr', 'cultura', 'local', 'fr', 'CULTURA_ID',
 'https://www.cultura.com/affiliate?isbn={isbn}&partner={partner_id}', 3, 3.5),

-- GERMAN
('de', 'amazon_de', 'amazon', 'de', 'YOURTAG-DE',
 'https://www.amazon.de/dp/{isbn}?tag={tag}', 1, 4.5),
('de', 'thalia', 'local', 'de', 'THALIA_ID',
 'https://www.thalia.de/shop/home/artikeldetails/{isbn}/ID{isbn}.html?partnerId={partner_id}',
 2, 5.0),

-- SPANISH
('es', 'amazon_es', 'amazon', 'es', 'YOURTAG-ES',
 'https://www.amazon.es/dp/{isbn}?tag={tag}', 1, 4.5),
('es', 'casa_del_libro', 'local', 'es', 'CASA_ID',
 'https://www.casadellibro.com/landing-page/index.html?tracking_id={tracking_id}&isbn={isbn}',
 2, 4.0);
```

### **5.2 Amazon PAAPI Integration**

```python
import paapi5_python_sdk

class AmazonAffiliator:
    """Wrapper PAAPI multi-régions"""
    
    REGIONS = {
        'us': 'webservices.amazon.com',
        'uk': 'webservices.amazon.co.uk',
        'de': 'webservices.amazon.de',
        'fr': 'webservices.amazon.fr',
        'jp': 'webservices.amazon.co.jp',
        'it': 'webservices.amazon.it',
        'es': 'webservices.amazon.es',
    }
    
    async def get_link(self, isbn: str, region: str, tag: str):
        """Génère lien affilié Amazon valide"""
        config = paapi5_python_sdk.Configuration(
            host=self.REGIONS[region]
        )
        # ... implémentation PAAPI
        return f"https://www.amazon.{region}/dp/{isbn}?tag={tag}"
```

---

## **SECTION 6 – BUDGET AJOUTÉ**

| Post | Coût/mois | Justification |
|------|-----------|---------------|
| **Traduction IA (GPU)** | €300-€600 | GPU T4/A100 pour NLLB inference |
| **Affiliate API** | €0 | Commission-based, pas de coût direct |
| **ISBN lookup** | €50-€100 | Open Library, Google Books API overages |
| **GeoIP** | €20-€50 | Détection pays utilisateur |
| **Relecture traductions** | €500-€1000 | Réviseurs pour vérifier fallback IA |
| **Total additionnel** | **€870-€1750/mois** | |

**Nouveau budget scaling total** : **€7,500-€9,000/mois**

---

## **SECTION 7 – CALENDRIER RÉVISÉ**

```
Mois:    1-2   3-4   5-6   7-8   9-10  11-12  13-15  16-18  19-21  22-24
--------|------|------|------|------|------|--------|-------|-------|-------|------
Dev EN  | #########|                                               [70K EN]
         | MVP +   |
         | search  |

Traduc  |        | FR    | DE    | ES    | IT/PT| JA    | RU/PL | NORD  | ARAB  |
PD      |        |####   |####   |####   |###    |###    |###    |##     |#      |

Affil   | EN ### | FR ###| DE ###| ES ###| IT ###| JP ### | RU  ## | MULTI ##| OPTIM |
        |        |       |       |       |       |        |        |        |       |

ISBN    | #####  | ##### | ##### | ##### | ####   | ####   | ###    | ####   | FULL  |
lookup  |        |       |       |       |        |        |        |        |       |

Scale   |                                                | #########| #########|
```

---

## **SECTION 8 – CHECKLIST PAR LANGUE**

Pour chaque langue avant "go live" :

- [ ] **Sources PD vérifiées** : Toutes les sources légales confirmées
- [ ] **Import complet** : 100% des livres disponibles importés
- [ ] **Priorisation trads** :
  - [ ] Vraies traductions PD identifiées et classées
  - [ ] IA fallback uniquement si nécessaire
  - [ ] Marquage clair "traduction automatique"
- [ ] **ISBN enrichis** : 90%+ des livres avec ISBN
- [ ] **Affiliation configurée** :
  - [ ] Programmes retailers approuvés
  - [ ] Liens testés et fonctionnels
  - [ ] Priorité retailers locaux
- [ ] **Recherche localisée** : Index dans la langue
- [ ] **SEO multilingue** : URLs /lang/, sitemaps par langue
- [ ] **Legal compliant** : Attribution sources par langue

---

## **SECTION 9 – RÈGLES D'OR FINALES**

### **Règle #1 : Priorité absolue aux traductions humaines PD**
- Jamais écraser une traduction existante de qualité par IA
- Classer les traductions : "humaine" > "machine" dans l'UI
- Afficher TOUTES les traductions disponibles, classées par qualité

### **Règle #2 : Transparence totale**
- Badge clair : "⚠️ Traduction automatique" sur les livres IA
- Info-bulle : "Cette traduction a été générée automatiquement"
- Lien vers version originale si différente

### **Règle #3 : Affiliation fine et contextuelle**
- Liens spécifiques à la langue de la traduction
- Priorité aux retailers locaux du pays utilisateur
- Toujours marqué "sponsorisé" / "lien affilié"

### **Règle #4 : Scalabilité**
- Architecture modulaire par langue
- Templates de scraping réutilisables
- Pipeline de traduction IA réutilisable

---

## **SECTION 10 – LIVRABLE FINAL**

**Librarfree.com** sera :

✅ **Catalogue géant** : 500K+ livres PD, 15+ langues  
✅ **Qualité traduction** : priorité aux éditions humaines existantes  
✅ **Affiliation intelligente** : liens adaptés langue + pays  
✅ **Traduction IA responsable** : UNIQUEMENT fallback, transparente  
✅ **Scalable** : nouvelle langue = 2-3 semaines  
✅ **100% légal** : respect strict des licences PD

**Prochaines étapes immédiates :**

1. 🔵 **Cette semaine** : Acheter librarfree.com + config dev
2. 🔵 **Semaine 2** : Lancer import Project Gutenberg (70K EN)
3. 🔵 **Semaine 3-4** : Développer core reader + search (EN)
4. 🟡 **Mois 2** : Intégrer Standard Ebooks + affiliation Amazon
5. 🟡 **Mois 3** : Scraping Gallica (FR) + affiliation Fnac
6. 🟡 **Mois 4** : DE/ES/IT : sources + affiliation
7. 🟠 **Mois 7-9** : Jap/Ru/Pl/Nordic
8. 🔴 **Mois 10+** : Langues émergentes

---

**Document complet prêt à partager avec n'importe quelle équipe de développement ou IA.**
