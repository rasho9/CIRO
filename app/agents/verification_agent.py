import asyncio
from typing import Dict, Any

from ..infrastructure.mock_weather_api import get_weather
from ..infrastructure.mock_traffic_api import get_traffic_status
from ..logger import logger

class VerificationAgent:
    """Agent that verifies the output of the NLP detection step.
    It enriches the payload with external data (weather, traffic) and
    applies simple business rules to confirm the event.
    """

    def __init__(self, min_confidence: float = 0.7):
        self.min_confidence = min_confidence

    async def verify(self, payload: Dict[str, Any]) -> Dict[str, Any]:
        """Return payload enriched with ``verified`` flag and supplemental data.
        Expected payload keys: ``event``, ``confidence``.
        """
        logger.info("VerificationAgent – start verification", extra=payload)
        # Basic confidence check
        if payload.get("confidence", 0) < self.min_confidence:
            payload["verified"] = False
            payload["reason"] = "low_confidence"
            logger.warning("Verification failed – low confidence", extra=payload)
            return payload

        # Enrich with weather & traffic data based on location (if present)
        location = payload.get("location")
        if location:
            weather = await get_weather(location)
            traffic = await get_traffic_status(location)
            payload["weather"] = weather
            payload["traffic"] = traffic
        else:
            payload["weather"] = None
            payload["traffic"] = None

        # Simple rule: if weather indicates heavy rain and event == "urban_flood" -> auto‑verify
        if payload["event"] == "urban_flood" and payload["weather"].get("condition") == "heavy_rain":
            payload["verified"] = True
            logger.info("Verification succeeded – weather corroborated", extra=payload)
        else:
            # fallback to confidence check only
            payload["verified"] = payload["confidence"] >= self.min_confidence
            logger.info("Verification result based on confidence", extra=payload)
        return payload
