import re
from datetime import datetime, timedelta

MAX_LINES = 200
MAX_DAYS = 3

def cut_dialogue_by_date(dialogue: list[str]) -> list[str]:
    date_blocks = []
    current_block = []
    current_date = None
    has_date = False

    date_pattern = re.compile(r"---\s*(\d{4})년\s*(\d{1,2})월\s*(\d{1,2})일.*---")

    for line in dialogue:
        match = date_pattern.match(line.strip())
        if match:
            has_date = True
            year, month, day = map(int, match.groups())
            current_date = datetime(year, month, day)
            if current_block:
                date_blocks.append((current_date, current_block))
            current_block = []
        else:
            current_block.append(line)

    if current_block:
        date_blocks.append((current_date or datetime.now(), current_block))

    if not has_date:
        return dialogue[-MAX_LINES:]

    cutoff = datetime.now() - timedelta(days=MAX_DAYS)
    recent_blocks = [block for date, block in date_blocks if date >= cutoff]
    flat = [line for block in recent_blocks for line in block]
    return flat[-MAX_LINES:]
