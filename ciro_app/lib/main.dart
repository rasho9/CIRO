import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:ciro_app/theme/colors.dart';
import 'package:ciro_app/simulation_controller.dart';
import 'package:ciro_app/models/simulation_models.dart';
import 'package:ciro_app/widgets/pulsing_dot.dart';
import 'package:ciro_app/widgets/report_dialog.dart';
import 'package:ciro_app/pages/dashboard_page.dart';
import 'package:ciro_app/pages/map_page.dart';
import 'package:ciro_app/pages/alerts_page.dart';
import 'package:ciro_app/pages/agent_orchestration_page.dart';
import 'package:ciro_app/pages/resources_page.dart';
import 'package:ciro_app/pages/antigravity_trace_page.dart';
import 'package:ciro_app/pages/judges_playground_page.dart';

void main() {
  runApp(const CIROApp());
}

class CIROApp extends StatelessWidget {
  const CIROApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CIRO Crisis OS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        colorScheme: const ColorScheme.dark(
          primary: AppColors.cyanAccent,
          secondary: AppColors.purpleGlow,
          error: AppColors.redAlert,
          surface: Color(0xFF0F143A),
        ),
        scaffoldBackgroundColor: AppColors.deepNavy,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late final SimulationController _simulationController;
  late AnimationController _mapAnimationController;
  late AnimationController _detailPanelAnimationController;

  @override
  void initState() {
    super.initState();

    _simulationController = SimulationController();

    _mapAnimationController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();

    _detailPanelAnimationController = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _mapAnimationController.dispose();
    _detailPanelAnimationController.dispose();
    _simulationController.dispose();
    super.dispose();
  }

  void _handleWhatIfAction(String action) {
    _simulationController.handleWhatIfAction(action);
  }

  void _toggleDemoPlayback() {
    _simulationController.toggleDemoPlayback();
  }

  void _resetEnvironment() {
    _simulationController.resetEnvironment();
  }

  void _triggerStressTest() {
    _simulationController.triggerStressTest();
  }

  void _selectCrisis(CrisisEvent c) {
    _simulationController.selectCrisis(c);
    _detailPanelAnimationController.forward(from: 0.0);
  }

  void _closeCrisisDetail() {
    _detailPanelAnimationController.reverse().then((_) {
      if (mounted) {
        _simulationController.closeCrisisDetail();
      }
    });
  }

  void _submitReport(
    String type,
    String severity,
    String location,
    String description,
  ) {
    _simulationController.submitReport(type, severity, location, description);
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth <= 900;

    final pages = [
      ListenableBuilder(
        listenable: _simulationController,
        builder: (context, _) => DashboardPage(
          crises: _simulationController.crises,
          alerts: _simulationController.alerts,
          confidence: _simulationController.confidence,
          logs: _simulationController.logs,
          weatherState: _simulationController.weatherState,
          confidenceHistory: _simulationController.confidenceHistory,
          onCrisisClick: _selectCrisis,
          vehicles: _simulationController.vehicles,
          trafficSegments: _simulationController.trafficSegments,
          hospitalLoads: _simulationController.hospitalLoads,
          onWhatIfAction: _handleWhatIfAction,
        ),
      ),
      MapPage(
        simulationController: _simulationController,
        onCrisisClick: _selectCrisis,
      ),
      ListenableBuilder(
        listenable: _simulationController,
        builder: (context, _) => AlertsPage(
          alerts: _simulationController.alerts,
          crises: _simulationController.crises,
          onCrisisClick: _selectCrisis,
        ),
      ),
      AgentOrchestrationPage(
        agents: _simulationController.agents,
        animationController: _mapAnimationController,
      ),
      ListenableBuilder(
        listenable: _simulationController,
        builder: (context, _) => ResourcesPage(
          vehicles: _simulationController.vehicles,
          handledCrises: _simulationController.handledCrises,
          hospitalCapacityUsed: _simulationController.hospitalCapacityUsed,
          hospitalCapacityTotal: _simulationController.hospitalCapacityTotal,
          shelterCapacityUsed: _simulationController.shelterCapacityUsed,
          shelterCapacityTotal: _simulationController.shelterCapacityTotal,
        ),
      ),
      ListenableBuilder(
        listenable: _simulationController,
        builder: (context, _) => AntigravityTracePage(
          traces: _simulationController.traces,
          confidenceHistory: _simulationController.confidenceHistory,
        ),
      ),
      ListenableBuilder(
        listenable: _simulationController,
        builder: (context, _) => JudgesPlaygroundPage(
          crises: _simulationController.crises,
          vehicles: _simulationController.vehicles,
          trafficSegments: _simulationController.trafficSegments,
          hospitalLoads: _simulationController.hospitalLoads,
          onWhatIfAction: _handleWhatIfAction,
          onResetEnvironment: _resetEnvironment,
          onTriggerStressTest: _triggerStressTest,
          onCustomScenario: (type, reliability, velocity, contradiction, geolocation, population, position) {
            _simulationController.triggerCustomScenario(
              type,
              reliability,
              velocity,
              contradiction,
              geolocation,
              population,
              position,
            );
          },
        ),
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.deepNavy,
      drawer: isMobile
          ? Drawer(
              backgroundColor: const Color(0xFF070B1F),
              child: _buildFuturisticSidebar(context, isMobile: true),
            )
          : null,
      body: SafeArea(
        child: Row(
          children: [
            if (!isMobile) _buildFuturisticSidebar(context, isMobile: false),
            Expanded(
              child: Stack(
                children: [
                  Column(
                    children: [
                      _buildTelemetryHeader(isMobile),
                      Expanded(
                        child: IndexedStack(
                          index: _selectedIndex,
                          children: pages,
                        ),
                      ),
                    ],
                  ),
                  ListenableBuilder(
                    listenable: _simulationController,
                    builder: (context, _) {
                      final c = _simulationController.selectedCrisisDetail;
                      if (c == null) return const SizedBox.shrink();
                      return _buildSlidingDetailPanel(c, screenWidth);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.transparent,
        elevation: 0,
        label: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF00E5FF), Color(0xFFB388FF)]),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00E5FF).withOpacity(0.4),
                blurRadius: 15,
                spreadRadius: 2,
              )
            ],
          ),
          child: const Row(
            children: [
              Icon(Icons.add_alert, color: Colors.black, size: 20),
              SizedBox(width: 8),
              Text(
                'REPORT CRISIS',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => ReportDialog(
              onSubmit: _submitReport,
            ),
          );
        },
      ),
    );
  }

  Widget _buildFuturisticSidebar(BuildContext context, {required bool isMobile}) {
    return Container(
      width: 250,
      decoration: const BoxDecoration(
        color: Color(0xFF070B1F),
        border: Border(
          right: BorderSide(color: Color(0xFF1E284C), width: 1.5),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFF1E284C), width: 1.0),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.blur_on, color: AppColors.cyanAccent, size: 28),
                    const SizedBox(width: 8),
                    Text(
                      'CIRO COMMAND',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        color: Colors.white,
                        letterSpacing: 1.5,
                        shadows: [
                          Shadow(
                            color: AppColors.cyanAccent.withOpacity(0.8),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'AI CRISIS RESPONSE OS',
                  style: TextStyle(
                    fontSize: 9,
                    color: Colors.white38,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.0,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _sidebarItem(0, Icons.dashboard_outlined, 'DASHBOARD', context, isMobile),
                _sidebarItem(1, Icons.explore_outlined, 'TACTICAL MAP', context, isMobile),
                _sidebarItem(2, Icons.warning_amber_outlined, 'INCIDENT ALERTS', context, isMobile),
                _sidebarItem(3, Icons.psychology_outlined, 'AGENT ORCHESTRATION', context, isMobile),
                _sidebarItem(4, Icons.settings_input_composite_outlined, 'RESOURCES CONSOLE', context, isMobile),
                _sidebarItem(5, Icons.analytics_outlined, 'ANTIGRAVITY TRACE', context, isMobile),
                _sidebarItem(6, Icons.gavel_outlined, 'JUDGES PLAYGROUND', context, isMobile),
              ],
            ),
          ),
          ListenableBuilder(
            listenable: _simulationController,
            builder: (context, _) {
              return Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F143A).withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF1E284C)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.shield, color: Color(0xFF00E676), size: 14),
                        SizedBox(width: 6),
                        Text(
                          'SYSTEM SECURE',
                          style: TextStyle(
                            fontSize: 10,
                            color: Color(0xFF00E676),
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Uptime: 04h 12m 45s',
                      style: TextStyle(fontSize: 10, color: Colors.white30),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Fusions processed: ${_simulationController.tickCount * 4}',
                      style: const TextStyle(fontSize: 10, color: Colors.white30),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _sidebarItem(int index, IconData icon, String label, BuildContext context, bool isMobile) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
        if (isMobile) {
          Navigator.pop(context); // Close Drawer
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    AppColors.cyanAccent.withOpacity(0.12),
                    AppColors.purpleGlow.withOpacity(0.04),
                  ],
                )
              : null,
          border: Border.all(
            color: isSelected ? AppColors.cyanAccent.withOpacity(0.3) : Colors.transparent,
            width: 1.0,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.cyanAccent : Colors.white30,
              size: 20,
            ),
            const SizedBox(width: 14),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white54,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                letterSpacing: 1.2,
              ),
            ),
            if (isSelected) ...[
              const Spacer(),
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppColors.cyanAccent,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: AppColors.cyanAccent, blurRadius: 4),
                  ],
                ),
              )
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildTelemetryHeader(bool isMobile) {
    return ListenableBuilder(
      listenable: _simulationController,
      builder: (context, child) {
        final bool isDemo = _simulationController.isDemoModeActive;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: const BoxDecoration(
            color: Color(0xFF070B1F),
            border: Border(
              bottom: BorderSide(color: Color(0xFF1E284C), width: 1.5),
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  if (isMobile) ...[
                    Builder(
                      builder: (drawerContext) => IconButton(
                        icon: const Icon(Icons.menu, color: AppColors.cyanAccent),
                        onPressed: () {
                          Scaffold.of(drawerContext).openDrawer();
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  // Blinking online indicators
                  Row(
                    children: [
                      const PulsingDot(color: Color(0xFF00E676)),
                      const SizedBox(width: 8),
                      Text(
                        isDemo ? 'CINEMATIC DEMO MODE ACTIVE' : 'CIRO CORE OS NOMINAL',
                        style: TextStyle(
                          fontSize: 10,
                          color: isDemo ? AppColors.cyanAccent : const Color(0xFF00E676),
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                  if (!isMobile) ...[
                    const SizedBox(width: 24),
                    // AI health status indices
                    _headerStatusTile('AI ENGINE', 'ONLINE', const Color(0xFF00E676)),
                    _headerStatusTile('LATENCY', '12ms', AppColors.cyanAccent),
                    _headerStatusTile('HEALTH', '100%', AppColors.purpleGlow),
                    _headerStatusTile('AGENTS', '7/7 NOMINAL', const Color(0xFFFFD600)),
                    _headerStatusTile('FALLBACK', 'STANDBY', Colors.white30),
                  ],
                  const Spacer(),
                  // Demo mode playback switch
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDemo ? AppColors.cyanAccent : const Color(0xFF0F143A),
                      side: BorderSide(color: isDemo ? Colors.transparent : const Color(0xFF1E284C)),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                    icon: Icon(
                      isDemo ? Icons.pause_circle : Icons.play_circle,
                      color: isDemo ? Colors.black : AppColors.cyanAccent,
                      size: 16,
                    ),
                    label: Text(
                      isDemo ? 'PAUSE presentation' : 'ACTIVATE JUDGE MODE',
                      style: TextStyle(
                        color: isDemo ? Colors.black : Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    onPressed: _toggleDemoPlayback,
                  ),
                ],
              ),
              if (isDemo) ...[
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.cyanAccent.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.cyanAccent.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.psychology, color: AppColors.cyanAccent, size: 16),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _simulationController.aiNarrationLog,
                          style: const TextStyle(
                            fontFamily: 'Courier',
                            fontSize: 11,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Flashing processing bar
                      SizedBox(
                        width: 60,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: const LinearProgressIndicator(
                            minHeight: 4,
                            backgroundColor: Colors.white10,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.cyanAccent),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _headerStatusTile(String label, String val, Color valColor) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(fontSize: 9, color: Colors.white38, fontWeight: FontWeight.bold)),
          Text(val, style: TextStyle(fontSize: 9, color: valColor, fontWeight: FontWeight.w900, fontFamily: 'Courier')),
        ],
      ),
    );
  }

  Widget _buildSlidingDetailPanel(CrisisEvent c, double screenWidth) {
    final color = c.severity == 'Critical'
        ? AppColors.redAlert
        : c.severity == 'Medium'
            ? const Color(0xFFFF9100)
            : const Color(0xFFFFD600);

    final double width = screenWidth <= 450 ? screenWidth : 420;

    return Positioned(
      right: 0,
      top: 0,
      bottom: 0,
      width: width,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1.0, 0.0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _detailPanelAnimationController,
          curve: Curves.easeOut,
        )),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFA070B1F), // low-end budget GPU optimized solid deepnavy backdrop
            border: const Border(
              left: BorderSide(color: Color(0xFF1E284C), width: 1.5),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 30,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: color),
                      ),
                      child: Text(
                        c.severity.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        c.type,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white54),
                      onPressed: _closeCrisisDetail,
                    ),
                  ],
                ),
              ),
              const Divider(color: Color(0xFF1E284C), height: 1),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    Row(
                      children: [
                        _miniMetric('LOCATION', c.locationName, Icons.location_on, AppColors.cyanAccent),
                        const SizedBox(width: 12),
                        _miniMetric('EST. MITIGATION', c.isResolved ? 'RESOLVED' : '${c.etaMinutes} MINS', Icons.timer, Colors.greenAccent),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _miniMetric('AFFECTED POP.', '${c.affectedPopulation}', Icons.people, const Color(0xFFFF8A80)),
                        const SizedBox(width: 12),
                        _miniMetric('AI CONFIDENCE', '${(c.confidence * 100).toStringAsFixed(1)}%', Icons.psychology, AppColors.purpleGlow),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'ASSIGNED FIELD UNITS',
                      style: TextStyle(fontSize: 11, color: Colors.white30, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                    ),
                    const SizedBox(height: 8),
                    c.assignedVehicleIds.isEmpty
                        ? const Text('No units assigned yet. Auto-triage in queue.', style: TextStyle(color: Colors.white38, fontSize: 13))
                        : Wrap(
                            spacing: 8,
                            children: c.assignedVehicleIds.map((id) {
                              return Chip(
                                backgroundColor: const Color(0xFF0F143A),
                                side: const BorderSide(color: AppColors.cyanAccent),
                                label: Text(id, style: const TextStyle(color: Colors.white, fontSize: 11)),
                                avatar: const Icon(Icons.local_shipping, size: 12, color: AppColors.cyanAccent),
                              );
                            }).toList(),
                          ),
                    const SizedBox(height: 24),
                    const Text(
                      'MULTI-AGENT DECISION FLOW',
                      style: TextStyle(fontSize: 11, color: Colors.white30, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                    ),
                    const SizedBox(height: 10),
                    ...c.aiReasoningSteps.map((step) => _buildReasoningRow(step)),
                    const SizedBox(height: 24),
                    const Text(
                      'SCENARIO MITIGATION IMPACT',
                      style: TextStyle(fontSize: 11, color: Colors.white30, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                    ),
                    const SizedBox(height: 10),
                    _impactComparisonWidget(c.beforeImpactStatus, c.afterImpactStatus),
                    const SizedBox(height: 24),
                    const Text(
                      'AI PREEMPTIVE ACTIONS',
                      style: TextStyle(fontSize: 11, color: Colors.white30, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                    ),
                    const SizedBox(height: 10),
                    ...c.recommendedActions.map((act) => _actionItem(act)),
                  ],
                ),
              ),
              const Divider(color: Color(0xFF1E284C), height: 1),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.redAlert),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: () {
                          _simulationController.forceUpdateSeverityAndAutoDispatch(c);
                        },
                        child: const Text(
                          'FORCE DISPATCH BACKUP',
                          style: TextStyle(color: AppColors.redAlert, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.cyanAccent,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: () {
                          _simulationController.forceEvacuateComplete(c);
                        },
                        child: const Text(
                          'DEPLOY EVACUATION',
                          style: TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _miniMetric(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF0F143A).withOpacity(0.4),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF1E284C)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontSize: 8, color: Colors.white30, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: const TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReasoningRow(String text) {
    String agentName = '';
    String content = text;
    if (text.startsWith('[')) {
      int endIdx = text.indexOf(']');
      if (endIdx != -1) {
        agentName = text.substring(1, endIdx);
        content = text.substring(endIdx + 2);
      }
    }

    Color agentColor = AppColors.cyanAccent;
    if (agentName.contains('Weather')) agentColor = const Color(0xFF80DEEA);
    if (agentName.contains('Verification')) agentColor = const Color(0xFFFFD54F);
    if (agentName.contains('Prediction')) agentColor = const Color(0xFFF48FB1);
    if (agentName.contains('Dispatch')) agentColor = AppColors.redAlert;
    if (agentName.contains('Planning')) agentColor = AppColors.purpleGlow;
    if (agentName.contains('Notification')) agentColor = const Color(0xFF81C784);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: agentColor.withOpacity(0.04),
        borderRadius: BorderRadius.circular(6),
        border: Border(left: BorderSide(color: agentColor, width: 2.0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            agentName.toUpperCase(),
            style: TextStyle(fontSize: 9, color: agentColor, fontWeight: FontWeight.bold, letterSpacing: 1.0),
          ),
          const SizedBox(height: 2),
          Text(content, style: const TextStyle(fontSize: 12, color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _impactComparisonWidget(String before, String after) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F143A).withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF1E284C)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.trending_up, color: AppColors.redAlert, size: 14),
              const SizedBox(width: 6),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    text: 'BEFORE AI INTERVENTION: ',
                    style: const TextStyle(color: AppColors.redAlert, fontSize: 10, fontWeight: FontWeight.bold),
                    children: [
                      TextSpan(text: before, style: const TextStyle(color: Colors.white60, fontWeight: FontWeight.normal)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.trending_down, color: Colors.greenAccent, size: 14),
              const SizedBox(width: 6),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    text: 'AFTER AI MITIGATION: ',
                    style: const TextStyle(color: Colors.greenAccent, fontSize: 10, fontWeight: FontWeight.bold),
                    children: [
                      TextSpan(text: after, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.normal)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionItem(String text) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline, color: AppColors.cyanAccent, size: 14),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 12, color: Colors.white70))),
        ],
      ),
    );
  }
}