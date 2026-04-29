from fastapi import APIRouter, status
from fastapi.responses import JSONResponse

router = APIRouter()


def perform_health_check() -> dict:
    """Perform the actual health check logic.
    
    This function can be mocked in tests to simulate errors.
    
    Returns:
        dict: Health status dictionary
        
    Raises:
        Exception: If health check fails
    """
    # In a real application, this might check database connectivity,
    # external service availability, etc.
    return {"status": "ok"}


@router.get("/health", tags=["health"], summary="Health check endpoint", response_description="Health status", responses={
    200: {
        "description": "Service is healthy",
        "content": {
            "application/json": {
                "example": {"status": "ok"}
            }
        }
    },
    500: {
        "description": "Internal server error",
        "content": {
            "application/json": {
                "example": {"detail": "Internal server error"}
            }
        }
    }
})
async def health_check():
    """Health check endpoint for service monitoring.

    Returns:
        JSONResponse: Service health status.
    """
    try:
        result = perform_health_check()
        return JSONResponse(content=result, status_code=status.HTTP_200_OK)
    except Exception:
        return JSONResponse(
            content={"detail": "Internal server error"},
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR
        )
