from fastapi import APIRouter, HTTPException, Query, Path
from app.schemas import ToneProfile
from app.services.storage import (
    save_tone_profile,
    load_latest_profile,
    list_user_history
)
from app.services.storage import (
    load_profile, update_profile, delete_profile
)

router = APIRouter()

# 임시 저장 (유저별)
_last_results: dict[str, ToneProfile] = {}

# 저장
@router.post("/save", response_model=dict)
def save_last_result(user_id: str = Query(..., description="사용자 ID")):
    profile = _last_results.get(user_id)
    if profile is None:
        raise HTTPException(status_code=400, detail="저장할 데이터가 없습니다.")
    
    path = save_tone_profile(user_id, profile)
    return {"message": "저장 완료", "path": path}

# 마지막 결과 로드
@router.get("/load", response_model=ToneProfile)
def load_saved_result(user_id: str = Query(...)):
    try:
        return load_latest_profile(user_id)
    except FileNotFoundError as e:
        raise HTTPException(status_code=404, detail=str(e))

# 사용자별 저장된 파일 목록
@router.get("/history", response_model=list[str])
def get_user_history(
    user_id: str = Query(...),
    sort: str = Query("asc", description="'asc' 또는 'desc'"),
    query: str | None = Query(None, description="검색 키워드")
):
    return list_user_history(user_id, sort, query)

def set_last_result(user_id: str, profile: ToneProfile):
    _last_results[user_id] = profile


#특정 파일 로드
@router.get("/load/{filename}", response_model=ToneProfile)
def load_by_filename(
    user_id: str = Query(...), 
    filename: str = Path(..., description="불러올 파일명")
):
    try:
        return load_profile(user_id, filename)
    except FileNotFoundError as e:
        raise HTTPException(status_code=404, detail=str(e))

#특정 파일 업데이트
@router.put("/update/{filename}", response_model=dict)
def update_file(
    user_id: str = Query(...),
    filename: str = Path(..., description="수정할 파일명"),
    profile: ToneProfile = ...
):
    try:
        update_profile(user_id, filename, profile)
        return {"message": f"{filename} 업데이트 완료"}
    except FileNotFoundError as e:
        raise HTTPException(status_code=404, detail=str(e))

#특정 파일 삭제
@router.delete("/delete/{filename}", response_model=dict)
def delete_file(
    user_id: str = Query(...),
    filename: str = Path(..., description="삭제할 파일명")
):
    try:
        delete_profile(user_id, filename)
        return {"message": f"{filename} 삭제 완료"}
    except FileNotFoundError as e:
        raise HTTPException(status_code=404, detail=str(e))