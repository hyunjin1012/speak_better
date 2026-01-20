import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../state/sessions_provider.dart';
import '../../models/session.dart';

class ProgressScreen extends ConsumerWidget {
  final String language; // 'ko' or 'en'

  const ProgressScreen({
    super.key,
    required this.language,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessions = ref.watch(sessionsProvider);
    final isKorean = language == 'ko';

    // Filter sessions by language and remove duplicates by ID
    final filteredSessions = sessions
        .where((s) => s.language == language)
        .fold<Map<String, PracticeSession>>(<String, PracticeSession>{}, (map, session) {
          if (!map.containsKey(session.id)) {
            map[session.id] = session;
          }
          return map;
        })
        .values
        .toList();

    // Calculate chart data
    final weeklyData = _calculateWeeklyData(filteredSessions);
    final monthlyData = _calculateMonthlyData(filteredSessions);
    final dailyData = _calculateDailyData(filteredSessions, 30); // Last 30 days

    return Scaffold(
      appBar: AppBar(
        title: Text(isKorean ? '진행 상황' : 'Progress'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary cards
            _buildSummaryCards(context, filteredSessions, isKorean),
            const SizedBox(height: 24),
            
            // Daily practice chart (last 30 days)
            _buildSectionTitle(
              context,
              isKorean ? '최근 30일 연습' : 'Last 30 Days Practice',
            ),
            const SizedBox(height: 16),
            _buildDailyChart(context, dailyData, isKorean),
            const SizedBox(height: 32),
            
            // Weekly chart
            _buildSectionTitle(
              context,
              isKorean ? '주간 연습' : 'Weekly Practice',
            ),
            const SizedBox(height: 16),
            _buildWeeklyChart(context, weeklyData, isKorean),
            const SizedBox(height: 32),
            
            // Monthly chart
            _buildSectionTitle(
              context,
              isKorean ? '월간 연습' : 'Monthly Practice',
            ),
            const SizedBox(height: 16),
            _buildMonthlyChart(context, monthlyData, isKorean),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards(
    BuildContext context,
    List<PracticeSession> sessions,
    bool isKorean,
  ) {
    final totalSessions = sessions.length;
    final thisWeekSessions = sessions.where((s) {
      final now = DateTime.now();
      // Get Monday of this week at 00:00:00
      final daysFromMonday = now.weekday - 1;
      final monday = DateTime(now.year, now.month, now.day).subtract(Duration(days: daysFromMonday));
      // Compare session date (without time) with Monday
      final sessionDate = DateTime(s.createdAt.year, s.createdAt.month, s.createdAt.day);
      return sessionDate.isAtSameMomentAs(monday) || sessionDate.isAfter(monday);
    }).length;
    final thisMonthSessions = sessions.where((s) {
      final now = DateTime.now();
      return s.createdAt.year == now.year && s.createdAt.month == now.month;
    }).length;

    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            context,
            isKorean ? '전체' : 'Total',
            '$totalSessions',
            Icons.mic,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            context,
            isKorean ? '이번 주' : 'This Week',
            '$thisWeekSessions',
            Icons.calendar_today,
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            context,
            isKorean ? '이번 달' : 'This Month',
            '$thisMonthSessions',
            Icons.calendar_month,
            Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _buildDailyChart(BuildContext context, Map<String, int> data, bool isKorean) {
    if (data.isEmpty) {
      return _buildEmptyChart(isKorean ? '데이터가 없습니다' : 'No data available');
    }

    final sortedDates = data.keys.toList()..sort();
    final spots = sortedDates.asMap().entries.map((entry) {
      final date = entry.key;
      final count = data[sortedDates[date]] ?? 0;
      return FlSpot(date.toDouble(), count.toDouble());
    }).toList();

    final maxY = spots.isEmpty 
        ? 5.0 
        : (spots.map((s) => s.y).reduce((a, b) => a > b ? a : b) + 1).clamp(1.0, double.infinity);
    
    final minX = 0.0;
    final maxX = (sortedDates.length - 1).toDouble().clamp(0.0, double.infinity);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 200,
          child: LineChart(
            LineChartData(
              minX: minX,
              maxX: maxX,
              minY: 0,
              maxY: maxY,
              gridData: FlGridData(show: true),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        value.toInt().toString(),
                        style: const TextStyle(fontSize: 10),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() % 5 == 0 && value.toInt() < sortedDates.length) {
                        final dateStr = sortedDates[value.toInt()];
                        final date = DateTime.parse(dateStr);
                        return Text(
                          DateFormat('M/d').format(date),
                          style: const TextStyle(fontSize: 10),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              borderData: FlBorderData(show: true),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: Colors.blue,
                  barWidth: 3,
                  dotData: FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    color: Colors.blue.withOpacity(0.1),
                    cutOffY: 0,
                    applyCutOffY: true,
                  ),
                  preventCurveOverShooting: true,
                  preventCurveOvershootingThreshold: 0.1,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeeklyChart(BuildContext context, Map<String, int> data, bool isKorean) {
    if (data.isEmpty) {
      return _buildEmptyChart(isKorean ? '데이터가 없습니다' : 'No data available');
    }

    final weeks = data.keys.toList()..sort();
    final barGroups = weeks.asMap().entries.map((entry) {
      final week = entry.key;
      final count = data[weeks[week]] ?? 0;
      return BarChartGroupData(
        x: week,
        barRods: [
          BarChartRodData(
            toY: count.toDouble(),
            color: Colors.green,
            width: 20,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
      );
    }).toList();

    final maxY = barGroups.isEmpty
        ? 5.0
        : (barGroups.map((g) => g.barRods.first.toY).reduce((a, b) => a > b ? a : b) + 1).clamp(1.0, double.infinity);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 200,
          child: BarChart(
            BarChartData(
              minY: 0,
              maxY: maxY,
              gridData: FlGridData(show: true),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        value.toInt().toString(),
                        style: const TextStyle(fontSize: 10),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() < weeks.length) {
                        final weekStr = weeks[value.toInt()];
                        // Show week range (e.g., "1/1-1/7")
                        final parts = weekStr.split('-');
                        if (parts.length == 2) {
                          final start = DateTime.parse(parts[0]);
                          final end = DateTime.parse(parts[1]);
                          return Text(
                            '${DateFormat('M/d').format(start)}\n${DateFormat('M/d').format(end)}',
                            style: const TextStyle(fontSize: 8),
                            textAlign: TextAlign.center,
                          );
                        }
                      }
                      return const Text('');
                    },
                  ),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              borderData: FlBorderData(show: true),
              barGroups: barGroups,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMonthlyChart(BuildContext context, Map<String, int> data, bool isKorean) {
    if (data.isEmpty) {
      return _buildEmptyChart(isKorean ? '데이터가 없습니다' : 'No data available');
    }

    final months = data.keys.toList()..sort();
    final barGroups = months.asMap().entries.map((entry) {
      final month = entry.key;
      final count = data[months[month]] ?? 0;
      return BarChartGroupData(
        x: month,
        barRods: [
          BarChartRodData(
            toY: count.toDouble(),
            color: Colors.orange,
            width: 20,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
      );
    }).toList();

    final maxY = barGroups.isEmpty
        ? 5.0
        : (barGroups.map((g) => g.barRods.first.toY).reduce((a, b) => a > b ? a : b) + 1).clamp(1.0, double.infinity);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 200,
          child: BarChart(
            BarChartData(
              minY: 0,
              maxY: maxY,
              gridData: FlGridData(show: true),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        value.toInt().toString(),
                        style: const TextStyle(fontSize: 10),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() < months.length) {
                        final monthStr = months[value.toInt()];
                        final date = DateTime.parse('$monthStr-01');
                        return Text(
                          DateFormat('MMM').format(date),
                          style: const TextStyle(fontSize: 10),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              borderData: FlBorderData(show: true),
              barGroups: barGroups,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyChart(String message) {
    return Card(
      elevation: 2,
      child: SizedBox(
        height: 200,
        child: Center(
          child: Text(
            message,
            style: const TextStyle(color: Colors.grey),
          ),
        ),
      ),
    );
  }

  // Calculate daily data for last N days
  Map<String, int> _calculateDailyData(List<PracticeSession> sessions, int days) {
    final data = <String, int>{};
    final now = DateTime.now();
    
    // Initialize all days with 0
    for (int i = days - 1; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateKey = DateFormat('yyyy-MM-dd').format(date);
      data[dateKey] = 0;
    }
    
    // Count sessions per day
    for (final session in sessions) {
      final dateKey = DateFormat('yyyy-MM-dd').format(session.createdAt);
      if (data.containsKey(dateKey)) {
        data[dateKey] = (data[dateKey] ?? 0) + 1;
      }
    }
    
    return data;
  }

  // Calculate weekly data
  Map<String, int> _calculateWeeklyData(List<PracticeSession> sessions) {
    final data = <String, int>{};
    
    for (final session in sessions) {
      final date = session.createdAt;
      // Get Monday of the week
      final daysFromMonday = date.weekday - 1;
      final monday = date.subtract(Duration(days: daysFromMonday));
      final sunday = monday.add(const Duration(days: 6));
      
      final weekKey = '${DateFormat('yyyy-MM-dd').format(monday)}-${DateFormat('yyyy-MM-dd').format(sunday)}';
      data[weekKey] = (data[weekKey] ?? 0) + 1;
    }
    
    return data;
  }

  // Calculate monthly data
  Map<String, int> _calculateMonthlyData(List<PracticeSession> sessions) {
    final data = <String, int>{};
    
    for (final session in sessions) {
      final monthKey = DateFormat('yyyy-MM').format(session.createdAt);
      data[monthKey] = (data[monthKey] ?? 0) + 1;
    }
    
    return data;
  }
}
