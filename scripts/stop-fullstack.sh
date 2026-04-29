#!/usr/bin/env bash
set -euo pipefail

# Colors for output
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Stopping Full Stack Application...${NC}"
echo ""

# Stop Backend
if [ -f /tmp/conduit-backend.pid ]; then
    BACKEND_PID=$(cat /tmp/conduit-backend.pid)
    if ps -p $BACKEND_PID > /dev/null 2>&1; then
        echo "Stopping backend (PID: $BACKEND_PID)..."
        kill $BACKEND_PID 2>/dev/null || true
        sleep 2
        # Force kill if still running
        if ps -p $BACKEND_PID > /dev/null 2>&1; then
            kill -9 $BACKEND_PID 2>/dev/null || true
        fi
        rm /tmp/conduit-backend.pid
        echo -e "${GREEN}✓ Backend stopped${NC}"
    else
        echo "Backend is not running"
        rm /tmp/conduit-backend.pid
    fi
else
    echo "Backend PID file not found (may not be running)"
fi

# Stop Frontend
if [ -f /tmp/conduit-frontend.pid ]; then
    FRONTEND_PID=$(cat /tmp/conduit-frontend.pid)
    if ps -p $FRONTEND_PID > /dev/null 2>&1; then
        echo "Stopping frontend (PID: $FRONTEND_PID)..."
        kill $FRONTEND_PID 2>/dev/null || true
        sleep 2
        # Force kill if still running
        if ps -p $FRONTEND_PID > /dev/null 2>&1; then
            kill -9 $FRONTEND_PID 2>/dev/null || true
        fi
        rm /tmp/conduit-frontend.pid
        echo -e "${GREEN}✓ Frontend stopped${NC}"
    else
        echo "Frontend is not running"
        rm /tmp/conduit-frontend.pid
    fi
else
    echo "Frontend PID file not found (may not be running)"
fi

# Also kill any remaining processes on the ports
echo ""
echo "Cleaning up any remaining processes on ports 4100 and 8000..."
lsof -ti:4100 | xargs kill -9 2>/dev/null || true
lsof -ti:8000 | xargs kill -9 2>/dev/null || true

# Stop PostgreSQL container
echo ""
if docker ps --filter "name=conduit-postgres" --format "{{.Names}}" | grep -q "conduit-postgres"; then
    echo "Stopping PostgreSQL container..."
    docker stop conduit-postgres
    echo -e "${GREEN}✓ PostgreSQL container stopped${NC}"
else
    echo "PostgreSQL container is not running"
fi

echo ""
echo -e "${GREEN}Full Stack Application stopped${NC}"
echo ""
echo "To remove the PostgreSQL container and data, run:"
echo "  docker rm conduit-postgres"
