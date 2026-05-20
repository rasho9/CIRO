import random
import asyncio
from typing import List, Tuple, Dict

from ..models.simulation_models import (
    TrafficRerouteRequest,
    TrafficRerouteResult,
    DispatchSimulationRequest,
    DispatchSimulationResult,
    AlertSimulationRequest,
    AlertSimulationResult,
    SimulationLog,
    FullSimulationResult,
    Coordinate,
)

from .mock_map_logic import build_graph, dijkstra, node_to_location, path_to_locations

class SimulationEngine:
    """Core simulation engine used by the FastAPI simulation endpoint.
    It uses a deterministic mock road graph (grid) to compute shortest paths.
    All calculations are mocked/simplified but produce deterministic, repeatable results
    suitable for a hackathon demo.
    """

    def __init__(self) -> None:
        self.graph = build_graph(self._generate_mock_edges())

    def _generate_mock_edges(self) -> List[Tuple[int, int, float]]:
        """Create a 10x10 grid graph where each adjacent node is 0.5 km apart.
        Node IDs are encoded as ``row * 100 + col`` to keep them unique.
        """
        edges: List[Tuple[int, int, float]] = []
        size = 10
        for row in range(size):
            for col in range(size):
                node = row * 100 + col
                # vertical neighbour
                if row < size - 1:
                    neighbor = (row + 1) * 100 + col
                    edges.append((node, neighbor, 0.5))
                # horizontal neighbour
                if col < size - 1:
                    neighbor = row * 100 + (col + 1)
                    edges.append((node, neighbor, 0.5))
        return edges

    async def run_traffic_reroute(self, req: TrafficRerouteRequest) -> TrafficRerouteResult:
        """Calculate a new route using Dijkstra and estimate congestion reduction.
        The ``origin`` and ``destination`` coordinates are deterministically mapped to
        the nearest grid node using a simple modulo conversion.
        """
        # Map coordinates to node IDs (deterministic, not geographic accurate)
        start_node = int(req.origin.lat * 1000) % 10000
        end_node = int(req.destination.lat * 1000) % 10000
        distance, node_path = dijkstra(self.graph, start_node, end_node)
        new_route = path_to_locations(node_path)

        # Simulate congestion reduction – higher when original congestion is high
        base_factor = random.uniform(0.3, 0.6)
        reduction = round(min(0.9, max(0.1, base_factor * (1 - req.congestion_level)), 3)
        eta_minutes = round(distance / 0.5 * 2, 1)  # rough conversion
        return TrafficRerouteResult(
            new_route=new_route,
            congestion_reduction=reduction,
            eta_minutes=eta_minutes,
        )

    async def run_dispatch_simulation(self, req: DispatchSimulationRequest) -> DispatchSimulationResult:
        """Simulate emergency vehicle travel using the same grid graph.
        Returns the fastest path and the new ETA (in minutes).
        """
        start_node = int(req.start_location.lat * 1000) % 10000
        dest_node = int(req.destination.lat * 1000) % 10000
        distance, node_path = dijkstra(self.graph, start_node, dest_node)
        # Speed conversion: km/min = speed_kmh / 60
        travel_time = distance / (req.speed_kmh / 60)
        return DispatchSimulationResult(
            eta_minutes=round(travel_time, 1),
            path=path_to_locations(node_path),
        )

    async def run_alert_simulation(self, req: AlertSimulationRequest) -> AlertSimulationResult:
        """Simulate broadcasting an alert to a list of recipients.
        ``broadcast_success`` is a random success flag (5 % chance of failure).
        """
        success = random.random() > 0.05
        notified = len(req.target_audience) if success else int(len(req.target_audience) * 0.85)
        return AlertSimulationResult(
            broadcast_success=success,
            recipients_notified=notified,
            timestamp="2026-05-15T15:45:00Z",
        )

    async def run_full_simulation(self, incident_id: str) -> FullSimulationResult:
        """Convenience method that ties the three sub‑simulations together.
        It returns a ``FullSimulationResult`` containing all sub‑results,
        a list of human‑readable log entries and an overall impact summary.
        """
        # Dummy coordinates for demo; in a real system these would be read from Firestore
        origin = Coordinate(lat=31.55, lng=74.34)
        destination = Coordinate(lat=31.56, lng=74.36)

        traffic_req = TrafficRerouteRequest(
            incident_id=incident_id,
            origin=origin,
            destination=destination,
            current_route=[],
            congestion_level=0.7,
        )
        traffic_res = await self.run_traffic_reroute(traffic_req)

        dispatch_req = DispatchSimulationRequest(
            incident_id=incident_id,
            vehicle_type="ambulance",
            start_location=origin,
            destination=destination,
            eta_minutes=30,
            speed_kmh=60.0,
        )
        dispatch_res = await self.run_dispatch_simulation(dispatch_req)

        alert_req = AlertSimulationRequest(
            incident_id=incident_id,
            message="Emergency alert: flood detected in sector 4",
            target_audience=[f"user_{i}" for i in range(1000)],
        )
        alert_res = await self.run_alert_simulation(alert_req)

        logs = [
            SimulationLog(timestamp="2026-05-15T15:40:00Z", message="Traffic reroute computed", level="info"),
            SimulationLog(timestamp="2026-05-15T15:41:00Z", message="Dispatch ETA calculated", level="info"),
            SimulationLog(timestamp="2026-05-15T15:42:00Z", message="Alert broadcast completed", level="info"),
        ]

        overall = (
            f"Traffic reduced by {int(traffic_res.congestion_reduction * 100)}%, "
            f"Rescue ETA improved by {int(dispatch_req.eta_minutes - dispatch_res.eta_minutes)} minutes, "
            f"Citizens alerted successfully"
        )

        return FullSimulationResult(
            reroute=traffic_res,
            dispatch=dispatch_res,
            alert=alert_res,
            logs=logs,
            overall_impact=overall,
        )

# Global singleton used by the FastAPI router
simulation_engine = SimulationEngine()
