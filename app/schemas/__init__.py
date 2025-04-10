from pydantic import BaseModel, Field
from typing import List, Literal
#학습용 대화 내용
class AnalyzeRequest(BaseModel):
    dialogue: List[str] = Field(..., description="대화 내용")
#관계유형,톤 분석
class RelationshipTone(BaseModel):
    context: str = Field(..., description="관계 유형 (예: 친구, 연인, 직장, 가족(동년배), 모르는 사람 등 자유롭게 입력)")
    tone: str = Field(..., description="해당 관계에서의 말투 예: '반말+이모지', '존댓말+단호함' 등")
# 말투 프로필
class ToneProfile(BaseModel):
    name: str = Field(..., description="말투 이름 또는 말투 대상 인물")
    tone: str = Field(..., description="전반적인 말투 톤 예: '정중한', '친근한', '장난기 있는'")
    emotion_tendency: str = Field(..., description="감정 경향성 예: '긍정적', '짜증섞인', '쿨한'")
    formality: str = Field(..., description="격식 수준 예: '높음', '중간', '낮음' 등 자유 입력 가능")

    vocab_style: List[str] = Field(..., description="어휘 스타일 예: ['줄임말', 'ㅋㅋ', '유행어']")
    sentence_style: List[str] = Field(..., description="문장 구성 예: ['짧은 문장', '말끝 흐림', '이모지 사용']")
    expression_freq: List[str] = Field(..., description="표현 빈도 예: ['감탄사 많음', '강조 표현 자주']")
    intent_bias: List[str] = Field(..., description="의도 성향 예: ['질문형', '리액션형', '조언형']")

    relationship_tendency: List[RelationshipTone] = Field(..., description="관계별 말투 차이")
    sample_phrases: List[str] = Field(..., description="대표적인 말투 문장 예시")
    notes: str = Field(..., description="관찰된 말투 특징, 요약 또는 설명")
    ai_recommendation_tone: str = Field(..., description="AI가 추천하는 말투 톤 예시")
# 변환 요청
class ConvertRequest(BaseModel):
    text: str = Field(..., description="변환할 문장")
    target_tone: str = Field(..., description="원하는 말투 스타일 예: '친근한', '정중한', '센스있는 친구'")
# 변환 응답
class ConvertResponse(BaseModel):
    converted_text: str = Field(..., description="변환된 문장")
# 변환 요청 (프로필 포함)
class ConvertWithProfileRequest(BaseModel):
    text: str
    tone_profile: ToneProfile
# 변환 응답 (프로필 포함)
class ConvertResponse(BaseModel):
    converted_text: str
# 변환 요청 (프리셋 포함)
class ConvertFromPresetRequest(BaseModel):
    text: str
    preset_name: str
    user_id: str

# 변환 요청 (프리셋 포함 AI 추천)
class ConvertWithAutoPresetRequest(BaseModel):
    text: str
    dialogue_context: List[str]
    user_id: str

# 변환 응답 (프리셋 포함 AI 추천)
class ConvertWithAutoPresetResponse(BaseModel):
    converted_text: str
    selected_preset: str