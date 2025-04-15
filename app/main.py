from fastapi import FastAPI, Request
from app.api import analyze,storage,convert,preset,history
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
import logging
import sys

# 기본 로깅 설정
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s [%(levelname)s] %(name)s: %(message)s',
    datefmt='%Y-%m-%d %H:%M:%S',
    handlers=[logging.StreamHandler(sys.stdout)]
)

# 로거 생성
logger = logging.getLogger("app")

app = FastAPI(
    title="Tone Analyzer API",
    description="톤 분석 및 변환을 위한 API",
    version="1.0.0"
)

# 시작 로그
@app.on_event("startup")
async def startup_event():
    logger.info("Application startup")
    logger.info("CORS settings initialized")

# 종료 로그
@app.on_event("shutdown")
async def shutdown_event():
    logger.info("Application shutdown")

# 미들웨어에서 요청/응답 로깅
@app.middleware("http")
async def log_requests(request: Request, call_next):
    logger.info(f"Request: {request.method} {request.url}")
    response = await call_next(request)
    logger.info(f"Response: {response.status_code}")
    return response

# 라우터 등록
app.include_router(analyze.router)
app.include_router(storage.router)
app.include_router(convert.router)
app.include_router(preset.router)
app.include_router(history.router)

# CORS 미들웨어 설정
app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "https://joshua92y.github.io",  # GitHub Pages
        "http://localhost:3000",        # 로컬 개발 환경
        "http://localhost:5173"         # 로컬 개발 환경
    ],
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "DELETE", "OPTIONS"],
    allow_headers=["*"],
    expose_headers=["*"],
    max_age=3600,
)

@app.get("/")
async def root():
    return {
        "message": "Tone Analyzer API is running",
        "docs_url": "/docs",
        "redoc_url": "/redoc"
    }

@app.get("/health")
async def health_check():
    logger.info("Health check requested")
    return {"status": "healthy"}

@app.options("/{rest_of_path:path}")
async def preflight_global(request: Request, rest_of_path: str):
    logger.info(f"Preflight request for path: {rest_of_path}")
    return JSONResponse(
        status_code=200,
        content={"message": "Preflight OK"},
        headers={
            "Access-Control-Allow-Origin": "https://joshua92y.github.io",
            "Access-Control-Allow-Methods": "GET, POST, PUT, DELETE, OPTIONS",
            "Access-Control-Allow-Headers": "Content-Type, Authorization, X-Requested-With",
            "Access-Control-Max-Age": "3600",
        }
    )
# 전역 예외 핸들러
@app.exception_handler(Exception)
async def global_exception_handler(request: Request, exc: Exception):
    logger.error(f"Global error: {str(exc)}", exc_info=True)
    return JSONResponse(
        status_code=500,
        content={"detail": "Internal server error"}
    )