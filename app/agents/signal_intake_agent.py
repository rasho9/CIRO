import re
import time
from typing import Dict

from ..models.schemas import ReportRequest, EnrichedReport

class SignalIntakeAgent:
    """Agent 1 – Signal Intake
    * Normalises the raw report
    * Detects language (simple heuristic)
    * Adds timestamp and GPS fallback (0,0 if missing)
    """

    async def process(self, request: ReportRequest) -> EnrichedReport:
        # language detection – naive: if any Urdu Unicode block present, treat as ur
        if request.language:
            language = request.language
        else:
            language = "ur" if re.search(r"[\u0600-\u06FF]", request.text) else "en"

        # fallback location – could be expanded with IP‑geo lookup
        latitude = request.latitude if request.latitude is not None else 0.0
        longitude = request.longitude if request.longitude is not None else 0.0

        enriched = EnrichedReport(
            text=request.text,
            language=language,
            latitude=latitude,
            longitude=longitude,
            timestamp=int(time.time()),
        )
        return enriched
