import 'package:flutter/material.dart';
import 'package:ciro_app/theme/colors.dart';
import 'package:ciro_app/models/simulation_models.dart';

class JudgesPlaygroundPage extends StatefulWidget {
  final List<CrisisEvent> crises;
  final List<EmergencyVehicle> vehicles;
  final List<TrafficSegment> trafficSegments;
  final Map<String, double> hospitalLoads;
  final Function(String) onWhatIfAction;
  final VoidCallback onResetEnvironment;
  final VoidCallback onTriggerStressTest;
  final Function(String, double, double, double, double, double, Offset) onCustomScenario;

  const JudgesPlaygroundPage({
    Key? key,
    required this.crises,
    required this.vehicles,
    required this.trafficSegments,
    required this.hospitalLoads,
    required this.onWhatIfAction,
    required this.onResetEnvironment,
    required this.onTriggerStressTest,
    required this.onCustomScenario,
  }) : super(key: key);

  @override
  State<JudgesPlaygroundPage> createState() => _JudgesPlaygroundPageState();
}

class _JudgesPlaygroundPageState extends State<JudgesPlaygroundPage> with SingleTickerProviderStateMixin {
  late TabController _stakeholderTabController;
  
  // Custom generator sliders state
  String _customCrisisType = 'Flash Flood';
  double _sourceReliability = 0.85;
  double _geolocationJitter = 4.2; // in meters
  double _urgencyLanguage = 0.90;
  double _contradictionLevel = 0.15;
  double _signalVelocity = 0.80;
  double _populationAtRisk = 1200;

  @override
  void initState() {
    super.initState();
    _stakeholderTabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _stakeholderTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeCrises = widget.crises.where((c) => !c.isResolved).toList();
    final CrisisEvent? selectedOrFirstCrisis = activeCrises.isNotEmpty ? activeCrises[0] : null;
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth <= 900;

    // Header actions
    Widget header = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'JUDGES TACTICAL PLAYGROUND',
              style: TextStyle(fontSize: 10, color: Colors.white30, fontWeight: FontWeight.bold, letterSpacing: 1.2),
            ),
            SizedBox(height: 4),
            Text(
              'CORE AGENTIC OS DIRECTIVES',
              style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 0.5),
            ),
          ],
        ),
        Row(
          children: [
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F143A),
                side: const BorderSide(color: AppColors.cyanAccent, width: 1.0),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              icon: const Icon(Icons.refresh, color: AppColors.cyanAccent, size: 16),
              label: const Text('RESET SYSTEM OS', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
              onPressed: widget.onResetEnvironment,
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.redAlert.withOpacity(0.15),
                side: const BorderSide(color: AppColors.redAlert, width: 1.0),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              icon: const Icon(Icons.flash_on, color: AppColors.redAlert, size: 16),
              label: const Text('STRESS TEST OS', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
              onPressed: widget.onTriggerStressTest,
            ),
          ],
        ),
      ],
    );

    // If header needs to be wrapped or simplified on narrow mobile views
    if (screenWidth < 600) {
      header = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'JUDGES TACTICAL PLAYGROUND',
            style: TextStyle(fontSize: 10, color: Colors.white30, fontWeight: FontWeight.bold, letterSpacing: 1.2),
          ),
          const SizedBox(height: 4),
          const Text(
            'CORE AGENTIC OS DIRECTIVES',
            style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 0.5),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F143A),
                    side: const BorderSide(color: AppColors.cyanAccent, width: 1.0),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  icon: const Icon(Icons.refresh, color: AppColors.cyanAccent, size: 14),
                  label: const Text('RESET OS', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  onPressed: widget.onResetEnvironment,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.redAlert.withOpacity(0.15),
                    side: const BorderSide(color: AppColors.redAlert, width: 1.0),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  icon: const Icon(Icons.flash_on, color: AppColors.redAlert, size: 14),
                  label: const Text('STRESS TEST', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  onPressed: widget.onTriggerStressTest,
                ),
              ),
            ],
          ),
        ],
      );
    }

    Widget leftColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('PREBUILT DISASTER SCENARIOS', style: TextStyle(fontSize: 11, color: Colors.white30, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
        const SizedBox(height: 12),
        _buildScenarioGrid(isMobile),
        const SizedBox(height: 24),
        const Text('JUDGES CUSTOM CRISIS INJECTOR', style: TextStyle(fontSize: 11, color: Colors.white30, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
        const SizedBox(height: 12),
        _buildCustomCrisisGenerator(),
      ],
    );

    Widget rightColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('ACTIVE ANOMALY AUDIT AND PREDICTIONS', style: TextStyle(fontSize: 11, color: Colors.white30, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
        const SizedBox(height: 12),
        if (selectedOrFirstCrisis == null)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: const Color(0xFF0F143A).withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF1E284C)),
            ),
            child: const Center(
              child: Text(
                'NO ACTIVE ANOMALIES DETECTED.\nUSE SCENARIOS OR CUSTOM INJECTOR TO DEMONSTRATE OS LOGIC.',
                style: TextStyle(color: Colors.white38, fontSize: 11, fontFamily: 'Courier'),
                textAlign: TextAlign.center,
              ),
            ),
          )
        else ...[
          _buildSignalCredibilityCard(selectedOrFirstCrisis),
          const SizedBox(height: 20),
          _buildImpactPredictionCard(selectedOrFirstCrisis),
          const SizedBox(height: 20),
          _buildStakeholderMessagePanel(selectedOrFirstCrisis),
        ],
      ],
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          header,
          const SizedBox(height: 24),
          if (isMobile) ...[
            leftColumn,
            const SizedBox(height: 32),
            rightColumn,
          ] else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: leftColumn,
                ),
                const SizedBox(width: 24),
                Expanded(
                  flex: 4,
                  child: rightColumn,
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildScenarioGrid(bool isMobile) {
    final scenarios = [
      {
        'title': '2026 Rawalpindi Cloudburst',
        'desc': 'Floods M-1 motorway links, triggers weather rain rate to 95%.',
        'type': 'Flash Flood',
        'action': 'increase_rainfall',
      },
      {
        'title': 'Karachi Transformer Fire Outbreak',
        'desc': 'High dry temperature risk, spikes Karachi hospital loads to 97.2%.',
        'type': 'Fire Outbreak',
        'action': 'power_failure',
      },
      {
        'title': 'M-2 Motorway Super Wreckage',
        'desc': 'Blocks Interstate avenues, triggers planning route recalculations.',
        'type': 'Traffic Accident',
        'action': 'road_collapse',
      },
    ];

    final double screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = 3;
    double childAspectRatio = 0.95;
    if (screenWidth < 600) {
      crossAxisCount = 1;
      childAspectRatio = 2.8;
    } else if (screenWidth < 900) {
      crossAxisCount = 2;
      childAspectRatio = 1.3;
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: scenarios.length,
      itemBuilder: (_, i) {
        final sc = scenarios[i];
        return InkWell(
          onTap: () {
            widget.onWhatIfAction(sc['action']!);
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF0F143A).withOpacity(0.4),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF1E284C)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.cyanAccent.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.warning_amber, color: AppColors.cyanAccent, size: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  sc['title']!,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  sc['desc']!,
                  style: const TextStyle(fontSize: 10, color: Colors.white38),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCustomCrisisGenerator() {
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
              const Text('Crisis Type Selection', style: TextStyle(fontSize: 11, color: Colors.white60, fontWeight: FontWeight.bold)),
              DropdownButton<String>(
                value: _customCrisisType,
                dropdownColor: const Color(0xFF070B1F),
                underline: Container(),
                items: ['Flash Flood', 'Fire Outbreak', 'Traffic Accident', 'Extreme Heatwave', 'Power Outage', 'Civic Protest']
                    .map((val) => DropdownMenuItem(
                          value: val,
                          child: Text(val, style: const TextStyle(color: Colors.white, fontSize: 12)),
                        ))
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _customCrisisType = val;
                    });
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          _sliderRow('Source Reliability', _sourceReliability, 0.0, 1.0, (val) => setState(() => _sourceReliability = val)),
          _sliderRow('Geolocation Variance (m)', _geolocationJitter, 0.1, 50.0, (val) => setState(() => _geolocationJitter = val)),
          _sliderRow('Urgency Language Weight', _urgencyLanguage, 0.0, 1.0, (val) => setState(() => _urgencyLanguage = val)),
          _sliderRow('Contradiction Coefficient', _contradictionLevel, 0.0, 1.0, (val) => setState(() => _contradictionLevel = val)),
          _sliderRow('Signal Velocity Rate', _signalVelocity, 0.0, 1.0, (val) => setState(() => _signalVelocity = val)),
          _sliderRow('Risk Population Size', _populationAtRisk, 100, 15000, (val) => setState(() => _populationAtRisk = val)),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.cyanAccent,
              padding: const EdgeInsets.symmetric(vertical: 14),
              minimumSize: const Size(double.infinity, 44),
            ),
            child: const Text('INJECT CUSTOM OS SIGNAL', style: TextStyle(color: Colors.black, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
            onPressed: () {
              widget.onCustomScenario(
                _customCrisisType,
                _sourceReliability,
                _signalVelocity,
                _contradictionLevel,
                _geolocationJitter,
                _populationAtRisk,
                const Offset(220, 180), // Centered on custom region
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _sliderRow(String title, double val, double min, double max, Function(double) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontSize: 10, color: Colors.white38)),
            Text(val.toStringAsFixed(title.contains('Population') ? 0 : 2), style: const TextStyle(fontSize: 10, color: AppColors.cyanAccent, fontWeight: FontWeight.bold)),
          ],
        ),
        Slider(
          value: val,
          min: min,
          max: max,
          activeColor: AppColors.cyanAccent,
          inactiveColor: const Color(0xFF1E284C),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildSignalCredibilityCard(CrisisEvent crisis) {
    // Generate simulated indices based on isFalseAlarm or severity
    double sourceRel = crisis.isFalseAlarm ? 0.35 : 0.88;
    double geoConf = crisis.isFalseAlarm ? 0.22 : 0.94;
    double urgLang = crisis.isFalseAlarm ? 0.45 : 0.82;
    double contraLevel = crisis.isFalseAlarm ? 0.92 : 0.08;
    double sigVel = crisis.isFalseAlarm ? 0.12 : 0.76;

    final Color statusColor = crisis.isFalseAlarm ? AppColors.redAlert : const Color(0xFF00E676);

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
              Expanded(
                child: Text(
                  'SIGNAL SOURCE AUDIT: ${crisis.id}',
                  style: const TextStyle(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: statusColor),
                ),
                child: Text(
                  crisis.isFalseAlarm ? 'CONCURRENT CONFLICT DETECTED' : 'CONSENSUS VERIFIED',
                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: statusColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _credibilityRow('Source Reliability Indicator', sourceRel),
          _credibilityRow('Geolocation Confidence Jitter', geoConf),
          _credibilityRow('Cognitive Urgency Language Ratio', urgLang),
          _credibilityRow('Contradiction and Drift Jitter', contraLevel),
          _credibilityRow('Incoming Signal Wave Velocity', sigVel),
          const SizedBox(height: 16),
          if (crisis.isFalseAlarm)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.redAlert.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.redAlert.withOpacity(0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.gavel, color: AppColors.redAlert, size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'RESOLVER DIRECTIVE: verification failure escalated. Confidence dropped. Staging responder fleets paused preemptively.',
                      style: TextStyle(fontSize: 10, color: Colors.white70, fontFamily: 'Courier'),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _credibilityRow(String title, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 10, color: Colors.white38)),
              Text('${(value * 100).toInt()}%', style: const TextStyle(fontSize: 10, color: Colors.white70)),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 4,
              backgroundColor: const Color(0xFF070B1F),
              valueColor: AlwaysStoppedAnimation<Color>(value > 0.6 ? AppColors.cyanAccent : AppColors.redAlert),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImpactPredictionCard(CrisisEvent crisis) {
    double econLoss = (crisis.affectedPopulation * 1450.0) / 1000.0;
    double hospRisk = crisis.severity == 'Critical' ? 92.4 : 35.8;

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
          const Text('OS IMPACT PREDICTION LOGIC', style: TextStyle(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _impactTile('Risk Spread Bound', '${crisis.dangerRadius.toStringAsFixed(0)}m', AppColors.cyanAccent),
              _impactTile('Provincial Hosp Overload', '${hospRisk.toStringAsFixed(0)}%', AppColors.redAlert),
              _impactTile('Econ. Disruption Cost', '\$${econLoss.toStringAsFixed(0)}k', const Color(0xFFFFD600)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _impactTile(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 9, color: Colors.white38)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: color, fontFamily: 'Courier')),
      ],
    );
  }

  Widget _buildStakeholderMessagePanel(CrisisEvent crisis) {
    final Map<String, String> stakeholderMessages = {
      'Public': 'SAFETY ADVISORY: Dynamic incident detected at ${crisis.locationName}. Commuters advised to detour immediately to avoid delays.',
      'Security': 'OPERATIONAL ALERT: Local security units proceed to establish safety boundaries at Lahore Outer grid segments.',
      'Hospitals': 'MED DIRECTIVE: Regional trauma units prepare backup containment beds. Spacing capacity index active.',
      'Utilities': 'GRID ADVISORY: Core utilities on standby. Coordinate with Verification Agent to monitor line surges.',
      'Transit': 'TRANSIT CONTROL: Alter light timing sequences along arterial lanes M-2 to sustain evacuation flows.',
      'Media': 'MEDIA SYNC: Authorized brief for ${crisis.id} released. Confidence rating verified at ${(crisis.confidence*100).toStringAsFixed(0)}%.',
    };

    final list = stakeholderMessages.entries.toList();

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
          const Text('STAKEHOLDER TRANSMISSIONS ENGINE', style: TextStyle(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          TabBar(
            controller: _stakeholderTabController,
            isScrollable: true,
            indicatorColor: AppColors.cyanAccent,
            labelColor: AppColors.cyanAccent,
            unselectedLabelColor: Colors.white38,
            labelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
            tabs: list.map((entry) => Tab(text: entry.key.toUpperCase())).toList(),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 60,
            child: TabBarView(
              controller: _stakeholderTabController,
              children: list.map((entry) {
                return Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.02), borderRadius: BorderRadius.circular(8)),
                  child: Text(
                    entry.value,
                    style: const TextStyle(fontSize: 11, color: Colors.white70, height: 1.4, fontFamily: 'Courier'),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
