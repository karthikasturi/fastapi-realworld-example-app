# GitHub Copilot Instructions — Training Repository

## Project Overview

This is a production-style **FastAPI RealWorld** application (Conduit) — a Medium.com-like
blogging platform used as the shared codebase across a 10-day GitHub Copilot training
for QA Engineers, DevOps Engineers, and SREs.

**Repository layout:**
- `app/` — FastAPI application source (models, routers, services, dependencies)
- `tests/unit/` — Unit tests (pytest)
- `tests/e2e/` — End-to-end UI tests (Playwright + Python)
- `tests/api/` — API tests (pytest + httpx)
- `infra/` — Dockerfile, Kubernetes manifests, Terraform configs
- `monitoring/` — Prometheus rules, alerting configs, log parsers
- `scripts/` — DevOps automation and shell/Python scripts
- `.github/workflows/` — GitHub Actions CI/CD pipelines

---

## Tech Stack

| Layer | Technology |
|---|---|
| API Framework | FastAPI (async, Python 3.11+) |
| ORM | SQLAlchemy (async) + Alembic migrations |
| Database | PostgreSQL |
| Auth | JWT (python-jose) |
| Testing | pytest, pytest-asyncio, httpx, Playwright |
| Containerisation | Docker, Docker Compose |
| Orchestration | Kubernetes (kubectl + YAML manifests) |
| IaC | Terraform (AWS provider) |
| CI/CD | GitHub Actions |
| Monitoring | Prometheus, Grafana, prometheus-fastapi-instrumentator |
| Code Style | Black, isort, Ruff |

---

## Coding Conventions

## Virtual Environment

- **Always use a Python virtual environment named `.venv`** when running the app and running tests. All commands, scripts, and development work must be executed inside this environment. Activate it with `source .venv/bin/activate` before running any Python code or tests.

### Python

- Use **async/await** for all database operations and route handlers
- Use **type hints** on all function signatures, including return types
- Follow **FastAPI dependency injection** — inject `db: AsyncSession` via `Depends(get_db)`
- Use **Pydantic v2 models** for request/response schemas — all schemas live in `app/schemas/`
- Raise **HTTPException** with appropriate status codes rather than returning raw dicts
- Group imports: stdlib → third-party → local, sorted by `isort`
- Maximum line length: **88 characters** (Black default)
- Docstrings: **Google style** for all public functions and classes

```python
# Preferred pattern for route handlers
@router.post("/articles", response_model=ArticleResponse, status_code=201)
async def create_article(
    article_in: ArticleCreate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> ArticleResponse:
    """Create a new article.

    Args:
        article_in: Validated article creation payload.
        db: Async database session.
        current_user: Authenticated user from JWT.

    Returns:
        The newly created article.

    Raises:
        HTTPException: 422 if slug already exists.
    """
```

### Tests

- **Unit tests** (`tests/unit/`) must be pure — no database, no HTTP calls, mock all I/O
- **API tests** (`tests/api/`) use `pytest-asyncio` + `httpx.AsyncClient` against a real test DB
- **E2E tests** (`tests/e2e/`) use Playwright Python with the **Page Object Model (POM)** pattern
- Test file names: `test_<module>.py`
- Test function names: `test_<behaviour>_when_<condition>`
- Use `pytest.mark` for categorisation: `@pytest.mark.unit`, `@pytest.mark.api`, `@pytest.mark.e2e`
- Always assert the **response status code first**, then payload fields
- Use **fixtures** in `conftest.py` — never duplicate setup logic across test files

- **Test case source of truth:**
    - All test cases under the `docs/` folder are the source of truth for creating tests. When implementing or updating tests, always refer to the test case specifications in `docs/` first.

```python
# Preferred API test pattern
@pytest.mark.api
async def test_create_article_returns_201_when_valid_payload(
    async_client: AsyncClient,
    auth_headers: dict[str, str],
) -> None:
    payload = {"article": {"title": "Test", "description": "Desc", "body": "Body"}}
    response = await async_client.post("/api/articles", json=payload, headers=auth_headers)
    assert response.status_code == 201
    assert response.json()["article"]["title"] == "Test"
```

### Playwright E2E

- Use the **Page Object Model** — one class per page in `tests/e2e/pages/`
- Use `page.get_by_role()` and `page.get_by_label()` locators — avoid CSS selectors
- Always `await page.wait_for_load_state("networkidle")` after navigation
- Parametrize cross-browser tests with `@pytest.mark.parametrize("browser_type", ["chromium", "firefox"])`

### Infrastructure

- Terraform: use `terraform fmt` before committing; all variables defined in `variables.tf`
- Kubernetes YAML: always set `resources.requests` and `resources.limits` on containers
- Docker: multi-stage builds only; final image must be non-root user
- All secrets via **environment variables** — never hardcode credentials or API keys
- Shell scripts: `#!/usr/bin/env bash`, `set -euo pipefail` at the top

---

## API Domain Knowledge

## Test and Spec Documentation

- **Test case specifications:**
    - The specifications for test cases are found under the `docs/` folder. These documents are the authoritative source for how tests should be written and what they should cover.
- **Spec creation:**
    - When creating new spec documents under the `docs/` folder, always use the actual code implementations as the basis. Gather the specifications directly from the code to ensure accuracy and alignment between documentation and implementation.

The RealWorld API has these primary resources — always use these exact endpoint paths:

| Resource | Base Path | Key Operations |
|---|---|---|
| Auth | `/api/users`, `/api/user` | register, login, get/update current user |
| Profiles | `/api/profiles/:username` | get profile, follow, unfollow |
| Articles | `/api/articles` | CRUD, list with filters, feed |
| Comments | `/api/articles/:slug/comments` | list, add, delete |
| Favourites | `/api/articles/:slug/favorite` | favourite, unfavourite |
| Tags | `/api/tags` | list all tags |

**Authentication:** Bearer token via `Authorization: Token <jwt>` header (NOT `Bearer`).

**Standard response envelope:**
```json
// Single resource
{ "article": { ... } }
// Collection
{ "articles": [ ... ], "articlesCount": 42 }
// Errors
{ "errors": { "body": ["can't be blank"] } }
```

---

## Security Rules

When generating any code in this repository, always follow these rules:

1. **Never hardcode credentials** — use `os.environ.get("SECRET_KEY")` or Pydantic `Settings`
2. **Parameterise all SQL** — never use f-strings or `.format()` in queries
3. **Validate all user input** via Pydantic schemas before it reaches the service layer
4. **Use `secrets.token_urlsafe()`** for token generation — never `random` or `uuid4` for secrets
5. **Hash passwords** with `passlib[bcrypt]` — never store or log plaintext passwords
6. **Set CORS origins explicitly** — do not use `allow_origins=["*"]` in non-dev environments
7. **Redact sensitive fields** from logs — no passwords, tokens, or PII in log output

---

## Monitoring Conventions

- All custom metrics use the prefix `conduit_` (e.g., `conduit_articles_created_total`)
- HTTP metrics are auto-instrumented via `prometheus-fastapi-instrumentator` on `/metrics`
- Alert rule names follow: `Conduit<Resource><Condition>` (e.g., `ConduitHighErrorRate`)
- Log format: structured JSON with fields `timestamp`, `level`, `service`, `trace_id`, `message`
- SLO targets: **99.5% availability**, **p99 latency < 500ms** for write endpoints

---

## CI/CD Conventions

GitHub Actions workflows follow this naming:

| File | Trigger | Purpose |
|---|---|---|
| `ci.yml` | push, pull_request | Lint, unit tests, API tests |
| `e2e.yml` | push to `main` | Playwright E2E suite |
| `deploy.yml` | push to `main` (manual approval) | Build image, push to ECR, apply K8s |

- All jobs must specify `runs-on: ubuntu-latest`
- Use `actions/cache` for pip dependencies
- Docker image tags: `ghcr.io/<org>/conduit:<git-sha>`
- Never use `latest` as a production image tag

---

## What Copilot Should NOT Generate

- Do not suggest `print()` for debugging — use the `logging` module with structured output
- Do not generate synchronous database calls — this is an async codebase
- Do not suggest `shell: true` in subprocess calls — use list arguments
- Do not generate `except Exception: pass` — always handle exceptions explicitly
- Do not suggest `.env` files committed to version control
- Do not use deprecated Playwright APIs: `waitForTimeout()`, `$()`, `$$()` — use role/label locators

---

## References to RealWorld App Specifications

- **Official RealWorld GitHub repository:**  
    https://github.com/realworld-apps/realworld
- **API Specification:**  
    https://github.com/realworld-apps/realworld/tree/main/specs/api
- **Documentation:**  
    https://docs.realworld.show/introduction/
- **Demo website:**  
    https://demo.realworld.show/
- **Frontend and Backend Implementations:**  
    https://codebase.show/projects/realworld

These resources provide the canonical API spec, implementation guides, and reference applications for the RealWorld project.