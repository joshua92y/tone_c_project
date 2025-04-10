from fastapi import APIRouter
from app.schemas import ConvertRequest, ConvertResponse,ConvertWithProfileRequest,ConvertFromPresetRequest,ConvertWithAutoPresetRequest,ConvertWithAutoPresetResponse
from app.services.convert import convert_tone,convert_with_tone_profile,convert_from_preset,convert_with_auto_preset

router = APIRouter()

@router.post("/convert", response_model=ConvertResponse)
def convert_text(data: ConvertRequest):
    return convert_tone(data)
@router.post("/convert/with-profile", response_model=ConvertResponse)
def convert_text_with_profile(data: ConvertWithProfileRequest):
    return convert_with_tone_profile(data)
@router.post("/convert/from-preset", response_model=ConvertResponse)
def convert_text_from_preset(data: ConvertFromPresetRequest):
    return convert_from_preset(data)
@router.post("/convert/auto-preset", response_model=ConvertWithAutoPresetResponse)
def convert_auto_preset(data: ConvertWithAutoPresetRequest):
    return convert_with_auto_preset(data)