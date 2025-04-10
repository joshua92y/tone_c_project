import json
from pathlib import Path
from app.schemas import ToneProfile

PRESET_DIR = Path("app/output/presets").resolve()

def get_preset_dir(user_id: str) -> Path:
    dir_path = PRESET_DIR / user_id
    dir_path.mkdir(parents=True, exist_ok=True)
    return dir_path

def save_preset(user_id: str, preset_name: str, profile: ToneProfile):
    file_path = get_preset_dir(user_id) / f"{preset_name}.json"
    with open(file_path, "w", encoding="utf-8") as f:
        json.dump(profile.dict(), f, ensure_ascii=False, indent=2)

def load_preset(user_id: str, preset_name: str) -> ToneProfile:
    file_path = get_preset_dir(user_id) / f"{preset_name}.json"
    if not file_path.exists():
        raise FileNotFoundError("프리셋이 존재하지 않습니다.")
    with open(file_path, "r", encoding="utf-8") as f:
        return ToneProfile(**json.load(f))

def list_presets(user_id: str) -> list[str]:
    return [
        file.stem
        for file in get_preset_dir(user_id).glob("*.json")
    ]

def delete_preset(user_id: str, preset_name: str):
    file_path = get_preset_dir(user_id) / f"{preset_name}.json"
    if file_path.exists():
        file_path.unlink()
