import json
from pathlib import Path
from app.schemas import ToneProfile

BASE_DIR = Path("app/output").resolve()

def get_user_dir(user_id: str) -> Path:
    ##사용자별 디렉토리 생성 또는 반환##
    user_path = BASE_DIR / user_id
    user_path.mkdir(parents=True, exist_ok=True)
    return user_path

def save_tone_profile(user_id: str, profile: ToneProfile) -> str:
    ##사용자별 폴더에 result_001.json, result_002.json 식으로 저장##
    user_dir = get_user_dir(user_id)
    existing_files = sorted(user_dir.glob("result_*.json"))
    next_index = len(existing_files) + 1
    file_path = user_dir / f"result_{next_index:03}.json"
    
    with open(file_path, "w", encoding="utf-8") as f:
        json.dump(profile.dict(), f, ensure_ascii=False, indent=2)
    
    return str(file_path)

def load_latest_profile(user_id: str) -> ToneProfile:
    ##가장 최근 저장 파일 불러오기##
    user_dir = get_user_dir(user_id)
    files = sorted(user_dir.glob("result_*.json"))
    if not files:
        raise FileNotFoundError("저장된 분석 결과가 없습니다.")
    
    latest_file = files[-1]
    with open(latest_file, "r", encoding="utf-8") as f:
        data = json.load(f)
    return ToneProfile(**data)

def list_user_history(user_id: str, sort: str = "asc", query: str | None = None) -> list[str]:
    user_dir = get_user_dir(user_id)
    files = sorted(user_dir.glob("result_*.json"))

    # 정렬
    if sort == "desc":
        files = sorted(files, reverse=True)

    # 검색
    if query:
        filtered_files = []
        for file in files:
            with open(file, "r", encoding="utf-8") as f:
                if query in f.read():
                    filtered_files.append(file)
        files = filtered_files

    return [file.name for file in files]

## 파일 삭제 함수 추가 ##
def delete_profile(user_id: str, filename: str):
    file_path = get_user_dir(user_id) / filename
    if not file_path.exists():
        raise FileNotFoundError(f"{filename} 파일이 없습니다.")
    file_path.unlink()

## 파일 업데이트 함수 추가 ##
def update_profile(user_id: str, filename: str, profile: ToneProfile):
    file_path = get_user_dir(user_id) / filename
    if not file_path.exists():
        raise FileNotFoundError(f"{filename} 파일이 없습니다.")
    with open(file_path, "w", encoding="utf-8") as f:
        json.dump(profile.dict(), f, ensure_ascii=False, indent=2)
## 파일 로드 함수 추가 ##
def load_profile(user_id: str, filename: str) -> ToneProfile:
    file_path = get_user_dir(user_id) / filename
    if not file_path.exists():
        raise FileNotFoundError(f"{filename} 파일이 없습니다.")
    with open(file_path, "r", encoding="utf-8") as f:
        return ToneProfile(**json.load(f))