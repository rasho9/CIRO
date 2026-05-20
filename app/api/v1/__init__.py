from fastapi import APIRouter
from .endpoints.crisis import router as crisis_router

router = APIRouter()
router.include_router(crisis_router, prefix="")
