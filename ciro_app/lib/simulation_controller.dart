import 'dart:math';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:ciro_app/theme/colors.dart';
import 'package:ciro_app/models/simulation_models.dart';

// ==========================================
// CENTRAL STATE & SIMULATION CONTROLLER
// ==========================================

class SimulationController extends ChangeNotifier {
  final Random _rand = Random();
  late Timer _simulationTimer;

  // Global State Stores
  final List<CrisisEvent> crises = [];
  final List<AlertModel> alerts = [];
  final List<LogEntry> logs = [];
  final List<AntigravityTrace> traces = [];
  final List<EmergencyVehicle> vehicles = [];
  final List<AgentState> agents = [];
  final WeatherState weatherState = WeatherState();
  final List<TrafficSegment> trafficSegments = [];
  final List<double> confidenceHistory = [0.85, 0.88, 0.84, 0.89, 0.91, 0.87, 0.85];

  // Presentation & UI Control State
  bool isDemoModeActive = false;
  int demoStageIndex = 0;
  Timer? demoPlaybackTimer;
  String aiNarrationLog = "Ready for Judge Presentation. Tap 'ACTIVATE JUDGES AUTO-DEMO MODE'.";

  double confidence = 0.85;
  int handledCrises = 0;
  int tickCount = 0;
  CrisisEvent? selectedCrisisDetail;

  // Provincial Hospital loads (percentage)
  final Map<String, double> hospitalLoads = {
    'Peshawar': 42.0,
    'Islamabad': 35.0,
    'Lahore': 58.0,
    'Quetta': 21.0,
    'Karachi': 64.0,
  };

  // Hospital & Shelter capacities
  int hospitalCapacityUsed = 42;
  int hospitalCapacityTotal = 150;
  int shelterCapacityUsed = 120;
  int shelterCapacityTotal = 500;

  // State of active false alarm sequence
  String? falseAlarmCrisisId;
  int falseAlarmSequenceStep = 0;

  SimulationController() {
    _initializeAgents();
    _initializeInfrastructure();
    _initializeVehicles();
    _seedInitialCrises();

    // Start the periodic simulation timer (Ticks every 2.5 seconds)
    _simulationTimer = Timer.periodic(
      const Duration(milliseconds: 2500),
      (_) => _tickSimulation(),
    );

    _log('CIRO Advanced Emergency Command Center OS initialized.', 'SUCCESS');
  }

  void selectCrisis(CrisisEvent c) {
    selectedCrisisDetail = c;
    notifyListeners();
  }

  void closeCrisisDetail() {
    selectedCrisisDetail = null;
    notifyListeners();
  }

  void forceSelectCrisisDetailDirectly(CrisisEvent? c) {
    selectedCrisisDetail = c;
    notifyListeners();
  }

  // ==========================================
  // INITIALIZATION HELPERS
  // ==========================================

  void _initializeAgents() {
    agents.addAll([
      AgentState(
        name: 'Signal Agent',
        icon: Icons.wifi_tethering,
        color: AppColors.cyanAccent,
        role: 'Ingests multiple raw emergency channels, handles noise filtering, and merges redundant incident reports.',
        currentStatus: 'Monitoring citizen reports & sensors',
        confidence: 0.96,
        reasoningSteps: [
          'Signal fusion model active.',
          'Satellite sensor feeds synced at 50Hz.',
        ],
      ),
      AgentState(
        name: 'Weather Agent',
        icon: Icons.cloudy_snowing,
        color: const Color(0xFF80DEEA),
        role: 'Calculates weather dynamics, flood spreads, temperature spikes, and atmospheric hazards.',
        currentStatus: 'Predicting flood risk margins',
        confidence: 0.94,
        reasoningSteps: [
          'Integrating doppler radar precipitation vectors.',
          'Calculated runoff probability matrix.',
        ],
      ),
      AgentState(
        name: 'Verification Agent',
        icon: Icons.verified_user,
        color: const Color(0xFFFFD54F),
        role: 'Cross-checks social alerts with hardware sensors and camera telemetry to detect false alarms.',
        currentStatus: 'Awaiting signal consensus',
        confidence: 0.95,
        reasoningSteps: [
          'CCTV feed analysis module online.',
          'Sentiment correlation matrices loaded.',
        ],
      ),
      AgentState(
        name: 'Prediction Agent',
        icon: Icons.timeline,
        color: const Color(0xFFF48FB1),
        role: 'Simulates cascade risks, hazard boundary spreads, and structural vulnerability timelines.',
        currentStatus: 'Running Markov chain hazard spreads',
        confidence: 0.92,
        reasoningSteps: [
          'Markov propagation networks primed.',
          'Secondary structural collapse hazard models synchronized.',
        ],
      ),
      AgentState(
        name: 'Planning Agent',
        icon: Icons.psychology,
        color: AppColors.purpleGlow,
        role: 'Compiles impact profiles, conducts before/after scenario analysis, and formats response playbooks.',
        currentStatus: 'Drafting multi-tier playbooks',
        confidence: 0.93,
        reasoningSteps: [
          'Triggering mitigation scenario run 14-B.',
          'Assessing population exposure rates.',
        ],
      ),
      AgentState(
        name: 'Dispatch Agent',
        icon: Icons.local_shipping,
        color: AppColors.redAlert,
        role: 'Allocates responder assets, calculates shortest transit times, and executes preemptive tradeoff redirection.',
        currentStatus: 'Calculating asset ETA equations',
        confidence: 0.95,
        reasoningSteps: [
          'Emergency vehicle coordinates locked.',
          'Asset response prioritizer primed.',
        ],
      ),
      AgentState(
        name: 'Notification Agent',
        icon: Icons.notifications_active,
        color: const Color(0xFF81C784),
        role: 'Formulates broadcast warnings, triggers neighborhood sirens, and publishes live safety protocols.',
        currentStatus: 'Awaiting coordination cues',
        confidence: 0.98,
        reasoningSteps: [
          'Warning broadcast templates parsed.',
          'Citizen feedback feedback-loop active.',
        ],
      ),
    ]);
  }

  void _initializeInfrastructure() {
    trafficSegments.addAll([
      TrafficSegment(start: const Offset(60, 80), end: const Offset(220, 70)),  // Peshawar to Islamabad (M-1)
      TrafficSegment(start: const Offset(220, 70), end: const Offset(320, 180)), // Islamabad to Lahore (M-2)
      TrafficSegment(start: const Offset(320, 180), end: const Offset(80, 280)), // Lahore to Quetta (N-70)
      TrafficSegment(start: const Offset(80, 280), end: const Offset(100, 430)), // Quetta to Karachi (N-25)
      TrafficSegment(start: const Offset(100, 430), end: const Offset(320, 180)), // Karachi to Lahore (M-5)
    ]);
  }

  void _initializeVehicles() {
    vehicles.addAll([
      EmergencyVehicle(
        id: 'AMB-1',
        type: 'Ambulance',
        position: const Offset(220, 70),
        basePosition: const Offset(220, 70),
        targetPosition: const Offset(220, 70),
        status: 'Idle',
        travelProgress: 0.0,
        color: AppColors.cyanAccent,
      ),
      EmergencyVehicle(
        id: 'AMB-2',
        type: 'Ambulance',
        position: const Offset(100, 430),
        basePosition: const Offset(100, 430),
        targetPosition: const Offset(100, 430),
        status: 'Idle',
        travelProgress: 0.0,
        color: AppColors.cyanAccent,
      ),
      EmergencyVehicle(
        id: 'POL-1',
        type: 'Police Unit',
        position: const Offset(320, 180),
        basePosition: const Offset(320, 180),
        targetPosition: const Offset(320, 180),
        status: 'Idle',
        travelProgress: 0.0,
        color: Colors.blueAccent,
      ),
      EmergencyVehicle(
        id: 'POL-2',
        type: 'Police Unit',
        position: const Offset(80, 280),
        basePosition: const Offset(80, 280),
        targetPosition: const Offset(80, 280),
        status: 'Idle',
        travelProgress: 0.0,
        color: Colors.blueAccent,
      ),
      EmergencyVehicle(
        id: 'RSC-1',
        type: 'Rescue Team',
        position: const Offset(60, 80),
        basePosition: const Offset(60, 80),
        targetPosition: const Offset(60, 80),
        status: 'Idle',
        travelProgress: 0.0,
        color: AppColors.purpleGlow,
      ),
      EmergencyVehicle(
        id: 'RSC-2',
        type: 'Rescue Team',
        position: const Offset(220, 70),
        basePosition: const Offset(220, 70),
        targetPosition: const Offset(220, 70),
        status: 'Idle',
        travelProgress: 0.0,
        color: AppColors.purpleGlow,
      ),
    ]);
  }

  void _seedInitialCrises() {
    _addNewCrisis(
      id: 'CRISIS-101',
      type: 'Fire Outbreak',
      severity: 'Medium',
      location: 'Lahore Outer Ring',
      position: const Offset(300, 190),
      population: 1450,
      reasoning: [
        '[Signal Agent] Verified thermal signature on Sat-Cam 4. High certainty.',
        '[Weather Agent] Temperature is 30°C with wind. Flame spread rate calculated at +1.4m/min.',
        '[Planning Agent] Recommending mobilization of 1 Police Unit (perimeter) and 1 Rescue Team (flame suppression).'
      ],
      recommended: [
        'Deploy perimeter isolation barriers.',
        'Actuate local high-pressure water grid.',
        'Issue local evacuation notification.'
      ],
      beforeImpact: 'Uncontained flames threat; potential \$3.2M infrastructure loss.',
      afterImpact: 'Contained within 40m radius; damages mitigated by 92% (\$250k total damage).',
    );

    _addNewCrisis(
      id: 'CRISIS-102',
      type: 'Flash Flood',
      severity: 'Critical',
      location: 'Islamabad Expressway Link',
      position: const Offset(200, 85),
      population: 4100,
      reasoning: [
        '[Signal Agent] Multiple civic camera visual feeds indicate rising water depth (>1.2 meters).',
        '[Weather Agent] Rain intensity is 0.75. Drainage absorption rate saturated. Runoff spike detected.',
        '[Planning Agent] High risk of vehicle trap. Recommend road blockade & rescue vehicle dispatch.'
      ],
      recommended: [
        'Close Islamabad Expressway entrance detour.',
        'Dispatch 1 Ambulance + 1 Rescue Team.',
        'Transmit neighborhood push warning.'
      ],
      beforeImpact: 'Critical traffic entrapment danger; estimated 12 vehicles at risk of submersion.',
      afterImpact: 'All traffic safely diverted. 0 casualties. Transit delays reduced from 90 min to 12 min.',
    );
  }

  // ==========================================
  // SIMULATION TOCK (HEARTBEAT)
  // ==========================================

  void _tickSimulation() {
    tickCount++;

    // 1. Slightly drift weather & traffic conditions
    _simulateAtmosphere();

    // 2. Drive emergency vehicles along their vector pathways
    _driveVehicles();

    // 3. Expand danger zones of active crises, evaluate status
    _growCrises();

    // 4. Progress active false alarm verification sequence
    if (falseAlarmCrisisId != null) {
      _tickFalseAlarmSequence();
    }

    // 5. Spawn new operations anomalies periodically
    if (tickCount % 12 == 0 && falseAlarmCrisisId == null) {
      // Trigger a False Alarm sequence
      _triggerFalseAlarmSequence();
    } else if (tickCount % 7 == 0) {
      // Spawn a genuine crisis
      _spawnGenuineCrisis();
    }

    // 6. Update global AI confidence telemetry
    _updateConfidenceTelemetry();

    // 7. Generate rich dynamic multi-agent collaborative reasoning logs
    final activeIncidents = crises.where((c) => !c.isResolved).toList();
    if (activeIncidents.isNotEmpty) {
      final randomCrisis = activeIncidents[_rand.nextInt(activeIncidents.length)];
      final randomAgent = agents[_rand.nextInt(agents.length)];

      switch (randomAgent.name) {
        case 'Signal Agent':
          _log('[Signal Agent] Analyzing packet consistency. Incident ${randomCrisis.id} GPS jitter within 2.3m variance.', 'INFO');
          break;
        case 'Weather Agent':
          _log('[Weather Agent] Climate Index nominal. Calculating heat / runoff aggravation coefficients for ${randomCrisis.id}.', 'INFO');
          break;
        case 'Verification Agent':
          _log('[Verification Agent] CCTV camera verification active for ${randomCrisis.id}. Neural parser visual match confidence: 99.4%.', 'SUCCESS');
          break;
        case 'Prediction Agent':
          _log('[Prediction Agent] Spread prediction model active for ${randomCrisis.id}. Secondary risk hazard containment: 91.5%.', 'INFO');
          break;
        case 'Planning Agent':
          _log('[Planning Agent] Recalculating dynamic evacuation buffers for ${randomCrisis.id} - boundary restricted to ${randomCrisis.dangerRadius.toStringAsFixed(0)}m.', 'INFO');
          break;
        case 'Dispatch Agent':
          _log('[Dispatch Agent] Tracking field asset transit pathways. Average telemetry latency: 14ms.', 'INFO');
          break;
        case 'Notification Agent':
          _log('[Notification Agent] Metropolitan warning alerts synchronized with ${randomCrisis.id} bypass directions.', 'SUCCESS');
          break;
      }
    } else {
      _log('[Signal Agent] Metropolitan sensor network scanning. 0 incidents flagged.', 'INFO');
    }

    notifyListeners();
  }

  void _simulateAtmosphere() {
    // Fluctuate Temperature
    weatherState.temperature += (_rand.nextDouble() - 0.5) * 0.4;
    weatherState.temperature = weatherState.temperature.clamp(15.0, 43.0);

    // Fluctuate rain
    weatherState.rainIntensity += (_rand.nextDouble() - 0.5) * 0.05;
    weatherState.rainIntensity = weatherState.rainIntensity.clamp(0.0, 1.0);

    // Wind speed
    weatherState.windSpeed += (_rand.nextDouble() - 0.5) * 2.0;
    weatherState.windSpeed = weatherState.windSpeed.clamp(5.0, 60.0);

    // Compute Flood Spread Probability based on rain
    weatherState.floodSpreadProbability = (weatherState.rainIntensity * 0.85).clamp(0.05, 0.95);

    // Heatwave risk
    if (weatherState.temperature > 38.0) {
      weatherState.heatwaveRisk = 'Extreme';
    } else if (weatherState.temperature > 32.0) {
      weatherState.heatwaveRisk = 'High';
    } else if (weatherState.temperature > 25.0) {
      weatherState.heatwaveRisk = 'Medium';
    } else {
      weatherState.heatwaveRisk = 'Low';
    }

    // Traffic congestion dynamics: If rain is high, congestion escalates
    for (var segment in trafficSegments) {
      segment.congestionLevel += (_rand.nextDouble() - 0.5) * 0.1;
      if (weatherState.rainIntensity > 0.6) {
        segment.congestionLevel += 0.05;
      }
      segment.congestionLevel = segment.congestionLevel.clamp(0.05, 0.95);
    }
  }

  void _driveVehicles() {
    for (var vehicle in vehicles) {
      if (vehicle.status == 'Dispatched') {
        vehicle.travelProgress += 0.10; // Moves 10% per tick
        vehicle.position = Offset.lerp(vehicle.basePosition, vehicle.targetPosition, vehicle.travelProgress)!;

        if (vehicle.travelProgress >= 1.0) {
          vehicle.travelProgress = 1.0;
          vehicle.position = vehicle.targetPosition;
          vehicle.status = 'OnScene';
          vehicle.fuelOrBattery -= 0.05;

          _log('[Dispatch Agent] Responder unit ${vehicle.id} arrived on-scene.', 'WARNING');
          _addTrace(
            category: 'Action Execution',
            title: '${vehicle.id} On-Scene',
            description: '${vehicle.id} locked to epicenter. Commencing containment operations.',
            value: 1.0,
          );
        }
      } else if (vehicle.status == 'OnScene') {
        // Commencing work
        vehicle.fuelOrBattery -= 0.02;
        vehicle.fuelOrBattery = vehicle.fuelOrBattery.clamp(0.1, 1.0);

        // Find assigned crisis
        final crisis = crises.firstWhere(
          (c) => c.id == vehicle.assignedCrisisId,
          orElse: () => crises[0],
        );

        if (crisis.id == vehicle.assignedCrisisId && !crisis.isResolved) {
          // Increase resolution progress! Faster with more active responders
          int totalResponders = vehicles.where((v) => v.assignedCrisisId == crisis.id && v.status == 'OnScene').length;
          crisis.resolvedProgress += 0.08 * totalResponders;

          if (crisis.resolvedProgress >= 1.0) {
            crisis.resolvedProgress = 1.0;
            crisis.isResolved = true;
            handledCrises++;

            _log('[Planning Agent] Mitigated all hazard threats for ${crisis.id}. Crisis Resolved.', 'SUCCESS');
            _addTrace(
              category: 'Action Execution',
              title: '${crisis.id} Mitigated',
              description: 'Crisis handled successfully. Before: ${crisis.beforeImpactStatus} After: ${crisis.afterImpactStatus}',
              value: 100.0,
            );

            // Re-route vehicle back to base
            _recallVehiclesForCrisis(crisis.id);
          }
        }
      } else if (vehicle.status == 'Returning') {
        vehicle.travelProgress -= 0.12; // Returning is faster
        vehicle.position = Offset.lerp(vehicle.basePosition, vehicle.targetPosition, vehicle.travelProgress)!;

        if (vehicle.travelProgress <= 0.0) {
          vehicle.travelProgress = 0.0;
          vehicle.position = vehicle.basePosition;
          vehicle.status = 'Idle';
          vehicle.assignedCrisisId = null;
          vehicle.fuelOrBattery = 1.0; // Refueled!
        }
      }
    }
  }

  void _recallVehiclesForCrisis(String crisisId) {
    for (var vehicle in vehicles) {
      if (vehicle.assignedCrisisId == crisisId) {
        vehicle.status = 'Returning';
        _log('[Dispatch Agent] Recalling responder ${vehicle.id} back to staging grid.', 'INFO');
      }
    }
  }

  void _growCrises() {
    for (var crisis in crises) {
      if (crisis.isResolved) continue;

      // 1. Expand danger radius slowly
      if (crisis.dangerRadius < crisis.maxDangerRadius) {
        // If there are responders on-scene, danger radius stops expanding
        bool hasResponders = vehicles.any((v) => v.assignedCrisisId == crisis.id && v.status == 'OnScene');
        if (!hasResponders) {
          crisis.dangerRadius += 3.5;
          crisis.affectedPopulation += (10 + _rand.nextInt(30));
        } else {
          // Shrink danger radius as mitigation works!
          crisis.dangerRadius -= 2.0;
          crisis.dangerRadius = crisis.dangerRadius.clamp(10.0, crisis.maxDangerRadius);
        }
      }

      // 2. Weather aggravation: If high rain / high heat, escalate severity
      if (crisis.severity == 'Medium' && !crisis.isResolved) {
        bool shouldEscalate = false;
        if (crisis.type == 'Fire Outbreak' && weatherState.temperature > 36.0 && _rand.nextDouble() > 0.7) {
          shouldEscalate = true;
          _log('[Weather Agent] Escalating Fire due to extreme temperature (${weatherState.temperature.toStringAsFixed(1)}°C)', 'WARNING');
        } else if (crisis.type == 'Flash Flood' && weatherState.rainIntensity > 0.75 && _rand.nextDouble() > 0.7) {
          shouldEscalate = true;
          _log('[Weather Agent] Escalating Flood severity due to intensive downpour rate.', 'WARNING');
        }

        if (shouldEscalate) {
          crisis.severity = 'Critical';
          crisis.maxDangerRadius += 40;
          _addTrace(
            category: 'Priority Rank',
            title: 'Escalation: ${crisis.id}',
            description: 'Incident elevated to CRITICAL. Weather factors exceeded hazard containment threshold.',
            value: 0.98,
          );
        }
      }

      // 3. Dynamic ETA prediction based on closest dispatch vehicles
      double minEta = 999.0;
      for (var v in vehicles) {
        if (v.assignedCrisisId == crisis.id) {
          double eta = (v.position - crisis.position).distance / 30.0;
          if (eta < minEta) minEta = eta;
        }
      }
      crisis.etaMinutes = minEta == 999.0 ? 0.0 : double.parse(minEta.toStringAsFixed(1));
    }
  }

  void _updateAgentStatus(AgentState agent) {
    int activeCount = crises.where((c) => !c.isResolved).length;

    if (activeCount == 0) {
      agent.currentStatus = 'Idle / Grid Scan Active';
      return;
    }

    switch (agent.name) {
      case 'Signal Agent':
        agent.currentStatus = 'Fusing ${activeCount * 3} telemetry streams';
        break;
      case 'Weather Agent':
        agent.currentStatus = 'Monitoring atmospheric hazards';
        break;
      case 'Verification Agent':
        agent.currentStatus = 'Cross-checking post sentiment vs sensor consensus';
        break;
      case 'Prediction Agent':
        agent.currentStatus = 'Predicting cascade risk profiles';
        break;
      case 'Planning Agent':
        agent.currentStatus = 'Evaluating population impact envelopes';
        break;
      case 'Dispatch Agent':
        int busyCount = vehicles.where((v) => v.status != 'Idle').length;
        agent.currentStatus = 'Routing $busyCount / ${vehicles.length} assets';
        break;
      case 'Notification Agent':
        agent.currentStatus = 'Broadcasting regional safety instructions';
        break;
    }
  }

  void _updateConfidenceTelemetry() {
    double totalConfidence = 0.0;
    for (var agent in agents) {
      agent.confidence += (_rand.nextDouble() - 0.5) * 0.02;
      agent.confidence = agent.confidence.clamp(0.80, 1.0);
      totalConfidence += agent.confidence;

      _updateAgentStatus(agent);
    }

    confidence = totalConfidence / agents.length;

    int unresolvedCriticals = crises.where((c) => !c.isResolved && c.severity == 'Critical').length;
    confidence -= (unresolvedCriticals * 0.04);
    confidence = confidence.clamp(0.40, 1.0);

    confidenceHistory.add(confidence);
    if (confidenceHistory.length > 20) {
      confidenceHistory.removeAt(0);
    }
  }

  // ==========================================
  // ACTION DISPATCH & REALLOCATION (TRADEOFFS)
  // ==========================================

  void _addNewCrisis({
    required String id,
    required String type,
    required String severity,
    required String location,
    required Offset position,
    required int population,
    required List<String> reasoning,
    required List<String> recommended,
    required String beforeImpact,
    required String afterImpact,
    bool isFalseAlarm = false,
  }) {
    final crisis = CrisisEvent(
      id: id,
      type: type,
      severity: severity,
      locationName: location,
      position: position,
      confidence: 0.82 + _rand.nextDouble() * 0.15,
      affectedPopulation: population,
      dangerRadius: 15,
      maxDangerRadius: severity == 'Critical' ? 120 : 70,
      assignedVehicleIds: [],
      aiReasoningSteps: reasoning,
      recommendedActions: recommended,
      beforeImpactStatus: beforeImpact,
      afterImpactStatus: afterImpact,
      isFalseAlarm: isFalseAlarm,
      isResolved: false,
      etaMinutes: 0.0,
      timestamp: DateTime.now(),
    );

    crises.add(crisis);

    alerts.insert(
      0,
      AlertModel(
        title: 'New $severity Crisis: $type in $location',
        body: recommended.isNotEmpty ? recommended[0] : 'Emergency containment recommended.',
        timestamp: DateTime.now(),
        crisisId: id,
        severity: severity,
      ),
    );

    _log('[Signal Agent] Signal fusion parsed raw data. Merged into $id: $type at $location.', 'WARNING');

    _addTrace(
      category: 'Signal Fusion',
      title: 'Merged Event: $id',
      description: 'Unified 4 disparate incoming reports into one single event coordinate: $location.',
      value: 0.95,
    );

    _setTrafficSegmentBlockage(position, true);

    _autoDispatchResources(crisis);
  }

  void _setTrafficSegmentBlockage(Offset position, bool isBlocked) {
    if (trafficSegments.isEmpty) return;
    TrafficSegment closest = trafficSegments[0];
    double minDist = 9999.0;
    for (var s in trafficSegments) {
      double dist = ((s.start + s.end) / 2.0 - position).distance;
      if (dist < minDist) {
        minDist = dist;
        closest = s;
      }
    }
    closest.isBlocked = isBlocked;
    if (isBlocked) {
      _log('[Traffic Agent] Blocked traffic path at E${(closest.start.dx).toInt()} : N${(closest.start.dy).toInt()}. Commencing global rerouting.', 'WARNING');
    }
  }

  void _autoDispatchResources(CrisisEvent crisis) {
    if (crisis.isFalseAlarm) return;

    List<String> targetTypes = [];
    if (crisis.type == 'Flash Flood') {
      targetTypes = ['Rescue Team', 'Ambulance'];
    } else if (crisis.type == 'Fire Outbreak') {
      targetTypes = ['Rescue Team', 'Police Unit'];
    } else if (crisis.type == 'Traffic Accident') {
      targetTypes = ['Police Unit', 'Ambulance'];
    } else if (crisis.type == 'Extreme Heatwave') {
      targetTypes = ['Ambulance'];
    } else if (crisis.type == 'Power Outage') {
      targetTypes = ['Rescue Team'];
    } else if (crisis.type == 'Civic Protest') {
      targetTypes = ['Police Unit'];
    } else {
      targetTypes = ['Police Unit'];
    }

    for (var type in targetTypes) {
      EmergencyVehicle? assignedVehicle;
      double minDistance = 99999.0;

      for (var v in vehicles) {
        if (v.type == type && v.status == 'Idle') {
          double dist = (v.position - crisis.position).distance;
          if (dist < minDistance) {
            minDistance = dist;
            assignedVehicle = v;
          }
        }
      }

      if (assignedVehicle != null) {
        assignedVehicle.status = 'Dispatched';
        assignedVehicle.assignedCrisisId = crisis.id;
        assignedVehicle.targetPosition = crisis.position;
        assignedVehicle.travelProgress = 0.0;
        crisis.assignedVehicleIds.add(assignedVehicle.id);

        _log('[Dispatch Agent] Automated dispatch: ${assignedVehicle.id} routed to ${crisis.id}. ETA: ${(minDistance / 30.0).toStringAsFixed(1)} min.', 'INFO');
        _addTrace(
          category: 'Action Execution',
          title: 'Dispatched ${assignedVehicle.id}',
          description: 'Mobilized asset for ${crisis.type} at ${crisis.locationName}. Dynamic ETA: ${(minDistance / 30.0).toStringAsFixed(1)} mins.',
          value: 1.0,
        );
      } else {
        EmergencyVehicle? candidateForPreemption;
        CrisisEvent? lowCrisis;

        for (var v in vehicles) {
          if (v.type == type && v.status == 'OnScene') {
            final activeCrisis = crises.firstWhere((c) => c.id == v.assignedCrisisId, orElse: () => crises[0]);
            if (activeCrisis.id == v.assignedCrisisId && activeCrisis.severity == 'Low') {
              candidateForPreemption = v;
              lowCrisis = activeCrisis;
              break;
            }
          }
        }

        if (candidateForPreemption != null && lowCrisis != null) {
          _log('[Dispatch Agent] TRADEOFF DECISION: Pre-empting ${candidateForPreemption.id} from low severity event ${lowCrisis.id} to critical event ${crisis.id}!', 'WARNING');

          _addTrace(
            category: 'Resource Tradeoff',
            title: 'Pre-emption: ${candidateForPreemption.id}',
            description: 'Redirected asset from lower severity ${lowCrisis.type} at ${lowCrisis.locationName} to higher priority ${crisis.type} at ${crisis.locationName} due to zero asset availability.',
            value: 0.88,
          );

          lowCrisis.assignedVehicleIds.remove(candidateForPreemption.id);
          candidateForPreemption.status = 'Dispatched';
          candidateForPreemption.assignedCrisisId = crisis.id;
          candidateForPreemption.targetPosition = crisis.position;
          candidateForPreemption.travelProgress = 0.0;
          crisis.assignedVehicleIds.add(candidateForPreemption.id);
        } else {
          _log('[Dispatch Agent] LOGISTICS WARNING: High priority asset deficit. Unable to allocate $type to ${crisis.id}. Re-queuing.', 'WARNING');
          _addTrace(
            category: 'Resource Tradeoff',
            title: 'Asset Depletion',
            description: 'Emergency response queue backed up. Zero available $type units. Manual intervention recommended.',
            value: 0.44,
          );
        }
      }
    }
  }

  // ==========================================
  // PERIODIC SPAWNING
  // ==========================================

  void _spawnGenuineCrisis() {
    final types = [
      'Flash Flood',
      'Traffic Accident',
      'Fire Outbreak',
      'Extreme Heatwave',
      'Power Outage',
      'Civic Protest'
    ];
    final places = [
      'Model Town Sector B',
      'Cantt Intersection',
      'Saddar Market',
      'G-10 Residential Block',
      'Gulberg Commercial Strip',
      'DHA Phase 5 Block K'
    ];
    final severities = ['Low', 'Medium', 'Critical'];

    final type = types[_rand.nextInt(types.length)];
    final location = places[_rand.nextInt(places.length)];
    final severity = severities[_rand.nextInt(severities.length)];

    final segment = trafficSegments[_rand.nextInt(trafficSegments.length)];
    final position = Offset.lerp(segment.start, segment.end, 0.2 + _rand.nextDouble() * 0.6)!;

    final id = 'CRISIS-${100 + _rand.nextInt(900)}';

    // Build unique multi-agent reasoning chain based on the crisis type!
    final List<String> reasoning = [];
    final List<String> recommended = [];
    String beforeImpact = '';
    String afterImpact = '';

    switch (type) {
      case 'Flash Flood':
        reasoning.addAll([
          '[Signal Agent] Hydrology sensors reporting rapid level rise (+12cm/min) in nearby storm drains.',
          '[Weather Agent] Doppler precipitation forecast shows extreme rain density continuing for 45 mins.',
          '[Prediction Agent] Models predict 84% chance of roadway submersion and commercial sector power grid failure.',
          '[Planning Agent] Triage priority locked: Critical threat to life/mobility. Deploying barriers and ambulances.'
        ]);
        recommended.addAll([
          'Deploy regional flood barriers to channel water runoff.',
          'Reroute traffic away from low-lying arterial underpasses.',
          'Preemptively alert localized electricity distribution substations.'
        ]);
        beforeImpact = 'Localized street drowning; predicted 140 casualties and complete utility failure.';
        afterImpact = 'Runoff safely diverted. Commuted threat with zero casualties recorded.';
        break;
      case 'Traffic Accident':
        reasoning.addAll([
          '[Signal Agent] Sudden GPS speed drop to zero detected for 25 consecutive cellular probes.',
          '[Prediction Agent] Models predict complete congestion spillover to Cantt expressway within 10 minutes.',
          '[Planning Agent] Triage priority: Medium. Rerouting emergency transit paths to bypass Cantt bottleneck.'
        ]);
        recommended.addAll([
          'Clear blocked lane using specialized heavy recovery tow vehicles.',
          'Instruct Traffic Agent to override traffic light cycles to green on detour corridors.'
        ]);
        beforeImpact = 'Gridlock spread; estimated 1.5-hour response delay for adjacent sectors.';
        afterImpact = 'Wreckage cleared under 12 mins. Traffic corridor velocity restored to normal.';
        break;
      case 'Fire Outbreak':
        reasoning.addAll([
          '[Signal Agent] Multi-spectral thermal cam Sat-3 detected distinct 430°C temperature anomaly.',
          '[Weather Agent] High dry wind velocity (38km/h) increases risk of structural fire leaps by 65%.',
          '[Prediction Agent] Fire path models predict potential fuel station exposure within 120 meters.',
          '[Planning Agent] Triage priority: Critical. Recommended fire containment and police lockdown.'
        ]);
        recommended.addAll([
          'Dispatch fire suppressive rescue units to establish containment lines.',
          'Establish a 200m isolation perimeter to secure fuel tank reservoirs.',
          'Broadcast local neighborhood evacuation cues.'
        ]);
        beforeImpact = 'Uncontrolled industrial flame spread; potential secondary thermal blast impact.';
        afterImpact = 'Containment perimeter held. Flame suppressed with zero structure damage.';
        break;
      case 'Extreme Heatwave':
        reasoning.addAll([
          '[Weather Agent] Surface temperature sensor array spiked to 43.8°C with high relative humidity.',
          '[Prediction Agent] Thermal strain models indicate 70% spike in geriatric hyperthermia occurrences.',
          '[Planning Agent] Triage priority: Low-Medium. Recommended localized public shelter mobilization.'
        ]);
        recommended.addAll([
          'Open public cooling centers with emergency hydration stock.',
          'Activate dynamic warning broadcasts on metropolitan digital screens.',
          'Mobilize community care check-ins.'
        ]);
        beforeImpact = 'Widespread heat exhaustion; predicted 35 medical emergency events.';
        afterImpact = 'Shelters mobilized; heat-related incidents suppressed by 85%.';
        break;
      case 'Power Outage':
        reasoning.addAll([
          '[Signal Agent] Telemetry drop at main grid transformer T-4. Current frequency fell to 0Hz.',
          '[Prediction Agent] Cascade outage probability at Phase 5 sub-network calculated at 92%.',
          '[Planning Agent] Triage priority: Medium. Emergency power routing sequence requested.'
        ]);
        recommended.addAll([
          'Engage emergency backup generators at Cantt medical wards.',
          'Deploy electrical repair crew to replace isolated transformer fuses.',
          'Alert traffic grid controllers to deploy battery-backed signals.'
        ]);
        beforeImpact = 'Metropolitan darkness; complete hospital and transit system vulnerability.';
        afterImpact = 'Backup grids engaged. Primary power loop restored with zero downtime on key institutions.';
        break;
      case 'Civic Protest':
        reasoning.addAll([
          '[Signal Agent] Social sentiment spikes indicating unauthorized gathering of 1200+ individuals.',
          '[Verification Agent] Confirmed via optical cameras. Realtime crowd size index matches signal logs.',
          '[Planning Agent] Triage priority: Medium. Recommending quiet buffer perimeter to secure commerce.'
        ]);
        recommended.addAll([
          'Establish crowd staging lines using local security units.',
          'Divert transit routes away from central protest coordinates.',
          'Deploy local community mediation support.'
        ]);
        beforeImpact = 'Uncontrolled boulevard congestion; estimated 4-hour commercial lockdown.';
        afterImpact = 'Staging lines held peacefully. Traffic bypass successfully redirected flow.';
        break;
    }

    _addNewCrisis(
      id: id,
      type: type,
      severity: severity,
      location: location,
      position: position,
      population: 400 + _rand.nextInt(3000),
      reasoning: reasoning,
      recommended: recommended,
      beforeImpact: beforeImpact,
      afterImpact: afterImpact,
    );
  }

  void _triggerFalseAlarmSequence() {
    final id = 'CRISIS-${100 + _rand.nextInt(900)}';
    final segment = trafficSegments[_rand.nextInt(trafficSegments.length)];
    final position = Offset.lerp(segment.start, segment.end, 0.5)!;

    falseAlarmCrisisId = id;
    falseAlarmSequenceStep = 0;

    final crisis = CrisisEvent(
      id: id,
      type: 'Flash Flood',
      severity: 'Critical',
      locationName: 'Cantt Expressway',
      position: position,
      confidence: 0.38,
      affectedPopulation: 1800,
      dangerRadius: 10,
      maxDangerRadius: 90,
      assignedVehicleIds: [],
      aiReasoningSteps: [
        '[Signal Agent] SOCIAL STREAM ALERT: Multiple social posts claiming severe flooding at Cantt Expressway corridor.',
        '[Weather Agent] CONFLICT DETECTED: Ground moisture and rain sensor grids reporting 0.0mm precipitation.',
        '[Verification Agent] Verification protocol initiated due to data contradiction. Deploying drone check.'
      ],
      recommendedActions: [
        'Await Verification Agent Consensus confirmation.',
        'Delay metropolitan siren alert to prevent panic.',
        'Mobilize local perimeter check unit.'
      ],
      beforeImpactStatus: 'Potential community evacuation panic; estimated \$45k resource waste.',
      afterImpactStatus: 'False alarm recognized; zero public disruption and zero asset waste.',
      isFalseAlarm: true,
      isResolved: false,
      etaMinutes: 0.0,
      timestamp: DateTime.now(),
    );

    crises.add(crisis);

    alerts.insert(
      0,
      AlertModel(
        title: 'PENDING VERIFICATION: Flooding at Cantt',
        body: 'Social stream feeds suggest water rise. Ground sensors report dry grid. Resolving conflict.',
        timestamp: DateTime.now(),
        crisisId: id,
        severity: 'Critical',
      ),
    );

    _log('[Signal Agent] Conflicting signals detected at Cantt. Social posts report flood but weather shows no precipitation.', 'WARNING');
    _addTrace(
      category: 'Signal Conflict',
      title: 'Conflict Detected: $id',
      description: 'Social posts report severe flooding. Weather reports 0% rain. Verification Agent auditing sensors.',
      value: 0.38,
    );

    // Preemptively dispatch a police unit to do a coordinate check
    final police = vehicles.firstWhere((v) => v.type == 'Police Unit' && v.status == 'Idle', orElse: () => vehicles[0]);
    if (police.status == 'Idle') {
      police.status = 'Dispatched';
      police.assignedCrisisId = id;
      police.targetPosition = position;
      police.travelProgress = 0.0;
      crisis.assignedVehicleIds.add(police.id);
      _log('[Dispatch Agent] Dispatched ${police.id} for visual coordinate verification.', 'INFO');
    }
  }

  void _tickFalseAlarmSequence() {
    falseAlarmSequenceStep++;
    final crisis = crises.firstWhere((c) => c.id == falseAlarmCrisisId, orElse: () => crises[0]);

    if (crisis.id != falseAlarmCrisisId) return;

    if (falseAlarmSequenceStep == 1) {
      crisis.aiReasoningSteps.add('[Verification Agent] Processing CCTV camera live streams at Cantt coordinate. Image parser reports zero standing water accumulation.');
      crisis.confidence = 0.20;
      _log('[Verification Agent] CCTV feeds verify clear asphalt lanes. Ground sensors active.', 'INFO');
    } else if (falseAlarmSequenceStep == 2) {
      crisis.aiReasoningSteps.add('[Prediction Agent] Sentiment analysis suggests social posts originated from a viral storm video from a previous year. 99% false positive probability.');
      crisis.confidence = 0.02;
      _log('[Prediction Agent] Sentiment source traced to historical media. Confirmed false positive.', 'INFO');
    } else if (falseAlarmSequenceStep == 3) {
      crisis.isResolved = true;
      crisis.aiReasoningSteps.add('[Planning Agent] Social flood report confirmed as False Positive. Standing down dispatcher units.');

      _log('[Planning Agent] False Alarm verified at Cantt Expressway. Staging units recalled.', 'SUCCESS');
      _addTrace(
        category: 'False Alarm Recovery',
        title: 'False Positive Cleared',
        description: 'Verified social storm stream was archived media. Ground sensors stable. Staging teams recalled safely.',
        value: 1.0,
      );

      _recallVehiclesForCrisis(crisis.id);
      falseAlarmCrisisId = null;
    }
  }

  // ==========================================
  // SYSTEM LOGGER & TRACER
  // ==========================================

  void _log(String message, String level) {
    logs.insert(
      0,
      LogEntry(
        message: message,
        timestamp: DateTime.now(),
        level: level,
      ),
    );
    if (logs.length > 50) {
      logs.removeLast();
    }
  }

  void _addTrace({
    required String category,
    required String title,
    required String description,
    required double value,
  }) {
    traces.insert(
      0,
      AntigravityTrace(
        timestamp: DateTime.now(),
        category: category,
        title: title,
        description: description,
        parameterValue: value,
      ),
    );
    if (traces.length > 30) {
      traces.removeLast();
    }
  }

  // ==========================================
  // PLAYGROUND SCENARIOS & COMMAND TRIGGERS
  // ==========================================

  void handleWhatIfAction(String action) {
    _log('[Manual Override] Commander triggered $action Directive.', 'AI');
    if (action == 'increase_rainfall') {
      weatherState.rainIntensity = 0.95;
      weatherState.windSpeed = 52.0;
      weatherState.floodSpreadProbability = 0.94;
      _log('[Weather Agent] Critical Downpour triggered manually. Flood escalation potential is 94%.', 'WARNING');
      for (var c in crises) {
        if (c.type == 'Flash Flood' && !c.isResolved) {
          c.severity = 'Critical';
          c.maxDangerRadius += 50.0;
          _log('[Prediction Agent] Escalating flash flood ${c.id} due to intense runoff simulation.', 'WARNING');
        }
      }
    } else if (action == 'add_crisis') {
      _spawnGenuineCrisis();
      _log('[Signal Agent] Secondary crisis node successfully spawned under What-If directive.', 'WARNING');
    } else if (action == 'hospital_overload') {
      hospitalLoads['Lahore'] = 98.4;
      hospitalLoads['Karachi'] = 97.2;
      hospitalLoads['Islamabad'] = 96.5;
      _log('[Planning Agent] Hospital Overload warning! Secondary field triage zones initialized in Punjab and Sindh.', 'WARNING');
      _addTrace(
        category: 'Hospital Capacity',
        title: 'Capacity Saturated',
        description: 'Manual overload simulated at 98.4% capacity. field assets dispatched.',
        value: 0.98,
      );
    } else if (action == 'road_collapse') {
      for (var s in trafficSegments) {
        s.isBlocked = true;
      }
      _log('[Traffic Agent] National Highways collapsed! Dynamic detour matrix recalculated by Planning Agent.', 'WARNING');
    } else if (action == 'power_failure') {
      hospitalLoads['Karachi'] = 99.0;
      final segment = trafficSegments[_rand.nextInt(trafficSegments.length)];
      final pos = Offset.lerp(segment.start, segment.end, 0.5)!;
      final id = 'CRISIS-${100 + _rand.nextInt(900)}';
      _addNewCrisis(
        id: id,
        type: 'Power Outage',
        severity: 'Critical',
        location: 'Karachi Central Grid',
        position: pos,
        population: 15000,
        reasoning: [
          '[Signal Agent] Voltage telemetry dropped below 110kV threshold.',
          '[Prediction Agent] High risk of provincial water pump grid failures.',
          '[Planning Agent] Triggering manual backup battery banks for local hospitals.'
        ],
        recommended: [
          'Engage secondary gas generator systems.',
          'Isolate main terminal block.',
          'Deploy field technicians.'
        ],
        beforeImpact: 'Provincial voltage breakdown; estimated \$1.4M economic disruption.',
        afterImpact: 'Backup grid sync complete; critical assets secured within 1.2s.',
      );
      _log('[Signal Agent] Critical voltage collapse at Karachi Central Grid!', 'WARNING');
    }
    notifyListeners();
  }

  void submitReport(
    String type,
    String severity,
    String location,
    String description,
  ) {
    double rx = 100.0 + _rand.nextDouble() * 200.0;
    double ry = 100.0 + _rand.nextDouble() * 300.0;

    _addNewCrisis(
      id: 'CRISIS-${100 + _rand.nextInt(900)}',
      type: type,
      severity: severity,
      location: location,
      position: Offset(rx, ry),
      population: 600 + _rand.nextInt(2500),
      reasoning: [
        '[Signal Agent] Civic report ingester parsed raw user description.',
        '[Planning Agent] Initializing standard response procedures.',
      ],
      recommended: [
        'Secure perimeter vectors.',
        description,
      ],
      beforeImpact: 'Potential civic disruption.',
      afterImpact: 'Incident mitigated successfully with zero public disruption.',
    );
    notifyListeners();
  }

  void triggerStressTest() {
    _log('[Stress Test] Global Emergency Simulation initialized. Injecting 5 high-density anomalies!', 'WARNING');

    // 1. Spikes provincial hospitals
    hospitalLoads['Lahore'] = 98.6;
    hospitalLoads['Karachi'] = 99.4;
    hospitalLoads['Islamabad'] = 97.8;

    // 2. Collapse routes
    for (var seg in trafficSegments) {
      seg.isBlocked = true;
    }

    // 3. Spawn multiple simultaneous crises!
    final list = [
      {'type': 'Flash Flood', 'loc': 'Khyber Expressway Corridor', 'pos': const Offset(80, 120), 'pop': 6700},
      {'type': 'Fire Outbreak', 'loc': 'Lahore Central Mall', 'pos': const Offset(310, 170), 'pop': 9200},
      {'type': 'Civic Protest', 'loc': 'Karachi Port Terminal', 'pos': const Offset(110, 440), 'pop': 18000},
      {'type': 'Extreme Heatwave', 'loc': 'Quetta Desert Outskirts', 'pos': const Offset(90, 310), 'pop': 4500},
      {'type': 'Power Outage', 'loc': 'Peshawar Grid Station', 'pos': const Offset(70, 75), 'pop': 11000},
    ];

    for (var item in list) {
      final id = 'CRISIS-${100 + _rand.nextInt(900)}';
      _addNewCrisis(
        id: id,
        type: item['type'] as String,
        severity: 'Critical',
        location: item['loc'] as String,
        position: item['pos'] as Offset,
        population: item['pop'] as int,
        reasoning: [
          '[Signal Agent] STRESS VECTOR: Mass telemetry sensor spike detected.',
          '[Prediction Agent] Rapid spread risk computed at 99%. Priority elevated to Critical.',
          '[Planning Agent] Triggering global tri-service triage allocations.'
        ],
        recommended: [
          'Establish emergency staging point.',
          'Deploy local regional safety buffers.',
          'Dispatch containment crew.'
        ],
        beforeImpact: 'Widespread metropolitan outage and commercial grid lockouts.',
        afterImpact: 'Autonomous containment successful with zero casualties.',
      );
    }

    confidence = 0.42; // Drop confidence temporarily due to high network stress!
    _log('[Prediction Agent] Global emergency response score: 42% fusion certainty. Recalculating allocations.', 'WARNING');
    notifyListeners();
  }

  void triggerCustomScenario(
    String type,
    double reliability,
    double velocity,
    double contradiction,
    double geolocation,
    double population,
    Offset position,
  ) {
    final id = 'CRISIS-${100 + _rand.nextInt(900)}';
    final List<String> reasoning = [
      '[Signal Agent] Custom signal injected. Reliability: ${(reliability * 100).toInt()}%. Geolocation Jitter: ${(geolocation * 10).toStringAsFixed(1)}m.',
      '[Verification Agent] Conflicting signals checked. Contradiction Level: ${(contradiction * 100).toInt()}%.'
    ];
    if (contradiction > 0.6) {
      reasoning.add('[Verification Agent] High contradiction detected. Drone check active. Dispatches suspended.');
    } else {
      reasoning.add('[Planning Agent] Consensus confirmed. Directing field teams.');
    }
    _addNewCrisis(
      id: id,
      type: type,
      severity: contradiction > 0.6 ? 'Medium' : 'Critical',
      location: 'Judges Custom Sector',
      position: position,
      population: population.toInt(),
      reasoning: reasoning,
      recommended: [
        'Deploy target containment grid.',
        'Initiate dynamic route bypass.',
      ],
      beforeImpact: 'Local sector grid failure; estimated \$120k disruption.',
      afterImpact: 'Autonomous diversion completed with zero disruption.',
      isFalseAlarm: contradiction > 0.6,
    );
    notifyListeners();
  }

  void toggleDemoPlayback() {
    if (isDemoModeActive) {
      demoPlaybackTimer?.cancel();
      isDemoModeActive = false;
      aiNarrationLog = "Judges auto-presentation mode deactivated.";
      _log('[Demo Mode] Presentation playback paused.', 'SUCCESS');
    } else {
      _log('[Demo Mode] Core OS auto-presentation playback engaged. Syncing timeline...', 'SUCCESS');
      isDemoModeActive = true;
      demoStageIndex = 0;
      _runDemoStageStep();

      demoPlaybackTimer = Timer.periodic(const Duration(seconds: 8), (timer) {
        if (!isDemoModeActive) {
          timer.cancel();
          return;
        }
        demoStageIndex = (demoStageIndex + 1) % 5;
        _runDemoStageStep();
        notifyListeners();
      });
    }
    notifyListeners();
  }

  void _runDemoStageStep() {
    switch (demoStageIndex) {
      case 0:
        aiNarrationLog = "[Stage 1/5: INGESTION] Ingesting multi-channel emergency feeds from Islamabad Expressway. Satellite Hydro Scanners locking thermal coordinates.";
        weatherState.rainIntensity = 0.85;
        weatherState.windSpeed = 38.0;
        _addNewCrisis(
          id: 'CRISIS-DEMO1',
          type: 'Flash Flood',
          severity: 'Critical',
          location: 'Islamabad Express bypass',
          position: const Offset(200, 85),
          population: 4100,
          reasoning: [
            '[Signal Agent] Ingested 12 social feeds and 2 water sensors.',
            '[Weather Agent] Precipitation rates index at 85%. Runoff saturation imminent.'
          ],
          recommended: [
            'Isolate expressway bypass.',
            'Initiate dynamic route alerts.'
          ],
          beforeImpact: 'Hydro buildup threatens nearby transit flows.',
          afterImpact: 'Autonomous diversions successfully mitigated delay times.',
        );
        _log('[Demo Mode] Stage 1 triggered: Multi-source signal ingestion.', 'WARNING');
        break;
      case 1:
        aiNarrationLog = "[Stage 2/5: VERIFICATION & AUDITING] Verification Agent parsing source credibility ratio. Noise and contradiction coefficient: 8%. Alert validity confirmed.";
        confidence = 0.94;
        agents[2].confidence = 0.96; // Verification Agent
        agents[2].currentStatus = "Consensus confirmed on active hydro data feeds.";
        _log('[Demo Mode] Stage 2 triggered: Source credibility verification completed.', 'SUCCESS');
        break;
      case 2:
        aiNarrationLog = "[Stage 3/5: IMPACT PREDICTION] Calculating regional hazard boundaries. Affected population: 4,100 citizens. Saturation overload alert flagged at Islamabad Hospital (84%).";
        hospitalLoads['Islamabad'] = 84.2;
        _addTrace(
          category: 'Signal Fusion',
          title: 'Critical Impact Forecasted',
          description: 'Projecting 84% hospital occupancy limits and \$250k potential damages.',
          value: 0.84,
        );
        _log('[Demo Mode] Stage 3 triggered: Foresight metrics compiled.', 'WARNING');
        break;
      case 3:
        aiNarrationLog = "[Stage 4/5: PREEMPTIVE DISPATCH] Routing dynamic response pathways. Deploying Ambulance AMB-1 from Islamabad base node. Bypassing collapsed expressway.";
        // Move vehicle AMB-1 towards the active flood
        for (var v in vehicles) {
          if (v.id == 'AMB-1') {
            v.status = 'En Route';
            v.targetPosition = const Offset(200, 85);
            v.travelProgress = 0.45;
          }
        }
        _log('[Demo Mode] Stage 4 triggered: Resource optimization detour synchronised.', 'SUCCESS');
        break;
      case 4:
        aiNarrationLog = "[Stage 5/5: BROADCAST WARN] Emergency warnings dispatched to civilian transits. Area Sirens actuate on G-10 avenues. CIRO status: Nominal.";
        _addTrace(
          category: 'Action Execution',
          title: 'Citizen Warnings Broadcasted',
          description: 'Dynamic emergency broadcasts transmitted to media and transport operators.',
          value: 1.0,
        );
        _log('[Demo Mode] Stage 5 triggered: Warning notifications published.', 'SUCCESS');
        break;
    }
  }

  void resetEnvironment() {
    _log('[System OS] Manual OS cold reboot initiated by Commander.', 'SUCCESS');
    crises.clear();
    alerts.clear();
    logs.clear();
    traces.clear();
    vehicles.clear();
    trafficSegments.clear();
    agents.clear();

    // Default capacities & confidence
    confidence = 0.85;
    handledCrises = 0;
    tickCount = 0;
    selectedCrisisDetail = null;
    falseAlarmCrisisId = null;

    hospitalLoads['Peshawar'] = 42.0;
    hospitalLoads['Islamabad'] = 35.0;
    hospitalLoads['Lahore'] = 58.0;
    hospitalLoads['Quetta'] = 21.0;
    hospitalLoads['Karachi'] = 64.0;

    _initializeAgents();
    _initializeInfrastructure();
    _initializeVehicles();
    _seedInitialCrises();

    _log('[System OS] Command environment reset successfully. Core agents nominal.', 'SUCCESS');
    notifyListeners();
  }

  void forceUpdateSeverityAndAutoDispatch(CrisisEvent c) {
    _log('[Manual Override] Dispatch request triggered for ${c.id}. Dispatching backup.', 'AI');
    c.severity = 'Critical';
    _autoDispatchResources(c);
    notifyListeners();
  }

  void forceEvacuateComplete(CrisisEvent c) {
    _log('[Manual Action] Evacuation order verified by Commander.', 'SUCCESS');
    c.affectedPopulation = 0;
    _addTrace(
      category: 'Action Execution',
      title: 'Evacuation Complete',
      description: 'Evacuated danger sector surrounding ${c.locationName} successfully.',
      value: 1.0,
    );
    notifyListeners();
  }

  @override
  void dispose() {
    _simulationTimer.cancel();
    demoPlaybackTimer?.cancel();
    super.dispose();
  }
}
