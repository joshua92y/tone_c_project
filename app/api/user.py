# app/api/user.py
from fastapi import APIRouter
from pathlib import Path

router = APIRouter()

PRESET_BASE = Path("app/output/presets")

@router.get("/user-ids", response_model=list[str])
async def get_user_ids():
    if not PRESET_BASE.exists():
        return []
    folders = [f.name for f in PRESET_BASE.iterdir() if f.is_dir()]
    return folders
