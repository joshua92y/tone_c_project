# Dockerfile
FROM python:3.10-slim

WORKDIR /app

# 캐시 최적화: 먼저 requirements 복사
COPY requirements.txt .

# 패키지 설치만 수행 (venv 없이)
RUN pip install --upgrade pip && pip install -r requirements.txt

# 소스 코드 복사
COPY . .

# FastAPI 서버 실행
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
