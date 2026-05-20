import heapq
from typing import List, Tuple, Dict
from ..models.simulation_models import Location

# Simple undirected graph representation: node id -> list of (neighbor_id, distance_km)

def build_graph(edges: List[Tuple[int, int, float]]) -> Dict[int, List[Tuple[int, float]]]:
    """Convert edge list to adjacency dict.
    edges = [(a, b, dist), ...]
    """
    graph: Dict[int, List[Tuple[int, float]]] = {}
    for a, b, d in edges:
        graph.setdefault(a, []).append((b, d))
        graph.setdefault(b, []).append((a, d))
    return graph

def dijkstra(graph: Dict[int, List[Tuple[int, float]]], start: int, end: int) -> Tuple[float, List[int]]:
    """Return (total_distance, node_path) using Dijkstra's algorithm.
    If no path exists, returns (float('inf'), []).
    """
    heap: List[Tuple[float, int, List[int]]] = [(0.0, start, [start])]
    visited: set[int] = set()
    while heap:
        dist, node, path = heapq.heappop(heap)
        if node in visited:
            continue
        visited.add(node)
        if node == end:
            return dist, path
        for neighbor, w in graph.get(node, []):
            if neighbor not in visited:
                heapq.heappush(heap, (dist + w, neighbor, path + [neighbor]))
    return float('inf'), []

def node_to_location(node_id: int) -> Location:
    """Map a deterministic node id to a lat/lng for demo purposes.
    This function creates a grid of points – for a hackathon it is enough.
    """
    # Simple deterministic conversion: each node increments lat/lng by 0.001
    base_lat, base_lng = 31.5497, 74.3436  # Lahore centre
    lat = base_lat + (node_id // 100) * 0.001
    lng = base_lng + (node_id % 100) * 0.001
    return Location(lat=lat, lng=lng)

def path_to_locations(node_path: List[int]) -> List[Location]:
    return [node_to_location(n) for n in node_path]
