from fastapi import APIRouter, HTTPException
from app.schemas import ToneProfile
from app.services.preset import save_preset, load_preset, list_presets, delete_preset

router = APIRouter()

@router.post("/presets/{user_id}")
def create_preset(user_id: str, profile: ToneProfile):
    save_preset(user_id, profile.name, profile)
    return {"message": f"{profile.name} 프리셋 저장 완료"}

@router.get("/presets/{user_id}")
def get_preset_list(user_id: str):
    return list_presets(user_id)

@router.get("/presets/{user_id}/{preset_name}", response_model=ToneProfile)
def get_preset(user_id: str, preset_name: str):
    try:
        return load_preset(user_id, preset_name)
    except FileNotFoundError:
        raise HTTPException(status_code=404, detail="프리셋을 찾을 수 없습니다")

@router.delete("/presets/{user_id}/{preset_name}")
def remove_preset(user_id: str, preset_name: str):
    delete_preset(user_id, preset_name)
    return {"message": f"{preset_name} 프리셋 삭제 완료"}
