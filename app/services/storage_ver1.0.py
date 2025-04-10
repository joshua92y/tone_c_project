import json
from pathlib import Path
from app.schemas import ToneProfile

SAVE_PATH = Path("app/output/result.json").resolve()
BASE_DIR = Path("output")


def save_tone_profile(profile: ToneProfile):
    with open(SAVE_PATH, "w", encoding="utf-8") as f:
        json.dump(profile.dict(), f, ensure_ascii=False, indent=2)

def load_tone_profile() -> ToneProfile:
    if not SAVE_PATH.exists():
        raise FileNotFoundError("저장된 분석 결과가 없습니다.")
    with open(SAVE_PATH, "r", encoding="utf-8") as f:
        data = json.load(f)
    return ToneProfile(**data)
