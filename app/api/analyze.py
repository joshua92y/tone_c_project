from fastapi import APIRouter, Query ,Response
from app.schemas import AnalyzeRequest, ToneProfile
from app.services.gemini import analyze_tone
from app.api.storage import set_last_result
from app.utils.dialogue import cut_dialogue_by_date

router = APIRouter()

@router.post("/analyze", response_model=ToneProfile)
def analyze_text(data: AnalyzeRequest, user_id: str = Query(...)):
    trimmed_dialogue = cut_dialogue_by_date(data.dialogue)
    result = analyze_tone(trimmed_dialogue)
    set_last_result(user_id, result)
    return result

@router.options("/analyze")
async def preflight_analyze():
    return Response(
        status_code=200,
        headers={
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Methods": "POST, OPTIONS",
            "Access-Control-Allow-Headers": "*",
        }
    )