import 'package:flutter/material.dart';
import 'package:ciro_app/theme/colors.dart';
import 'package:ciro_app/models/simulation_models.dart';
import 'package:ciro_app/widgets/pulsing_dot.dart';

class AlertsPage extends StatelessWidget {
  final List<AlertModel> alerts;
  final List<CrisisEvent> crises;
  final Function(CrisisEvent) onCrisisClick;

  const AlertsPage({
    Key? key,
    required this.alerts,
    required this.crises,
    required this.onCrisisClick,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'LOGISTICS RADAR: EMERGENCY ALERTS STREAM',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white30,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: alerts.isEmpty
                ? const Center(
                    child: Text(
                      'Incident feed quiescent. Monitoring grid.',
                      style: TextStyle(color: Colors.white38, fontSize: 13),
                    ),
                  )
                : ListView.builder(
                    itemCount: alerts.length,
                    itemBuilder: (_, i) {
                      final alert = alerts[i];
                      final matchingCrisis = crises.firstWhere(
                        (c) => c.id == alert.crisisId,
                        orElse: () => crises[0],
                      );

                      final isResolved = matchingCrisis.id == alert.crisisId ? matchingCrisis.isResolved : false;

                      final color = alert.severity == 'Critical'
                          ? AppColors.redAlert
                          : alert.severity == 'Medium'
                              ? const Color(0xFFFF9100)
                              : const Color(0xFFFFD600);

                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F143A).withOpacity(0.4),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isResolved ? Colors.green.withValues(alpha: 0.3) : color.withValues(alpha: 0.3),
                          ),
                        ),
                        child: ExpansionTile(
                          leading: PulsingDot(color: isResolved ? Colors.green : color),
                          title: Row(
                            children: [
                              Text(
                                alert.title,
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              const SizedBox(width: 10),
                              if (isResolved)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'RESOLVED',
                                    style: TextStyle(fontSize: 8, color: Colors.green, fontWeight: FontWeight.bold),
                                  ),
                                ),
                            ],
                          ),
                          subtitle: Text(
                            'Fused Timestamp: ${alert.timestamp.toString().substring(0, 19)}',
                            style: const TextStyle(color: Colors.white30, fontSize: 11),
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    alert.body,
                                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                                  ),
                                  const SizedBox(height: 14),
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.cyanAccent,
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    ),
                                    icon: const Icon(Icons.launch, color: Colors.black, size: 16),
                                    label: const Text(
                                      'OPEN COGNITIVE DETAILS PANEL',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    onPressed: () {
                                      onCrisisClick(matchingCrisis);
                                    },
                                  ),
                                ],
                              ),
                            )
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
}
