import 'dart:math';
import 'package:flutter/material.dart';
import 'package:ciro_app/theme/colors.dart';
import 'package:ciro_app/models/simulation_models.dart';

class AgentOrchestrationPage extends StatefulWidget {
  final List<AgentState> agents;
  final AnimationController animationController;

  const AgentOrchestrationPage({
    Key? key,
    required this.agents,
    required this.animationController,
  }) : super(key: key);

  @override
  State<AgentOrchestrationPage> createState() => _AgentOrchestrationPageState();
}

class _AgentOrchestrationPageState extends State<AgentOrchestrationPage> {
  AgentState? _selectedAgent;

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth <= 900;

    final neuralWheelContainer = Container(
      height: isMobile ? 350 : double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF070B1F),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF1E284C)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double w = constraints.maxWidth;
          final double h = constraints.maxHeight;

          return AnimatedBuilder(
            animation: widget.animationController,
            builder: (context, child) {
              return GestureDetector(
                onTapDown: (details) => _handleAgentTap(details.localPosition, w, h),
                child: CustomPaint(
                  size: Size(w, h),
                  painter: AgentNetworkPainter(
                    agents: widget.agents,
                    animationValue: widget.animationController.value,
                  ),
                  child: Container(
                    width: w,
                    height: h,
                    color: Colors.transparent,
                  ),
                ),
              );
            },
          );
        },
      ),
    );

    if (isMobile) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'COGNITIVE AGENT ORCHESTRATION NETWORK',
              style: TextStyle(
                fontSize: 11,
                color: Colors.white30,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 16),
            neuralWheelContainer,
            const SizedBox(height: 24),
            const Text(
              'SELECTED AGENT NODE INTELLIGENCE',
              style: TextStyle(
                fontSize: 11,
                color: Colors.white30,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 450,
              child: _buildAgentDetailSection(),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: neuralWheelContainer,
          ),
          const SizedBox(width: 24),
          Expanded(
            flex: 2,
            child: _buildAgentDetailSection(),
          ),
        ],
      ),
    );
  }

  void _handleAgentTap(Offset tap, double w, double h) {
    final Map<String, Offset> nodePositions = {};
    final double centerX = w / 2;
    final double centerY = h / 2;
    final double radius = min(w, h) * 0.35;

    final agentNames = [
      'Signal Agent',
      'Weather Agent',
      'Verification Agent',
      'Prediction Agent',
      'Planning Agent',
      'Dispatch Agent',
      'Notification Agent',
    ];

    for (int i = 0; i < agentNames.length; i++) {
      final double angle = (i * 2 * pi / agentNames.length) - (pi / 2);
      nodePositions[agentNames[i]] = Offset(
        centerX + radius * cos(angle),
        centerY + radius * sin(angle),
      );
    }

    for (var entry in nodePositions.entries) {
      double dist = (entry.value - tap).distance;
      if (dist < 45) {
        setState(() {
          _selectedAgent = widget.agents.firstWhere((a) => a.name == entry.key);
        });
        break;
      }
    }
  }

  Widget _buildAgentDetailSection() {
    final agent = _selectedAgent ?? widget.agents[0];
    final color = agent.color;

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
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                  border: Border.all(color: color.withValues(alpha: 0.4)),
                ),
                child: Icon(agent.icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    agent.name.toUpperCase(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: color,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'ACTIVE MULTI-AGENT NODE',
                    style: TextStyle(fontSize: 9, color: Colors.white30, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'COGNITIVE INSTANCE ROLE',
            style: TextStyle(fontSize: 10, color: Colors.white30, fontWeight: FontWeight.bold, letterSpacing: 1.0),
          ),
          const SizedBox(height: 6),
          Text(agent.role, style: const TextStyle(fontSize: 13, color: Colors.white70, height: 1.4)),
          const SizedBox(height: 20),
          Row(
            children: [
              const Text('Node Confidence Index: ', style: TextStyle(fontSize: 12, color: Colors.white54)),
              const Spacer(),
              Text(
                '${(agent.confidence * 100).toStringAsFixed(1)}%',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: agent.confidence,
              minHeight: 6,
              backgroundColor: const Color(0xFF070B1F),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'CURRENT SYSTEM PROCESS',
            style: TextStyle(fontSize: 10, color: Colors.white30, fontWeight: FontWeight.bold, letterSpacing: 1.0),
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.02), borderRadius: BorderRadius.circular(8)),
            child: Text(
              agent.currentStatus,
              style: const TextStyle(fontFamily: 'Courier', fontSize: 11, color: Colors.white),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'COGNITIVE DECISION TRACE',
            style: TextStyle(fontSize: 10, color: Colors.white30, fontWeight: FontWeight.bold, letterSpacing: 1.0),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: agent.reasoningSteps.length,
              itemBuilder: (_, i) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('• ', style: TextStyle(color: color, fontSize: 14)),
                      Expanded(
                        child: Text(
                          agent.reasoningSteps[i],
                          style: const TextStyle(fontSize: 12, color: Colors.white60),
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
}

class AgentNetworkPainter extends CustomPainter {
  final List<AgentState> agents;
  final double animationValue;

  AgentNetworkPainter({
    required this.agents,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // Center circular neural wheel layout
    final Map<String, Offset> nodePositions = {};
    final double centerX = w / 2;
    final double centerY = h / 2;
    final double radius = min(w, h) * 0.35;

    final agentNames = [
      'Signal Agent',
      'Weather Agent',
      'Verification Agent',
      'Prediction Agent',
      'Planning Agent',
      'Dispatch Agent',
      'Notification Agent',
    ];

    for (int i = 0; i < agentNames.length; i++) {
      final double angle = (i * 2 * pi / agentNames.length) - (pi / 2);
      nodePositions[agentNames[i]] = Offset(
        centerX + radius * cos(angle),
        centerY + radius * sin(angle),
      );
    }

    // 1. Draw connection lines between nodes with animated pulses
    final Paint linePaint = Paint()
      ..color = const Color(0xFF1E284C).withValues(alpha: 0.5)
      ..strokeWidth = 2.0;

    final connections = [
      ['Signal Agent', 'Verification Agent'],
      ['Signal Agent', 'Prediction Agent'],
      ['Weather Agent', 'Prediction Agent'],
      ['Weather Agent', 'Planning Agent'],
      ['Verification Agent', 'Planning Agent'],
      ['Prediction Agent', 'Planning Agent'],
      ['Planning Agent', 'Dispatch Agent'],
      ['Dispatch Agent', 'Notification Agent'],
    ];

    for (var conn in connections) {
      final p1 = nodePositions[conn[0]];
      final p2 = nodePositions[conn[1]];
      if (p1 == null || p2 == null) continue;

      canvas.drawLine(p1, p2, linePaint);

      // Animated data flow pulse along connection line
      final Paint pulsePaint = Paint()
        ..color = AppColors.cyanAccent
        ..style = PaintingStyle.fill;

      // Calculate pulsing point along the line
      final double progress = (animationValue * 2.0 + conn.hashCode % 10 / 10.0) % 1.0;
      final Offset pulsePos = Offset.lerp(p1, p2, progress)!;

      canvas.drawCircle(pulsePos, 4.0, pulsePaint);

      final Paint pulseGlow = Paint()
        ..color = AppColors.cyanAccent.withValues(alpha: 0.3)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(pulsePos, 8.0, pulseGlow);
    }

    // 2. Draw each agent node
    for (var agent in agents) {
      final pos = nodePositions[agent.name];
      if (pos == null) continue;

      final color = agent.color;

      // Draw glass card backdrop
      final Paint shadowPaint = Paint()
        ..color = Colors.black.withValues(alpha: 0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);
      canvas.drawCircle(pos, 45.0, shadowPaint);

      final Paint fillPaint = Paint()
        ..color = const Color(0xFF0F143A).withValues(alpha: 0.85);
      canvas.drawCircle(pos, 40.0, fillPaint);

      // Pulsing node border
      final Paint borderPaint = Paint()
        ..color = color.withValues(alpha: 0.5 + 0.3 * sin(animationValue * pi * 2))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5;
      canvas.drawCircle(pos, 40.0, borderPaint);

      // Outer thin glowing circle
      final Paint outerGlow = Paint()
        ..color = color.withValues(alpha: 0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;
      canvas.drawCircle(pos, 48.0 + 4.0 * sin(animationValue * pi * 2), outerGlow);

      // Draw label text
      final TextPainter nameTp = TextPainter(
        text: TextSpan(
          text: agent.name.split(' ')[0], // just 'Signal', 'Weather' etc.
          style: TextStyle(
            color: Colors.white,
            fontSize: 10.0,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
            shadows: [
              Shadow(color: color.withValues(alpha: 0.8), blurRadius: 8),
            ],
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      nameTp.layout();
      nameTp.paint(canvas, Offset(pos.dx - nameTp.width / 2, pos.dy - 12));

      // Draw confidence text
      final TextPainter confTp = TextPainter(
        text: TextSpan(
          text: '${(agent.confidence * 100).toInt()}%',
          style: TextStyle(
            color: color,
            fontSize: 9.0,
            fontWeight: FontWeight.w900,
            fontFamily: 'Courier',
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      confTp.layout();
      confTp.paint(canvas, Offset(pos.dx - confTp.width / 2, pos.dy + 8));
    }
  }

  @override
  bool shouldRepaint(covariant AgentNetworkPainter oldDelegate) {
    return true;
  }
}
