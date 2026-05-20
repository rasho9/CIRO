// backend/app/agents/nlp_crisis_detection_agent.py
import re
import asyncio
from typing import Dict, Any
from ..infrastructure.gemini.gemini_client import GeminiClient
from ..logger import logger

class NLPCrisisDetectionAgent:
    """Agent that receives raw report text and returns structured detection.
    Supports English and Urdu (via simple regex heuristics; in production replace with LLM).
    """
    def __init__(self, gemini: GeminiClient):
        self.gemini = gemini
        # basic keyword dictionaries for event detection
        self.event_keywords = {
            "urban_flood": [r"pani", r"bho\w*", r"flood", r"water"],
            "road_accident": [r"accident", r"crash", r"collision", r"hadsa"],
            "heatwave": [r"heat", r"heatwave", r"garmi"],
            "road_blockage": [r"block", r"jam", r"rukawat", r"traffic"],
        }
        self.severity_keywords = {
            "high": [r"high", r"zayada", r"severe", r"shiddat"],
            "medium": [r"medium", r"madhyam", r"moderate"],
            "low": [r"low", r"kam", r"light"]
        }

    async def detect(self, text: str) -> Dict[str, Any]:
        """Run detection pipeline.
        Returns dict with keys: event, severity, confidence.
        """
        logger.info(f"[NLPCrisisDetection] Received text: {text}")
        # 1️⃣ language detection – naive check for Urdu Unicode range
        is_urdu = any('\u0600' <= ch <= '\u06FF' for ch in text)
        language = "ur" if is_urdu else "en"
        logger.debug(f"Detected language: {language}")

        # 2️⃣ event classification – simple keyword match
        event = "unknown"
        confidence = 0.6  # base confidence
        for ev, patterns in self.event_keywords.items():
            for pat in patterns:
                if re.search(pat, text, flags=re.IGNORECASE):
                    event = ev
                    confidence = 0.85
                    break
            if event != "unknown":
                break
        logger.debug(f"Event inferred: {event} (base conf {confidence})")

        # 3️⃣ severity inference
        severity = "medium"
        for sev, patterns in self.severity_keywords.items():
            for pat in patterns:
                if re.search(pat, text, flags=re.IGNORECASE):
                    severity = sev
                    confidence += 0.1
                    break
            if severity != "medium":
                break
        confidence = min(confidence, 0.99)
        logger.debug(f"Severity inferred: {severity}, confidence: {confidence}")

        # 4️⃣ optional LLM refinement – call Gemini for better confidence if needed
        if confidence < 0.9:
            prompt = (
                f"You are a crisis detection model. Given the following report in {language}, "
                f"classify it into one of: urban_flood, road_accident, heatwave, road_blockage, unknown. "
                f"Also return severity (high/medium/low) and a confidence score (0-1).\nReport: \"{text}\""
            )
            llm_resp = await self.gemini.generate(prompt)
            # Expected format: {"event": "...", "severity": "...", "confidence": 0.xx}
            try:
                parsed = eval(llm_resp)  # safe because Gemini returns JSON‑like string
                event = parsed.get("event", event)
                severity = parsed.get("severity", severity)
                confidence = parsed.get("confidence", confidence)
            except Exception as e:
                logger.error(f"Gemini parsing failed: {e}")

        return {"event": event, "severity": severity, "confidence": round(confidence, 2), "language": language}

# Export a singleton for DI convenience
_gemini_client = GeminiClient()
nlp_agent = NLPCrisisDetectionAgent(_gemini_client)
