class Crisis {
  final String type;
  final double confidence; // 0‑1
  final String severity;   // Low / Medium / High
  final String trafficStatus;
  final String dispatchStatus;
  final int activeUnits;

  const Crisis({
    required this.type,
    required this.confidence,
    required this.severity,
    required this.trafficStatus,
    required this.dispatchStatus,
    required this.activeUnits,
  });
}
