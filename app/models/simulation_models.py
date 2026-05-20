from pydantic import BaseModel, Field
from typing import List, Dict, Any

class Coordinate(BaseModel):
    lat: float = Field(..., description="Latitude of the point")
    lng: float = Field(..., description="Longitude of the point")

class TrafficRerouteRequest(BaseModel):
    incident_id: str = Field(..., description="ID of the incident to simulate")
    current_route: List[Coordinate] = Field(..., description="Original vehicle route before rerouting")
    congestion_level: float = Field(..., ge=0, le=1, description="Current congestion factor (0‑1)")

class DispatchSimulationRequest(BaseModel):
    incident_id: str = Field(..., description="Incident ID")
    vehicle_type: str = Field(..., description="e.g., 'ambulance', 'fire_truck'")
    start_location: Coordinate = Field(...)
    destination: Coordinate = Field(...)
    eta_minutes: int = Field(..., description="Estimated time of arrival before any optimization")

class SimulationTimelineEvent(BaseModel):
    timestamp: float = Field(..., description="Unix epoch seconds when the event occurs")
    description: str = Field(..., description="Human‑readable description of the event")
    data: Dict[str, Any] = Field(default_factory=dict, description="Optional extra data for the event")

class SimulationResult(BaseModel):
    incident_id: str = Field(...)
    rerouted_route: List[Coordinate] = Field(..., description="New route after traffic optimization")
    congestion_reduction: float = Field(..., description="Percentage reduction (0‑1)")
    dispatch_eta_improvement: int = Field(..., description="Minutes saved for emergency vehicle")
    alerts_sent: int = Field(..., description="Number of citizens notified")
    timeline: List[SimulationTimelineEvent] = Field(..., description="Chronological events of the simulation")

# Helper for converting list of tuples to Coordinates (used in mock map logic)
def coords_from_tuples(tuples: List[tuple]):
    return [Coordinate(lat=lat, lng=lng) for lat, lng in tuples]
