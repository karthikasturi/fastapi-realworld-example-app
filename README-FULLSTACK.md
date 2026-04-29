# FastAPI RealWorld Example App - Full Stack Setup

This repository now includes both backend (FastAPI) and frontend (React) for the RealWorld Conduit application, ready for comprehensive testing including Playwright E2E tests.

## Project Structure

```
├── app/                    # FastAPI backend application
├── frontend/               # React + Redux frontend application
├── tests/
│   ├── unit/              # Backend unit tests
│   ├── api/               # Backend API integration tests
│   └── e2e/               # Playwright end-to-end tests
├── scripts/               # Helper scripts for development
├── docs/                  # Documentation
└── infra/                 # Infrastructure configurations
```

## Quick Start

### 1. Full Stack Development

Start both backend and frontend together:

```bash
./scripts/start-fullstack.sh
```

This will:
- Start PostgreSQL in Docker
- Run database migrations
- Start the FastAPI backend on http://localhost:8000
- Start the React frontend on http://localhost:4100

**Access Points:**
- Frontend UI: http://localhost:4100
- Backend API: http://localhost:8000
- API Docs: http://localhost:8000/docs
- Health Check: http://localhost:8000/health

### 2. Backend Only

If you only need the backend API:

```bash
./scripts/start-dev.sh
```

### 3. Frontend Only

If the backend is already running:

```bash
cd frontend
npm start
```

## Testing

### Unit Tests (Backend)

```bash
source .venv/bin/activate
PYTHONPATH=. pytest tests/unit/ -v
```

### E2E Tests (Full Stack)

```bash
# Make sure both backend and frontend are running first
./scripts/start-fullstack.sh

# In another terminal, run E2E tests
./scripts/run-e2e-tests.sh
```

Or manually:

```bash
source .venv/bin/activate
PYTHONPATH=. pytest tests/e2e/ -v
```

### Run Specific Test Types

```bash
# Only unit tests
pytest -m unit -v

# Only API tests
pytest -m api -v

# Only E2E tests
pytest -m e2e -v
```

## Environment Configuration

### Backend Environment Variables

The backend requires these environment variables:

```bash
APP_ENV=dev                          # dev, prod, or test
DATABASE_URL=postgresql://user:password@localhost:5432/conduit
SECRET_KEY=your_secret_key           # For JWT token signing
```

### Frontend Configuration

Frontend is configured via `frontend/.env`:

```env
PORT=4100
REACT_APP_API_ROOT=http://localhost:8000/api
```

## Available Scripts

| Script | Purpose |
|--------|---------|
| `./scripts/start-fullstack.sh` | Start backend + frontend + database |
| `./scripts/stop-fullstack.sh` | Stop all services |
| `./scripts/start-dev.sh` | Start backend only |
| `./scripts/stop-dev.sh` | Stop backend only |
| `./scripts/run-e2e-tests.sh` | Run Playwright E2E tests |

## Database Management

### PostgreSQL via Docker

The application uses PostgreSQL running in Docker:

```bash
# Check if running
docker ps --filter "name=conduit-postgres"

# View logs
docker logs conduit-postgres

# Connect to database
docker exec -it conduit-postgres psql -U user -d conduit

# Stop and remove (deletes data)
docker stop conduit-postgres
docker rm conduit-postgres
```

### Migrations

```bash
source .venv/bin/activate
export DATABASE_URL=postgresql://user:password@localhost:5432/conduit
export SECRET_KEY=your_secret_key

# Run migrations
alembic upgrade head

# Rollback one migration
alembic downgrade -1

# Create new migration
alembic revision -m "description"
```

## Technology Stack

### Backend
- **Framework**: FastAPI (async, Python 3.12+)
- **ORM**: SQLAlchemy (async) + Alembic migrations
- **Database**: PostgreSQL
- **Auth**: JWT (python-jose)
- **Testing**: pytest, pytest-asyncio, httpx

### Frontend
- **Framework**: React + Redux
- **Router**: React Router
- **HTTP Client**: Superagent
- **Build**: Create React App

### E2E Testing
- **Framework**: Playwright (Python)
- **Test Runner**: pytest with pytest-playwright plugin
- **Browser**: Chromium

## Development Workflow

1. **Start the full stack**:
   ```bash
   ./scripts/start-fullstack.sh
   ```

2. **Make changes** to backend or frontend code
   - Backend: Auto-reload enabled with `--reload` flag
   - Frontend: Auto-reload enabled by default (React)

3. **Test changes**:
   ```bash
   # Unit tests
   pytest tests/unit/ -v
   
   # E2E tests
   ./scripts/run-e2e-tests.sh
   ```

4. **Stop services**:
   ```bash
   ./scripts/stop-fullstack.sh
   ```

## Troubleshooting

### Port Already in Use

If you see "port already in use" errors:

```bash
# Check what's using the ports
lsof -i :8000   # Backend
lsof -i :4100   # Frontend
lsof -i :5432   # PostgreSQL

# Kill processes on specific port
lsof -ti:8000 | xargs kill -9
```

### Database Connection Issues

```bash
# Check if PostgreSQL is running
docker ps --filter "name=conduit-postgres"

# Restart PostgreSQL
docker restart conduit-postgres

# Check logs
docker logs conduit-postgres
```

### Frontend Not Connecting to Backend

1. Verify backend is running: `curl http://localhost:8000/health`
2. Check `frontend/.env` has correct `REACT_APP_API_ROOT`
3. Check browser console for CORS errors
4. Verify backend CORS settings in `app/main.py`

### E2E Tests Fail

1. Ensure both services are running:
   ```bash
   curl http://localhost:8000/health
   curl http://localhost:4100
   ```

2. Check if Playwright browsers are installed:
   ```bash
   playwright install chromium
   ```

3. Run tests in headed mode to see what's happening:
   ```bash
   PYTHONPATH=. pytest tests/e2e/ -v --headed
   ```

## Documentation

- [Development Guide](docs/DEVELOPMENT.md) - Backend development details
- [E2E Testing Guide](tests/e2e/README.md) - Playwright testing guide
- [API Specification](docs/health-api.md) - API endpoint documentation
- [Test Cases](docs/tests-cases/) - Detailed test specifications

## RealWorld Specification

This application implements the [RealWorld](https://github.com/gothinkster/realworld) specification:

- **API Spec**: https://realworld-docs.netlify.app/docs/specs/backend-specs/introduction
- **Frontend Spec**: https://realworld-docs.netlify.app/docs/specs/frontend-specs/introduction
- **Live Demo**: https://demo.realworld.show/

## Contributing

1. Create feature branch
2. Make changes
3. Run tests: `pytest tests/ -v`
4. Run E2E tests: `./scripts/run-e2e-tests.sh`
5. Commit and create pull request

## License

MIT License - see LICENSE file for details
