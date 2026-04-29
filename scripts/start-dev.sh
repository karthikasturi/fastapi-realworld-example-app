#!/usr/bin/env bash
set -euo pipefail

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Starting FastAPI RealWorld Application (Development)${NC}"

# Check if virtual environment is activated
if [[ -z "${VIRTUAL_ENV:-}" ]]; then
    echo -e "${YELLOW}Activating virtual environment...${NC}"
    source .venv/bin/activate
fi

# Check if PostgreSQL container is running
if ! docker ps --filter "name=conduit-postgres" --format "{{.Names}}" | grep -q "conduit-postgres"; then
    echo -e "${YELLOW}Starting PostgreSQL container...${NC}"
    
    # Check if container exists but is stopped
    if docker ps -a --filter "name=conduit-postgres" --format "{{.Names}}" | grep -q "conduit-postgres"; then
        docker start conduit-postgres
    else
        # Create new container
        docker run -d \
            --name conduit-postgres \
            -e POSTGRES_USER=user \
            -e POSTGRES_PASSWORD=password \
            -e POSTGRES_DB=conduit \
            -p 5432:5432 \
            postgres:15-alpine
    fi
    
    echo "Waiting for PostgreSQL to be ready..."
    sleep 5
fi

echo -e "${GREEN}PostgreSQL is running${NC}"

# Run migrations
echo -e "${YELLOW}Running database migrations...${NC}"
export APP_ENV=dev
export DATABASE_URL=postgresql://user:password@localhost:5432/conduit
export SECRET_KEY=your_secret_key

alembic upgrade head

# Start the application
echo -e "${GREEN}Starting FastAPI application on http://127.0.0.1:8000${NC}"
echo -e "${GREEN}API Documentation: http://127.0.0.1:8000/docs${NC}"
echo -e "${GREEN}Health Check: http://127.0.0.1:8000/health${NC}"
echo ""
echo "Press Ctrl+C to stop the server"
echo ""

uvicorn app.main:app --reload
