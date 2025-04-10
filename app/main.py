from fastapi import FastAPI
from app.api import analyze,storage,convert,preset,history
from fastapi.middleware.cors import CORSMiddleware

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