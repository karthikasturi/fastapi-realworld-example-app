"""PyInstaller entry-point for the Conduit API server.

This wrapper is used only when building the frozen binary.
It must be the top-level script passed to PyInstaller so that
multiprocessing.freeze_support() is called before uvicorn starts.
"""

import multiprocessing

import uvicorn

from app.main import app  # noqa: F401 — import triggers hidden-import resolution

if __name__ == "__main__":
    multiprocessing.freeze_support()
    uvicorn.run(
        app,
        host="0.0.0.0",  # noqa: S104 — host binding controlled via env in prod
        port=8000,
        log_config=None,  # app configures loguru; disable uvicorn's default logging
    )
