-- ============================================
-- LIBRARFREE DATABASE SCHEMA – VERSION COMPLÈTE
-- Mégabibliothèque légale multilingue
-- ============================================

-- Extension pgvector pour embeddings IA
CREATE EXTENSION IF NOT EXISTS vector;
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- ============================================
-- TABLE 1: AUTHORS (Auteurs originaux)
-- ============================================
CREATE TABLE IF NOT EXISTS authors (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    birth_year INTEGER,
    death_year INTEGER,
    nationality VARCHAR(100),
    bio TEXT,
    wikipedia_url VARCHAR(500),
    image_url VARCHAR(500),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_authors_name ON authors USING gin(name gin_trgm_ops);
CREATE INDEX idx_authors_nationality ON authors(nationality);
CREATE INDEX idx_authors_lifespan ON authors(birth_year, death_year);

-- ============================================
-- TABLE 2: BOOKS (Oeuvres originales – métadonnées universelles)
-- ============================================
CREATE TABLE IF NOT EXISTS books (
    id SERIAL PRIMARY KEY,
    gutenberg_id INTEGER UNIQUE,          -- ID Project Gutenberg
    title_original VARCHAR(500) NOT NULL,  -- Titre original
    author_id INTEGER REFERENCES authors(id),
    original_language VARCHAR(10) NOT NULL DEFAULT 'en',
    first_publication_year INTEGER,
    description TEXT,
    cover_image_url VARCHAR(1000),
    average_rating DECIMAL(3,2) DEFAULT 0,
    rating_count INTEGER DEFAULT 0,
    read_count INTEGER DEFAULT 0,
    download_count INTEGER DEFAULT 0,
    -- Metadata pour recherche
    subjects TEXT[],                       -- Array de sujets
    genres TEXT[],                         -- Array genres (fiction, etc)
    -- Sources
    source_project VARCHAR(100),           -- 'gutenberg', 'standardebooks', 'wikisource', etc.
    source_identifier VARCHAR(255),        -- ID dans la source
    source_url VARCHAR(1000),              -- URL vers source originale
    -- Quality indicators
    quality_score INTEGER DEFAULT 80,      -- 0-100 (édition soignée, etc.)
    is_featured BOOLEAN DEFAULT FALSE,     -- Curation manuelle
    featured_reason VARCHAR(255),
    -- Timestamps
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Index full-text search
CREATE INDEX idx_books_title ON books USING gin(title_original gin_trgm_ops);
CREATE INDEX idx_books_original_lang ON books(original_language);
CREATE INDEX idx_books_year ON books(first_publication_year);
CREATE INDEX idx_books_source ON books(source_project);
CREATE INDEX idx_books_quality ON books(quality_score DESC);
CREATE INDEX idx_books_featured ON books(is_featured) WHERE is_featured = TRUE;

-- Full-text search (PostgreSQL tsvector)
CREATE INDEX idx_books_fulltext ON books USING gin(
    setweight(to_tsvector('english', COALESCE(title_original, '')), 'A') ||
    setweight(to_tsvector('english', COALESCE(description, '')), 'B')
);

-- ============================================
-- TABLE 3: BOOK_TRANSLATIONS (Traductions – 1ROW par langue)
-- ============================================
CREATE TABLE IF NOT EXISTS book_translations (
    id SERIAL PRIMARY KEY,
    book_id INTEGER NOT NULL REFERENCES books(id) ON DELETE CASCADE,
    language_code VARCHAR(10) NOT NULL DEFAULT 'en',
    -- CONTENU DE LA TRADUCTION
    title_translated VARCHAR(500),
    content_url VARCHAR(500),              -- R2/S3 URL to full text file
    content_format VARCHAR(20) DEFAULT 'txt', -- 'epub', 'txt', 'html', 'pdf'
    content_size_bytes BIGINT,             -- file size for download estimates
    -- MÉTADONNÉES DE TRADUCTION
    is_machine_translated BOOLEAN DEFAULT FALSE,
    translation_quality VARCHAR(50) NOT NULL DEFAULT 'human_unknown',
    -- Catégorie de qualité:
    -- 'human_professional' – traduction éditeur reconnu
    -- 'human_volunteer' – Wikisource, benevoles
    -- 'machine_nllb' – NLLB-200 IA
    -- 'machine_m2m100' – M2M100 IA
    -- 'machine_other' – autre modèle
    translator_name VARCHAR(255),
    translator_bio TEXT,
    publisher VARCHAR(255),
    publication_year INTEGER,
    translation_edition VARCHAR(100),      -- "First edition", "Revised"
    isbn_13 VARCHAR(13),                   -- ISBN de cette édition spécifique
    -- SOURCE DE LA TRADUCTION
    source_project VARCHAR(100),           -- 'standardebooks', 'wikisource', 'nllb_fallback', etc.
    source_identifier VARCHAR(255),        -- ID dans la source
    source_url VARCHAR(1000),              -- Lien vers source originale
    -- MÉTADONNÉES ENRICHIES
    word_count INTEGER,
    reading_time_minutes INTEGER,
    readability_score DECIMAL(4,2),        -- Score Flesch-Kincaid
    -- EMBEDDING VECTORIEL (pgvector)
    embedding vector(768),                 -- Embedding Nomic embedding (768 dims)
    embedding_model VARCHAR(50) DEFAULT 'nomic-embed-text-v1.5',
    embedding_generated_at TIMESTAMP,
    -- TIMESTAMPS
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    -- CONTRAINTES
    CONSTRAINT chk_language_format CHECK (language_code ~ '^[a-z]{2}(-[A-Z]{2})?$')
);

-- Index traductions
CREATE INDEX idx_translations_book ON book_translations(book_id);
CREATE INDEX idx_translations_lang ON book_translations(language_code);
CREATE INDEX idx_translations_quality ON book_translations(translation_quality);
CREATE INDEX idx_translations_is_ai ON book_translations(is_machine_translated);
CREATE INDEX idx_translations_isbn ON book_translations(isbn_13) WHERE isbn_13 IS NOT NULL;
CREATE INDEX idx_translations_wordcount ON book_translations(word_count);
CREATE INDEX idx_translations_embedding ON book_translations USING hnsw (embedding vector_cosine_ops);

-- Full-text search sur traductions (par langue)
CREATE INDEX idx_translations_fulltext_en ON book_translations USING gin(to_tsvector('english', content)) WHERE language_code = 'en';
CREATE INDEX idx_translations_fulltext_fr ON book_translations USING gin(to_tsvector('french', content)) WHERE language_code = 'fr';
CREATE INDEX idx_translations_fulltext_de ON book_translations USING gin(to_tsvector('german', content)) WHERE language_code = 'de';
CREATE INDEX idx_translations_fulltext_es ON book_translations USING gin(to_tsvector('spanish', content)) WHERE language_code = 'es';

-- ============================================
-- TABLE 4: BOOK_ISBNs (ISBN par édition)
-- ============================================
CREATE TABLE IF NOT EXISTS book_isbns (
    id SERIAL PRIMARY KEY,
    book_translation_id INTEGER NOT NULL REFERENCES book_translations(id) ON DELETE CASCADE,
    isbn_13 VARCHAR(13) UNIQUE NOT NULL,
    isbn_10 VARCHAR(10),
    -- ÉDITION
    publisher VARCHAR(255),
    publication_year INTEGER,
    edition VARCHAR(100),                  -- "First edition", "Revised", etc.
    format VARCHAR(20),                    -- 'hardcover', 'paperback', 'ebook', 'audiobook'
    -- LIENS AFFILIATION (JSON dynamique)
    affiliate_links JSONB,                 -- {"amazon": "...", "fnac": "...", "thalia": "..."}
    -- MÉTADONNÉES
    pages INTEGER,
    weight_grams INTEGER,
    dimensions VARCHAR(50),                -- "19 x 12 x 2 cm"
    -- SOURCE
    source VARCHAR(100),                   -- 'isbndb', 'openlibrary', 'manual'
    verified BOOLEAN DEFAULT FALSE,        -- ISBN vérifié fonctionne
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_isbns_translation ON book_isbns(book_translation_id);
CREATE INDEX idx_isbns_isbn13 ON book_isbns(isbn_13);
CREATE INDEX idx_isbns_publisher ON book_isbns(publisher);
CREATE INDEX idx_isbns_verified ON book_isbns(verified) WHERE verified = TRUE;

-- ============================================
-- TABLE 5: AFFILIATE_RETAILERS (Configuration)
-- ============================================
-- (Déjà définie dans le document séparé, incluse ici pour complétude)
CREATE TABLE IF NOT EXISTS affiliate_retailers (
    id SERIAL PRIMARY KEY,
    language_code VARCHAR(10) NOT NULL,
    retailer_name VARCHAR(100) NOT NULL,
    retailer_type VARCHAR(20) NOT NULL CHECK (retailer_type IN ('amazon', 'local', 'specialized')),
    country_code VARCHAR(10) NOT NULL,
    affiliate_tag VARCHAR(255) NOT NULL,
    url_template TEXT NOT NULL,
    api_endpoint VARCHAR(500),
    active BOOLEAN DEFAULT TRUE,
    priority INTEGER DEFAULT 1,
    commission_rate DECIMAL(5,2),
    min_sales_threshold INTEGER DEFAULT 3,
    notes TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(language_code, retailer_name)
);

CREATE INDEX idx_aff_lang ON affiliate_retailers(language_code);
CREATE INDEX idx_aff_country ON affiliate_retailers(country_code);
CREATE INDEX idx_aff_active ON affiliate_retailers(active) WHERE active = TRUE;

-- Pré-insertion des retailers majeurs (voir document séparé pour liste complète)
INSERT INTO affiliate_retailers (language_code, retailer_name, retailer_type, country_code, affiliate_tag, url_template, priority, commission_rate)
VALUES
  -- English
  ('en', 'amazon_com', 'amazon', 'us', 'YOURTAG-20', 'https://www.amazon.com/dp/{isbn}?tag={tag}', 1, 4.5),
  ('en', 'amazon_uk', 'amazon', 'uk', 'YOURTAG-21', 'https://www.amazon.co.uk/dp/{isbn}?tag={tag}', 2, 4.5),
  ('en', 'barnes_noble', 'local', 'us', 'BN_ID', 'https://www.barnesandnoble.com/w/{isbn}', 3, 4.0)
ON CONFLICT (language_code, retailer_name) DO NOTHING;

-- ============================================
-- TABLE 6: USERS (OPTIONNEL – comptes utilisateurs)
-- ============================================
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    username VARCHAR(50) UNIQUE,
    display_name VARCHAR(100),
    avatar_url VARCHAR(1000),
    -- Preferences
    preferred_language VARCHAR(10) DEFAULT 'en',
    theme VARCHAR(20) DEFAULT 'system',  -- 'light', 'dark', 'auto'
    font_size INTEGER DEFAULT 16,        -- Taille police
    -- Stats
    books_read INTEGER DEFAULT 0,
    reading_streak INTEGER DEFAULT 0,    -- Jours consécutifs
    last_read_at TIMESTAMP,
    -- Social
    bio TEXT,
    location VARCHAR(100),
    website VARCHAR(500),
    -- Supabase Auth compatible
    auth_provider VARCHAR(20),            -- 'email', 'google', 'github', etc.
    auth_provider_id VARCHAR(255),
    -- Timing
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    last_seen_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_language ON users(preferred_language);

-- ============================================
-- TABLE 7: USER_LIBRARY (Bibliothèque personnelle)
-- ============================================
CREATE TABLE IF NOT EXISTS user_library (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    book_translation_id INTEGER NOT NULL REFERENCES book_translations(id) ON DELETE CASCADE,
    -- Status
    status VARCHAR(20) DEFAULT 'reading', -- 'reading', 'finished', 'planned', 'dropped'
    current_progress INTEGER DEFAULT 0,    -- % lu
    last_read_page INTEGER DEFAULT 0,
    -- Rating & review
    rating INTEGER CHECK (rating >= 1 AND rating <= 5),
    review_text TEXT,
    review_visible BOOLEAN DEFAULT TRUE,
    -- Timing
    started_at TIMESTAMP,
    finished_at TIMESTAMP,
    last_activity_at TIMESTAMP DEFAULT NOW(),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(user_id, book_translation_id)
);

CREATE INDEX idx_user_library_user ON user_library(user_id);
CREATE INDEX idx_user_library_book ON user_library(book_translation_id);
CREATE INDEX idx_user_library_status ON user_library(status);
CREATE INDEX idx_user_library_rating ON user_library(rating) WHERE rating IS NOT NULL;

-- ============================================
-- TABLE 8: ANNOTATIONS (Surlignages & notes)
-- ============================================
CREATE TABLE IF NOT EXISTS annotations (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    book_translation_id INTEGER NOT NULL REFERENCES book_translations(id) ON DELETE CASCADE,
    -- Location in text
    chapter_id INTEGER,                   -- Optionnel: chapitre
    start_offset INTEGER NOT NULL,        -- Position caractère début
    end_offset INTEGER NOT NULL,          -- Position caractère fin
    selected_text TEXT NOT NULL,
    -- Annotation
    note TEXT,
    annotation_type VARCHAR(20) DEFAULT 'highlight', -- 'highlight', 'note', 'question'
    tags TEXT[],                          -- Tags utilisateur
    -- Visibility
    is_private BOOLEAN DEFAULT TRUE,      -- False = partagé publiquement
    likes_count INTEGER DEFAULT 0,
    -- Timing
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_annotations_user ON annotations(user_id);
CREATE INDEX idx_annotations_book ON annotations(book_translation_id);
CREATE INDEX idx_annotations_public ON annotations(is_private) WHERE is_private = FALSE;
CREATE INDEX idx_annotations_type ON annotations(annotation_type);

-- ============================================
-- TABLE 9: READING_SESSIONS (Historique lecture)
-- ============================================
CREATE TABLE IF NOT EXISTS reading_sessions (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    book_translation_id INTEGER NOT NULL REFERENCES book_translations(id) ON DELETE CASCADE,
    -- Session data
    start_page INTEGER,
    end_page INTEGER,
    duration_seconds INTEGER,             -- Durée de session
    pages_read INTEGER,
    -- Device
    user_agent TEXT,
    device_type VARCHAR(20),              -- 'desktop', 'mobile', 'tablet'
    -- Timing
    started_at TIMESTAMP DEFAULT NOW(),
    ended_at TIMESTAMP
);

CREATE INDEX idx_sessions_user ON reading_sessions(user_id);
CREATE INDEX idx_sessions_book ON reading_sessions(book_translation_id);
CREATE INDEX idx_sessions_time ON reading_sessions(started_at DESC);

-- ============================================
-- TABLE 10: SEARCH_QUERIES (Analytics recherche)
-- ============================================
CREATE TABLE IF NOT EXISTS search_queries (
    id SERIAL PRIMARY KEY,
    query_text TEXT NOT NULL,
    query_language VARCHAR(10),
    results_count INTEGER,
    user_id INTEGER REFERENCES users(id), -- NULL = anonymous
    -- Search type
    search_type VARCHAR(20) DEFAULT 'text', -- 'text', 'semantic', 'author', 'subject'
    -- Successful?
    clicked_book_id INTEGER REFERENCES books(id),
    clicked_at TIMESTAMP,
    -- Timing
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_search_queries_text ON search_queries USING gin(query_text gin_trgm_ops);
CREATE INDEX idx_search_queries_lang ON search_queries(query_language);
CREATE INDEX idx_search_queries_time ON search_queries(created_at DESC);

-- ============================================
-- TABLE 11: AFFILIATE_CLICKS (Tracking affiliation)
-- ============================================
CREATE TABLE IF NOT EXISTS affiliate_clicks (
    id SERIAL PRIMARY KEY,
    book_isbn_id INTEGER REFERENCES book_isbns(id),
    retailer_name VARCHAR(100) NOT NULL,
    user_id INTEGER REFERENCES users(id),
    user_ip INET,
    user_country VARCHAR(10),
    user_agent TEXT,
    -- Click metadata
    clicked_at TIMESTAMP DEFAULT NOW(),
    -- Conversion
    converted BOOLEAN DEFAULT FALSE,      -- Achat confirmé via webhook
    converted_at TIMESTAMP,
    conversion_value DECIMAL(10,2),      -- Montant commission
    order_id VARCHAR(255),                -- ID commande retailer
    -- Geolocation
    geo_city VARCHAR(100),
    geo_region VARCHAR(100)
);

CREATE INDEX idx_affiliate_clicks_isbn ON affiliate_clicks(book_isbn_id);
CREATE INDEX idx_affiliate_clicks_retailer ON affiliate_clicks(retailer_name);
CREATE INDEX idx_affiliate_clicks_time ON affiliate_clicks(clicked_at DESC);
CREATE INDEX idx_affiliate_clicks_converted ON affiliate_clicks(converted) WHERE converted = TRUE;

-- ============================================
-- TABLE 12: SYSTEM_JOBS (Workers IA, imports, etc.)
-- ============================================
CREATE TABLE IF NOT EXISTS system_jobs (
    id SERIAL PRIMARY KEY,
    job_type VARCHAR(100) NOT NULL,       -- 'translation_nllb', 'embedding_generation', 'isbn_lookup', 'import_gutenberg'
    status VARCHAR(20) DEFAULT 'pending', -- 'pending', 'running', 'completed', 'failed'
    -- Job parameters
    parameters JSONB,
    -- Execution
    started_at TIMESTAMP,
    completed_at TIMESTAMP,
    error_message TEXT,
    items_processed INTEGER DEFAULT 0,
    items_total INTEGER,
    -- Worker info
    worker_id VARCHAR(100),
    -- Timing
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_jobs_type ON system_jobs(job_type);
CREATE INDEX idx_jobs_status ON system_jobs(status);
CREATE INDEX idx_jobs_time ON system_jobs(created_at DESC);

-- ============================================
-- TRIGGERS: updated_at automation
-- ============================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply triggers to all tables with updated_at
CREATE TRIGGER update_authors_updated_at BEFORE UPDATE ON authors FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_books_updated_at BEFORE UPDATE ON books FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_translations_updated_at BEFORE UPDATE ON book_translations FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_isbns_updated_at BEFORE UPDATE ON book_isbns FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_user_library_updated_at BEFORE UPDATE ON user_library FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_annotations_updated_at BEFORE UPDATE ON annotations FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_system_jobs_updated_at BEFORE UPDATE ON system_jobs FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- FUNCTIONS UTILITAIRES
-- ============================================

-- Fonction: Trouver la meilleure traduction disponible pour un livre
CREATE OR REPLACE FUNCTION get_best_translation(book_id_param INTEGER, lang_code VARCHAR(10))
RETURNS TABLE (
    translation_id INTEGER,
    title VARCHAR,
    quality VARCHAR,
    is_machine BOOLEAN,
    source VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        bt.id,
        COALESCE(bt.title_translated, b.title_original) as title,
        bt.translation_quality,
        bt.is_machine_translated,
        bt.source_project
    FROM book_translations bt
    JOIN books b ON bt.book_id = b.id
    WHERE bt.book_id = book_id_param
      AND bt.language_code = lang_code
    ORDER BY 
        CASE bt.translation_quality
            WHEN 'human_professional' THEN 1
            WHEN 'human_volunteer' THEN 2
            ELSE 3
        END,
        bt.is_machine_translated ASC
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;

-- Fonction: Générer lien affilié pour une traduction
CREATE OR REPLACE FUNCTION generate_affiliate_url(
    isbn_param VARCHAR(13),
    language_param VARCHAR(10),
    country_param VARCHAR(10) DEFAULT NULL
)
RETURNS TEXT AS $$
DECLARE
    retailer_record RECORD;
    url_result TEXT;
BEGIN
    -- Trouver le retailer prioritaire pour cette langue/pays
    SELECT url_template, affiliate_tag INTO retailer_record
    FROM affiliate_retailers
    WHERE language_code = language_param
      AND active = TRUE
      AND (country_code = country_param OR country_param IS NULL)
    ORDER BY 
        CASE WHEN country_code = country_param THEN 0 ELSE 1 END,
        priority ASC
    LIMIT 1;
    
    IF NOT FOUND THEN
        RETURN NULL;
    END IF;
    
    -- Substituer placeholders
    url_result := retailer_record.url_template;
    url_result := REPLACE(url_result, '{isbn}', isbn_param);
    url_result := REPLACE(url_result, '{tag}', retailer_record.affiliate_tag);
    url_result := REPLACE(url_result, '{affiliate_id}', retailer_record.affiliate_tag);
    url_result := REPLACE(url_result, '{partner_id}', retailer_record.affiliate_tag);
    
    RETURN url_result;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- VIEWS UTILITAIRES
-- ============================================

-- Vue: Catalogue complet avec traductions
CREATE OR REPLACE VIEW v_book_catalog AS
SELECT 
    b.id as book_id,
    b.title_original,
    b.original_language,
    a.name as author_name,
    a.nationality as author_nationality,
    b.first_publication_year,
    bt.id as translation_id,
    bt.language_code,
    bt.title_translated,
    bt.is_machine_translated,
    bt.translation_quality,
    bi.isbn_13,
    bi.format as book_format,
    -- Stats
    b.read_count,
    b.download_count,
    -- Recherche
    b.subjects,
    b.genres,
    -- Qualité
    b.quality_score,
    b.is_featured
FROM books b
LEFT JOIN authors a ON b.author_id = a.id
LEFT JOIN book_translations bt ON b.id = bt.book_id
LEFT JOIN book_isbns bi ON bt.id = bi.book_translation_id
WHERE bt.id IS NOT NULL  -- Seulement les livres avec au moins une traduction
ORDER BY b.quality_score DESC, b.read_count DESC;

-- Vue: Dashboard qualité traductions
CREATE OR REPLACE VIEW v_translation_quality_dashboard AS
SELECT 
    language_code,
    COUNT(*) as total_translations,
    COUNT(DISTINCT book_id) as unique_books,
    SUM(CASE WHEN is_machine_translated THEN 1 ELSE 0 END) as ai_translations,
    SUM(CASE WHEN is_machine_translated THEN 0 ELSE 1 END) as human_translations,
    ROUND(100.0 * SUM(CASE WHEN is_machine_translated THEN 0 ELSE 1 END) / COUNT(*), 2) as human_pct,
    AVG(word_count) as avg_word_count,
    COUNT(isbn_13) as translations_with_isbn,
    ROUND(100.0 * COUNT(isbn_13) / COUNT(*), 2) as isbn_coverage_pct
FROM book_translations
GROUP BY language_code
ORDER BY total_translations DESC;

-- Vue: Performance affiliation par langue
CREATE OR REPLACE VIEW v_affiliate_performance AS
SELECT 
    bt.language_code,
    ar.retailer_name,
    COUNT(DISTINCT bi.book_translation_id) as books_available,
    SUM(CASE WHEN bt.is_machine_translated THEN 0 ELSE 1 END) as human_translations,
    ar.commission_rate,
    COUNT(ac.id) as total_clicks,
    SUM(CASE WHEN ac.converted THEN 1 ELSE 0 END) as conversions,
    ROUND(SUM(CASE WHEN ac.converted THEN ac.conversion_value ELSE 0 END), 2) as total_earnings
FROM affiliate_retailers ar
LEFT JOIN book_isbns bi ON true  -- cross join to get all books
LEFT JOIN book_translations bt ON bi.book_translation_id = bt.id
LEFT JOIN affiliate_clicks ac ON bi.id = ac.book_isbn_id
WHERE ar.active = TRUE
GROUP BY bt.language_code, ar.retailer_name, ar.commission_rate
ORDER BY bt.language_code, total_clicks DESC;

-- ============================================
-- INSERT DONNÉES EXEMPLES (pour développement)
-- ============================================

-- auteurs exemples
INSERT INTO authors (name, birth_year, death_year, nationality, bio) VALUES
('Victor Hugo', 1802, 1885, 'French', 'Écrivain français, poète et homme politique. Œuvres majeures : Les Misérables, Notre-Dame de Paris.'),
('Leo Tolstoy', 1828, 1910, 'Russian', 'Écrivain russe, auteur de Guerre et Paix et Anna Karénine.'),
('Jane Austen', 1775, 1817, 'British', 'Romancière anglaise, œuvres : Orgueil et Préjugés, Raison et Sentiments.'),
('Mark Twain', 1835, 1910, 'American', 'Écrivain américain, Adventures of Huckleberry Finn, Tom Sawyer.'),
('William Shakespeare', 1564, 1616, 'British', 'Dramaturge et poète anglais, considéré comme le plus grand écrivain de langue anglaise.')
ON CONFLICT DO NOTHING;

-- livres exemples (liés aux auteurs)
INSERT INTO books (gutenberg_id, title_original, author_id, original_language, first_publication_year, source_project, quality_score) VALUES
(174, 'Les Misérables', 1, 'fr', 1862, 'gutenberg', 95),
(2600, 'War and Peace', 2, 'ru', 1869, 'gutenberg', 98),
(161, 'Pride and Prejudice', 3, 'en', 1813, 'gutenberg', 96),
(76, 'Adventures of Huckleberry Finn', 4, 'en', 1884, 'gutenberg', 94),
(100, 'The Complete Works of William Shakespeare', 5, 'en', 1623, 'gutenberg', 100)
ON CONFLICT (gutenberg_id) DO NOTHING;

-- ============================================
-- POLICIES RLS (Row Level Security) – optionnel
-- ============================================
-- ALTER TABLE users ENABLE ROW LEVEL SECURITY;
-- CREATE POLICY user_policy ON users FOR ALL USING (auth.uid() = id);

-- ============================================
-- FIN DU SCHEMA
-- ============================================

-- VACUUM ANALYZE;
-- \dx  -- Voir extensions installées
-- SELECT * FROM pg_extension;

COMMIT;

-- ============================================
-- NOTES D'UTILISATION
-- ============================================

-- 1. Appliquer ce schéma:
--    psql -U postgres -d librarfree_db -f schema.sql

-- 2. Créer un utilisateur dédié:
--    CREATE USER librarian WITH PASSWORD 'secure_password';
--    GRANT CONNECT ON DATABASE librarfree_db TO librarian;
--    GRANT USAGE ON SCHEMA public TO librarian;
--    GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO librarian;
--    ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO librarian;

-- 3. Backup automatique:
--    pg_dump -U postgres -d librarfree_db > backup_$(date +%Y%m%d).sql

-- 4. Monitoring taille DB:
--    SELECT pg_size_pretty(pg_database_size('librarfree_db'));

-- 5. Purge anciens jobs (cron):
--    DELETE FROM system_jobs WHERE created_at < NOW() - INTERVAL '90 days';
