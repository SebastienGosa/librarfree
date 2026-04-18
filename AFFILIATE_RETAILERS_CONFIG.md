# **AFFILIATE RETAILERS CONFIGURATION – MULTILINGUE**
## **Librarfree.com – Liens d'affiliation par langue et pays**

---

## **TABLEAU COMPLET DES RETAILERS**

### **Structure de la table `affiliate_retailers`**

```sql
-- Table principale
CREATE TABLE affiliate_retailers (
    id SERIAL PRIMARY KEY,
    language_code VARCHAR(10) NOT NULL,
    retailer_name VARCHAR(100) NOT NULL,
    retailer_type ENUM('amazon', 'local', 'specialized') NOT NULL,
    country_code VARCHAR(10) NOT NULL,
    affiliate_tag VARCHAR(255) NOT NULL,
    url_template TEXT NOT NULL,
    api_endpoint VARCHAR(500),           -- Optionnel: PAAPI endpoint
    active BOOLEAN DEFAULT TRUE,
    priority INTEGER DEFAULT 1,          -- Ordre d'affichage
    commission_rate DECIMAL(5,2),        -- % commission (pour analytics)
    min_sales_threshold INTEGER DEFAULT 3, -- Seuil PAAPI
    notes TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(language_code, retailer_name)
);
```

---

## **SECTION 1 – AMAZON ASSOCIATES (PAR RÉGION)**

### **1.1 Amazon US (en-US)**
```sql
INSERT INTO affiliate_retailers VALUES
(NULL, 'en', 'amazon_com', 'amazon', 'us', 'YOURTAG-20',
 'https://www.amazon.com/dp/{isbn}?tag={tag}',
 'https://webservices.amazon.com/paapi5/searchitems',
 TRUE, 1, 4.5, 3,
 'Main Amazon US store, English books',
 NOW());
```

**PAAPI Requirements** :
- Tag format : `yourtag-20`
- Min sales : 3 in 30 days
- API endpoint : `webservices.amazon.com/paapi5/searchitems`
- Rate limit : 1 req/sec (burst 10)

---

### **1.2 Amazon UK (en-GB)**
```sql
INSERT INTO affiliate_retailers VALUES
(NULL, 'en', 'amazon_uk', 'amazon', 'uk', 'YOURTAG-21',
 'https://www.amazon.co.uk/dp/{isbn}?tag={tag}',
 'https://webservices.amazon.co.uk/paapi5/searchitems',
 TRUE, 2, 4.5, 3,
 'Amazon UK, English books, ships to EU',
 NOW());
```

---

### **1.3 Amazon Germany (de-DE)**
```sql
INSERT INTO affiliate_retailers VALUES
(NULL, 'de', 'amazon_de', 'amazon', 'de', 'YOURTAG-21',
 'https://www.amazon.de/dp/{isbn}?tag={tag}',
 'https://webservices.amazon.de/paapi5/searchitems',
 TRUE, 1, 4.5, 3,
 'Amazon DE, largest German bookstore',
 NOW()),

(NULL, 'de', 'thalia', 'local', 'de', 'THALIA_PARTNER_ID',
 'https://www.thalia.de/shop/home/artikeldetails/{isbn}/ID{isbn}.html?partnerId={partner_id}',
 NULL, TRUE, 2, 5.0, 0,
 'Local German retailer, higher commission',
 NOW()),

(NULL, 'de', 'weltbild', 'local', 'de', 'WELTBILD_ID',
 'https://www.weltbild.de/ebook/{isbn}?partner={partner_id}',
 NULL, TRUE, 3, 4.5, 0,
 'German retailer, good for non-fiction',
 NOW());
```

---

### **1.4 Amazon France (fr-FR)**
```sql
INSERT INTO affiliate_retailers VALUES
(NULL, 'fr', 'amazon_fr', 'amazon', 'fr', 'YOURTAG-21',
 'https://www.amazon.fr/dp/{isbn}?tag={tag}',
 'https://webservices.amazon.fr/paapi5/searchitems',
 TRUE, 1, 4.5, 3,
 'Amazon FR, standard commission',
 NOW()),

(NULL, 'fr', 'fnac', 'local', 'fr', 'FNAC_PARTNER_ID',
 'https://www.fnac.com/Interface/Affiliation/GetProductUrl?productId={isbn}&affiliate={affiliate_id}',
 NULL, TRUE, 2, 3.0, 0,
 'Fnac affiliate program, trusted brand',
 NOW()),

(NULL, 'fr', 'cultura', 'local', 'fr', 'CULTURA_PARTNER_ID',
 'https://www.cultura.com/affiliate?isbn={isbn}&partner={partner_id}',
 NULL, TRUE, 3, 3.5, 0,
 'Cultura, popular French bookstore chain',
 NOW()),

(NULL, 'fr', 'decitre', 'local', 'fr', 'DECITRE_ID',
 'https://www.decitre.fr/livre/{isbn}?ref={partner_id}',
 NULL, TRUE, 4, 4.0, 0,
 'Decitre, academic & general books',
 NOW());
```

---

### **1.5 Amazon Spain (es-ES)**
```sql
INSERT INTO affiliate_retailers VALUES
(NULL, 'es', 'amazon_es', 'amazon', 'es', 'YOURTAG-21',
 'https://www.amazon.es/dp/{isbn}?tag={tag}',
 'https://webservices.amazon.es/paapi5/searchitems',
 TRUE, 1, 4.5, 3,
 'Amazon Spain',
 NOW()),

(NULL, 'es', 'casa_del_libro', 'local', 'es', 'CASA_LIBRO_ID',
 'https://www.casadellibro.com/landing-page/index.html?tracking_id={tracking_id}&utm_source={isbn}',
 NULL, TRUE, 2, 4.0, 0,
 'Casa del Libro, major Spanish retailer',
 NOW()),

(NULL, 'es', 'el_corte_ingles', 'local', 'es', 'ECI_ID',
 'https://www.elcorteingles.es/ebooks/Affiliate/?isbn={isbn}&ref={partner_id}',
 NULL, TRUE, 3, 3.5, 0,
 'El Corte Inglés, department store books',
 NOW());
```

---

### **1.6 Amazon Italy (it-IT)**
```sql
INSERT INTO affiliate_retailers VALUES
(NULL, 'it', 'amazon_it', 'amazon', 'it', 'YOURTAG-21',
 'https://www.amazon.it/dp/{isbn}?tag={tag}',
 'https://webservices.amazon.it/paapi5/searchitems',
 TRUE, 1, 4.5, 3,
 'Amazon Italy',
 NOW()),

(NULL, 'it', 'ibs', 'local', 'it', 'IBS_PARTNER_ID',
 'https://www.ibs.it/dsp/Associazioni.jsp?isbn={isbn}&idAssociazione={partner_id}',
 NULL, TRUE, 2, 5.0, 0,
 'IBS.it, major Italian online bookstore',
 NOW()),

(NULL, 'it', 'feltrinelli', 'local', 'it', 'FELTRINELLI_ID',
 'https://www.feltrinelli.it/ebook/{isbn}?affiliates={partner_id}',
 NULL, TRUE, 3, 4.0, 0,
 'Feltrinelli, classic Italian publisher/retailer',
 NOW());
```

---

### **1.7 Amazon Japan (ja-JP)**
```sql
INSERT INTO affiliate_retailers VALUES
(NULL, 'ja', 'amazon_jp', 'amazon', 'jp', 'YOURTAG-22',
 'https://www.amazon.co.jp/dp/{isbn}?tag={tag}',
 'https://webservices.amazon.co.jp/paapi5/searchitems',
 TRUE, 1, 4.5, 3,
 'Amazon Japan',
 NOW()),

(NULL, 'ja', 'rakuten_books', 'local', 'jp', 'RAKUTEN_ID',
 'https://books.rakuten.co.jp/rb/{isbn}/?l-id={partner_id}',
 NULL, TRUE, 2, 3.0, 0,
 'Rakuten Books, major Japanese platform',
 NOW()),

(NULL, 'ja', 'bookwalker', 'specialized', 'jp', 'BOOKWALKER_ID',
 'https://bookwalker.jp/de/{isbn}/?adpcnt=7_3_{partner_id}',
 NULL, TRUE, 3, 5.0, 0,
 'BookWalker, specialized in ebooks (Kadokawa)',
 NOW());
```

---

### **1.8 Amazon Canada (en-CA / fr-CA)**
```sql
-- For EN content
INSERT INTO affiliate_retailers VALUES
(NULL, 'en', 'amazon_ca', 'amazon', 'ca', 'YOURTAG-20',
 'https://www.amazon.ca/dp/{isbn}?tag={tag}',
 'https://webservices.amazon.ca/paapi5/searchitems',
 TRUE, 1, 4.5, 3,
 'Amazon Canada English',
 NOW()),

-- For FR content
(NULL, 'fr', 'amazon_ca_fr', 'amazon', 'ca', 'YOURTAG-20',
 'https://www.amazon.ca/dp/{isbn}?tag={tag}',
 'https://webservices.amazon.ca/paapi5/searchitems',
 TRUE, 1, 4.5, 3,
 'Amazon Canada French section',
 NOW()),

(NULL, 'fr', 'chapters_indigo', 'local', 'ca', 'INDIGO_ID',
 'https://www.chapters.indigo.ca/en-ca/books/{isbn}/product.html?partner={partner_id}',
 NULL, TRUE, 2, 4.0, 0,
 'Indigo/Chapters, Canadian major retailer',
 NOW());
```

---

### **1.9 Amazon Brazil (pt-BR)**
```sql
INSERT INTO affiliate_retailers VALUES
(NULL, 'pt', 'amazon_br', 'amazon', 'br', 'YOURTAG-21',
 'https://www.amazon.com.br/dp/{isbn}?tag={tag}',
 'https://webservices.amazon.com.br/paapi5/searchitems',
 TRUE, 1, 4.5, 3,
 'Amazon Brazil Portuguese',
 NOW()),

(NULL, 'pt', 'saraiva', 'local', 'br', 'SARAIVA_ID',
 'https://www.saraiva.com.br/produto/{isbn}?affiliate={partner_id}',
 NULL, TRUE, 2, 4.0, 0,
 'Saraiva, major Brazilian bookstore',
 NOW());
```

---

## **SECTION 2 – RETAILERS LOCAUX (NON-AMAZON)**

### **2.1 Pays-Bas / Belgique NL (nl-NL)**
```sql
INSERT INTO affiliate_retailers VALUES
(NULL, 'nl', 'bol_com', 'local', 'nl', 'BOL_PARTNER_ID',
 'https://www.bol.com/nl/p/{isbn}/{partner_id}/',
 NULL, TRUE, 1, 3.5, 0,
 'Bol.com, #1 Dutch/Belgian online retailer',
 NOW()),

(NULL, 'nl', 'amazon_nl', 'amazon', 'nl', 'YOURTAG-21',
 'https://www.amazon.nl/dp/{isbn}?tag={tag}',
 'https://webservices.amazon.nl/paapi5/searchitems',
 TRUE, 2, 4.5, 3,
 'Amazon Netherlands',
 NOW());
```

---

### **2.2 Pologne (pl-PL)**
```sql
INSERT INTO affiliate_retailers VALUES
(NULL, 'pl', 'empik', 'local', 'pl', 'EMPIK_ID',
 'https://www.empik.com/{isbn}?partnerId={partner_id}',
 NULL, TRUE, 1, 4.0, 0,
 'Empik, largest Polish bookstore chain',
 NOW()),

(NULL, 'pl', 'amazon_pl', 'amazon', 'pl', 'YOURTAG-21',
 'https://www.amazon.pl/dp/{isbn}?tag={tag}',
 'https://webservices.amazon.pl/paapi5/searchitems',
 TRUE, 2, 4.5, 3,
 'Amazon Poland',
 NOW());
```

---

### **2.3 Russie (ru-RU) – Option alternatif**
```sql
INSERT INTO affiliate_retailers VALUES
(NULL, 'ru', 'ozon', 'local', 'ru', 'OZON_PARTNER_ID',
 'https://www.ozon.ru/product/{isbn}/?partner={partner_id}',
 NULL, TRUE, 1, 3.0, 0,
 'Ozon.ru, Russian Amazon equivalent',
 NOW()),

(NULL, 'ru', 'labirint', 'local', 'ru', 'LABIRINT_ID',
 'https://www.labirint.ru/books/{isbn}/?partner={partner_id}',
 NULL, TRUE, 2, 3.5, 0,
 'Labirint, major Russian bookseller',
 NOW());
```
*Note: Amazon.ru disponible mais moins développé.*

---

### **2.4 Monde arabe (ar) – Moyen-Orient**
```sql
INSERT INTO affiliate_retailers VALUES
(NULL, 'ar', 'neelwafurat', 'local', 'ae', 'NEELWAFURAT_ID',
 'https://www.neelwafurat.com/itempage.aspx?isbn={isbn}&affiliate={partner_id}',
 NULL, TRUE, 1, 4.0, 0,
 'Neelwafurat, major Arabic bookstore network',
 NOW()),

(NULL, 'ar', 'jamalon', 'local', 'ae', 'JAMALON_ID',
 'https://www.jamalon.com/en/{isbn}/?aff={partner_id}',
 NULL, TRUE, 2, 3.5, 0,
 'Jamalon, largest online Arab bookseller',
 NOW()),

(NULL, 'ar', 'amazon_ae', 'amazon', 'ae', 'YOURTAG-22',
 'https://www.amazon.ae/dp/{isbn}?tag={tag}',
 'https://webservices.amazon.ae/paapi5/searchitems',
 TRUE, 3, 4.5, 3,
 'Amazon UAE, ships to MENA',
 NOW());
```

---

### **2.5 Corée (ko-KR) – Option**
```sql
INSERT INTO affiliate_retailers VALUES
(NULL, 'ko', 'yes24', 'local', 'kr', 'YES24_ID',
 'https://www.yes24.com/Product/Goods/{isbn}?Partner={partner_id}',
 NULL, TRUE, 1, 3.0, 0,
 'YES24, leading Korean bookstore',
 NOW()),

(NULL, 'ko', 'aladin', 'local', 'kr', 'ALADIN_ID',
 'https://www.aladin.co.kr/shop/wproduct.aspx?ISBN={isbn}&partner={partner_id}',
 NULL, TRUE, 2, 3.5, 0,
 'Aladin, popular Korean retailer',
 NOW());
```

---

### **2.6 Chine (zh-CN/zh-TW) – Option complexe**
```sql
-- Chine continentale (zh-CN)
INSERT INTO affiliate_retailers VALUES
(NULL, 'zh', 'dangdang', 'local', 'cn', 'DANGDANG_ID',
 'https://product.dangdang.com/{isbn}.html?ref=partner_{partner_id}',
 NULL, TRUE, 1, 4.0, 0,
 'Dangdang, major Chinese online bookseller',
 NOW()),

(NULL, 'zh', 'jd_com', 'local', 'cn', 'JD_ID',
 'https://item.jd.com/{isbn}.html?utm_source=partner&utm_medium=affiliate',
 NULL, TRUE, 2, 3.5, 0,
 'JD.com, Chinese e-commerce giant',
 NOW()),

-- Taiwan (zh-TW)
(NULL, 'zh', 'books_com_tw', 'local', 'tw', 'BOOKSCOMTW_ID',
 'https://www.books.com.tw/products/{isbn}?ref=aff_{partner_id}',
 NULL, TRUE, 1, 3.0, 0,
 'Books.com.tw, largest Taiwan bookstore',
 NOW());
```
*Note: La Chine a des restrictions d'affiliation complexes, alternatives locales recommandées.*

---

## **SECTION 3 – API INTEGRATION CODE**

### **3.1 Service principal (Python)**

```python
# services/affiliate_service.py
from typing import List, Dict, Optional
from dataclasses import dataclass
import re

@dataclass
class AffiliateLink:
    retailer: str
    url: str
    type: str  # 'amazon', 'local', 'specialized'
    country: str
    language: str
    commission: Optional[float] = None

class AffiliateService:
    """
    Service central de génération de liens affiliés
    """
    
    def __init__(self, db_pool, geoip_service):
        self.db = db_pool
        self.geoip = geoip_service
        
    async def get_links_for_book(
        self,
        book_id: int,
        language: str,
        user_country: Optional[str] = None,
        max_links: int = 5
    ) -> List[AffiliateLink]:
        """
        Génère les liens affiliés pour un livre
        Priorité: pays utilisateur > langue > général
        """
        
        # 1. Détection pays si non fourni
        if not user_country:
            user_country = await self.geoip.detect_country()
        
        # 2. Récupérer la traduction (ISBN)
        translation = await self._get_translation_isbn(book_id, language)
        if not translation or not translation.get('isbn'):
            return []
        
        isbn = translation['isbn']
        
        # 3. Requête BDD optimisée
        query = """
            SELECT * FROM affiliate_retailers
            WHERE language_code = $1
              AND active = TRUE
            ORDER BY
              CASE WHEN country_code = $2 THEN 0 ELSE 1 END,  -- Locaux en premier
              priority ASC
            LIMIT $3
        """
        
        retailers = await self.db.fetch(query, language, user_country, max_links)
        
        links = []
        for retailer in retailers:
            url = self._transform_url(retailer['url_template'], {
                'isbn': isbn,
                'tag': retailer['affiliate_tag'],
                'affiliate_id': retailer['affiliate_tag'],
                'partner_id': retailer['affiliate_tag'],
                'tracking_id': retailer['affiliate_tag'],
            })
            
            links.append(AffiliateLink(
                retailer=retailer['retailer_name'],
                url=url,
                type=retailer['retailer_type'],
                country=retailer['country_code'],
                language=language,
                commission=retailer['commission_rate']
            ))
        
        return links
    
    def _transform_url(self, template: str, values: Dict[str, str]) -> str:
        """Remplace les placeholders dans l'URL template"""
        url = template
        for key, value in values.items():
            placeholder = "{" + key + "}"
            url = url.replace(placeholder, value)
        return url
    
    async def _get_translation_isbn(self, book_id: int, language: str) -> Optional[Dict]:
        """Récupère l'ISBN de la traduction dans la langue demandée"""
        query = """
            SELECT bi.isbn_13, bi.isbn_10, bi.publisher, bi.publication_year
            FROM book_translations bt
            JOIN book_isbns bi ON bt.id = bi.book_translation_id
            WHERE bt.book_id = $1 AND bt.language_code = $2
            ORDER BY bi.publication_year DESC
            LIMIT 1
        """
        return await self.db.fetchrow(query, book_id, language)
```

---

### **3.2 ISBN Enricher Service**

```python
# services/isbn_enricher.py
import requests
from isbnlib import meta, is_isbn13

class ISBNEnricher:
    """
    Enrichit les métadonnées ISBN depuis multiples sources
    """
    
    SOURCES = {
        'openlibrary': 'https://openlibrary.org/api/books?bibkeys=ISBN:{isbn}&format=json',
        'google_books': 'https://www.googleapis.com/books/v1/volumes?q=isbn:{isbn}',
        'isbndb': 'https://api.isbndb.com/book/{isbn}',  # Requires key
    }
    
    async def find_isbn(self, title: str, author: str, language: str) -> Optional[str]:
        """
        Trouve l'ISBN via plusieurs APIs
        """
        
        # 1. Open Library (gratuit, pas de clé)
        isbn = await self._search_openlibrary(title, author)
        if isbn:
            return isbn
        
        # 2. Google Books API
        isbn = await self._search_google_books(title, author)
        if isbn:
            return isbn
        
        # 3. Scraping Amazon (dernier recours, delicate)
        # ... pas recommandé, risque de blocage
        
        return None
    
    async def _search_openlibrary(self, title: str, author: str) -> Optional[str]:
        """Query Open Library API"""
        query = f"title:{title} author:{author}"
        url = f"https://openlibrary.org/search.json?q={query}&language={self.lang}"
        
        response = requests.get(url)
        if response.status_code == 200:
            data = response.json()
            if data['docs']:
                # Prendre le premier ISBN trouvé
                for doc in data['docs']:
                    if 'isbn' in doc and doc['isbn']:
                        return doc['isbn'][0]
        return None
```

---

### **3.3 Frontend Component (React/Next.js)**

```tsx
// components/BookAffiliatePanel.tsx
'use client';

import { useState } from 'react';
import { Globe, ShoppingCart, ExternalLink, Store } from 'lucide-react';
import { useLocale } from 'next-intl';
import { useAffiliateLinks } from '@/hooks/useAffiliateLinks';

export function BookAffiliatePanel({ bookId }: { bookId: number }) {
  const locale = useLocale();
  const [selectedCountry, setSelectedCountry] = useState<string>('');
  const { data: links, isLoading, error } = useAffiliateLinks({
    bookId,
    language: locale,
    country: selectedCountry || undefined,
  });
  
  // Pays courants par langue
  const commonCountries = {
    en: ['US', 'UK', 'CA', 'AU'],
    fr: ['FR', 'BE', 'CA', 'CH'],
    de: ['DE', 'AT', 'CH'],
    es: ['ES', 'MX', 'AR'],
  };
  
  if (isLoading) return <div>Loading retailers...</div>;
  
  return (
    <div className="mt-8 p-6 bg-gray-50 rounded-lg border">
      <div className="flex items-start justify-between mb-4">
        <div>
          <h3 className="text-lg font-semibold flex items-center gap-2">
            <ShoppingCart className="w-5 h-5" />
            Acheter ce livre en {locale.toUpperCase()}
          </h3>
          <p className="text-sm text-gray-600 mt-1">
            Liens affiliés - Soutenez-nous sans frais supplémentaire
          </p>
        </div>
      </div>
      
      {/* Country selector for multi-country languages */}
      {commonCountries[locale] && (
        <div className="mb-4">
          <label className="block text-sm font-medium mb-2">
            <Globe className="w-4 h-4 inline mr-1" />
            Pays de livraison :
          </label>
          <select
            value={selectedCountry}
            onChange={(e) => setSelectedCountry(e.target.value)}
            className="border rounded px-3 py-2 text-sm"
          >
            <option value="">Détecté automatiquement</option>
            {commonCountries[locale].map(country => (
              <option key={country} value={country}>
                {country}
              </option>
            ))}
          </select>
        </div>
      )}
      
      {/* Retailer links */}
      <div className="space-y-3">
        {links?.map((link, idx) => (
          <a
            key={`${link.retailer}-${idx}`}
            href={link.url}
            target="_blank"
            rel="noopener noreferrer sponsored"
            className="flex items-center justify-between p-4 bg-white rounded-lg border hover:border-blue-500 hover:shadow-md transition-all group"
          >
            <div className="flex items-center gap-3">
              <Store className="w-5 h-5 text-gray-500" />
              <div>
                <div className="font-medium capitalize">
                  {link.retailer.replace('_', ' ')}
                </div>
                <div className="text-xs text-gray-500">
                  {link.country} • {link.type === 'amazon' ? 'Amazon' : 'Librairie locale'}
                </div>
              </div>
            </div>
            <div className="flex items-center gap-2">
              {link.commission && (
                <span className="text-xs text-green-600 bg-green-50 px-2 py-1 rounded">
                  +{link.commission}%
                </span>
              )}
              <ExternalLink className="w-4 h-4 opacity-0 group-hover:opacity-100 transition-opacity" />
            </div>
          </a>
        ))}
      </div>
      
      {/* Warning for AI translations */}
      {links?.[0]?.hasOwnProperty('translation_quality') && (
        <p className="mt-4 text-xs text-amber-600 bg-amber-50 p-3 rounded flex items-start gap-2">
          ⚠️ <span>
            <strong>Traduction automatique :</strong> Cette version a été générée par IA.
            La qualité peut varier. Consultez la version originale si besoin.
          </span>
        </p>
      )}
      
      <p className="mt-4 text-xs text-gray-500">
        En suivant ces liens, vous soutenez Librarfree sans frais supplémentaires.
        Nous recevons une commission sur chaque achat.
      </p>
    </div>
  );
}
```

---

## **SECTION 4 – RETAILERS NATIONAUX (DÉTAILLÉ)**

### **4.1 France (FR)**

| Retailer | URL Template | Commission | Notes |
|----------|--------------|------------|-------|
| Amazon FR | `https://www.amazon.fr/dp/{isbn}?tag={tag}` | 4.5% | PAAPI requis, min 3 ventes |
| Fnac | `https://www.fnac.com/Interface/Affiliation/...` | 3.0% | API exclusif, contacter partenariat |
| Cultura | `https://www.cultura.com/affiliate?...` | 3.5% | En cours de setup |
| Decitre | `https://www.decitre.fr/livre/...` | 4.0% | Academic focus |
| Chapitre.com | `https://www.chapitre.com/...` | 3.5% | (Optionnel) |
| Librairie Eyrolles | `https://www.eyrolles.com/...` | 4.0% | Tech/Informatique |

---

### **4.2 Allemagne (DE)**

| Retailer | URL Template | Commission | Notes |
|----------|--------------|------------|-------|
| Amazon DE | `https://www.amazon.de/dp/{isbn}?tag={tag}` | 4.5% | PAAPI |
| Thalia | `https://www.thalia.de/...` | 5.0% | Meilleure commission |
| Weltbild | `https://www.weltbild.de/ebook/...` | 4.5% |
| Hugendubel | `https://www.hugendubel.de/...` | 4.0% | |
| Bücher.de | `https://www.buecher.de/...` | 3.5% | |

---

### **4.3 Espagne (ES)**

| Retailer | URL Template | Commission | Notes |
|----------|--------------|------------|-------|
| Amazon ES | `https://www.amazon.es/dp/{isbn}?tag={tag}` | 4.5% | |
| Casa del Libro | `https://www.casadellibro.com/...` | 4.0% | Principal retailer |
| El Corte Inglés | `https://www.elcorteingles.es/ebooks/...` | 3.5% | |
| La Central | `https://www.lacentral.com/...` | 3.0% | |

---

### **4.4 Italie (IT)**

| Retailer | URL Template | Commission | Notes |
|----------|--------------|------------|-------|
| Amazon IT | `https://www.amazon.it/dp/{isbn}?tag={tag}` | 4.5% | |
| IBS.it | `https://www.ibs.it/dsp/Associazioni.jsp?...` | 5.0% | Plus haute commission |
| Feltrinelli | `https://www.feltrinelli.it/ebook/...` | 4.0% | Éditeur historique |
| Mondadori | `https://www.mondadoristore.it/...` | 4.0% | |

---

### **4.5 Japon (JA)**

| Retailer | URL Template | Commission | Notes |
|----------|--------------|------------|-------|
| Amazon JP | `https://www.amazon.co.jp/dp/{isbn}?tag={tag}` | 4.5% | Tag format: -22 |
| Rakuten Books | `https://books.rakuten.co.jp/rb/{isbn}/?l-id=...` | 3.0% | Membres Rakuten = fidélité |
| BookWalker | `https://bookwalker.jp/de/{isbn}/?adpcnt=...` | 5.0% | Spécialisé manga + novels |
| honto.jp | `https://honto.jp/ebook/...` | 3.5% | NTTDocomo |

---

### **4.6 Pays-Bas (NL)**

| Retailer | URL Template | Commission | Notes |
|----------|--------------|------------|-------|
| Bol.com | `https://www.bol.com/nl/p/{isbn}/{partner_id}/` | 3.5% | Numéro 1 aux Pays-Bas/Belgique |
| Amazon NL | `https://www.amazon.nl/dp/{isbn}?tag={tag}` | 4.5% | |
| Proefschriften | `https://www.proefschriften.nl/...` | 4.0% | Academic focus |

---

## **SECTION 5 – AFFILIATE API INTEGRATION**

### **5.1 Amazon PAAPI v5 Python Wrapper**

```python
# api_clients/amazon_paapi.py
import paapi5_python_sdk
from paapi5_python_sdk.models import *
from paapi5_python_sdk.api.default_api import DefaultApi
from typing import Optional

class AmazonPAAPI:
    """
    Wrapper pour Amazon Product Advertising API v5
    Support multi-région
    """
    
    def __init__(self, access_key: str, secret_key: str, region: str, partner_tag: str):
        self.access_key = access_key
        self.secret_key = secret_key
        self.partner_tag = partner_tag
        
        host_map = {
            'us': 'webservices.amazon.com',
            'uk': 'webservices.amazon.co.uk',
            'de': 'webservices.amazon.de',
            'fr': 'webservices.amazon.fr',
            'jp': 'webservices.amazon.co.uk',
            'it': 'webservices.amazon.it',
            'es': 'webservices.amazon.es',
            'ca': 'webservices.amazon.ca',
            'br': 'webservices.amazon.com.br',
            'au': 'webservices.amazon.com.au',
        }
        
        self.host = host_map[region]
        self.configuration = paapi5_python_sdk.Configuration(
            access_key=access_key,
            secret_key=secret_key,
            host=self.host
        )
    
    async def get_item_by_isbn(self, isbn: str, lang: str = 'en') -> Optional[dict]:
        """
        Recherche un livre par ISBN et retourne métadonnées + lien affilié
        """
        try:
            api_instance = DefaultApi(self.configuration)
            
            # Build request
            request = SearchItemsRequest(
                partner_tag=self.partner_tag,
                partner_type='Associates',
                keywords=isbn,
                search_index='Books',
                item_count=1,
                resources=[
                    'ItemInfo.Title',
                    'ItemInfo.ByLineInfo',
                    'Offers.Listings.Price',
                    'Images.Primary.Large',
                    'CustomerReviews.Count',
                ]
            )
            
            response = api_instance.search_items(request)
            
            if response.search_result?.items:
                item = response.search_result.items[0]
                
                return {
                    'title': item.item_info?.title?.display_value,
                    'author': item.item_info?.by_line_info?.contributors?.[0]?.name,
                    'price': item.offers?.listings?.[0]?.price?.display_amount,
                    'currency': item.offers?.listings?.[0]?.price?.currency,
                    'url': item.detail_page_url,
                    'image': item.images?.primary?.large?.url,
                    'isbn': isbn,
                    'review_count': item.customer_reviews?.count,
                }
            
            return None
            
        except Exception as e:
            logger.error(f"PAAPI error for {isbn}: {e}")
            return None
```

---

### **5.2 Cache des liens affiliés**

```python
# services/affiliate_cache.py
import redis
import json
from typing import Dict

class AffiliateCache:
    """
    Cache Redis pour liens affiliés (éviter régénération)
    TTL: 24h (liens Amazon stables)
    """
    
    def __init__(self, redis_client):
        self.redis = redis_client
        
    def get_cache_key(self, isbn: str, language: str, country: str = None) -> str:
        parts = [isbn, language]
        if country:
            parts.append(country)
        return f"affiliate:{':'.join(parts)}"
    
    async def get(self, isbn: str, language: str, country: str = None) -> Optional[Dict]:
        key = self.get_cache_key(isbn, language, country)
        cached = await self.redis.get(key)
        return json.loads(cached) if cached else None
    
    async def set(self, isbn: str, language: str, links: List[Dict], country: str = None, ttl: int = 86400):
        key = self.get_cache_key(isbn, language, country)
        await self.redis.setex(key, ttl, json.dumps(links))
```

---

## **SECTION 6 – TESTING & QUALITY CONTROL**

### **6.1 Lien testing script**

```python
# scripts/test_affiliate_links.py
import asyncio
import aiohttp
from datetime import datetime

class AffiliateLinkTester:
    """Test workflow pour validating affiliate links"""
    
    def __init__(self, affiliate_service):
        self.service = affiliate_service
        
    async def test_all_links(self, sample_isbns: List[str], languages: List[str]):
        """
        Vérifie que tous les liens affiliés sont fonctionnels
        """
        results = {
            'passed': [],
            'failed': [],
            'warnings': []
        }
        
        for isbn in sample_isbns:
            for lang in languages:
                links = await self.service.get_links_for_book(
                    book_id=0,  # dummy
                    language=lang,
                    isbn_override=isbn
                )
                
                for link in links:
                    try:
                        async with aiohttp.ClientSession() as session:
                            async with session.head(link.url, timeout=5, allow_redirects=True) as resp:
                                if resp.status == 200:
                                    results['passed'].append({
                                        'isbn': isbn,
                                        'lang': lang,
                                        'retailer': link.retailer,
                                        'status': resp.status
                                    })
                                else:
                                    results['failed'].append({
                                        'isbn': isbn,
                                        'lang': lang,
                                        'retailer': link.retailer,
                                        'status': resp.status,
                                        'url': link.url
                                    })
                    except Exception as e:
                        results['failed'].append({
                            'isbn': isbn,
                            'lang': lang,
                            'retailer': link.retailer,
                            'error': str(e)
                        })
        
        return results
```

---

## **SECTION 7 – DASHBOARD METRICS**

```sql
-- Vue pour analyser performance affiliation
CREATE VIEW affiliate_performance AS
SELECT 
    ar.language_code,
    ar.retailer_name,
    COUNT(Distinct bi.book_translation_id) as books_with_affiliate,
    SUM(CASE WHEN bt.is_machine_translated THEN 0 ELSE 1 END) as human_translations,
    SUM(CASE WHEN bt.is_machine_translated THEN 1 ELSE 0 END) as ai_translations,
    ROUND(AVG(ar.commission_rate), 2) as avg_commission
FROM affiliate_retailers ar
LEFT JOIN book_isbns bi ON true
LEFT JOIN book_translations bt ON bi.book_translation_id = bt.id
WHERE ar.active = TRUE
GROUP BY ar.language_code, ar.retailer_name
ORDER BY ar.language_code, ar.priority;
```

---

## **SECTION 8 – CHECKLIST AFFILIATION PAR LANGUE**

Pour chaque langue avant launch :

- [ ] **Programme affilié approuvé** (Amazon PAAPI ou local program)
- [ ] **Tag affilié configuré** (enregistré dans BDD)
- [ ] **URL templates testés** (vérifier que {isbn} se remplace)
- [ ] **ISBN lookup** fonctionne pour cette langue
- [ ] **Minimum 3 retailers** par langue (1 Amazon + 2 locaux)
- [ ] **API responsive** (taux de réponse < 200ms)
- [ ] **Cache Redis** implémenté (éviter répétition)
- [ ] **GeoIP detection** fonctionne pour pays cibles
- [ ] **Frontend component** testé UX
- [ ] **Législation locale** respectée (disclosure sponsor)

---

## **SECTION 9 – CONTRACT & LEGAL**

### **9.1 Amazon Associates Operating Agreement (résumé)**

- **Requerments** :
  - Révéler clairement "sponsored" / "affiliate link"
  - Ne pas cacher les liens
  - Utiliser uniquement les liens fournis
  - Minimum 3 ventes en 30 jours pour rester dans le programme
  - Ne pas utiliser dans offline/email (sauf conditions spéciales)

- **Prohibited** :
  - Ne pas lier directement à checkout
  - Ne pas utiliser dans apps without approval
  - Ne pas masquer l'affiliate nature

### **9.2 Local affiliate programs**

Chaque retailer local a ses conditions :

- **Fnac** : Contactez programme affiliationFnac
- **Thalia** : Partenariat via AWIN ou直接
- **Cultura** : En cours d'ouverture programme
- **IBS.it** : Affiliation via Awin network
- **Rakuten** : Rakuten Advertising network

---

## **SECTION 10 – MAINTENANCE**

### **10.1 Monitoring quotidien**

```bash
# Cron job: vérifier liens morts
0 2 * * * python scripts/check_affiliate_links.py --days 7

# Rapport hebdomadaire commission
0 9 * * 1 python scripts/affiliate_report.py --week
```

### **10.2 Nettoyage retailers inactifs**

```sql
-- Marquer retailers inactifs si pas de vente depuis 90 jours
UPDATE affiliate_retailers 
SET active = FALSE 
WHERE id IN (
  SELECT retailer_id FROM affiliate_clicks 
  WHERE clicked_at < NOW() - INTERVAL '90 days'
  AND converted = FALSE
);
```

---

**FIN DU DOCUMENT AFFILIATE CONFIG**
