import 'package:flutter/material.dart';

class CrisisEvent {
  final String id;
  final String type;
  String severity; // Low, Medium, Critical
  final String locationName;
  final Offset position;
  double confidence; // 0.0 - 1.0
  int affectedPopulation;
  double dangerRadius;
  double maxDangerRadius;
  final List<String> assignedVehicleIds;
  final List<String> aiReasoningSteps;
  final List<String> recommendedActions;
  String beforeImpactStatus;
  String afterImpactStatus;
  final bool isFalseAlarm;
  bool isResolved;
  double etaMinutes;
  final DateTime timestamp;
  double resolvedProgress; // 0.0 to 1.0

  CrisisEvent({
    required this.id,
    required this.type,
    required this.severity,
    required this.locationName,
    required this.position,
    required this.confidence,
    required this.affectedPopulation,
    required this.dangerRadius,
    required this.maxDangerRadius,
    required this.assignedVehicleIds,
    required this.aiReasoningSteps,
    required this.recommendedActions,
    required this.beforeImpactStatus,
    required this.afterImpactStatus,
    required this.isFalseAlarm,
    required this.isResolved,
    required this.etaMinutes,
    required this.timestamp,
    this.resolvedProgress = 0.0,
  });
}

class EmergencyVehicle {
  final String id;
  final String type; // Ambulance, Police, Rescue
  Offset position;
  final Offset basePosition;
  Offset targetPosition;
  String status; // Idle, Dispatched, OnScene, Returning
  double travelProgress; // 0.0 to 1.0
  String? assignedCrisisId;
  final Color color;
  double fuelOrBattery;

  EmergencyVehicle({
    required this.id,
    required this.type,
    required this.position,
    required this.basePosition,
    required this.targetPosition,
    required this.status,
    required this.travelProgress,
    this.assignedCrisisId,
    required this.color,
    this.fuelOrBattery = 1.0,
  });
}

class AntigravityTrace {
  final DateTime timestamp;
  final String category; // Signal Fusion, Confidence Score, Priority Rank, Resource Tradeoff, Action Execution, False Alarm Recovery
  final String title;
  final String description;
  final double parameterValue;

  AntigravityTrace({
    required this.timestamp,
    required this.category,
    required this.title,
    required this.description,
    required this.parameterValue,
  });
}

class AgentState {
  final String name;
  final IconData icon;
  final Color color;
  final String role;
  String currentStatus;
  double confidence;
  final List<String> reasoningSteps;

  AgentState({
    required this.name,
    required this.icon,
    required this.color,
    required this.role,
    required this.currentStatus,
    required this.confidence,
    required this.reasoningSteps,
  });
}

class WeatherState {
  double rainIntensity;
  double temperature;
  double windSpeed;
  double floodSpreadProbability;
  String heatwaveRisk;

  WeatherState({
    this.rainIntensity = 0.25,
    this.temperature = 29.5,
    this.windSpeed = 14.0,
    this.floodSpreadProbability = 0.20,
    this.heatwaveRisk = 'Medium',
  });
}

class TrafficSegment {
  final Offset start;
  final Offset end;
  double congestionLevel;
  bool isBlocked;

  TrafficSegment({
    required this.start,
    required this.end,
    this.congestionLevel = 0.15,
    this.isBlocked = false,
  });
}

class AlertModel {
  final String title;
  final String body;
  final DateTime timestamp;
  final String crisisId;
  final String severity;

  AlertModel({
    required this.title,
    required this.body,
    required this.timestamp,
    required this.crisisId,
    required this.severity,
  });
}

class LogEntry {
  final String message;
  final DateTime timestamp;
  final String level; // INFO, WARNING, SUCCESS, AI

  LogEntry({
    required this.message,
    required this.timestamp,
    this.level = 'INFO',
  });
}
