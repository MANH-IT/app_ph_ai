// lib/features/analytics/widgets/radar_chart_widget.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_theme.dart';

class AnalyticsRadarChart extends StatelessWidget {
  final double moistureRisk;
  final double nutrientRisk;
  final double acidityRisk;
  final double balanceRisk;

  const AnalyticsRadarChart({
    super.key,
    required this.moistureRisk,
    required this.nutrientRisk,
    required this.acidityRisk,
    required this.balanceRisk,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.3,
      child: RadarChart(
        RadarChartData(
          dataSets: [
            RadarDataSet(
              fillColor: Colors.green.withValues(alpha: 0.2),
              borderColor: Colors.green,
              entryRadius: 4,
              dataEntries: [
                RadarEntry(value: moistureRisk),
                RadarEntry(value: acidityRisk),
                RadarEntry(value: balanceRisk),
                RadarEntry(value: nutrientRisk),
              ],
              borderWidth: 2,
            ),
          ],
          radarBackgroundColor: Colors.transparent,
          borderData: FlBorderData(show: false),
          radarBorderData: const BorderSide(color: Colors.transparent),
          titlePositionPercentageOffset: 0.2,
          titleTextStyle: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.bold),
          getTitle: (index, angle) {
            switch (index) {
              case 0:
                return const RadarChartTitle(text: 'Độ ẩm');
              case 1:
                return const RadarChartTitle(text: 'Độ chua (pH)');
              case 2:
                return const RadarChartTitle(text: 'Cân bằng');
              case 3:
                return const RadarChartTitle(text: 'Dinh dưỡng');
              default:
                return const RadarChartTitle(text: '');
            }
          },
          tickCount: 5,
          ticksTextStyle: const TextStyle(color: Colors.transparent, fontSize: 10),
          tickBorderData: const BorderSide(color: Colors.black12),
          gridBorderData: const BorderSide(color: Colors.black12, width: 1.5),
        ),
        duration: const Duration(milliseconds: 800),
      ),
    );
  }
}
