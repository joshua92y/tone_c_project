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

브런치 데스트용 문구 추가
https://joshua92y.github.io/tone_c_project/

프론트 재배포 명령어 흐름
git checkout --orphan gh-pages
git reset --hard
git commit --allow-empty -m "init gh-pages"
git push origin gh-pages
git checkout main

빌드 흐름
cd tone_web
flutter build web --base-href="/tone_c_project/"
git subtree push --prefix=tone_web/build/web origin gh-pages
