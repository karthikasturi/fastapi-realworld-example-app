#!/usr/bin/env bash
set -euo pipefail

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${GREEN}Starting Full Stack RealWorld Application${NC}"
echo ""

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

echo -e "${GREEN}✓ PostgreSQL is running${NC}"

# Run migrations
echo -e "${YELLOW}Running database migrations...${NC}"
export APP_ENV=dev
export DATABASE_URL=postgresql://user:password@localhost:5432/conduit
export SECRET_KEY=your_secret_key

alembic upgrade head

echo -e "${GREEN}✓ Database migrations complete${NC}"
echo ""

# Start backend in background
echo -e "${BLUE}Starting Backend API on http://127.0.0.1:8000${NC}"
uvicorn app.main:app --reload > /tmp/conduit-backend.log 2>&1 &
BACKEND_PID=$!
echo $BACKEND_PID > /tmp/conduit-backend.pid

# Wait for backend to start
sleep 3

# Check if backend is running
if ! ps -p $BACKEND_PID > /dev/null; then
    echo -e "${YELLOW}Backend failed to start. Check /tmp/conduit-backend.log${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Backend is running (PID: $BACKEND_PID)${NC}"
echo ""

# Start frontend
echo -e "${BLUE}Starting Frontend on http://localhost:4100${NC}"
cd frontend
npm start &
FRONTEND_PID=$!
echo $FRONTEND_PID > /tmp/conduit-frontend.pid
cd ..

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}   Full Stack Application Running!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "  ${BLUE}Frontend:${NC}     http://localhost:4100"
echo -e "  ${BLUE}Backend API:${NC}  http://127.0.0.1:8000"
echo -e "  ${BLUE}API Docs:${NC}     http://127.0.0.1:8000/docs"
echo -e "  ${BLUE}Health:${NC}       http://127.0.0.1:8000/health"
echo ""
echo -e "${YELLOW}Backend logs:${NC}  tail -f /tmp/conduit-backend.log"
echo ""
echo -e "${YELLOW}To stop both services, run:${NC} ./scripts/stop-fullstack.sh"
echo ""
echo "Press Ctrl+C to view this menu again, or run stop script to shut down."

# Keep script running
wait
