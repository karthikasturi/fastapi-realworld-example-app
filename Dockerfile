# =============================================================================
# Stage 1 — builder
# Install production dependencies, then compile the app to a self-contained
# binary bundle using PyInstaller.  Nothing from this stage leaks into prod.
# =============================================================================
FROM python:3.11-slim AS builder

# Harden the build environment
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

WORKDIR /build

# Install only the C toolchain needed to compile asyncpg / psycopg2 wheels
RUN apt-get update \
    && apt-get install -y --no-install-recommends gcc libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Copy dependency manifests first (layer-cache friendly)
COPY pyproject.toml poetry.lock ./

# Install Poetry then production deps only; no virtualenv inside Docker
RUN pip install --no-cache-dir "poetry>=1.8,<2" \
    && poetry config virtualenvs.create false \
    && poetry install --only main --no-interaction --no-ansi

# Install PyInstaller into the same environment
RUN pip install --no-cache-dir "pyinstaller>=6,<7"

# Copy application source and the frozen-binary entry-point
COPY app/ ./app/
COPY entrypoint.py ./

# Compile to a one-directory bundle (avoids temp-extraction at runtime).
# --collect-all  : copies every sub-module + data files for dynamic loaders.
# --add-data     : bundles the raw SQL files aiosql reads at startup.
# --hidden-import: guarantees C-extension sub-modules are not tree-shaken.
RUN pyinstaller \
        --onedir \
        --name conduit \
        --collect-all uvicorn \
        --collect-all fastapi \
        --collect-all starlette \
        --collect-all asyncpg \
        --collect-all databases \
        --collect-all aiosql \
        --collect-all pypika \
        --collect-all passlib \
        --collect-all pydantic \
        --collect-all email_validator \
        --collect-all loguru \
        --collect-all python_slugify \
        --hidden-import=asyncpg.pgproto.pgproto \
        --hidden-import=asyncpg.protocol.protocol \
        --hidden-import=asyncpg.protocol.record \
        --hidden-import=passlib.handlers.bcrypt \
        --hidden-import=app.main \
        --hidden-import=app.api.routes.api \
        --hidden-import=app.api.routes.health \
        --hidden-import=app.core.config \
        --hidden-import=app.core.events \
        --hidden-import=app.db.events \
        --hidden-import=app.db.queries.queries \
        --add-data "app/db/queries/sql:app/db/queries/sql" \
        --noconfirm \
        --clean \
        entrypoint.py

# =============================================================================
# Stage 2 — final (production image)
# Only the compiled binary bundle is copied here — no Python interpreter,
# no pip, no build tools, no source code.
# =============================================================================
FROM debian:bookworm-slim AS final

# Install only the runtime C libraries the binary links against.
# libpq5   : PostgreSQL wire-protocol (asyncpg / psycopg2 both need it)
# ca-certificates : TLS root store for outbound HTTPS / DB TLS connections
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
           libpq5 \
           ca-certificates \
           wget \
    && rm -rf /var/lib/apt/lists/* \
    # Strip all setuid / setgid bits from the OS to reduce privilege-esc surface
    && find / -xdev \( -perm -4000 -o -perm -2000 \) -type f -exec chmod a-s {} + 2>/dev/null || true

# Dedicated non-root user: no home directory, locked shell, fixed UID/GID
RUN groupadd --gid 10001 appgroup \
    && useradd \
           --uid 10001 \
           --gid appgroup \
           --no-create-home \
           --shell /usr/sbin/nologin \
           appuser

WORKDIR /app

# Copy only the compiled bundle from the builder stage
COPY --from=builder --chown=appuser:appgroup /build/dist/conduit/ ./

# Drop to non-root for all subsequent instructions and at runtime
USER appuser

# Expose the application port (actual binding enforced by the binary)
EXPOSE 8000

# Liveness probe: hit the dedicated /health endpoint
# wget is the only tool available in this minimal image (no curl)
HEALTHCHECK --interval=30s --timeout=5s --start-period=15s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:8000/health || exit 1

# Run the compiled binary directly — no shell, no interpreter in the call chain
ENTRYPOINT ["/app/conduit"]
