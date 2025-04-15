from fastapi import APIRouter, Query, Response, HTTPException
from app.schemas import AnalyzeRequest, ToneProfile
from app.services.gemini import analyze_tone
from app.api.storage import set_last_result
from app.utils.dialogue import cut_dialogue_by_date
from app.core.logging_config import api_logger, error_logger
import logging
import sys
from pathlib import Path
from logging.handlers import RotatingFileHandler

router = APIRouter()

# 로그 디렉토리 설정
LOG_DIR = Path("/tmp/logs")  # Railway에서는 임시 디렉토리 사용
LOG_DIR.mkdir(exist_ok=True)

# 로거 설정
def setup_logger(name: str, level=logging.INFO):
    formatter = logging.Formatter(
        '%(asctime)s [%(levelname)s] %(name)s: %(message)s',
        datefmt='%Y-%m-%d %H:%M:%S'
    )

    # 콘솔 핸들러 설정 (Railway에서는 콘솔 로깅만 사용)
    console_handler = logging.StreamHandler(sys.stdout)
    console_handler.setFormatter(formatter)

    # 로거 설정
    logger = logging.getLogger(name)
    logger.setLevel(level)
    
    # 중복 핸들러 방지
    if not logger.handlers:
        logger.addHandler(console_handler)
    
    return logger

# 각 모듈별 로거 생성
api_logger = setup_logger('api')
gemini_logger = setup_logger('gemini')
error_logger = setup_logger('error', level=logging.ERROR)

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