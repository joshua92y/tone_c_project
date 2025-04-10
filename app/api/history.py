from fastapi import APIRouter, Body
from pathlib import Path
import json

router = APIRouter()
HISTORY_BASE = Path("app/history")

@router.post("/history/{user_id}")
def add_history(user_id: str, text: str = Body(..., embed=True)):
    user_file = HISTORY_BASE / f"{user_id}.json"
    history = []

    if user_file.exists():
        history = json.loads(user_file.read_text(encoding="utf-8"))

    history.append(text)
    if len(history) > 100:
        history = history[-100:]  # 최근 100개만 유지

    user_file.parent.mkdir(parents=True, exist_ok=True)
    user_file.write_text(json.dumps(history, ensure_ascii=False, indent=2), encoding="utf-8")
    return {"message": "saved", "count": len(history)}


@router.get("/history/{user_id}")
def get_history(user_id: str):
    user_file = HISTORY_BASE / f"{user_id}.json"
    if not user_file.exists():
        return []
    return json.loads(user_file.read_text(encoding="utf-8"))
