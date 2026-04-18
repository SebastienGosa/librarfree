-- ============================================================
-- LIBRARFREE DATABASE SCHEMA — v2 (UUID-native, multi-tenant ready)
-- ============================================================
-- Changes vs v1:
--   * Every PK/FK migrated SERIAL → UUID (gen_random_uuid())
--   * TIMESTAMP → TIMESTAMPTZ everywhere (timezone-safe)
--   * RLS enabled on user-scoped tables (users, user_library, annotations,
--     reading_sessions, premium_subscriptions, donations, reading_lists)
--   * 8 tables added: categories, book_categories, collections, collection_books,
--     book_files, premium_subscriptions, donations, reading_lists, reading_list_books
--   * Bugs fixed:
--       - Dropped idx_translations_fulltext_{en,fr,de,es} that referenced
--         non-existent column `content` (full-text lives in Meilisearch now)
--       - Rewrote v_affiliate_performance (was cartesian product via LEFT JOIN … ON true)
--       - Added composite index on book_translations to prevent dedup drift
--   * `users.id` is aligned with Supabase `auth.users(id)` (1:1)
-- ============================================================

-- Extensions (also bootstrapped by init-extensions.sql on docker init)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE EXTENSION IF NOT EXISTS vector;
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- ============================================================
-- TABLE 1: authors
-- ============================================================
CREATE TABLE IF NOT EXISTS authors (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID,                          -- NULL = public catalog; set for B2B tenants (Phase 6)
    slug VARCHAR(255) UNIQUE NOT NULL,             -- SEO URL: /authors/victor-hugo
    name VARCHAR(255) NOT NULL,
    birth_year INTEGER,
    death_year INTEGER,
    nationality VARCHAR(100),
    bio TEXT,
    wikipedia_url VARCHAR(500),
    image_url VARCHAR(500),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_authors_name_trgm ON authors USING gin(name gin_trgm_ops);
CREATE INDEX idx_authors_nationality ON authors(nationality);
CREATE INDEX idx_authors_lifespan ON authors(birth_year, death_year);
CREATE INDEX idx_authors_org ON authors(organization_id) WHERE organization_id IS NOT NULL;

-- ============================================================
-- TABLE 2: books (canonical work — language-agnostic)
-- ============================================================
CREATE TABLE IF NOT EXISTS books (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID,
    slug VARCHAR(300) UNIQUE NOT NULL,
    gutenberg_id INTEGER UNIQUE,
    title_original VARCHAR(500) NOT NULL,
    author_id UUID REFERENCES authors(id) ON DELETE SET NULL,
    original_language VARCHAR(10) NOT NULL DEFAULT 'en',
    first_publication_year INTEGER,
    description TEXT,
    cover_image_url VARCHAR(1000),
    cover_credit VARCHAR(255),                     -- artist attribution (Phase 5 cover community)
    average_rating DECIMAL(3,2) DEFAULT 0,
    rating_count INTEGER DEFAULT 0,
    read_count BIGINT DEFAULT 0,
    download_count BIGINT DEFAULT 0,
    subjects TEXT[],
    genres TEXT[],
    source_project VARCHAR(100),
    source_identifier VARCHAR(255),
    source_url VARCHAR(1000),
    quality_score INTEGER DEFAULT 80 CHECK (quality_score BETWEEN 0 AND 100),
    is_featured BOOLEAN DEFAULT FALSE,
    featured_reason VARCHAR(255),
    age_restricted BOOLEAN DEFAULT FALSE,           -- 18+ gating (Sade, Crébillon, etc.)
    license VARCHAR(50) DEFAULT 'public_domain',    -- 'public_domain', 'cc0', 'cc_by', etc.
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_books_title_trgm ON books USING gin(title_original gin_trgm_ops);
CREATE INDEX idx_books_original_lang ON books(original_language);
CREATE INDEX idx_books_year ON books(first_publication_year);
CREATE INDEX idx_books_source ON books(source_project);
CREATE INDEX idx_books_quality ON books(quality_score DESC);
CREATE INDEX idx_books_featured ON books(is_featured) WHERE is_featured = TRUE;
CREATE INDEX idx_books_org ON books(organization_id) WHERE organization_id IS NOT NULL;
CREATE INDEX idx_books_subjects_gin ON books USING gin(subjects);
CREATE INDEX idx_books_genres_gin ON books USING gin(genres);

-- ============================================================
-- TABLE 3: book_translations (one row per (book, language) pair)
-- ============================================================
CREATE TABLE IF NOT EXISTS book_translations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    book_id UUID NOT NULL REFERENCES books(id) ON DELETE CASCADE,
    language_code VARCHAR(10) NOT NULL DEFAULT 'en',
    title_translated VARCHAR(500),
    description_translated TEXT,
    is_machine_translated BOOLEAN DEFAULT FALSE,
    translation_quality VARCHAR(50) NOT NULL DEFAULT 'human_unknown',
        -- allowed: human_professional, human_volunteer, machine_nllb, machine_m2m100, machine_other, human_unknown
    translator_name VARCHAR(255),
    translator_bio TEXT,
    publisher VARCHAR(255),
    publication_year INTEGER,
    translation_edition VARCHAR(100),
    isbn_13 VARCHAR(13),
    source_project VARCHAR(100),                    -- 'standardebooks', 'wikisource', 'nllb_fallback', …
    source_identifier VARCHAR(255),
    source_url VARCHAR(1000),
    word_count INTEGER,
    reading_time_minutes INTEGER,
    readability_score DECIMAL(4,2),                 -- Flesch-Kincaid
    embedding vector(768),                          -- nomic-embed-text-v1.5
    embedding_model VARCHAR(50) DEFAULT 'nomic-embed-text-v1.5',
    embedding_generated_at TIMESTAMPTZ,
    quality_check_score INTEGER DEFAULT 100 CHECK (quality_check_score BETWEEN 0 AND 100),
        -- detects mojibake, OCR errors — set by workers/importers pipeline
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT chk_language_format CHECK (language_code ~ '^[a-z]{2}(-[A-Z]{2})?$')
);

CREATE INDEX idx_translations_book ON book_translations(book_id);
CREATE INDEX idx_translations_lang ON book_translations(language_code);
CREATE INDEX idx_translations_quality ON book_translations(translation_quality);
CREATE INDEX idx_translations_is_ai ON book_translations(is_machine_translated);
CREATE INDEX idx_translations_isbn ON book_translations(isbn_13) WHERE isbn_13 IS NOT NULL;
CREATE INDEX idx_translations_wordcount ON book_translations(word_count);
CREATE INDEX idx_translations_embedding ON book_translations USING hnsw (embedding vector_cosine_ops);

-- Non-unique composite index: helps dedup drift between imports from same source
CREATE INDEX idx_translations_dedup
    ON book_translations(book_id, language_code, source_project, source_identifier);

-- NOTE: Full-text search lives in Meilisearch (off-Postgres). No tsvector indexes on content —
-- the prior v1 schema referenced a non-existent `content` column, causing schema creation to fail.

-- ============================================================
-- TABLE 4: book_files (multi-format downloadable files — Phase 2 download/send-to-ereader)
-- ============================================================
CREATE TABLE IF NOT EXISTS book_files (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    book_translation_id UUID NOT NULL REFERENCES book_translations(id) ON DELETE CASCADE,
    format VARCHAR(20) NOT NULL CHECK (format IN ('epub','pdf','mobi','azw3','txt','html','mp3','m4b')),
    file_url VARCHAR(1000) NOT NULL,                -- R2/MinIO URL
    file_size_bytes BIGINT NOT NULL,
    checksum_sha256 CHAR(64),
    is_original BOOLEAN DEFAULT FALSE,              -- true = source file; false = converted via Calibre
    generator VARCHAR(100),                         -- 'original', 'calibre-7.x', 'piper-tts-1.x', …
    duration_seconds INTEGER,                       -- audiobooks only
    voice VARCHAR(50),                              -- audiobooks: Piper voice model id
    download_count BIGINT DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(book_translation_id, format, voice)
);

CREATE INDEX idx_book_files_translation ON book_files(book_translation_id);
CREATE INDEX idx_book_files_format ON book_files(format);

-- ============================================================
-- TABLE 5: book_isbns (per-edition ISBN + affiliate payload)
-- ============================================================
CREATE TABLE IF NOT EXISTS book_isbns (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    book_translation_id UUID NOT NULL REFERENCES book_translations(id) ON DELETE CASCADE,
    isbn_13 VARCHAR(13) UNIQUE NOT NULL,
    isbn_10 VARCHAR(10),
    publisher VARCHAR(255),
    publication_year INTEGER,
    edition VARCHAR(100),
    format VARCHAR(20),                             -- 'hardcover', 'paperback', 'ebook', 'audiobook'
    affiliate_links JSONB,                          -- { "amazon_com": "…", "fnac": "…", … }
    pages INTEGER,
    weight_grams INTEGER,
    dimensions VARCHAR(50),
    source VARCHAR(100),                            -- 'isbndb', 'openlibrary', 'google_books', 'manual'
    verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_isbns_translation ON book_isbns(book_translation_id);
CREATE INDEX idx_isbns_isbn13 ON book_isbns(isbn_13);
CREATE INDEX idx_isbns_publisher ON book_isbns(publisher);
CREATE INDEX idx_isbns_verified ON book_isbns(verified) WHERE verified = TRUE;

-- ============================================================
-- TABLE 6: categories (hierarchical taxonomy — philosophy > ethics, etc.)
-- ============================================================
CREATE TABLE IF NOT EXISTS categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    slug VARCHAR(120) UNIQUE NOT NULL,
    name_i18n JSONB NOT NULL,                       -- { "en": "Philosophy", "fr": "Philosophie", … }
    description_i18n JSONB,
    parent_id UUID REFERENCES categories(id) ON DELETE SET NULL,
    sort_order INTEGER DEFAULT 0,
    icon VARCHAR(50),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_categories_parent ON categories(parent_id);

-- ============================================================
-- TABLE 7: book_categories (many-to-many book ↔ category)
-- ============================================================
CREATE TABLE IF NOT EXISTS book_categories (
    book_id UUID NOT NULL REFERENCES books(id) ON DELETE CASCADE,
    category_id UUID NOT NULL REFERENCES categories(id) ON DELETE CASCADE,
    is_primary BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    PRIMARY KEY (book_id, category_id)
);

CREATE INDEX idx_book_categories_category ON book_categories(category_id);
CREATE INDEX idx_book_categories_primary ON book_categories(book_id) WHERE is_primary = TRUE;

-- ============================================================
-- TABLE 8: collections (curated editorial groupings — Curator Program, Phase 5)
-- ============================================================
CREATE TABLE IF NOT EXISTS collections (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    slug VARCHAR(200) UNIQUE NOT NULL,
    curator_user_id UUID,                           -- nullable: editorial team collections
    title_i18n JSONB NOT NULL,
    description_i18n JSONB,
    cover_image_url VARCHAR(1000),
    is_published BOOLEAN DEFAULT FALSE,
    is_official BOOLEAN DEFAULT FALSE,              -- marked by editorial team
    organization_id UUID,                           -- NULL = public; Phase 6 B2B
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_collections_curator ON collections(curator_user_id);
CREATE INDEX idx_collections_published ON collections(is_published) WHERE is_published = TRUE;
CREATE INDEX idx_collections_official ON collections(is_official) WHERE is_official = TRUE;

-- ============================================================
-- TABLE 9: collection_books (ordered many-to-many)
-- ============================================================
CREATE TABLE IF NOT EXISTS collection_books (
    collection_id UUID NOT NULL REFERENCES collections(id) ON DELETE CASCADE,
    book_id UUID NOT NULL REFERENCES books(id) ON DELETE CASCADE,
    sort_order INTEGER DEFAULT 0,
    note TEXT,                                      -- curator annotation for this book within the collection
    added_at TIMESTAMPTZ DEFAULT NOW(),
    PRIMARY KEY (collection_id, book_id)
);

CREATE INDEX idx_collection_books_order ON collection_books(collection_id, sort_order);

-- ============================================================
-- TABLE 10: affiliate_retailers (configuration)
-- ============================================================
CREATE TABLE IF NOT EXISTS affiliate_retailers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
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
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(language_code, retailer_name)
);

CREATE INDEX idx_aff_lang ON affiliate_retailers(language_code);
CREATE INDEX idx_aff_country ON affiliate_retailers(country_code);
CREATE INDEX idx_aff_active ON affiliate_retailers(active) WHERE active = TRUE;

INSERT INTO affiliate_retailers (language_code, retailer_name, retailer_type, country_code, affiliate_tag, url_template, priority, commission_rate) VALUES
    ('en', 'amazon_com', 'amazon', 'us', 'YOURTAG-20', 'https://www.amazon.com/dp/{isbn}?tag={tag}', 1, 4.5),
    ('en', 'amazon_uk', 'amazon', 'uk', 'YOURTAG-21', 'https://www.amazon.co.uk/dp/{isbn}?tag={tag}', 2, 4.5),
    ('en', 'barnes_noble', 'local', 'us', 'BN_ID', 'https://www.barnesandnoble.com/w/{isbn}', 3, 4.0)
ON CONFLICT (language_code, retailer_name) DO NOTHING;

-- ============================================================
-- TABLE 11: users (mirror of Supabase auth.users — id matches)
-- ============================================================
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY,                            -- = auth.users.id (set by trigger below)
    email VARCHAR(255) UNIQUE NOT NULL,
    username VARCHAR(50) UNIQUE,
    display_name VARCHAR(100),
    avatar_url VARCHAR(1000),
    preferred_language VARCHAR(10) DEFAULT 'en',
    theme VARCHAR(20) DEFAULT 'system',
    reader_prefs JSONB DEFAULT '{}'::jsonb,         -- font, size, line height, focus mode, etc.
    books_read INTEGER DEFAULT 0,
    reading_streak INTEGER DEFAULT 0,
    last_read_at TIMESTAMPTZ,
    bio TEXT,
    location VARCHAR(100),
    website VARCHAR(500),
    is_scholar BOOLEAN DEFAULT FALSE,               -- Scholars Program (Phase 3+)
    is_curator BOOLEAN DEFAULT FALSE,               -- Curator Program (Phase 5)
    is_supporter BOOLEAN DEFAULT FALSE,             -- donated or premium at least once
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    last_seen_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_language ON users(preferred_language);
CREATE INDEX idx_users_supporter ON users(is_supporter) WHERE is_supporter = TRUE;

-- ============================================================
-- TABLE 12: user_library (personal shelf)
-- ============================================================
CREATE TABLE IF NOT EXISTS user_library (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    book_translation_id UUID NOT NULL REFERENCES book_translations(id) ON DELETE CASCADE,
    status VARCHAR(20) DEFAULT 'reading' CHECK (status IN ('reading','finished','planned','dropped')),
    current_progress INTEGER DEFAULT 0,
    last_read_page INTEGER DEFAULT 0,
    rating INTEGER CHECK (rating >= 1 AND rating <= 5),
    review_text TEXT,
    review_visible BOOLEAN DEFAULT TRUE,
    started_at TIMESTAMPTZ,
    finished_at TIMESTAMPTZ,
    last_activity_at TIMESTAMPTZ DEFAULT NOW(),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, book_translation_id)
);

CREATE INDEX idx_user_library_user ON user_library(user_id);
CREATE INDEX idx_user_library_book ON user_library(book_translation_id);
CREATE INDEX idx_user_library_status ON user_library(status);
CREATE INDEX idx_user_library_rating ON user_library(rating) WHERE rating IS NOT NULL;

-- ============================================================
-- TABLE 13: reading_lists + reading_list_books (user-curated lists)
-- ============================================================
CREATE TABLE IF NOT EXISTS reading_lists (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    is_public BOOLEAN DEFAULT FALSE,
    fork_of_id UUID REFERENCES reading_lists(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_reading_lists_user ON reading_lists(user_id);
CREATE INDEX idx_reading_lists_public ON reading_lists(is_public) WHERE is_public = TRUE;
CREATE INDEX idx_reading_lists_fork ON reading_lists(fork_of_id) WHERE fork_of_id IS NOT NULL;

CREATE TABLE IF NOT EXISTS reading_list_books (
    reading_list_id UUID NOT NULL REFERENCES reading_lists(id) ON DELETE CASCADE,
    book_id UUID NOT NULL REFERENCES books(id) ON DELETE CASCADE,
    sort_order INTEGER DEFAULT 0,
    note TEXT,
    added_at TIMESTAMPTZ DEFAULT NOW(),
    PRIMARY KEY (reading_list_id, book_id)
);

CREATE INDEX idx_rlb_order ON reading_list_books(reading_list_id, sort_order);

-- ============================================================
-- TABLE 14: annotations (highlights + notes)
-- ============================================================
CREATE TABLE IF NOT EXISTS annotations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    book_translation_id UUID NOT NULL REFERENCES book_translations(id) ON DELETE CASCADE,
    chapter_id INTEGER,
    start_offset INTEGER NOT NULL,
    end_offset INTEGER NOT NULL,
    selected_text TEXT NOT NULL,
    note TEXT,
    annotation_type VARCHAR(20) DEFAULT 'highlight' CHECK (annotation_type IN ('highlight','note','question','bookmark')),
    highlight_color VARCHAR(20),                    -- 4 signature colors
    tags TEXT[],
    is_private BOOLEAN DEFAULT TRUE,
    likes_count INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_annotations_user ON annotations(user_id);
CREATE INDEX idx_annotations_book ON annotations(book_translation_id);
CREATE INDEX idx_annotations_public ON annotations(is_private) WHERE is_private = FALSE;
CREATE INDEX idx_annotations_type ON annotations(annotation_type);
CREATE INDEX idx_annotations_tags_gin ON annotations USING gin(tags);

-- ============================================================
-- TABLE 15: reading_sessions (per-session telemetry, privacy-light)
-- ============================================================
CREATE TABLE IF NOT EXISTS reading_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    book_translation_id UUID NOT NULL REFERENCES book_translations(id) ON DELETE CASCADE,
    start_page INTEGER,
    end_page INTEGER,
    duration_seconds INTEGER,
    pages_read INTEGER,
    user_agent TEXT,
    device_type VARCHAR(20) CHECK (device_type IN ('desktop','mobile','tablet','ereader','other')),
    started_at TIMESTAMPTZ DEFAULT NOW(),
    ended_at TIMESTAMPTZ
);

CREATE INDEX idx_sessions_user ON reading_sessions(user_id);
CREATE INDEX idx_sessions_book ON reading_sessions(book_translation_id);
CREATE INDEX idx_sessions_time ON reading_sessions(started_at DESC);

-- ============================================================
-- TABLE 16: premium_subscriptions (Stripe-backed, Phase 4)
-- ============================================================
CREATE TABLE IF NOT EXISTS premium_subscriptions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    stripe_customer_id VARCHAR(255) UNIQUE,
    stripe_subscription_id VARCHAR(255) UNIQUE,
    plan VARCHAR(50) NOT NULL CHECK (plan IN ('monthly','yearly','lifetime','api_indie','api_startup','api_enterprise')),
    status VARCHAR(30) NOT NULL CHECK (status IN ('trialing','active','past_due','canceled','incomplete','incomplete_expired','unpaid','paused')),
    current_period_start TIMESTAMPTZ,
    current_period_end TIMESTAMPTZ,
    cancel_at TIMESTAMPTZ,
    canceled_at TIMESTAMPTZ,
    trial_end TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_premium_user ON premium_subscriptions(user_id);
CREATE INDEX idx_premium_active ON premium_subscriptions(status) WHERE status IN ('trialing','active');
CREATE INDEX idx_premium_stripe_cust ON premium_subscriptions(stripe_customer_id);

-- ============================================================
-- TABLE 17: donations (one-shot or recurring, transparent dashboard)
-- ============================================================
CREATE TABLE IF NOT EXISTS donations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,   -- NULL = anonymous donation
    stripe_payment_intent_id VARCHAR(255) UNIQUE,
    amount_cents BIGINT NOT NULL CHECK (amount_cents > 0),
    currency VARCHAR(3) NOT NULL DEFAULT 'EUR',
    is_recurring BOOLEAN DEFAULT FALSE,
    stripe_subscription_id VARCHAR(255),                    -- if recurring
    message TEXT,                                           -- optional public dedication
    display_name VARCHAR(100),                              -- name shown on transparency dashboard
    anonymous BOOLEAN DEFAULT FALSE,
    campaign VARCHAR(100),                                  -- e.g. 'launch_2026', 'cover_artists_grant'
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_donations_user ON donations(user_id);
CREATE INDEX idx_donations_campaign ON donations(campaign);
CREATE INDEX idx_donations_time ON donations(created_at DESC);

-- ============================================================
-- TABLE 18: search_queries (analytics — anonymous or opt-in user-linked)
-- ============================================================
CREATE TABLE IF NOT EXISTS search_queries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    query_text TEXT NOT NULL,
    query_language VARCHAR(10),
    results_count INTEGER,
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    search_type VARCHAR(20) DEFAULT 'text' CHECK (search_type IN ('text','semantic','author','subject','voice')),
    clicked_book_id UUID REFERENCES books(id) ON DELETE SET NULL,
    clicked_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_search_queries_text_trgm ON search_queries USING gin(query_text gin_trgm_ops);
CREATE INDEX idx_search_queries_lang ON search_queries(query_language);
CREATE INDEX idx_search_queries_time ON search_queries(created_at DESC);

-- ============================================================
-- TABLE 19: affiliate_clicks (tracking)
-- ============================================================
CREATE TABLE IF NOT EXISTS affiliate_clicks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    book_isbn_id UUID REFERENCES book_isbns(id) ON DELETE SET NULL,
    retailer_name VARCHAR(100) NOT NULL,
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    user_ip INET,
    user_country VARCHAR(10),
    user_agent TEXT,
    clicked_at TIMESTAMPTZ DEFAULT NOW(),
    converted BOOLEAN DEFAULT FALSE,
    converted_at TIMESTAMPTZ,
    conversion_value DECIMAL(10,2),
    order_id VARCHAR(255),
    geo_city VARCHAR(100),
    geo_region VARCHAR(100)
);

CREATE INDEX idx_affiliate_clicks_isbn ON affiliate_clicks(book_isbn_id);
CREATE INDEX idx_affiliate_clicks_retailer ON affiliate_clicks(retailer_name);
CREATE INDEX idx_affiliate_clicks_time ON affiliate_clicks(clicked_at DESC);
CREATE INDEX idx_affiliate_clicks_converted ON affiliate_clicks(converted) WHERE converted = TRUE;

-- ============================================================
-- TABLE 20: system_jobs (BullMQ mirror for audit / Phase 1+ pipeline)
-- ============================================================
CREATE TABLE IF NOT EXISTS system_jobs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    job_type VARCHAR(100) NOT NULL,
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending','running','completed','failed','cancelled')),
    parameters JSONB,
    started_at TIMESTAMPTZ,
    completed_at TIMESTAMPTZ,
    error_message TEXT,
    items_processed INTEGER DEFAULT 0,
    items_total INTEGER,
    worker_id VARCHAR(100),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_jobs_type ON system_jobs(job_type);
CREATE INDEX idx_jobs_status ON system_jobs(status);
CREATE INDEX idx_jobs_time ON system_jobs(created_at DESC);

-- ============================================================
-- TRIGGERS: updated_at automation
-- ============================================================
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DO $$
DECLARE
    t TEXT;
BEGIN
    FOR t IN SELECT unnest(ARRAY[
        'authors','books','book_translations','book_isbns','categories','collections',
        'affiliate_retailers','users','user_library','reading_lists','annotations',
        'premium_subscriptions','system_jobs'
    ])
    LOOP
        EXECUTE format(
            'DROP TRIGGER IF EXISTS trg_%I_updated_at ON %I; ' ||
            'CREATE TRIGGER trg_%I_updated_at BEFORE UPDATE ON %I ' ||
            'FOR EACH ROW EXECUTE FUNCTION set_updated_at();',
            t, t, t, t
        );
    END LOOP;
END;
$$;

-- ============================================================
-- SUPABASE AUTH → public.users sync
-- ============================================================
-- When a new row appears in auth.users, create the matching public.users row.
-- Skipped in plain docker-compose (no auth schema); runs on Supabase.
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.schemata WHERE schema_name = 'auth') THEN
        EXECUTE $f$
            CREATE OR REPLACE FUNCTION public.handle_new_auth_user()
            RETURNS TRIGGER AS $inner$
            BEGIN
                INSERT INTO public.users (id, email, display_name)
                VALUES (NEW.id, NEW.email, COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(NEW.email,'@',1)))
                ON CONFLICT (id) DO NOTHING;
                RETURN NEW;
            END;
            $inner$ LANGUAGE plpgsql SECURITY DEFINER;
        $f$;
        EXECUTE 'DROP TRIGGER IF EXISTS trg_on_auth_user_created ON auth.users';
        EXECUTE 'CREATE TRIGGER trg_on_auth_user_created AFTER INSERT ON auth.users ' ||
                'FOR EACH ROW EXECUTE FUNCTION public.handle_new_auth_user()';
    END IF;
END;
$$;

-- ============================================================
-- HELPER FUNCTIONS
-- ============================================================
CREATE OR REPLACE FUNCTION get_best_translation(book_id_param UUID, lang_code VARCHAR(10))
RETURNS TABLE (
    translation_id UUID,
    title VARCHAR,
    quality VARCHAR,
    is_machine BOOLEAN,
    source VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        bt.id,
        COALESCE(bt.title_translated, b.title_original) AS title,
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
        bt.is_machine_translated ASC,
        bt.quality_check_score DESC
    LIMIT 1;
END;
$$ LANGUAGE plpgsql STABLE;

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

    url_result := retailer_record.url_template;
    url_result := REPLACE(url_result, '{isbn}', isbn_param);
    url_result := REPLACE(url_result, '{tag}', retailer_record.affiliate_tag);
    url_result := REPLACE(url_result, '{affiliate_id}', retailer_record.affiliate_tag);
    url_result := REPLACE(url_result, '{partner_id}', retailer_record.affiliate_tag);

    RETURN url_result;
END;
$$ LANGUAGE plpgsql STABLE;

-- ============================================================
-- VIEWS
-- ============================================================
CREATE OR REPLACE VIEW v_book_catalog AS
SELECT
    b.id AS book_id,
    b.slug AS book_slug,
    b.title_original,
    b.original_language,
    a.name AS author_name,
    a.slug AS author_slug,
    a.nationality AS author_nationality,
    b.first_publication_year,
    bt.id AS translation_id,
    bt.language_code,
    bt.title_translated,
    bt.is_machine_translated,
    bt.translation_quality,
    bi.isbn_13,
    bi.format AS book_format,
    b.read_count,
    b.download_count,
    b.subjects,
    b.genres,
    b.quality_score,
    b.is_featured
FROM books b
LEFT JOIN authors a ON b.author_id = a.id
LEFT JOIN book_translations bt ON bt.book_id = b.id
LEFT JOIN book_isbns bi ON bi.book_translation_id = bt.id
WHERE bt.id IS NOT NULL
ORDER BY b.quality_score DESC, b.read_count DESC;

CREATE OR REPLACE VIEW v_translation_quality_dashboard AS
SELECT
    language_code,
    COUNT(*) AS total_translations,
    COUNT(DISTINCT book_id) AS unique_books,
    SUM(CASE WHEN is_machine_translated THEN 1 ELSE 0 END) AS ai_translations,
    SUM(CASE WHEN is_machine_translated THEN 0 ELSE 1 END) AS human_translations,
    ROUND(100.0 * SUM(CASE WHEN is_machine_translated THEN 0 ELSE 1 END) / NULLIF(COUNT(*),0), 2) AS human_pct,
    AVG(word_count) AS avg_word_count,
    COUNT(isbn_13) AS translations_with_isbn,
    ROUND(100.0 * COUNT(isbn_13) / NULLIF(COUNT(*),0), 2) AS isbn_coverage_pct
FROM book_translations
GROUP BY language_code
ORDER BY total_translations DESC;

-- Fixed view: previous LEFT JOIN book_isbns ON true produced a cartesian product.
-- Now we join through book_translations on language_code, then isbns, then clicks.
CREATE OR REPLACE VIEW v_affiliate_performance AS
SELECT
    ar.language_code,
    ar.retailer_name,
    ar.commission_rate,
    COUNT(DISTINCT bi.id) AS books_with_isbn,
    SUM(CASE WHEN bt.is_machine_translated THEN 0 ELSE 1 END) AS human_translations,
    COUNT(ac.id) AS total_clicks,
    SUM(CASE WHEN ac.converted THEN 1 ELSE 0 END) AS conversions,
    ROUND(SUM(CASE WHEN ac.converted THEN ac.conversion_value ELSE 0 END)::numeric, 2) AS total_earnings
FROM affiliate_retailers ar
LEFT JOIN book_translations bt ON bt.language_code = ar.language_code
LEFT JOIN book_isbns bi ON bi.book_translation_id = bt.id
LEFT JOIN affiliate_clicks ac ON ac.book_isbn_id = bi.id AND ac.retailer_name = ar.retailer_name
WHERE ar.active = TRUE
GROUP BY ar.language_code, ar.retailer_name, ar.commission_rate
ORDER BY ar.language_code, total_clicks DESC NULLS LAST;

-- Transparency view (public dashboard, Phase 4)
CREATE OR REPLACE VIEW v_transparency_monthly AS
SELECT
    date_trunc('month', created_at) AS month,
    SUM(amount_cents) / 100.0 AS donation_total,
    COUNT(*) AS donation_count,
    COUNT(DISTINCT user_id) FILTER (WHERE user_id IS NOT NULL) AS unique_donors
FROM donations
GROUP BY 1
ORDER BY 1 DESC;

-- ============================================================
-- ROW LEVEL SECURITY (Supabase)
-- ============================================================
ALTER TABLE users                  ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_library           ENABLE ROW LEVEL SECURITY;
ALTER TABLE reading_lists          ENABLE ROW LEVEL SECURITY;
ALTER TABLE reading_list_books     ENABLE ROW LEVEL SECURITY;
ALTER TABLE annotations            ENABLE ROW LEVEL SECURITY;
ALTER TABLE reading_sessions       ENABLE ROW LEVEL SECURITY;
ALTER TABLE premium_subscriptions  ENABLE ROW LEVEL SECURITY;
ALTER TABLE donations              ENABLE ROW LEVEL SECURITY;

-- Helper that returns NULL outside Supabase (so the schema still loads in plain docker)
CREATE OR REPLACE FUNCTION current_auth_uid() RETURNS UUID AS $$
BEGIN
    RETURN COALESCE(
        NULLIF(current_setting('request.jwt.claim.sub', true), '')::uuid,
        NULL
    );
EXCEPTION WHEN OTHERS THEN
    RETURN NULL;
END;
$$ LANGUAGE plpgsql STABLE;

-- users: owner read/update; public read of profile-safe columns handled at view/query layer
DROP POLICY IF EXISTS users_self_select ON users;
CREATE POLICY users_self_select ON users FOR SELECT USING (id = current_auth_uid() OR true);
    -- keep SELECT open so public profiles render; sensitive columns must be filtered at the query layer
DROP POLICY IF EXISTS users_self_update ON users;
CREATE POLICY users_self_update ON users FOR UPDATE USING (id = current_auth_uid());
DROP POLICY IF EXISTS users_self_insert ON users;
CREATE POLICY users_self_insert ON users FOR INSERT WITH CHECK (id = current_auth_uid());

DROP POLICY IF EXISTS user_library_owner ON user_library;
CREATE POLICY user_library_owner ON user_library FOR ALL
    USING (user_id = current_auth_uid())
    WITH CHECK (user_id = current_auth_uid());

DROP POLICY IF EXISTS reading_lists_owner ON reading_lists;
CREATE POLICY reading_lists_owner ON reading_lists FOR ALL
    USING (user_id = current_auth_uid() OR is_public = TRUE)
    WITH CHECK (user_id = current_auth_uid());

DROP POLICY IF EXISTS reading_list_books_owner ON reading_list_books;
CREATE POLICY reading_list_books_owner ON reading_list_books FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM reading_lists rl
            WHERE rl.id = reading_list_books.reading_list_id
              AND (rl.user_id = current_auth_uid() OR rl.is_public = TRUE)
        )
    )
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM reading_lists rl
            WHERE rl.id = reading_list_books.reading_list_id
              AND rl.user_id = current_auth_uid()
        )
    );

DROP POLICY IF EXISTS annotations_rw ON annotations;
CREATE POLICY annotations_rw ON annotations FOR ALL
    USING (user_id = current_auth_uid() OR is_private = FALSE)
    WITH CHECK (user_id = current_auth_uid());

DROP POLICY IF EXISTS reading_sessions_owner ON reading_sessions;
CREATE POLICY reading_sessions_owner ON reading_sessions FOR ALL
    USING (user_id = current_auth_uid())
    WITH CHECK (user_id = current_auth_uid());

DROP POLICY IF EXISTS premium_owner ON premium_subscriptions;
CREATE POLICY premium_owner ON premium_subscriptions FOR SELECT
    USING (user_id = current_auth_uid());
    -- All writes go through service_role (Stripe webhooks) — RLS blocks direct writes.

DROP POLICY IF EXISTS donations_self ON donations;
CREATE POLICY donations_self ON donations FOR SELECT
    USING (user_id = current_auth_uid() OR anonymous = FALSE);
    -- Writes via service_role only.

-- ============================================================
-- SAMPLE DATA (dev only)
-- ============================================================
WITH a AS (
    INSERT INTO authors (slug, name, birth_year, death_year, nationality, bio) VALUES
        ('victor-hugo',       'Victor Hugo',         1802, 1885, 'French',   'Écrivain français — Les Misérables, Notre-Dame de Paris.'),
        ('leo-tolstoy',       'Leo Tolstoy',         1828, 1910, 'Russian',  'Romancier russe — Guerre et Paix, Anna Karénine.'),
        ('jane-austen',       'Jane Austen',         1775, 1817, 'British',  'Romancière anglaise — Orgueil et Préjugés.'),
        ('mark-twain',        'Mark Twain',          1835, 1910, 'American', 'Écrivain américain — Huckleberry Finn, Tom Sawyer.'),
        ('william-shakespeare','William Shakespeare', 1564, 1616, 'British',  'Dramaturge anglais.')
    ON CONFLICT (slug) DO NOTHING
    RETURNING id, slug
)
INSERT INTO books (slug, gutenberg_id, title_original, author_id, original_language, first_publication_year, source_project, quality_score)
SELECT v.slug, v.gid, v.title, a.id, v.lang, v.year, 'gutenberg', v.q
FROM (VALUES
    ('les-miserables',       174,  'Les Misérables',                          'fr', 1862, 95, 'victor-hugo'),
    ('war-and-peace',        2600, 'War and Peace',                           'ru', 1869, 98, 'leo-tolstoy'),
    ('pride-and-prejudice',  161,  'Pride and Prejudice',                     'en', 1813, 96, 'jane-austen'),
    ('huckleberry-finn',     76,   'Adventures of Huckleberry Finn',          'en', 1884, 94, 'mark-twain'),
    ('shakespeare-complete', 100,  'The Complete Works of William Shakespeare','en', 1623, 100,'william-shakespeare')
) AS v(slug, gid, title, lang, year, q, author_slug)
JOIN a ON a.slug = v.author_slug
ON CONFLICT (slug) DO NOTHING;

COMMIT;

-- ============================================================
-- OPERATIONAL NOTES
-- ============================================================
-- Apply:
--   psql "$DATABASE_URL" -f database/schema.sql
--
-- Size monitoring:
--   SELECT pg_size_pretty(pg_database_size(current_database()));
--
-- Purge old jobs (cron):
--   DELETE FROM system_jobs WHERE created_at < NOW() - INTERVAL '90 days';
