import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class AnalyticsScreen extends StatelessWidget {
  final int totalSeconds;
  final int cycles;

  const AnalyticsScreen({
    super.key,
    required this.totalSeconds,
    required this.cycles,
  });

  @override
  Widget build(BuildContext context) {
    int minutes = totalSeconds ~/ 60;
    int seconds = totalSeconds % 60;
    double averageTimePerCycle = totalSeconds / cycles;

    // Create data points dynamically for the Line Chart
    List<FlSpot> cycleData = [];
    for (int i = 0; i < cycles; i++) {
      cycleData.add(FlSpot(i.toDouble(), (i * averageTimePerCycle).toDouble()));
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromARGB(255, 255, 255, 255), // Primary color
              Color(0xFF0D3445), // Darker shade
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  title: const Text(
                    "BreathAnalytics",
                    style: TextStyle(
                      color: Color(0xFF0D3445),
                      fontSize: 20,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  centerTitle: true,
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.share, color: Colors.white),
                      onPressed: () {/* Implement share functionality */},
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Session Summary Cards
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard(
                        icon: Icons.timer,
                        title: "Duration",
                        value: "$minutes:${seconds.toString().padLeft(2, '0')}",
                        unit: "min",
                        color: const Color(0xFF64B5F6),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: _buildMetricCard(
                        icon: Icons.waves,
                        title: "Cycles",
                        value: "$cycles",
                        unit: "breaths",
                        color: const Color(0xFF81C784),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                // Breathing Pattern Chart
                _buildCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Breathing Pattern",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 250,
                        child: LineChart(
                          LineChartData(
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: true,
                              horizontalInterval: 1,
                              verticalInterval: 1,
                              getDrawingHorizontalLine: (value) {
                                return FlLine(
                                  color: const Color(0xFF0D3445),
                                  strokeWidth: 1,
                                );
                              },
                            ),
                            titlesData: FlTitlesData(
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  interval: 1,
                                  getTitlesWidget: (value, meta) {
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(
                                        "Cycle ${value.toInt() + 1}",
                                        style: const TextStyle(
                                          color: Color(0xFF68737d),
                                          fontSize: 12,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  interval: 10,
                                  getTitlesWidget: (value, meta) {
                                    return Text(
                                      "${value.toInt()}s",
                                      style: const TextStyle(
                                        color: Color(0xFF68737d),
                                        fontSize: 12,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                            ),
                            borderData: FlBorderData(
                              show: true,
                              border: Border.all(
                                color: const Color(0xFF37434d),
                                width: 1,
                              ),
                            ),
                            lineBarsData: [
                              LineChartBarData(
                                spots: cycleData,
                                isCurved: true,
                                color: const Color(0xFF64B5F6),
                                barWidth: 3,
                                isStrokeCapRound: true,
                                dotData: FlDotData(
                                  show: true,
                                  getDotPainter:
                                      (spot, percent, barData, index) {
                                    return FlDotCirclePainter(
                                      radius: 4,
                                      color: const Color(0xFF64B5F6),
                                      strokeWidth: 2,
                                      strokeColor: Colors.white,
                                    );
                                  },
                                ),
                                belowBarData: BarAreaData(
                                  show: true,
                                  color:
                                      const Color(0xFF64B5F6).withOpacity(0.2),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                // Session Insights
                _buildCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Session Insights",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 15),
                      _buildInsightRow(
                        icon: Icons.timer_outlined,
                        title: "Average Cycle Time",
                        value:
                            "${averageTimePerCycle.toStringAsFixed(1)} seconds",
                      ),
                      const SizedBox(height: 10),
                      _buildInsightRow(
                        icon: Icons.trending_up,
                        title: "Consistency Score",
                        value: "${(85 + cycles % 10)}%",
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2D3E),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required String title,
    required String value,
    required String unit,
    required Color color,
  }) {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            unit,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: Colors.white54, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
