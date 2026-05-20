import 'package:flutter/material.dart';
import 'package:ciro_app/theme/colors.dart';
import 'package:ciro_app/models/simulation_models.dart';

class ResourcesPage extends StatelessWidget {
  final List<EmergencyVehicle> vehicles;
  final int handledCrises;
  final int hospitalCapacityUsed;
  final int hospitalCapacityTotal;
  final int shelterCapacityUsed;
  final int shelterCapacityTotal;

  const ResourcesPage({
    Key? key,
    required this.vehicles,
    required this.handledCrises,
    required this.hospitalCapacityUsed,
    required this.hospitalCapacityTotal,
    required this.shelterCapacityUsed,
    required this.shelterCapacityTotal,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth <= 900;

    final respondersListHeader = const Text(
      'STAGING FIELD RESPONDERS LIST (VEHICLE MANAGEMENT)',
      style: TextStyle(fontSize: 11, color: Colors.white30, fontWeight: FontWeight.bold, letterSpacing: 1.2),
    );

    final respondersListBuilder = ListView.builder(
      itemCount: vehicles.length,
      itemBuilder: (_, i) {
        final v = vehicles[i];
        Color statusColor = Colors.greenAccent;
        if (v.status == 'Dispatched') statusColor = AppColors.cyanAccent;
        if (v.status == 'OnScene') statusColor = AppColors.redAlert;
        if (v.status == 'Returning') statusColor = AppColors.purpleGlow;

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF0F143A).withOpacity(0.4),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF1E284C)),
          ),
          child: Row(
            children: [
              Icon(Icons.local_shipping, color: v.color, size: 24),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(v.id, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14)),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: v.color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                          child: Text(v.type.toUpperCase(), style: TextStyle(fontSize: 8, color: v.color, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      v.status == 'Idle'
                          ? 'Standby coordinates: E${v.position.dx.toInt()} : N${v.position.dy.toInt()}'
                          : 'Mission assigned: ${v.assignedCrisisId} | Travel Progress: ${(v.travelProgress * 100).toInt()}%',
                      style: const TextStyle(fontSize: 11, color: Colors.white38),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('ENERGY: ${(v.fuelOrBattery * 100).toInt()}%', style: const TextStyle(fontSize: 10, color: Colors.white54, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Container(
                    width: 80,
                    height: 6,
                    decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(3)),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: v.fuelOrBattery,
                      child: Container(color: Colors.greenAccent),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: statusColor),
                ),
                child: Text(
                  v.status.toUpperCase(),
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor),
                ),
              ),
            ],
          ),
        );
      },
    );

    final capacityMatrixHeader = const Text(
      'CIVIC RESPONSE CAPACITY MATRIX',
      style: TextStyle(fontSize: 11, color: Colors.white30, fontWeight: FontWeight.bold, letterSpacing: 1.2),
    );

    final capacityMatrixBody = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF0F143A).withOpacity(0.4),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF1E284C)),
          ),
          child: Row(
            children: [
              const Icon(Icons.verified, color: Colors.greenAccent, size: 36),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('TOTAL MITIGATED EVENTS', style: TextStyle(fontSize: 9, color: Colors.white30, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('$handledCrises INCIDENTS', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                ],
              )
            ],
          ),
        ),
        const SizedBox(height: 20),
        _infrastructureCapacityWidget(
          'CENTRAL TRAUMA HOSPITAL BED LOAD',
          hospitalCapacityUsed,
          hospitalCapacityTotal,
          Icons.local_hospital,
          AppColors.cyanAccent,
        ),
        const SizedBox(height: 20),
        _infrastructureCapacityWidget(
          'METROPOLIS SHELTER BED CAPACITY',
          shelterCapacityUsed,
          shelterCapacityTotal,
          Icons.home,
          AppColors.purpleGlow,
        ),
      ],
    );

    if (isMobile) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            respondersListHeader,
            const SizedBox(height: 16),
            SizedBox(
              height: 400,
              child: respondersListBuilder,
            ),
            const SizedBox(height: 32),
            capacityMatrixHeader,
            const SizedBox(height: 16),
            capacityMatrixBody,
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                respondersListHeader,
                const SizedBox(height: 16),
                Expanded(
                  child: respondersListBuilder,
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                capacityMatrixHeader,
                const SizedBox(height: 16),
                capacityMatrixBody,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infrastructureCapacityWidget(String label, int used, int total, IconData icon, Color color) {
    double ratio = total > 0 ? used / total : 0.0;
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
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 10),
              Text(label, style: const TextStyle(fontSize: 9, color: Colors.white30, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$used / $total OCCUPIED', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
              Text('${(ratio * 100).toInt()}%', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 8,
              backgroundColor: const Color(0xFF070B1F),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          )
        ],
      ),
    );
  }
}
