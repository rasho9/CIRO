import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/constants/colors.dart';
import '../../data/models/simulation_result.dart';
import '../../data/repositories/simulation_service.dart';
import '../widgets/animated_route_map.dart';
import '../widgets/futuristic_card.dart';

class SimulationScreen extends ConsumerStatefulWidget {
  const SimulationScreen({Key? key}) : super(key: key);
  @override
  ConsumerState<SimulationScreen> createState() => _SimulationScreenState();
}

class _SimulationScreenState extends ConsumerState<SimulationScreen> {
  late final SimulationService _service;
  SimulationResult? _result;
  bool _loading = true;
  final String _incidentId = "demo_incident_001"; // demo – replace with real ID

  @override
  void initState() {
    super.initState();
    _service = ref.read(simulationServiceProvider);
    _fetchSimulation();
  }

  Future<void> _fetchSimulation() async {
    setState(() => _loading = true);
    final res = await _service.runFullSimulation(_incidentId);
    setState(() {
      _result = res;
      _loading = false;
    });
    // Listen to live logs via WebSocket (optional)
    _service.streamLogs(_incidentId).listen((log) {
      // Append to UI logs – a simple setState for demo
      setState(() {
        _result?.logs.add(log);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Crisis Simulation'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _result == null
              ? const Center(child: Text('No data'))
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Animated map with before/after routes
                      SizedBox(
                        height: 260,
                        child: AnimatedRouteMap(
                          beforeRoute: _result!.reroute.currentRoute,
                          afterRoute: _result!.reroute.newRoute,
                          incidentLocation: _result!.incidentLocation,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Metrics cards
                      FuturisticCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Impact Summary',
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Text(
                                'Traffic reduced by ${(_result!.reroute.congestionReduction * 100).toInt()}%',
                                style: const TextStyle(fontSize: 16)),
                            Text(
                                'Rescue ETA improved by ${(_result!.dispatch.etaImprovement).toInt()} min',
                                style: const TextStyle(fontSize: 16)),
                            const Text('Citizens alerted successfully',
                                style: TextStyle(fontSize: 16)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Real‑time log feed
                      FuturisticCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Simulation Log',
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            ..._result!.logs.map((log) => Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4),
                                  child: Text(
                                      "[${log.timestamp}] ${log.message}",
                                      style: const TextStyle(
                                          fontSize: 14,
                                          color: AppColors.primaryText)),
                                )),
                          ],
                        ),
                      ),
                      const SizedBox(height: 80), // bottom padding for nav bar
                    ],
                  ),
                ),
      // Bottom navigation is already handled globally
    );
  }
}
