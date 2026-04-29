#!/usr/bin/env bash
set -euo pipefail

# Colors for output
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Stopping development environment...${NC}"

# Stop PostgreSQL container
if docker ps --filter "name=conduit-postgres" --format "{{.Names}}" | grep -q "conduit-postgres"; then
    echo "Stopping PostgreSQL container..."
    docker stop conduit-postgres
    echo -e "${GREEN}PostgreSQL container stopped${NC}"
else
    echo "PostgreSQL container is not running"
fi

echo -e "${GREEN}Development environment stopped${NC}"
echo ""
echo "To remove the PostgreSQL container and data, run:"
echo "  docker rm conduit-postgres"
