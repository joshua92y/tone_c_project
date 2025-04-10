from fastapi import APIRouter
from app.schemas import AnalyzeRequest, ToneProfile
from app.services.gemini import analyze_tone
from app.api.storage import set_last_result

router = APIRouter()

@router.post("/analyze", response_model=ToneProfile)
def analyze_text(data: AnalyzeRequest):
    result = analyze_tone(data.dialogue)
    set_last_result(result)  # 분석 결과 저장
    return result