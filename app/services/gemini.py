# services/gemini.py
import google.generativeai as genai
import json
import re
from app.schemas import ToneProfile
from app.core.config import GEMINI_API_KEY
from app.core.logging_config import setup_logger

# 로거 생성: 순환 참조 없이 직접 설정
# "gemini"는 이 모듈의 이름, ERROR 로거는 별도로 설정
gemini_logger = setup_logger("gemini")
error_logger = setup_logger("error", level=40)

# Gemini 모델 초기화
if not GEMINI_API_KEY:
    raise EnvironmentError("GEMINI_API_KEY is not set in the environment.")

genai.configure(api_key=GEMINI_API_KEY)
model = genai.GenerativeModel("models/gemini-2.0-pro-exp")

def analyze_tone(dialogue: list[str]) -> ToneProfile:
    gemini_logger.info("Starting tone analysis")
    gemini_logger.debug(f"Input dialogue length: {len(dialogue)}")

    if not dialogue:
        raise ValueError("Dialogue input is empty or not provided")

    # Gemini 프롬프트 작성
    prompt = f"""
다음은 두 사람 간의 대화입니다:

{chr(10).join(dialogue)}

이 대화를 분석해서, 이들이 어떤 관계인지(예: 친구, 연인, 직장 동료 등)를 먼저 추론하고,
그 관계에 어울리는 말투 분석 결과를 아래 JSON 형식으로 생성해주세요.

주의:
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
  "notes": "이 말투는 긍정적이며 편안한 분위기를 전달합니다.",
  "ai_recommendation_tone": "이 대화는 친구 간의 대화로, 반말과 유머가 섞인 톤을 추천합니다."
}}
"""

    try:
        gemini_logger.debug("Sending prompt to Gemini API")
        response = model.generate_content(prompt)
        raw_output = response.text.strip()
        gemini_logger.debug(f"Gemini raw output: {raw_output[:200]}...")

        match = re.search(r'\{[\s\S]*\}', raw_output)
        if not match:
            raise ValueError("Failed to find JSON block in Gemini response")

        parsed_json = json.loads(match.group())
        result = ToneProfile(**parsed_json)
        gemini_logger.info("Successfully parsed tone profile")
        return result

    except json.JSONDecodeError:
        error_logger.error("JSON decode error from Gemini response", exc_info=True)
        raise ValueError("Gemini 응답을 JSON으로 변환하는 데 실패했습니다.")

    except Exception:
        error_logger.error("Unhandled exception in analyze_tone", exc_info=True)
        raise RuntimeError("Gemini 분석 중 알 수 없는 오류가 발생했습니다.")