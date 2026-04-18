#!/bin/bash
# ============================================
# Librarfree Quick Setup Script
# Déploiement rapide local + imports initiaux
# ============================================
#
# Usage: ./scripts/setup_dev.sh
# Requirements: Docker, Node.js 18+, pnpm
# ============================================

set -e  # Exit on error

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}=========================================${NC}"
echo -e "${GREEN}   Librarfree – Setup Dev Environment    ${NC}"
echo -e "${GREEN}=========================================${NC}"

# ============================================
# 1. Check prerequisites
# ============================================
echo -e "\n${YELLOW}[1/7] Checking prerequisites...${NC}"

# Check Docker
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker is not installed. Please install Docker first.${NC}"
    exit 1
fi
echo "✅ Docker is installed"

# Check Docker Compose
if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    echo -e "${RED}❌ Docker Compose is not installed.${NC}"
    exit 1
fi
echo "✅ Docker Compose is installed"

# Check Node.js
if ! command -v node &> /dev/null; then
    echo -e "${RED}❌ Node.js is not installed. Please install Node.js 18+.${NC}"
    exit 1
fi
NODE_VERSION=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
if [ "$NODE_VERSION" -lt 18 ]; then
    echo -e "${RED}❌ Node.js version must be 18+ (current: $(node -v))${NC}"
    exit 1
fi
echo "✅ Node.js $(node -v) is installed"

# Check pnpm
if ! command -v pnpm &> /dev/null; then
    echo -e "${YELLOW}⚠️  pnpm is not installed. Installing pnpm...${NC}"
    npm install -g pnpm
    echo "✅ pnpm installed"
else
    echo "✅ pnpm is installed"
fi

# ============================================
# 2. Start Docker services
# ============================================
echo -e "\n${YELLOW}[2/7] Starting Docker services (PostgreSQL, Meilisearch, Redis)...${NC}"
docker-compose up -d postgres meilisearch redis
echo "✅ Services started"

# Wait for PostgreSQL to be ready
echo -e "${YELLOW}⏳ Waiting for PostgreSQL...${NC}"
for i in $(seq 1 30); do
    if docker-compose exec -T postgres pg_isready -U postgres &> /dev/null; then
        echo "✅ PostgreSQL is ready"
        break
    fi
    if [ $i -eq 30 ]; then
        echo -e "${RED}❌ PostgreSQL failed to start${NC}"
        exit 1
    fi
    sleep 2
done

# ============================================
# 3. Install dependencies
# ============================================
echo -e "\n${YELLOW}[3/7] Installing Node.js dependencies...${NC}"
pnpm install
echo "✅ Dependencies installed"

# ============================================
# 4. Setup database schema
# ============================================
echo -e "\n${YELLOW}[4/7] Setting up database schema...${NC}"

# Get DATABASE_URL from .env.local or generate default
if [ -f .env.local ]; then
    source .env.local
else
    DATABASE_URL="postgresql://postgres:postgres@localhost:5432/librarfree"
fi

# Apply schema
echo "Applying database schema..."
docker-compose exec -T postgres psql -U postgres -d librarfree -f /docker-entrypoint-initdb.d/schema.sql 2>/dev/null || \
psql "$DATABASE_URL" -f database/schema.sql

echo "✅ Database schema applied"

# ============================================
# 5. Seed initial data (authors, affiliate retailers)
# ============================================
echo -e "\n${YELLOW}[5/7] Seeding initial data...${NC}"

# Authors
psql "$DATABASE_URL" << 'EOF'
INSERT INTO authors (name, birth_year, death_year, nationality, bio) VALUES
('Victor Hugo', 1802, 1885, 'French', 'Écrivain français, poète et homme politique. Œuvres majeures : Les Misérables, Notre-Dame de Paris.'),
('Leo Tolstoy', 1828, 1910, 'Russian', 'Écrivain russe, auteur de Guerre et Paix et Anna Karénine.'),
('Jane Austen', 1775, 1817, 'British', 'Romancière anglaise, œuvres : Orgueil et Préjugés, Raison et Sentiments.')
ON CONFLICT DO NOTHING;
EOF

# Affiliate retailers (basic EN/FR/DE)
psql "$DATABASE_URL" << 'EOF'
INSERT INTO affiliate_retailers (language_code, retailer_name, retailer_type, country_code, affiliate_tag, url_template, priority, commission_rate)
VALUES
  ('en', 'amazon_com', 'amazon', 'us', 'YOURTAG-20', 'https://www.amazon.com/dp/{isbn}?tag={tag}', 1, 4.5),
  ('en', 'amazon_uk', 'amazon', 'uk', 'YOURTAG-21', 'https://www.amazon.co.uk/dp/{isbn}?tag={tag}', 2, 4.5),
  ('fr', 'amazon_fr', 'amazon', 'fr', 'YOURTAG-21', 'https://www.amazon.fr/dp/{isbn}?tag={tag}', 1, 4.5),
  ('fr', 'fnac', 'local', 'fr', 'FNAC_ID', 'https://www.fnac.com/Interface/Affiliation/GetProductUrl?productId={isbn}&affiliate={affiliate_id}', 2, 3.0),
  ('de', 'amazon_de', 'amazon', 'de', 'YOURTAG-21', 'https://www.amazon.de/dp/{isbn}?tag={tag}', 1, 4.5),
  ('de', 'thalia', 'local', 'de', 'THALIA_ID', 'https://www.thalia.de/shop/home/artikeldetails/{isbn}/ID{isbn}.html?partnerId={partner_id}', 2, 5.0)
ON CONFLICT DO NOTHING;
EOF

echo "✅ Initial data seeded"

# ============================================
# 6. Pull Ollama model (optional)
# ============================================
echo -e "\n${YELLOW}[6/7] Pulling Ollama Nomic embedding model...${NC}"
if command -v ollama &> /dev/null; then
    ollama pull nomic-embed-text:v1.5
    echo "✅ Ollama model ready"
else
    echo -e "${YELLOW}⚠️  Ollama not installed locally. You can pull later:${NC}"
    echo "   docker run -d -p 11434:11434 ollama/ollama"
    echo "   ollama pull nomic-embed-text:v1.5"
fi

# ============================================
# 7. Start development servers
# ============================================
echo -e "\n${YELLOW}[7/7] Starting development servers...${NC}"

# Build if needed
echo "Building Next.js app..."
pnpm --filter web build 2>/dev/null || echo "⚠️ Build skipped (will build on first dev start)"

echo ""
echo -e "${GREEN}=========================================${NC}"
echo -e "${GREEN}   Setup Complete! 🎉                    ${NC}"
echo -e "${GREEN}=========================================${NC}"
echo ""
echo -e "${YELLOW}Start development:${NC}"
echo "   Terminal 1: pnpm --filter api dev"
echo "   Terminal 2: pnpm --filter web dev"
echo ""
echo -e "${YELLOW}Import Project Gutenberg (test 100 books):${NC}"
echo "   pnpm --filter workers run import-gutenberg --limit 100"
echo ""
echo -e "${YELLOW}Start embedding generation (requires Ollama):${NC}"
echo "   pnpm --filter workers run generate-embeddings --batch-size 50"
echo ""
echo -e "${YELLOW}Access URLs:${NC}"
echo "   Frontend: http://localhost:3000"
echo "   API:      http://localhost:3333"
echo "   Meilisearch admin: http://localhost:7700"
echo "   PostgreSQL: localhost:5432 (user: postgres, pass: postgres)"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "   1. Configure .env.local with Amazon PAAPI credentials (optional)"
echo "   2. Import books from sources (see docs/IMPORTS.md)"
echo "   3. Add translations for FR/DE/ES (see docs/TRANSLATIONS.md)"
echo "   4. Configure affiliate retailers (see AFFILIATE_RETAILERS_CONFIG.md)"
echo ""
echo -e "${GREEN}Happy coding! 📚🚀${NC}"
