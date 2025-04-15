import google.generativeai as genai
import json
import re
import os
from app.schemas import ToneProfile, RelationshipTone
from app.core.config import GEMINI_API_KEY
from app.core.logging_config import gemini_logger, error_logger

genai.configure(api_key=GEMINI_API_KEY)

model = genai.GenerativeModel("models/gemini-2.0-pro-exp")  # Gemini 모델 설정

def analyze_tone(dialogue: list) -> ToneProfile:
    try:
        gemini_logger.info("Starting tone analysis")
        gemini_logger.debug(f"Input dialogue length: {len(dialogue)}")
        
        prompt = f"""
다음은 두 사람 간의 대화입니다:

{chr(10).join(dialogue)}

이 대화를 분석해서, 이들이 어떤 관계인지(예: 친구, 연인, 직장 동료 등)를 먼저 추론하고,
그 관계에 어울리는 말투 분석 결과를 아래 JSON 형식으로 생성해주세요.

주의:
- 꼭 실제 분석 결과를 작성하세요. 예시 형식 그대로는 반환하지 마세요.
- 설명 없이 JSON 데이터만 응답하세요.

JSON 형식:

{{
  "name": "말투 이름",
  "tone": "친근한, 정중한 등",
  "emotion_tendency": "긍정적, 부정적 등",
  "formality": "높음 | 중간 | 낮음",
  "vocab_style": ["줄임말", "유행어", "..."],
  "sentence_style": ["짧은 문장", "이모지 사용", "..."],
  "expression_freq": ["감탄사 많음", "강조 표현 자주", "..."],
  "intent_bias": ["리액션형", "조언형", "..."],
  "relationship_tendency": [
    {{ "context": "친구", "tone": "반말 + 유쾌함" }},
    {{ "context": "직장", "tone": "존댓말 + 공손함" }}
  ],
  "sample_phrases": ["와 진짜 대박!", "고마워~", "ㅇㅋㅋㅋ"],
  "notes": "이 말투는 긍정적이며 편안한 분위기를 전달합니다."
  "ai_recommendation_tone": "이 대화는 친구 간의 대화로, 반말과 유머가 섞인 톤을 추천합니다."
}}
"""

        gemini_logger.debug("Sending request to Gemini API")
        response = model.generate_content(prompt)
        gemini_logger.debug(f"Received response from Gemini API: {response.text[:200]}...")
        
        match = re.search(r'\{[\s\S]*\}', response.text)
        if not match:
            error_msg = "Gemini 응답에서 JSON을 찾을 수 없습니다."
            gemini_logger.error(error_msg)
            raise ValueError(error_msg)
            
        try:
            parsed_dict = json.loads(match.group())
            gemini_logger.debug("Successfully parsed JSON response")
            result = ToneProfile(**parsed_dict)
            gemini_logger.info("Successfully created ToneProfile")
            return result
            
        except json.JSONDecodeError as e:
            error_logger.error("JSON 파싱 오류", exc_info=True)
            error_logger.error(f"응답 원문: {response.text}")
            raise
            
    except Exception as e:
        error_logger.error("Unexpected error in analyze_tone", exc_info=True)
        raise