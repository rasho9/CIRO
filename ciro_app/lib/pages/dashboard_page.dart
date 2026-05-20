import 'dart:math';
import 'package:flutter/material.dart';
import 'package:ciro_app/theme/colors.dart';
import 'package:ciro_app/models/simulation_models.dart';
import 'package:ciro_app/widgets/pulsing_dot.dart';
import 'package:ciro_app/widgets/cyber_stat_card.dart';

class DashboardPage extends StatelessWidget {
  final List<CrisisEvent> crises;
  final List<AlertModel> alerts;
  final double confidence;
  final List<LogEntry> logs;
  final WeatherState weatherState;
  final List<double> confidenceHistory;
  final Function(CrisisEvent) onCrisisClick;
  final List<EmergencyVehicle> vehicles;
  final List<TrafficSegment> trafficSegments;
  final Map<String, double> hospitalLoads;
  final Function(String) onWhatIfAction;

  const DashboardPage({
    Key? key,
    required this.crises,
    required this.alerts,
    required this.confidence,
    required this.logs,
    required this.weatherState,
    required this.confidenceHistory,
    required this.onCrisisClick,
    required this.vehicles,
    required this.trafficSegments,
    required this.hospitalLoads,
    required this.onWhatIfAction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final activeCrises = crises.where((c) => !c.isResolved).toList();
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth <= 900;

    final double gridRatio = screenWidth < 600 ? 2.0 : 2.8;
    final int gridCount = screenWidth < 600 ? 2 : 3;

    final grid = GridView.count(
      crossAxisCount: gridCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: gridRatio,
      children: [
        CyberStatCard(
          title: 'ACTIVE INCIDENTS',
          value: '${activeCrises.length}',
          icon: Icons.warning,
          glowColor: AppColors.redAlert,
        ),
        const CyberStatCard(
          title: 'AI ENGINE HEALTH',
          value: '98.7% ONLINE',
          icon: Icons.health_and_safety,
          glowColor: Color(0xFF00E676),
        ),
        const CyberStatCard(
          title: 'AVG RESPONSE TIME',
          value: '4.8 MINS',
          icon: Icons.timer,
          glowColor: Color(0xFFFFD600),
        ),
        CyberStatCard(
          title: 'DEPLOYED TEAMS',
          value: '${vehicles.where((v) => v.status != 'Idle').length} ACTIVE',
          icon: Icons.local_shipping,
          glowColor: AppColors.purpleGlow,
        ),
        CyberStatCard(
          title: 'AFFECTED POPULATION',
          value: '${activeCrises.fold<int>(0, (sum, c) => sum + c.affectedPopulation)} EST',
          icon: Icons.people,
          glowColor: const Color(0xFF80DEEA),
        ),
        CyberStatCard(
          title: 'BLOCKED SECTORS',
          value: '${trafficSegments.where((s) => s.isBlocked).length} ROADS',
          icon: Icons.block,
          glowColor: const Color(0xFFFF9100),
        ),
      ],
    );

    if (isMobile) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            grid,
            const SizedBox(height: 20),
            _buildConfidenceTelemetryCard(),
            const SizedBox(height: 20),
            SizedBox(
              height: 300,
              child: RepaintBoundary(
                child: _buildRealtimeLogPanel(),
              ),
            ),
            const SizedBox(height: 20),
            _buildWeatherSimulationConsole(),
            const SizedBox(height: 20),
            SizedBox(
              height: 300,
              child: RepaintBoundary(
                child: _buildIncidentPriorityFeed(),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Column(
              children: [
                grid,
                const SizedBox(height: 20),
                _buildConfidenceTelemetryCard(),
                const SizedBox(height: 20),
                Expanded(
                  child: RepaintBoundary(
                    child: _buildRealtimeLogPanel(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            flex: 2,
            child: Column(
              children: [
                _buildWeatherSimulationConsole(),
                const SizedBox(height: 20),
                Expanded(
                  child: RepaintBoundary(
                    child: _buildIncidentPriorityFeed(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfidenceTelemetryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F143A).withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E284C)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'GLOBAL COGNITIVE SYNC',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white30,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'AI CONFIDENCE COEFFICIENT',
                    style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
              Text(
                '${(confidence * 100).toStringAsFixed(1)}%',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: confidence > 0.75 ? AppColors.cyanAccent : AppColors.redAlert,
                  shadows: [
                    Shadow(
                      color: (confidence > 0.75 ? AppColors.cyanAccent : AppColors.redAlert).withValues(alpha: 0.5),
                      blurRadius: 10,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: confidence,
              minHeight: 8,
              backgroundColor: const Color(0xFF070B1F),
              valueColor: AlwaysStoppedAnimation<Color>(
                confidence > 0.75 ? AppColors.cyanAccent : AppColors.redAlert,
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'REAL-TIME SYNC COEFFICIENT TIMELINE (24H FUSION RATIO)',
            style: TextStyle(fontSize: 9, color: Colors.white30, fontWeight: FontWeight.bold, letterSpacing: 1.0),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 80,
            child: CustomPaint(
              painter: TelemetryChartPainter(confidenceHistory),
              child: Container(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRealtimeLogPanel() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F143A).withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E284C)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              PulsingDot(color: AppColors.cyanAccent),
              SizedBox(width: 8),
              Text(
                'AI COGNITION STREAMS (DECISION LOGGER)',
                style: TextStyle(fontSize: 10, color: Colors.white30, fontWeight: FontWeight.bold, letterSpacing: 1.2),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: logs.length,
              itemBuilder: (_, i) {
                final log = logs[i];
                Color c = Colors.white70;
                if (log.level == 'WARNING') c = const Color(0xFFFFB74D);
                if (log.level == 'SUCCESS') c = const Color(0xFF81C784);
                if (log.level == 'AI') c = AppColors.purpleGlow;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${log.timestamp.toIso8601String().substring(11, 19)} ',
                        style: const TextStyle(fontFamily: 'Courier', fontSize: 11, color: Colors.white24),
                      ),
                      const Text(
                        '» ',
                        style: TextStyle(fontFamily: 'Courier', fontSize: 11, color: AppColors.cyanAccent),
                      ),
                      Expanded(
                        child: Text(
                          log.message,
                          style: TextStyle(fontFamily: 'Courier', fontSize: 11, color: c),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherSimulationConsole() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F143A).withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E284C)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.psychology, color: AppColors.cyanAccent, size: 16),
              SizedBox(width: 8),
              Text(
                'TACTICAL SIMULATION CONSOLE',
                style: TextStyle(fontSize: 10, color: Colors.white30, fontWeight: FontWeight.bold, letterSpacing: 1.2),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _simpleMetric('AMBIENT TEMP', '${weatherState.temperature.toStringAsFixed(1)}°C'),
              _simpleMetric('RAIN RATE', '${(weatherState.rainIntensity * 100).toInt()}%'),
              _simpleMetric('WIND FLOW', '${weatherState.windSpeed.toStringAsFixed(1)} KM/H'),
            ],
          ),
          const SizedBox(height: 16),
          const Text('PROVINCIAL HOSPITAL LOAD INDEX', style: TextStyle(fontSize: 9, color: Colors.white30, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: hospitalLoads.entries.map((entry) {
              final double val = entry.value;
              final Color col = val > 85
                  ? AppColors.redAlert
                  : (val > 50 ? const Color(0xFFFF9100) : const Color(0xFF00E676));
              return Column(
                children: [
                  Text(
                    entry.key.substring(0, 3).toUpperCase(),
                    style: const TextStyle(fontSize: 9, color: Colors.white60),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${val.toStringAsFixed(0)}%',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: col),
                  ),
                ],
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          const Divider(color: Color(0xFF1E284C), height: 1),
          const SizedBox(height: 16),
          const Text(
            'ACTIVE WHAT-IF CRISIS DIRECTIVES',
            style: TextStyle(fontSize: 9, color: Colors.white30, fontWeight: FontWeight.bold, letterSpacing: 1.0),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _whatIfButton(
                'INCREASE RAINFALL',
                Icons.opacity,
                const Color(0xFF80DEEA),
                () => onWhatIfAction('increase_rainfall'),
              ),
              _whatIfButton('ADD CRISIS', Icons.add_alert, AppColors.cyanAccent, () => onWhatIfAction('add_crisis')),
              _whatIfButton(
                'HOSPITAL OVERLOAD',
                Icons.local_hospital,
                const Color(0xFFFFD600),
                () => onWhatIfAction('hospital_overload'),
              ),
              _whatIfButton(
                'ROAD COLLAPSE',
                Icons.broken_image,
                const Color(0xFFFF9100),
                () => onWhatIfAction('road_collapse'),
              ),
              _whatIfButton('GRID FAILURE', Icons.power_off, AppColors.redAlert, () => onWhatIfAction('power_failure')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _whatIfButton(String text, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1.0),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 12),
            const SizedBox(width: 6),
            Text(
              text,
              style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: color, letterSpacing: 0.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _simpleMetric(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 8, color: Colors.white30, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white)),
      ],
    );
  }

  Widget _buildIncidentPriorityFeed() {
    final activeCrises = crises.where((c) => !c.isResolved).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F143A).withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E284C)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ACTIVE HAZARD CHRONICLES',
            style: TextStyle(fontSize: 10, color: Colors.white30, fontWeight: FontWeight.bold, letterSpacing: 1.2),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: activeCrises.isEmpty
                ? const Center(
                    child: Text(
                      'Grid Quiet. Zero Active Incidents.',
                      style: TextStyle(color: Colors.white38, fontSize: 13),
                    ),
                  )
                : ListView.builder(
                    itemCount: activeCrises.length,
                    itemBuilder: (_, i) {
                      final c = activeCrises[i];
                      final color = c.severity == 'Critical'
                          ? AppColors.redAlert
                          : c.severity == 'Medium'
                              ? const Color(0xFFFF9100)
                              : const Color(0xFFFFD600);

                      return GestureDetector(
                        onTap: () => onCrisisClick(c),
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.02),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: color.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              PulsingDot(color: color),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      c.type.toUpperCase(),
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Location: ${c.locationName} | Risk Pop: ${c.affectedPopulation}',
                                      style: const TextStyle(fontSize: 10, color: Colors.white38),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.white30),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class TelemetryChartPainter extends CustomPainter {
  final List<double> history;

  TelemetryChartPainter(this.history);

  @override
  void paint(Canvas canvas, Size size) {
    if (history.isEmpty) return;

    final paintLine = Paint()
      ..color = AppColors.cyanAccent
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final paintFill = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.cyanAccent.withValues(alpha: 0.24),
          AppColors.cyanAccent.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    final fillPath = Path();

    final double stepX = size.width / (history.length - 1).clamp(1, 100);

    path.moveTo(0, size.height * (1.0 - history[0]));
    fillPath.moveTo(0, size.height);
    fillPath.lineTo(0, size.height * (1.0 - history[0]));

    for (int i = 1; i < history.length; i++) {
      final double x = i * stepX;
      final double y = size.height * (1.0 - history[i]);
      path.lineTo(x, y);
      fillPath.lineTo(x, y);
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, paintFill);
    canvas.drawPath(path, paintLine);

    final paintGrid = Paint()
      ..color = Colors.white.withValues(alpha: 0.06)
      ..strokeWidth = 0.8;
    canvas.drawLine(Offset(0, size.height * 0.25), Offset(size.width, size.height * 0.25), paintGrid);
    canvas.drawLine(Offset(0, size.height * 0.5), Offset(size.width, size.height * 0.5), paintGrid);
    canvas.drawLine(Offset(0, size.height * 0.75), Offset(size.width, size.height * 0.75), paintGrid);
  }

  @override
  bool shouldRepaint(covariant TelemetryChartPainter oldDelegate) {
    return oldDelegate.history != history;
  }
}
