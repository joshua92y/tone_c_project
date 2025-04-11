import google.generativeai as genai
from app.core.config import GEMINI_API_KEY
from app.services.preset import load_preset,list_presets
from app.schemas import ConvertRequest, ConvertResponse,ConvertWithProfileRequest,ConvertFromPresetRequest,ConvertWithAutoPresetRequest,ConvertWithAutoPresetResponse

genai.configure(api_key=GEMINI_API_KEY)
model = genai.GenerativeModel("models/gemini-1.5-pro-latest")

def convert_tone(data: ConvertRequest) -> ConvertResponse:
    prompt = f"""
아래 문장을 '{data.target_tone}' 스타일로 자연스럽게 바꿔줘. 존댓말, 반말, 이모지 등도 반영해줘.
설명 없이 바뀐 문장만 출력해줘.

입력 문장:
{data.text}
"""
    response = model.generate_content(prompt)
    return ConvertResponse(converted_text=response.text.strip())

def convert_with_tone_profile(data: ConvertWithProfileRequest) -> ConvertResponse:
    profile = data.tone_profile

    prompt = f"""
다음 문장을 아래의 말투 스타일에 맞게 자연스럽게 변환해줘. 말투 특성(말끝 흐림, 줄임말, 이모지 등)을 반영해줘.

변환할 문장:
{data.text}

목표 말투 스타일:
- 말투 이름: {profile.name}
- 전반적 톤: {profile.tone}
- 감정 경향성: {profile.emotion_tendency}
- 격식 수준: {profile.formality}
- 어휘 스타일: {", ".join(profile.vocab_style)}
- 문장 스타일: {", ".join(profile.sentence_style)}
- 표현 빈도: {", ".join(profile.expression_freq)}
- 의도 성향: {", ".join(profile.intent_bias)}

결과 문장만 출력해줘.
"""

    response = model.generate_content(prompt)
    return ConvertResponse(converted_text=response.text.strip())
# 프리셋 이름과 사용자 ID를 받아서 변환 요청을 처리하는 함수
def convert_from_preset(data: ConvertFromPresetRequest) -> ConvertResponse:
    profile = load_preset(data.user_id, data.preset_name)
    request_data = ConvertWithProfileRequest(text=data.text, tone_profile=profile)
    return convert_with_tone_profile(request_data)
#AI가 추천하는 프리셋을 사용하여 변환하는 함수
def choose_best_preset_name(context_lines: list[str], user_id: str) -> str:
    preset_names = list_presets(user_id)
    preset_descriptions = []

    for name in preset_names:
        profile = load_preset(user_id, name)
        summary = f"""
- 프리셋 이름: {profile.name}
- 톤: {profile.tone}
- 감정: {profile.emotion_tendency}
- 격식: {profile.formality}
- 어휘 스타일: {", ".join(profile.vocab_style)}
- 문장 스타일: {", ".join(profile.sentence_style)}
- 표현 빈도: {", ".join(profile.expression_freq)}
- 의도 성향: {", ".join(profile.intent_bias)}
- 요약: {profile.notes}
"""
        preset_descriptions.append(summary.strip())

    prompt = f"""
당신은 사용자 맞춤 말투 추천 시스템입니다.

다음은 최근 대화 내용입니다:
{chr(10).join(context_lines)}

그리고 다음은 사용자가 저장한 말투 프리셋 목록입니다:
{chr(10).join(preset_descriptions)}

이 대화 스타일과 가장 잘 어울리는 프리셋을 하나만 골라주세요.
반환은 **정확히 프리셋 이름만** 첫 줄에 적어주세요.
"""

    response = model.generate_content(prompt)
    return response.text.strip().splitlines()[0]
# 프리셋 이름과 사용자 ID를 받아서 자동으로 변환 요청을 처리하는 함수 
def convert_with_auto_preset(data: ConvertWithAutoPresetRequest) -> ConvertWithAutoPresetResponse:
    preset_name = choose_best_preset_name(data.dialogue_context, data.user_id)
    tone_profile = load_preset(data.user_id, preset_name)
    request_data = ConvertWithProfileRequest(text=data.text, tone_profile=tone_profile)
    result = convert_with_tone_profile(request_data)

    return ConvertWithAutoPresetResponse(
        converted_text=result.converted_text,
        selected_preset=preset_name
    )