import 'package:flutter/material.dart';
import 'package:ciro_app/core/constants/colors.dart';

class AIReasoningTimeline extends StatelessWidget {
  final List<String> steps;
  const AIReasoningTimeline({Key? key, required this.steps}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: steps.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (ctx, i) {
          final step = steps[i];
          IconData icon;
          if (step.toLowerCase().contains('detect')) {
            icon = Icons.search;
          } else if (step.toLowerCase().contains('verify')) {
            icon = Icons.check_circle;
          } else if (step.toLowerCase().contains('plan')) {
            icon = Icons.play_arrow;
          } else if (step.toLowerCase().contains('simulate')) {
            icon = Icons.sync;
          } else {
            icon = Icons.auto_awesome;
          }
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppColors.tealLight, size: 28),
              const SizedBox(height: 4),
              Text(step,
                  style: const TextStyle(
                      color: AppColors.onBackground, fontSize: 12)),
            ],
          );
        },
      ),
    );
  }
}
