import 'package:flutter/material.dart';
import 'package:ciro_app/theme/colors.dart';
import 'package:ciro_app/models/simulation_models.dart';

class AntigravityTracePage extends StatefulWidget {
  final List<AntigravityTrace> traces;
  final List<double> confidenceHistory;

  const AntigravityTracePage({
    Key? key,
    required this.traces,
    required this.confidenceHistory,
  }) : super(key: key);

  @override
  State<AntigravityTracePage> createState() => _AntigravityTracePageState();
}

class _AntigravityTracePageState extends State<AntigravityTracePage> {
  String _selectedCategoryFilter = 'ALL';

  @override
  Widget build(BuildContext context) {
    final categories = ['ALL', 'Signal Fusion', 'Confidence Score', 'Priority Rank', 'Resource Tradeoff', 'Action Execution', 'False Alarm Recovery'];

    final filteredTraces = _selectedCategoryFilter == 'ALL'
        ? widget.traces
        : widget.traces.where((t) => t.category == _selectedCategoryFilter).toList();

    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth <= 900;

    final categoriesSelector = SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map((cat) {
          bool isSel = _selectedCategoryFilter == cat;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategoryFilter = cat;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isSel ? AppColors.cyanAccent.withOpacity(0.12) : const Color(0xFF0F143A),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: isSel ? AppColors.cyanAccent : const Color(0xFF1E284C)),
              ),
              child: Text(
                cat.toUpperCase(),
                style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: isSel ? Colors.white : Colors.white38),
              ),
            ),
          );
        }).toList(),
      ),
    );

    final traceListBuilder = filteredTraces.isEmpty
        ? const Center(child: Text('Telemetry quiet. Awaiting logs.', style: TextStyle(color: Colors.white38, fontSize: 13)))
        : ListView.builder(
            itemExtent: 72.0, // performance optimization
            itemCount: filteredTraces.length,
            itemBuilder: (_, i) {
              final trace = filteredTraces[i];
              Color catColor = AppColors.cyanAccent;
              if (trace.category == 'Resource Tradeoff') catColor = const Color(0xFFFFB74D);
              if (trace.category == 'False Alarm Recovery') catColor = const Color(0xFF81C784);
              if (trace.category == 'Priority Rank') catColor = AppColors.redAlert;

              return RepaintBoundary( // isolated repaint layer
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F143A).withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF1E284C)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 140,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: catColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                        child: Text(
                          trace.category.toUpperCase(),
                          style: TextStyle(fontSize: 8, color: catColor, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(trace.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white)),
                            const SizedBox(height: 4),
                            Text(trace.description, style: const TextStyle(fontSize: 11, color: Colors.white54)),
                            const SizedBox(height: 4),
                            Text('Telemetry Timestamp: ${trace.timestamp.toIso8601String().substring(11, 19)}', style: const TextStyle(fontSize: 8, color: Colors.white24)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );

    if (isMobile) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ANTIGRAVITY TELEMETRY FUSION TRACE FEED (AUDIT STREAM)',
              style: TextStyle(fontSize: 11, color: Colors.white30, fontWeight: FontWeight.bold, letterSpacing: 1.2),
            ),
            const SizedBox(height: 16),
            categoriesSelector,
            const SizedBox(height: 16),
            SizedBox(
              height: 400,
              child: traceListBuilder,
            ),
            const SizedBox(height: 32),
            const Text(
              'AI FUSION & COGNITIVE ANALYTICS',
              style: TextStyle(fontSize: 11, color: Colors.white30, fontWeight: FontWeight.bold, letterSpacing: 1.2),
            ),
            const SizedBox(height: 16),
            _buildScoringDerivationConsole(),
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
                const Text(
                  'ANTIGRAVITY TELEMETRY FUSION TRACE FEED (AUDIT STREAM)',
                  style: TextStyle(fontSize: 11, color: Colors.white30, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                ),
                const SizedBox(height: 16),
                categoriesSelector,
                const SizedBox(height: 16),
                Expanded(
                  child: traceListBuilder,
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            flex: 2,
            child: _buildScoringDerivationConsole(),
          ),
        ],
      ),
    );
  }

  Widget _buildScoringDerivationConsole() {
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
            'AI FUSION & COGNITIVE ANALYTICS',
            style: TextStyle(fontSize: 10, color: Colors.white30, fontWeight: FontWeight.bold, letterSpacing: 1.2),
          ),
          const SizedBox(height: 16),
          const Text(
            'RESPONSE EFFICIENCY GAUGES',
            style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          _metricProgressRow('Response Efficiency Index', 0.94, const Color(0xFF00E676)),
          _metricProgressRow('Prediction Accuracy Score', 0.98, AppColors.cyanAccent),
          _metricProgressRow('Resource Allocation Utility', 0.89, AppColors.purpleGlow),
          const SizedBox(height: 16),
          // Estimated lives saved counter
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF0F143A), Color(0xFF070B1F)]),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.cyanAccent.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.favorite, color: AppColors.redAlert, size: 24),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('ESTIMATED PUBLIC LIVES SAVED', style: TextStyle(fontSize: 8, color: Colors.white38, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          '1,420',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white, fontFamily: 'Courier', shadows: [
                            Shadow(color: AppColors.cyanAccent.withOpacity(0.8), blurRadius: 8),
                          ]),
                        ),
                        const SizedBox(width: 6),
                        const Text('CITIZENS', style: TextStyle(fontSize: 9, color: Colors.white70, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Divider(color: Color(0xFF1E284C)),
          const SizedBox(height: 14),
          const Text(
            'AI HISTORICAL MEMORY MATRIX',
            style: TextStyle(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          _historicalMemoryPatternTile('2023 Karachi Hydro Grid Anomaly', 0.92, 'Detour arterial bypass, pre-allocate Karachi generators.'),
          const SizedBox(height: 10),
          _historicalMemoryPatternTile('2010 Indus River Monsoon Flood', 0.84, 'Setup Remote triage, engage M-5 motorway diversions.'),
        ],
      ),
    );
  }

  Widget _metricProgressRow(String label, double value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 10, color: Colors.white54)),
              Text('${(value * 100).toStringAsFixed(1)}%', style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 4,
              backgroundColor: const Color(0xFF070B1F),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _historicalMemoryPatternTile(String incident, double similarity, String strategy) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF070B1F),
        borderRadius: BorderRadius.circular(8),
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
                  incident,
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '${(similarity * 100).toInt()}% match',
                style: const TextStyle(fontSize: 9, color: AppColors.cyanAccent, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Learned: $strategy',
            style: const TextStyle(fontSize: 9, color: Colors.white38),
          ),
        ],
      ),
    );
  }
}
