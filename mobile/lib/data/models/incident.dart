class Incident {
  final String id;
  final String title;
  final String description;
  final double latitude;
  final double longitude;
  final int severity; // 1-5
  final DateTime reportedAt;

  Incident({
    required this.id,
    required this.title,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.severity,
    required this.reportedAt,
  });

  factory Incident.fromMap(String id, Map<String, dynamic> data) {
    return Incident(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      latitude: (data['location']?['lat'] ?? 0).toDouble(),
      longitude: (data['location']?['lng'] ?? 0).toDouble(),
      severity: data['severity'] ?? 1,
      reportedAt: (data['reportedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'location': {'lat': latitude, 'lng': longitude},
      'severity': severity,
      'reportedAt': reportedAt,
    };
  }
}
