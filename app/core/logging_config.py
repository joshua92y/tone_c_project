from fastapi import APIRouter, Query, Response, HTTPException
from app.schemas import AnalyzeRequest, ToneProfile
from app.services.gemini import analyze_tone
from app.api.storage import set_last_result
from app.utils.dialogue import cut_dialogue_by_date
from app.core.logging_config import api_logger, error_logger

router = APIRouter()

@router.post("/analyze", response_model=ToneProfile)
async def analyze_text_post(data: AnalyzeRequest, user_id: str = Query(...)):
    try:
        api_logger.info(f"Received POST request - user_id: {user_id}")
        api_logger.debug(f"Request data: {data.dict()}")
        
        trimmed_dialogue = cut_dialogue_by_date(data.dialogue)
        api_logger.debug(f"Trimmed dialogue length: {len(trimmed_dialogue)}")
        
        result = analyze_tone(trimmed_dialogue)
        api_logger.info(f"Analysis completed successfully for user_id: {user_id}")
        
        set_last_result(user_id, result)
        return result
        
    except Exception as e:
        error_logger.error(f"Error in analyze_text_post - user_id: {user_id}", exc_info=True)
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/analyze", response_model=ToneProfile)
async def analyze_text_get(dialogue: list[str] = Query(...), user_id: str = Query(...)):
    try:
        api_logger.info(f"Received GET request - user_id: {user_id}")
        api_logger.debug(f"Request dialogue length: {len(dialogue)}")
        
        trimmed_dialogue = cut_dialogue_by_date(dialogue)
        api_logger.debug(f"Trimmed dialogue length: {len(trimmed_dialogue)}")
        
        result = analyze_tone(trimmed_dialogue)
        api_logger.info(f"Analysis completed successfully for user_id: {user_id}")
        
        set_last_result(user_id, result)
        return result
        
    except Exception as e:
        error_logger.error(f"Error in analyze_text_get - user_id: {user_id}", exc_info=True)
        raise HTTPException(status_code=500, detail=str(e))

@router.options("/analyze")
async def preflight_analyze():
    return Response(
        status_code=200,
        headers={
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Methods": "POST, OPTIONS, GET",
            "Access-Control-Allow-Headers": "*",
        }
    )