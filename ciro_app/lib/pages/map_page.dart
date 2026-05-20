import 'dart:math';
import 'package:flutter/material.dart';
import 'package:ciro_app/theme/colors.dart';
import 'package:ciro_app/models/simulation_models.dart';
import 'package:ciro_app/simulation_controller.dart';

class MapPage extends StatefulWidget {
  final SimulationController simulationController;
  final Function(CrisisEvent) onCrisisClick;

  const MapPage({
    Key? key,
    required this.simulationController,
    required this.onCrisisClick,
  }) : super(key: key);

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  void _handleMapTap(Offset tapPos, double w, double h) {
    final double scale = min(w / 400.0, h / 500.0);
    final double dx = (w - 400.0 * scale) / 2;
    final double dy = (h - 500.0 * scale) / 2;

    final activeCrises = widget.simulationController.crises.where((c) => !c.isResolved).toList();
    for (var c in activeCrises) {
      final Offset screenPos = Offset(dx + c.position.dx * scale, dy + c.position.dy * scale);
      double dist = (screenPos - tapPos).distance;
      if (dist < 35.0) {
        widget.onCrisisClick(c);
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      margin: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF070B1F),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF1E284C), width: 1.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double w = constraints.maxWidth;
            final double h = constraints.maxHeight;

            return Stack(
              children: [
                // Layer 1: Static Grid Background (const, wrapped in RepaintBoundary)
                const RepaintBoundary(
                  child: GridLayer(),
                ),

                // Layer 2: Animated Radar Sweep (isolated 60 FPS repainting)
                const RepaintBoundary(
                  child: RadarSweepLayer(),
                ),

                // Layer 3: High-Performance Road/Motorways Layer (isolated, smooth dash travels)
                RepaintBoundary(
                  child: RoadLayer(simulationController: widget.simulationController),
                ),

                // Layer 4: Cities Layer (Pakistan provincial nodes with load arcs)
                RepaintBoundary(
                  child: CitiesLayer(simulationController: widget.simulationController),
                ),

                // Layer 5: Active Crisis Zones (danger circles)
                RepaintBoundary(
                  child: CrisisZonesLayer(
                    simulationController: widget.simulationController,
                    width: w,
                    height: h,
                  ),
                ),

                // Layer 6: Dynamic Key-ed Markers Layer (Crises & Vehicles positioned dynamically)
                RepaintBoundary(
                  child: MarkersAndVehiclesLayer(
                    simulationController: widget.simulationController,
                    onCrisisClick: widget.onCrisisClick,
                    width: w,
                    height: h,
                  ),
                ),

                // Layer 7: Focus layer for selected crisis (crosshairs, etc.)
                RepaintBoundary(
                  child: FocusLayer(
                    simulationController: widget.simulationController,
                    width: w,
                    height: h,
                  ),
                ),

                // Layer 8: Static Overlay HUD (Legend & Compass)
                const Positioned(
                  top: 20,
                  left: 20,
                  child: StaticLegend(),
                ),
                const Positioned(
                  bottom: 20,
                  right: 20,
                  child: StaticCompass(),
                ),

                // Map Tap Receiver overlay
                Positioned.fill(
                  child: GestureDetector(
                    onTapDown: (details) {
                      _handleMapTap(details.localPosition, w, h);
                    },
                    child: Container(
                      color: Colors.transparent,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ==========================================
// HIGH-PERFORMANCE STATIC BACKDROP LAYER
// ==========================================
class GridLayer extends StatelessWidget {
  const GridLayer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: const GridPainter(),
      child: Container(),
    );
  }
}

class GridPainter extends CustomPainter {
  const GridPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // Grid lines with neon cyber styling
    final Paint gridPaint = Paint()
      ..color = const Color(0xFF1E284C).withValues(alpha: 0.12)
      ..strokeWidth = 0.8;

    const double gridSize = 25.0;
    for (double x = 0; x < w; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, h), gridPaint);
    }
    for (double y = 0; y < h; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(w, y), gridPaint);
    }

    // Concentric radar circles
    final Offset center = Offset(w / 2, h / 2);
    final double maxRadius = sqrt(w * w + h * h) / 2;
    final Paint circlePaint = Paint()
      ..color = const Color(0xFF00E5FF).withValues(alpha: 0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    canvas.drawCircle(center, maxRadius * 0.3, circlePaint);
    canvas.drawCircle(center, maxRadius * 0.6, circlePaint);
    canvas.drawCircle(center, maxRadius * 0.9, circlePaint);
  }

  @override
  bool shouldRepaint(covariant GridPainter oldDelegate) => false;
}

// ==========================================
// RADAR SWEEP ANIMATION LAYER
// ==========================================
class RadarSweepLayer extends StatefulWidget {
  const RadarSweepLayer({Key? key}) : super(key: key);

  @override
  State<RadarSweepLayer> createState() => _RadarSweepLayerState();
}

class _RadarSweepLayerState extends State<RadarSweepLayer> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return CustomPaint(
          painter: RadarSweepPainter(sweepAngle: _animationController.value * 2 * pi),
          child: Container(),
        );
      },
    );
  }
}

class RadarSweepPainter extends CustomPainter {
  final double sweepAngle;
  RadarSweepPainter({required this.sweepAngle});

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final Offset center = Offset(w / 2, h / 2);
    final double maxRadius = sqrt(w * w + h * h) / 2;

    final Paint radarSweepPaint = Paint()
      ..shader = SweepGradient(
        center: Alignment.center,
        colors: [
          const Color(0xFF00E5FF).withValues(alpha: 0.10),
          const Color(0xFF00E5FF).withValues(alpha: 0.0),
        ],
        transform: GradientRotation(sweepAngle),
      ).createShader(Rect.fromCircle(center: center, radius: maxRadius));

    canvas.drawCircle(center, maxRadius, radarSweepPaint);
  }

  @override
  bool shouldRepaint(covariant RadarSweepPainter oldDelegate) {
    return oldDelegate.sweepAngle != sweepAngle;
  }
}

// ==========================================
// DYNAMIC HIGHWAY / ROADWAY LAYER
// ==========================================
class RoadLayer extends StatefulWidget {
  final SimulationController simulationController;

  const RoadLayer({
    Key? key,
    required this.simulationController,
  }) : super(key: key);

  @override
  State<RoadLayer> createState() => _RoadLayerState();
}

class _RoadLayerState extends State<RoadLayer> with SingleTickerProviderStateMixin {
  late AnimationController _dashAnimationController;

  @override
  void initState() {
    super.initState();
    _dashAnimationController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _dashAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.simulationController,
      builder: (context, child) {
        return AnimatedBuilder(
          animation: _dashAnimationController,
          builder: (context, child) {
            return CustomPaint(
              painter: RoadPainter(
                trafficSegments: widget.simulationController.trafficSegments,
                dashProgressValue: _dashAnimationController.value,
              ),
              child: Container(),
            );
          },
        );
      },
    );
  }
}

class RoadPainter extends CustomPainter {
  final List<TrafficSegment> trafficSegments;
  final double dashProgressValue;

  RoadPainter({
    required this.trafficSegments,
    required this.dashProgressValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final double scale = min(w / 400.0, h / 500.0);
    final double dx = (w - 400.0 * scale) / 2;
    final double dy = (h - 500.0 * scale) / 2;

    Offset toScreen(Offset pos) {
      return Offset(dx + pos.dx * scale, dy + pos.dy * scale);
    }

    for (var seg in trafficSegments) {
      Color streetColor = Colors.white.withValues(alpha: 0.08);
      double thickness = 3.0;
      if (seg.isBlocked) {
        streetColor = AppColors.redAlert.withValues(alpha: 0.6 + 0.4 * sin(dashProgressValue * 2 * pi * 6));
        thickness = 4.0;
      } else {
        if (seg.congestionLevel > 0.7) {
          streetColor = const Color(0xFFFF9100).withValues(alpha: 0.5);
        } else if (seg.congestionLevel > 0.4) {
          streetColor = const Color(0xFFFFD600).withValues(alpha: 0.4);
        } else {
          streetColor = const Color(0xFF00E676).withValues(alpha: 0.25);
        }
      }

      final Paint roadPaint = Paint()
        ..color = streetColor
        ..strokeWidth = thickness
        ..strokeCap = StrokeCap.round;

      final p1 = toScreen(seg.start);
      final p2 = toScreen(seg.end);
      canvas.drawLine(p1, p2, roadPaint);

      // Dash animations traveling on roads
      if (!seg.isBlocked) {
        final Paint dashPaint = Paint()
          ..color = (seg.congestionLevel > 0.7 ? const Color(0xFFFF9100) : const Color(0xFF00E676)).withValues(alpha: 0.6)
          ..strokeWidth = thickness + 1.0
          ..strokeCap = StrokeCap.round;

        final double progress = (dashProgressValue + seg.hashCode % 10 / 10.0) % 1.0;
        final Offset dashPos = Offset.lerp(p1, p2, progress)!;
        canvas.drawCircle(dashPos, 3.0, dashPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant RoadPainter oldDelegate) {
    return oldDelegate.dashProgressValue != dashProgressValue || oldDelegate.trafficSegments != trafficSegments;
  }
}

// ==========================================
// CITIES / REGIONAL NODES LAYER
// ==========================================
class CitiesLayer extends StatefulWidget {
  final SimulationController simulationController;

  const CitiesLayer({
    Key? key,
    required this.simulationController,
  }) : super(key: key);

  @override
  State<CitiesLayer> createState() => _CitiesLayerState();
}

class _CitiesLayerState extends State<CitiesLayer> with SingleTickerProviderStateMixin {
  late AnimationController _pulseAnimationController;

  @override
  void initState() {
    super.initState();
    _pulseAnimationController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _pulseAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.simulationController,
      builder: (context, child) {
        return AnimatedBuilder(
          animation: _pulseAnimationController,
          builder: (context, child) {
            return CustomPaint(
              painter: CitiesPainter(
                crises: widget.simulationController.crises,
                hospitalLoads: widget.simulationController.hospitalLoads,
                pulseValue: _pulseAnimationController.value,
              ),
              child: Container(),
            );
          },
        );
      },
    );
  }
}

class CitiesPainter extends CustomPainter {
  final List<CrisisEvent> crises;
  final Map<String, double> hospitalLoads;
  final double pulseValue;

  CitiesPainter({
    required this.crises,
    required this.hospitalLoads,
    required this.pulseValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final double scale = min(w / 400.0, h / 500.0);
    final double dx = (w - 400.0 * scale) / 2;
    final double dy = (h - 500.0 * scale) / 2;

    Offset toScreen(Offset pos) {
      return Offset(dx + pos.dx * scale, dy + pos.dy * scale);
    }

    final Map<String, Offset> cities = {
      'Peshawar': const Offset(60, 80),
      'Islamabad': const Offset(220, 70),
      'Lahore': const Offset(320, 180),
      'Quetta': const Offset(80, 280),
      'Karachi': const Offset(100, 430),
    };

    cities.forEach((cityName, cityPos) {
      final Offset sPos = toScreen(cityPos);
      final double load = hospitalLoads[cityName] ?? 40.0;
      final Color loadColor = load > 85
          ? AppColors.redAlert
          : (load > 60 ? const Color(0xFFFF9100) : const Color(0xFF00E676));

      // Check if this city has an active crisis nearby
      bool hasActiveCrisis = crises.any((c) => !c.isResolved && (c.position - cityPos).distance < 60);

      // Pulse background around city
      final Paint pulsePaint = Paint()
        ..color = (hasActiveCrisis ? AppColors.redAlert : const Color(0xFF00E676)).withValues(alpha: 0.04 + 0.05 * sin(pulseValue * 2 * pi * 3))
        ..style = PaintingStyle.fill;
      canvas.drawCircle(sPos, 22.0 * scale, pulsePaint);

      // Draw double city ring
      final Paint cityRing = Paint()
        ..color = (hasActiveCrisis ? AppColors.redAlert : const Color(0xFF00E676)).withValues(alpha: 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawCircle(sPos, 8.0 * scale, cityRing);
      canvas.drawCircle(sPos, 14.0 * scale, cityRing..color = (hasActiveCrisis ? AppColors.redAlert : const Color(0xFF00E676)).withValues(alpha: 0.15));

      // Draw Hospital Load Arc around the city node
      final Rect arcRect = Rect.fromCircle(center: sPos, radius: 18.0 * scale);
      final Paint arcPaint = Paint()
        ..color = loadColor.withValues(alpha: 0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(arcRect, -pi / 2, (load / 100.0) * 2 * pi, false, arcPaint);

      // Labeled text
      final TextPainter tp = TextPainter(
        text: TextSpan(
          text: '$cityName\nHosp: ${load.toStringAsFixed(0)}%',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 7.5,
            fontWeight: FontWeight.bold,
            fontFamily: 'Courier',
            backgroundColor: Colors.black45,
          ),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      tp.layout();
      tp.paint(canvas, Offset(sPos.dx - tp.width / 2, sPos.dy + 20 * scale));
    });
  }

  @override
  bool shouldRepaint(covariant CitiesPainter oldDelegate) {
    return oldDelegate.pulseValue != pulseValue || oldDelegate.crises != crises || oldDelegate.hospitalLoads != hospitalLoads;
  }
}

// ==========================================
// DANGER RADIUS / BUFFER ZONE LAYER
// ==========================================
class CrisisZonesLayer extends StatefulWidget {
  final SimulationController simulationController;
  final double width;
  final double height;

  const CrisisZonesLayer({
    Key? key,
    required this.simulationController,
    required this.width,
    required this.height,
  }) : super(key: key);

  @override
  State<CrisisZonesLayer> createState() => _CrisisZonesLayerState();
}

class _CrisisZonesLayerState extends State<CrisisZonesLayer> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.simulationController,
      builder: (context, child) {
        return AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return CustomPaint(
              size: Size(widget.width, widget.height),
              painter: CrisisZonesPainter(
                crises: widget.simulationController.crises,
                pulseValue: _pulseController.value,
              ),
            );
          },
        );
      },
    );
  }
}

class CrisisZonesPainter extends CustomPainter {
  final List<CrisisEvent> crises;
  final double pulseValue;

  CrisisZonesPainter({
    required this.crises,
    required this.pulseValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final double scale = min(w / 400.0, h / 500.0);
    final double dx = (w - 400.0 * scale) / 2;
    final double dy = (h - 500.0 * scale) / 2;

    Offset toScreen(Offset pos) {
      return Offset(dx + pos.dx * scale, dy + pos.dy * scale);
    }

    for (var crisis in crises) {
      if (crisis.isResolved) continue;

      final Color severityColor = crisis.severity == 'Critical'
          ? AppColors.redAlert
          : crisis.severity == 'Medium'
              ? const Color(0xFFFF9100)
              : const Color(0xFFFFD600);

      // Expanding danger pulse
      final double animatedRadius = crisis.dangerRadius * scale * (1.0 + 0.15 * sin(pulseValue * 2 * pi * 3));
      final Paint zonePaint = Paint()
        ..color = severityColor.withValues(alpha: 0.08)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(toScreen(crisis.position), animatedRadius, zonePaint);

      final Paint zoneBorder = Paint()
        ..color = severityColor.withValues(alpha: 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;
      canvas.drawCircle(toScreen(crisis.position), animatedRadius, zoneBorder);

      // Outer expanding rings
      final Paint expandingRingPaint = Paint()
        ..color = severityColor.withValues(alpha: 0.2 * (1.0 - pulseValue))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawCircle(toScreen(crisis.position), (crisis.dangerRadius + (crisis.maxDangerRadius - crisis.dangerRadius) * pulseValue) * scale, expandingRingPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CrisisZonesPainter oldDelegate) {
    return oldDelegate.pulseValue != pulseValue || oldDelegate.crises != crises;
  }
}

// ==========================================
// KEYED INDEPENDENT MARKERS & VEHICLES LAYER
// ==========================================
class MarkersAndVehiclesLayer extends StatelessWidget {
  final SimulationController simulationController;
  final Function(CrisisEvent) onCrisisClick;
  final double width;
  final double height;

  const MarkersAndVehiclesLayer({
    Key? key,
    required this.simulationController,
    required this.onCrisisClick,
    required this.width,
    required this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double scale = min(width / 400.0, height / 500.0);
    final double dx = (width - 400.0 * scale) / 2;
    final double dy = (height - 500.0 * scale) / 2;

    Offset toScreen(Offset pos) {
      return Offset(dx + pos.dx * scale, dy + pos.dy * scale);
    }

    return ListenableBuilder(
      listenable: simulationController,
      builder: (context, child) {
        final activeCrises = simulationController.crises.where((c) => !c.isResolved).toList();
        final vehicles = simulationController.vehicles;

        final List<Widget> children = [];

        // 1. Draw vehicle route vectors on bottom
        children.add(
          CustomPaint(
            size: Size(width, height),
            painter: RoutePathPainter(
              vehicles: vehicles,
              scale: scale,
              dx: dx,
              dy: dy,
            ),
          ),
        );

        // 2. Add keyed Crisis Markers
        for (var crisis in activeCrises) {
          final Offset screenPos = toScreen(crisis.position);
          children.add(
            Positioned(
              key: ValueKey('crisis-${crisis.id}'),
              left: screenPos.dx - 40 * scale,
              top: screenPos.dy - 40 * scale,
              width: 80 * scale,
              height: 80 * scale,
              child: GestureDetector(
                onTap: () => onCrisisClick(crisis),
                child: CrisisMarkerWidget(
                  crisis: crisis,
                  scale: scale,
                ),
              ),
            ),
          );
        }

        // 3. Add keyed Vehicle Markers
        for (var vehicle in vehicles) {
          final Offset screenPos = toScreen(vehicle.position);
          children.add(
            Positioned(
              key: ValueKey('vehicle-${vehicle.id}'),
              left: screenPos.dx - 30 * scale,
              top: screenPos.dy - 30 * scale,
              width: 60 * scale,
              height: 60 * scale,
              child: VehicleMarkerWidget(
                vehicle: vehicle,
                scale: scale,
              ),
            ),
          );
        }

        return Stack(
          children: children,
        );
      },
    );
  }
}

class RoutePathPainter extends CustomPainter {
  final List<EmergencyVehicle> vehicles;
  final double scale;
  final double dx;
  final double dy;

  RoutePathPainter({
    required this.vehicles,
    required this.scale,
    required this.dx,
    required this.dy,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Offset toScreen(Offset pos) {
      return Offset(dx + pos.dx * scale, dy + pos.dy * scale);
    }

    for (var vehicle in vehicles) {
      if (vehicle.status == 'Dispatched' ||
          vehicle.status == 'OnScene' ||
          vehicle.status == 'Returning' ||
          vehicle.status == 'En Route') {
        final Paint routePaint = Paint()
          ..color = vehicle.color.withValues(alpha: 0.3)
          ..strokeWidth = 1.5
          ..style = PaintingStyle.stroke;

        canvas.drawLine(toScreen(vehicle.basePosition), toScreen(vehicle.targetPosition), routePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant RoutePathPainter oldDelegate) {
    return oldDelegate.vehicles != vehicles || oldDelegate.scale != scale;
  }
}

class CrisisMarkerWidget extends StatefulWidget {
  final CrisisEvent crisis;
  final double scale;

  const CrisisMarkerWidget({
    Key? key,
    required this.crisis,
    required this.scale,
  }) : super(key: key);

  @override
  State<CrisisMarkerWidget> createState() => _CrisisMarkerWidgetState();
}

class _CrisisMarkerWidgetState extends State<CrisisMarkerWidget> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color severityColor = widget.crisis.severity == 'Critical'
        ? AppColors.redAlert
        : widget.crisis.severity == 'Medium'
            ? const Color(0xFFFF9100)
            : const Color(0xFFFFD600);

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return CustomPaint(
          painter: CrisisMarkerPainter(
            crisis: widget.crisis,
            scale: widget.scale,
            severityColor: severityColor,
            pulseValue: _pulseController.value,
          ),
        );
      },
    );
  }
}

class CrisisMarkerPainter extends CustomPainter {
  final CrisisEvent crisis;
  final double scale;
  final Color severityColor;
  final double pulseValue;

  CrisisMarkerPainter({
    required this.crisis,
    required this.scale,
    required this.severityColor,
    required this.pulseValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double cx = size.width / 2;
    final double cy = size.height / 2;

    final Paint markerPaint = Paint()
      ..color = severityColor
      ..style = PaintingStyle.fill;

    // Draw diamond shield shape
    final Path path = Path();
    final double markerSize = 10.0 * scale;
    path.moveTo(cx, cy - markerSize * 1.3);
    path.lineTo(cx + markerSize, cy);
    path.lineTo(cx, cy + markerSize * 1.3);
    path.lineTo(cx - markerSize, cy);
    path.close();

    canvas.drawPath(path, markerPaint);

    // Draw localized glow pulse circle
    final Paint markerGlow = Paint()
      ..color = Colors.white.withValues(alpha: 0.4 + 0.4 * pulseValue)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(Offset(cx, cy), 4.0 * scale * (1.0 + 0.25 * pulseValue), markerGlow);

    // Dynamic labeled tag
    final TextPainter tp = TextPainter(
      text: TextSpan(
        text: '${crisis.id}\n(${crisis.type})',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 7.0,
          fontWeight: FontWeight.bold,
          fontFamily: 'Courier',
          backgroundColor: Colors.black54,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(canvas, Offset(cx - tp.width / 2, cy - 32 * scale));
  }

  @override
  bool shouldRepaint(covariant CrisisMarkerPainter oldDelegate) {
    return oldDelegate.pulseValue != pulseValue || oldDelegate.crisis != crisis || oldDelegate.scale != scale;
  }
}

class VehicleMarkerWidget extends StatefulWidget {
  final EmergencyVehicle vehicle;
  final double scale;

  const VehicleMarkerWidget({
    Key? key,
    required this.vehicle,
    required this.scale,
  }) : super(key: key);

  @override
  State<VehicleMarkerWidget> createState() => _VehicleMarkerWidgetState();
}

class _VehicleMarkerWidgetState extends State<VehicleMarkerWidget> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return CustomPaint(
          painter: VehicleMarkerPainter(
            vehicle: widget.vehicle,
            scale: widget.scale,
            pulseValue: _pulseController.value,
          ),
        );
      },
    );
  }
}

class VehicleMarkerPainter extends CustomPainter {
  final EmergencyVehicle vehicle;
  final double scale;
  final double pulseValue;

  VehicleMarkerPainter({
    required this.vehicle,
    required this.scale,
    required this.pulseValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double cx = size.width / 2;
    final double cy = size.height / 2;

    final Paint vehiclePaint = Paint()
      ..color = vehicle.color
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(cx, cy), 6.0 * scale, vehiclePaint);

    final Paint vehicleOuterRing = Paint()
      ..color = vehicle.color.withValues(alpha: 0.35 * (1.0 - pulseValue))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(Offset(cx, cy), (10.0 + 4.0 * pulseValue) * scale, vehicleOuterRing);

    // Labeled tag
    final TextPainter tp = TextPainter(
      text: TextSpan(
        text: vehicle.id,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 7.0,
          fontWeight: FontWeight.bold,
          backgroundColor: Colors.black54,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(canvas, Offset(cx - tp.width / 2, cy + 12 * scale));
  }

  @override
  bool shouldRepaint(covariant VehicleMarkerPainter oldDelegate) {
    return oldDelegate.pulseValue != pulseValue || oldDelegate.vehicle != vehicle || oldDelegate.scale != scale;
  }
}

// ==========================================
// TARGET CRITICAL CRISIS CROSSHAIRS LAYER
// ==========================================
class FocusLayer extends StatefulWidget {
  final SimulationController simulationController;
  final double width;
  final double height;

  const FocusLayer({
    Key? key,
    required this.simulationController,
    required this.width,
    required this.height,
  }) : super(key: key);

  @override
  State<FocusLayer> createState() => _FocusLayerState();
}

class _FocusLayerState extends State<FocusLayer> with SingleTickerProviderStateMixin {
  late AnimationController _crosshairController;

  @override
  void initState() {
    super.initState();
    _crosshairController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _crosshairController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.simulationController,
      builder: (context, child) {
        final selected = widget.simulationController.selectedCrisisDetail;
        if (selected == null || selected.isResolved) {
          return const SizedBox.shrink();
        }

        return AnimatedBuilder(
          animation: _crosshairController,
          builder: (context, child) {
            return CustomPaint(
              size: Size(widget.width, widget.height),
              painter: FocusPainter(
                selectedCrisis: selected,
                pulseValue: _crosshairController.value,
              ),
            );
          },
        );
      },
    );
  }
}

class FocusPainter extends CustomPainter {
  final CrisisEvent selectedCrisis;
  final double pulseValue;

  FocusPainter({
    required this.selectedCrisis,
    required this.pulseValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final double scale = min(w / 400.0, h / 500.0);
    final double dx = (w - 400.0 * scale) / 2;
    final double dy = (h - 500.0 * scale) / 2;

    Offset toScreen(Offset pos) {
      return Offset(dx + pos.dx * scale, dy + pos.dy * scale);
    }

    final Paint selectedRingPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final Offset sPos = toScreen(selectedCrisis.position);
    final double focusSize = (35.0 + 5.0 * sin(pulseValue * 2 * pi * 5)) * scale;
    canvas.drawCircle(sPos, focusSize, selectedRingPaint);

    // Draw crosshairs
    final Paint crosshairPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.5;
    canvas.drawLine(Offset(sPos.dx - focusSize - 5, sPos.dy), Offset(sPos.dx - focusSize + 5, sPos.dy), crosshairPaint);
    canvas.drawLine(Offset(sPos.dx + focusSize - 5, sPos.dy), Offset(sPos.dx + focusSize + 5, sPos.dy), crosshairPaint);
    canvas.drawLine(Offset(sPos.dx, sPos.dy - focusSize - 5), Offset(sPos.dx, sPos.dy - focusSize + 5), crosshairPaint);
    canvas.drawLine(Offset(sPos.dx, sPos.dy + focusSize - 5), Offset(sPos.dx, sPos.dy + focusSize + 5), crosshairPaint);
  }

  @override
  bool shouldRepaint(covariant FocusPainter oldDelegate) {
    return oldDelegate.pulseValue != pulseValue || oldDelegate.selectedCrisis != selectedCrisis;
  }
}

// ==========================================
// STATIC OVERLAY COMPONENT: LEGEND CARD
// ==========================================
class StaticLegend extends StatelessWidget {
  const StaticLegend({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.cyanAccent.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'GRID MAP LEGEND',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: AppColors.cyanAccent,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 8),
            _legendItem('Ambulance Vector', AppColors.cyanAccent),
            _legendItem('Police Perimeter', Colors.blueAccent),
            _legendItem('Rescue Containment', AppColors.purpleGlow),
            _legendItem('Critical Flame/Flood', AppColors.redAlert),
            _legendItem('Road Barrier Blockade', AppColors.redAlert, isLine: true),
          ],
        ),
      ),
    );
  }

  Widget _legendItem(String name, Color c, {bool isLine = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: isLine ? 3 : 12,
            color: c,
            margin: const EdgeInsets.only(right: 8),
          ),
          Text(name, style: const TextStyle(fontSize: 10, color: Colors.white70)),
        ],
      ),
    );
  }
}

// ==========================================
// STATIC OVERLAY COMPONENT: COMPASS
// ==========================================
class StaticCompass extends StatelessWidget {
  const StaticCompass({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const RepaintBoundary(
      child: Opacity(
        opacity: 0.2,
        child: Icon(Icons.explore, size: 80, color: AppColors.cyanAccent),
      ),
    );
  }
}
