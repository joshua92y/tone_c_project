from fastapi import APIRouter, Query, Response, HTTPException
from app.schemas import AnalyzeRequest, ToneProfile
from app.services.gemini import analyze_tone
from app.api.storage import set_last_result
from app.utils.dialogue import cut_dialogue_by_date
import logging

# 로거 설정
api_logger = logging.getLogger('api')
error_logger = logging.getLogger('error')

router = APIRouter()

@router.post("/analyze", response_model=ToneProfile)
async def analyze_text_post(data: AnalyzeRequest, user_id: str = Query(...)):
    try:
        api_logger.info(f"POST /analyze - user_id: {user_id}")
        api_logger.debug(f"Request data: {data.dict()}")
        
        if not data.dialogue:
            raise HTTPException(status_code=400, detail="Dialogue is empty")
            
        trimmed_dialogue = cut_dialogue_by_date(data.dialogue)
        api_logger.debug(f"Trimmed dialogue length: {len(trimmed_dialogue)}")
        
        try:
            result = analyze_tone(trimmed_dialogue)
            api_logger.info("Analysis completed successfully")
        except Exception as e:
            error_logger.error(f"Analysis failed: {str(e)}", exc_info=True)
            raise HTTPException(status_code=500, detail=str(e))
        
        try:
            set_last_result(user_id, result)
            api_logger.debug("Result saved successfully")
        except Exception as e:
            error_logger.error(f"Failed to save result: {str(e)}", exc_info=True)
            # 결과 저장 실패는 클라이언트에게 반환하지 않음
            
        return result
        
    except HTTPException:
        raise
    except Exception as e:
        error_msg = f"Unexpected error: {str(e)}"
        error_logger.error(error_msg, exc_info=True)
        raise HTTPException(status_code=500, detail=error_msg)

@router.get("/analyze", response_model=ToneProfile)
async def analyze_text_get(dialogue: list[str] = Query(...), user_id: str = Query(...)):
    try:
        api_logger.info(f"GET /analyze - user_id: {user_id}")
        api_logger.debug(f"Request dialogue length: {len(dialogue)}")
        
        trimmed_dialogue = cut_dialogue_by_date(dialogue)
        api_logger.debug(f"Trimmed dialogue length: {len(trimmed_dialogue)}")
        
        try:
            result = analyze_tone(trimmed_dialogue)
            api_logger.info("Analysis completed successfully")
        except Exception as e:
            error_logger.error(f"Analysis failed: {str(e)}", exc_info=True)
            raise HTTPException(status_code=500, detail=str(e))
            
        try:
            set_last_result(user_id, result)
            api_logger.debug("Result saved successfully")
        except Exception as e:
            error_logger.error(f"Failed to save result: {str(e)}", exc_info=True)
            
        return result
        
    except HTTPException:
        raise
    except Exception as e:
        error_msg = f"Unexpected error: {str(e)}"
        error_logger.error(error_msg, exc_info=True)
        raise HTTPException(status_code=500, detail=error_msg)

@router.options("/analyze")
async def preflight_analyze():
    api_logger.debug("OPTIONS /analyze - CORS preflight request")
    return Response(
        status_code=200,
        headers={
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Methods": "POST, OPTIONS, GET",
            "Access-Control-Allow-Headers": "*",
        }
    )