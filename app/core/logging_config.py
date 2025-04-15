# app/core/logging_config.py
# 이 모듈은 로깅 전용 모듈로, 어떤 다른 모듈도 import 하지 않고 오직 logger 정의만 담당합니다.

import logging
import sys
from typing import Optional

# 공통 로거 생성 함수
# - name: 로거 이름
# - level: 로그 레벨 (기본은 INFO)
# - stream: 출력 스트림 (기본은 sys.stdout)
def setup_logger(name: str, level: int = logging.INFO, stream: Optional[object] = None) -> logging.Logger:
    formatter = logging.Formatter(
        fmt='%(asctime)s [%(levelname)s] %(name)s: %(message)s',
        datefmt='%Y-%m-%d %H:%M:%S'
    )

    # 기본 출력 스트림 설정
    if stream is None:
        stream = sys.stdout

    handler = logging.StreamHandler(stream)
    handler.setFormatter(formatter)

    logger = logging.getLogger(name)
    logger.setLevel(level)

    # 중복 핸들러 방지
    if not logger.hasHandlers():
        logger.addHandler(handler)

    return logger