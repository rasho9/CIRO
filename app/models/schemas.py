from pydantic import BaseModel, Field
from typing import List, Optional

class ReportRequest(BaseModel):
    """Incoming social‑media style report from a citizen"""
    text: str = Field(..., description="Raw report text (Urdu or English)")
    language: Optional[str] = Field(None, description="Explicit language code (en/ur). If omitted, auto‑detect.")
    latitude: Optional[float] = Field(None, description="Optional GPS latitude supplied by client")
    longitude: Optional[float] = Field(None, description="Optional GPS longitude supplied by client")

class ReportResponse(BaseModel):
    event: str = Field(..., description="Canonical event type, e.g. urban_flood")
    severity: str = Field(..., description="Severity label (low/medium/high)")
    confidence: float = Field(..., ge=0.0, le=1.0, description="Confidence score from 0‑1")
    recommended_actions: List[str] = Field(..., description="AI‑generated response plan")

# Internal intermediate schemas (not exposed via HTTP) – useful for agents
class EnrichedReport(BaseModel):
    text: str
    language: str
    latitude: float
    longitude: float
    timestamp: int

class DetectionResult(BaseModel):
    event_type: str
    severity: str
    confidence: float
    language: str

class PlanResult(BaseModel):
    event_type: str
    severity: str
    confidence: float
    actions: List[str]
    simulation: Optional[dict] = None
    outcome: Optional[dict] = None
