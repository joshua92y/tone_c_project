pip install -r requirements.txt 한번에 파이썬 환경 설치 하기

#환경 저장하기
pip freeze > requirements.txt

#테스트 환경 셋팅
cd C:\Users\Admin\Desktop\AIX\Tone_C
venv\Scripts\activate.bat
uvicorn app.main:app --reload
uvicorn app.main:app --reload --limit-max-request-size 100
#FastAPI
http://127.0.0.1:8000/docs

#gemini model:

{
  "dialogue": ["안녕?", "오늘 뭐해?", "좋은 하루 보내!"]
}