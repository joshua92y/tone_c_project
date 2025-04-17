# main.py (FastAPI entrypoint)
from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from app.core.config import GEMINI_API_KEY
from app.core.logging_config import setup_logger
from pathlib import Path
import logging
import sys

# API 라우터들
from app.api import analyze, storage, convert, preset, history ,user

# 전역 경로 기준 설정
BASE_DIR = Path(__file__).resolve().parent

# 로깅 설정 (모듈화된 로거 사용)
logger = setup_logger("app")

app = FastAPI(title="Tone Analyzer API", version="1.0.0")

@app.on_event("startup")
async def startup_event():
    logger.info("Application startup")

@app.on_event("shutdown")
async def shutdown_event():
    logger.info("Application shutdown")

@app.middleware("http")
async def log_requests(request: Request, call_next):
    logger.info(f"Request: {request.method} {request.url}")
    response = await call_next(request)
    logger.info(f"Response: {response.status_code}")
    return response

# CORS 설정
origins = [
    "https://joshua92y.github.io",
    "https://joshua92y.github.io/tone_c_project",
    "http://localhost:3000",
    "http://localhost:5173"
]
app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
    expose_headers=["*"],
    max_age=3600
)

# 라우터 등록 (prefix 제거)
app.include_router(analyze.router)
app.include_router(storage.router)
app.include_router(convert.router)
app.include_router(preset.router)
app.include_router(history.router)
app.include_router(user.router)

@app.get("/")
async def root():
    return {"message": "Tone Analyzer API is running", "docs_url": "/docs"}

@app.get("/health")
async def health_check():
    return {"status": "healthy"}

@app.exception_handler(Exception)
async def global_exception_handler(request: Request, exc: Exception):
    logger.error(f"Global error: {str(exc)}", exc_info=True)
    return JSONResponse(status_code=500, content={"detail": "Internal server error"})
