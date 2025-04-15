# schemas/__init__.py
from pydantic import BaseModel, Field
from typing import List

# 분석 요청: 사용자가 대화를 분석 요청할 때 사용하는 형식
class AnalyzeRequest(BaseModel):
    dialogue: List[str] = Field(..., description="대화 내용")

# 관계별 말투 정의: 상황(관계)별로 어떤 말투를 사용하는지 기술
class RelationshipTone(BaseModel):
    context: str = Field(..., description="관계 유형 (예: 친구, 연인, 직장 등)")
    tone: str = Field(..., description="말투 설명 예: '반말+이모지', '존댓말+단호함'")

# 전체 말투 프로필 구조
class ToneProfile(BaseModel):
    name: str = Field(..., description="말투 이름 또는 타겟 인물")
    tone: str = Field(..., description="전반적인 말투 톤 예: '정중한', '친근한', '장난기 있는'")
    emotion_tendency: str = Field(..., description="감정 성향 예: '긍정적', '짜증섞인', '쿨한'")
    formality: str = Field(..., description="격식 수준: 높음/중간/낮음")

    vocab_style: List[str] = Field(..., description="어휘 스타일 예: ['줄임말', 'ㅋㅋ', '유행어']")
    sentence_style: List[str] = Field(..., description="문장 구성 예: ['짧은 문장', '말끝 흐림', '이모지 사용']")
    expression_freq: List[str] = Field(..., description="표현 빈도 예: ['감탄사 많음', '강조 표현 자주']")
    intent_bias: List[str] = Field(..., description="의도 성향 예: ['질문형', '리액션형', '조언형']")
    relationship_tendency: List[RelationshipTone] = Field(..., description="관계별 말투 차이")
    sample_phrases: List[str] = Field(..., description="대표적인 말투 문장 예시")
    notes: str = Field(..., description="관찰된 말투 특징, 요약 또는 설명")
    ai_recommendation_tone: str = Field(..., description="AI가 추천하는 말투 톤 예시")

# 변환 요청: 텍스트를 단순한 톤 이름으로 변환 요청할 때 사용
class ConvertRequest(BaseModel):
    text: str = Field(..., description="변환할 문장")
    target_tone: str = Field(..., description="원하는 말투 스타일 예: '친근한', '정중한', '센스있는 친구'")

# 변환 요청 (전체 프로필을 전달하는 방식)
class ConvertWithProfileRequest(BaseModel):
    text: str = Field(..., description="변환할 문장")
    tone_profile: ToneProfile = Field(..., description="말투 프로필 전체")

# 프리셋 이름을 통해 변환 요청
class ConvertFromPresetRequest(BaseModel):
    text: str = Field(..., description="변환할 문장")
    preset_name: str = Field(..., description="사용할 프리셋 이름")
    user_id: str = Field(..., description="프리셋 소유 사용자 ID")

# 자동 프리셋 추천 기반 요청
class ConvertWithAutoPresetRequest(BaseModel):
    text: str = Field(..., description="변환할 문장")
    dialogue_context: List[str] = Field(..., description="최근 대화 맥락")
    user_id: str = Field(..., description="사용자 ID")

# 변환 응답: 변환된 문장 반환
class ConvertResponse(BaseModel):
    converted_text: str = Field(..., description="변환된 최종 문장")

# 자동 추천 변환 응답: 변환 결과 + 선택된 프리셋 이름 포함
class ConvertWithAutoPresetResponse(BaseModel):
    converted_text: str = Field(..., description="변환된 최종 문장")
    selected_preset: str = Field(..., description="자동 추천된 프리셋 이름")
