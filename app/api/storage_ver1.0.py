from fastapi import APIRouter, HTTPException
from app.schemas import ToneProfile
from app.services.storage import save_tone_profile, load_tone_profile

router = APIRouter()

_last_result: ToneProfile | None = None  # 임시로 메모리에 저장

@router.post("/save", response_model=dict)
def save_last_result():
    if _last_result is None:
        raise HTTPException(status_code=400, detail="저장할 데이터가 없습니다.")
    save_tone_profile(_last_result)
    return {"message": "저장 완료"}

@router.get("/load", response_model=ToneProfile)
def load_saved_result():
    try:
        return load_tone_profile()
    except FileNotFoundError as e:
        raise HTTPException(status_code=404, detail=str(e))

# API 테스트용으로 마지막 결과 메모리에 저장
def set_last_result(profile: ToneProfile):
    global _last_result
    _last_result = profile
