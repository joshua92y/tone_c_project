from fastapi import FastAPI ,Request
from app.api import analyze,storage,convert,preset,history
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse

app = FastAPI()

# 라우터 등록
app.include_router(analyze.router)
app.include_router(storage.router)
app.include_router(convert.router)
app.include_router(preset.router)
app.include_router(history.router)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["https://joshua92y.github.io", "http://localhost:3000", "http://localhost:5173"],  # 실제 프론트엔드 도메인 추가
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "DELETE", "OPTIONS"],  # 필요한 HTTP 메서드만 명시적으로 허용
    allow_headers=["*"],
)



@app.options("/{rest_of_path:path}")
async def preflight_global(request: Request, rest_of_path: str):
    return JSONResponse(
        status_code=200,
        content={"message": "Preflight OK"},
        headers={
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Methods": "POST, OPTIONS, GET",
            "Access-Control-Allow-Headers": "*",
        }
    )