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
    allow_origins=["*"],  # 또는 ["http://localhost:54041"] 등으로 제한 가능
    allow_credentials=True,
    allow_methods=["*"],  # ["POST", "GET", "OPTIONS"]만 설정해도 OK
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