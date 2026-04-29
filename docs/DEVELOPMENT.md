# Development Guide

## Prerequisites

- Python 3.9+
- Docker (for PostgreSQL)
- Virtual environment (`.venv`)

## Quick Start

### 1. Start the Application

```bash
./scripts/start-dev.sh
```

This script will:
- Activate the virtual environment
- Start PostgreSQL in Docker (if not running)
- Run database migrations
- Start the FastAPI development server

The application will be available at:
- **API Server**: http://127.0.0.1:8000
- **API Documentation (Swagger)**: http://127.0.0.1:8000/docs
- **ReDoc Documentation**: http://127.0.0.1:8000/redoc
- **Health Check**: http://127.0.0.1:8000/health

### 2. Stop the Application

Press `Ctrl+C` to stop the server, then run:

```bash
./scripts/stop-dev.sh
```

This will stop the PostgreSQL Docker container.

## Manual Setup

If you prefer to run commands manually:

### Start PostgreSQL

```bash
docker run -d \
    --name conduit-postgres \
    -e POSTGRES_USER=user \
    -e POSTGRES_PASSWORD=password \
    -e POSTGRES_DB=conduit \
    -p 5432:5432 \
    postgres:15-alpine
```

### Run Migrations

```bash
source .venv/bin/activate
APP_ENV=dev \
DATABASE_URL=postgresql://user:password@localhost:5432/conduit \
SECRET_KEY=your_secret_key \
alembic upgrade head
```

### Start the Application

```bash
source .venv/bin/activate
APP_ENV=dev \
DATABASE_URL=postgresql://user:password@localhost:5432/conduit \
SECRET_KEY=your_secret_key \
uvicorn app.main:app --reload
```

## Environment Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `APP_ENV` | Application environment | `dev`, `prod`, `test` |
| `DATABASE_URL` | PostgreSQL connection string | `postgresql://user:password@localhost:5432/conduit` |
| `SECRET_KEY` | JWT secret key | `your_secret_key` |

## Running Tests

```bash
source .venv/bin/activate
PYTHONPATH=. pytest tests/unit/ -v
```

## Database Management

### View Tables

```bash
docker exec conduit-postgres psql -U user -d conduit -c "\dt"
```

### Access PostgreSQL Shell

```bash
docker exec -it conduit-postgres psql -U user -d conduit
```

### Reset Database

```bash
docker stop conduit-postgres
docker rm conduit-postgres
# Then start again with ./scripts/start-dev.sh
```

## API Endpoints

The application implements the RealWorld API specification:

- `POST /api/users` - Register user
- `POST /api/users/login` - Login user
- `GET /api/user` - Get current user
- `PUT /api/user` - Update user
- `GET /api/profiles/{username}` - Get profile
- `POST /api/profiles/{username}/follow` - Follow user
- `DELETE /api/profiles/{username}/follow` - Unfollow user
- `GET /api/articles` - List articles
- `GET /api/articles/feed` - Get user feed
- `GET /api/articles/{slug}` - Get article
- `POST /api/articles` - Create article
- `PUT /api/articles/{slug}` - Update article
- `DELETE /api/articles/{slug}` - Delete article
- `POST /api/articles/{slug}/favorite` - Favorite article
- `DELETE /api/articles/{slug}/favorite` - Unfavorite article
- `GET /api/articles/{slug}/comments` - Get comments
- `POST /api/articles/{slug}/comments` - Add comment
- `DELETE /api/articles/{slug}/comments/{id}` - Delete comment
- `GET /api/tags` - Get tags
- `GET /health` - Health check

## Troubleshooting

### Port 5432 Already in Use

If you see "port is already allocated", stop any existing PostgreSQL services:

```bash
# Check what's using port 5432
sudo lsof -i :5432

# Stop Docker containers using the port
docker ps -a | grep 5432
docker stop <container-name>
```

### Database Connection Errors

Ensure PostgreSQL container is running:

```bash
docker ps --filter "name=conduit-postgres"
```

If not running, start it:

```bash
docker start conduit-postgres
```

### Migration Errors

Reset migrations and reapply:

```bash
APP_ENV=dev \
DATABASE_URL=postgresql://user:password@localhost:5432/conduit \
SECRET_KEY=your_secret_key \
alembic downgrade base

APP_ENV=dev \
DATABASE_URL=postgresql://user:password@localhost:5432/conduit \
SECRET_KEY=your_secret_key \
alembic upgrade head
```

## Development Workflow

1. Make code changes
2. The server will auto-reload (watch mode enabled)
3. Test endpoints using Swagger UI at http://127.0.0.1:8000/docs
4. Run tests to verify changes: `pytest tests/unit/ -v`
5. Commit changes

## Additional Resources

- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [RealWorld API Spec](https://realworld-docs.netlify.app/docs/specs/backend-specs/introduction)
- [Project README](../README.md)
