// lib/features/sleep/sleep_screen.dart
// THEO DÕI GIẤC NGỦ – PHÂN TÍCH CHI TIẾT – 2025
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_theme.dart';

class SleepScreen extends StatefulWidget {
  const SleepScreen({super.key});

  @override
  State<SleepScreen> createState() => _SleepScreenState();
}

class _SleepScreenState extends State<SleepScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  int _selectedDay = 0; // 0 = today

  // Dữ liệu giả lập 7 ngày gần nhất
  final List<SleepData> _weekData = [
    SleepData(
      date: DateTime.now(),
      bedTime: const TimeOfDay(hour: 22, minute: 30),
      wakeTime: const TimeOfDay(hour: 6, minute: 15),
      totalHours: 7.75,
      deepSleep: 2.1,
      lightSleep: 3.8,
      remSleep: 1.5,
      awake: 0.35,
      heartRateAvg: 62,
      heartRateMin: 52,
      spo2Avg: 97.8,
      quality: SleepQuality.good,
    ),
    SleepData(
      date: DateTime.now().subtract(const Duration(days: 1)),
      bedTime: const TimeOfDay(hour: 23, minute: 15),
      wakeTime: const TimeOfDay(hour: 6, minute: 45),
      totalHours: 7.5,
      deepSleep: 1.8,
      lightSleep: 4.0,
      remSleep: 1.3,
      awake: 0.4,
      heartRateAvg: 65,
      heartRateMin: 54,
      spo2Avg: 97.5,
      quality: SleepQuality.good,
    ),
    SleepData(
      date: DateTime.now().subtract(const Duration(days: 2)),
      bedTime: const TimeOfDay(hour: 0, minute: 30),
      wakeTime: const TimeOfDay(hour: 7, minute: 0),
      totalHours: 6.5,
      deepSleep: 1.2,
      lightSleep: 3.6,
      remSleep: 1.1,
      awake: 0.6,
      heartRateAvg: 68,
      heartRateMin: 58,
      spo2Avg: 96.8,
      quality: SleepQuality.fair,
    ),
    SleepData(
      date: DateTime.now().subtract(const Duration(days: 3)),
      bedTime: const TimeOfDay(hour: 21, minute: 45),
      wakeTime: const TimeOfDay(hour: 5, minute: 30),
      totalHours: 7.75,
      deepSleep: 2.4,
      lightSleep: 3.5,
      remSleep: 1.6,
      awake: 0.25,
      heartRateAvg: 60,
      heartRateMin: 50,
      spo2Avg: 98.2,
      quality: SleepQuality.excellent,
    ),
    SleepData(
      date: DateTime.now().subtract(const Duration(days: 4)),
      bedTime: const TimeOfDay(hour: 23, minute: 0),
      wakeTime: const TimeOfDay(hour: 5, minute: 45),
      totalHours: 6.75,
      deepSleep: 1.5,
      lightSleep: 3.8,
      remSleep: 1.0,
      awake: 0.45,
      heartRateAvg: 64,
      heartRateMin: 55,
      spo2Avg: 97.2,
      quality: SleepQuality.fair,
    ),
    SleepData(
      date: DateTime.now().subtract(const Duration(days: 5)),
      bedTime: const TimeOfDay(hour: 1, minute: 0),
      wakeTime: const TimeOfDay(hour: 7, minute: 30),
      totalHours: 6.5,
      deepSleep: 1.0,
      lightSleep: 3.9,
      remSleep: 0.9,
      awake: 0.7,
      heartRateAvg: 70,
      heartRateMin: 60,
      spo2Avg: 96.5,
      quality: SleepQuality.poor,
    ),
    SleepData(
      date: DateTime.now().subtract(const Duration(days: 6)),
      bedTime: const TimeOfDay(hour: 22, minute: 0),
      wakeTime: const TimeOfDay(hour: 6, minute: 0),
      totalHours: 8.0,
      deepSleep: 2.5,
      lightSleep: 3.5,
      remSleep: 1.7,
      awake: 0.3,
      heartRateAvg: 58,
      heartRateMin: 48,
      spo2Avg: 98.5,
      quality: SleepQuality.excellent,
    ),
  ];

  SleepData get _selectedData => _weekData[_selectedDay];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Color _qualityColor(SleepQuality q) => switch (q) {
    SleepQuality.excellent => AppColors.primary,
    SleepQuality.good => AppColors.primaryLight,
    SleepQuality.fair => AppColors.warning,
    SleepQuality.poor => AppColors.error,
  };

  String _qualityLabel(SleepQuality q) => switch (q) {
    SleepQuality.excellent => 'Tuyệt vời',
    SleepQuality.good => 'Tốt',
    SleepQuality.fair => 'Bình thường',
    SleepQuality.poor => 'Kém',
  };

  String _qualityEmoji(SleepQuality q) => switch (q) {
    SleepQuality.excellent => '😴✨',
    SleepQuality.good => '😊',
    SleepQuality.fair => '😐',
    SleepQuality.poor => '😟',
  };

  String _dayLabel(int index) {
    if (index == 0) return 'Hôm nay';
    if (index == 1) return 'Hôm qua';
    final d = _weekData[index].date;
    return '${d.day}/${d.month}';
  }

  String _formatTime(TimeOfDay t) {
    return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final data = _selectedData;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 24),
          onPressed: () => context.go('/dashboard'),
          tooltip: "Quay lại Trang chủ",
        ),
        title: const Text("Giấc ngủ", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.indigo.shade700, Colors.indigo.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo.shade50, Colors.blue.shade50],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // === CHỌN NGÀY ===
                SizedBox(
                  height: 46,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _weekData.length,
                    itemBuilder: (context, index) {
                      final selected = index == _selectedDay;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(_dayLabel(index)),
                          selected: selected,
                          onSelected: (_) => setState(() => _selectedDay = index),
                          selectedColor: Colors.indigo.shade600,
                          backgroundColor: AppColors.surface,
                          labelStyle: TextStyle(
                            color: selected ? Colors.white : Colors.indigo.shade600,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          side: BorderSide(color: selected ? Colors.transparent : Colors.indigo.shade200),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 20),

                // === CARD CHẤT LƯỢNG TỔNG QUAN ===
                Card(
                  elevation: 10,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: LinearGradient(
                        colors: [Colors.indigo.shade800, Colors.indigo.shade500],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _qualityEmoji(data.quality),
                                  style: const TextStyle(fontSize: 36),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _qualityLabel(data.quality),
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: _qualityColor(data.quality),
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${data.totalHours.toStringAsFixed(1)}h',
                                  style: const TextStyle(fontSize: 42, fontWeight: FontWeight.w300, color: Colors.white),
                                ),
                                Text(
                                  '${_formatTime(data.bedTime)} → ${_formatTime(data.wakeTime)}',
                                  style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.7)),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Sleep stages bar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Row(
                            children: [
                              _stageBar(data.deepSleep / data.totalHours, Colors.indigo.shade900, 'Sâu'),
                              _stageBar(data.lightSleep / data.totalHours, Colors.indigo.shade400, 'Nhẹ'),
                              _stageBar(data.remSleep / data.totalHours, Colors.purple.shade300, 'REM'),
                              _stageBar(data.awake / data.totalHours, Colors.orange.shade300, 'Thức'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // === CHI TIẾT GIAI ĐOẠN GIẤC NGỦ ===
                Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Giai đoạn giấc ngủ", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        _sleepStageRow('Ngủ sâu', data.deepSleep, Colors.indigo.shade900, Icons.nightlight, 'Phục hồi cơ thể'),
                        const Divider(height: 24),
                        _sleepStageRow('Ngủ nhẹ', data.lightSleep, Colors.indigo.shade400, Icons.bedtime, 'Giai đoạn chuyển tiếp'),
                        const Divider(height: 24),
                        _sleepStageRow('REM', data.remSleep, Colors.purple.shade300, Icons.psychology, 'Mơ & ghi nhớ'),
                        const Divider(height: 24),
                        _sleepStageRow('Thức giấc', data.awake, Colors.orange.shade300, Icons.visibility, 'Tỉnh giấc giữa đêm'),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // === CHỈ SỐ SỨC KHỎE KHI NGỦ ===
                Row(
                  children: [
                    Expanded(
                      child: _metricCard(
                        icon: Icons.favorite,
                        title: 'Nhịp tim',
                        value: '${data.heartRateAvg}',
                        unit: 'bpm',
                        subtitle: 'Thấp nhất: ${data.heartRateMin}',
                        color: Colors.redAccent,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _metricCard(
                        icon: Icons.air,
                        title: 'SpO₂',
                        value: data.spo2Avg.toStringAsFixed(1),
                        unit: '%',
                        subtitle: data.spo2Avg >= 95 ? 'Bình thường' : 'Thấp hơn BT',
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // === BIỂU ĐỒ TUẦN ===
                Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Xu hướng tuần", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text(
                          'Trung bình: ${(_weekData.map((d) => d.totalHours).reduce((a, b) => a + b) / _weekData.length).toStringAsFixed(1)}h/đêm',
                          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 180,
                          child: BarChart(
                            BarChartData(
                              alignment: BarChartAlignment.spaceAround,
                              maxY: 10,
                              barTouchData: BarTouchData(enabled: true),
                              titlesData: FlTitlesData(
                                show: true,
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, _) {
                                      final idx = value.toInt();
                                      if (idx < 0 || idx >= _weekData.length) return const SizedBox.shrink();
                                      final labels = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];
                                      final dayOfWeek = _weekData[_weekData.length - 1 - idx].date.weekday;
                                      return Text(labels[dayOfWeek % 7], style: const TextStyle(fontSize: 11));
                                    },
                                  ),
                                ),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 30,
                                    getTitlesWidget: (value, _) => Text('${value.toInt()}h', style: const TextStyle(fontSize: 10)),
                                  ),
                                ),
                                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              ),
                              borderData: FlBorderData(show: false),
                              gridData: FlGridData(
                                show: true,
                                drawVerticalLine: false,
                                horizontalInterval: 2,
                                getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.shade200, strokeWidth: 1),
                              ),
                              barGroups: List.generate(_weekData.length, (i) {
                                final d = _weekData[_weekData.length - 1 - i];
                                return BarChartGroupData(
                                  x: i,
                                  barRods: [
                                    BarChartRodData(
                                      toY: d.totalHours,
                                      color: _qualityColor(d.quality),
                                      width: 20,
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                                    ),
                                  ],
                                );
                              }),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // === LỜI KHUYÊN ===
                Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.tips_and_updates, color: Colors.amber.shade700, size: 24),
                            const SizedBox(width: 8),
                            const Text("Lời khuyên", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _tipItem('Ngủ 7-9 tiếng mỗi đêm để cơ thể phục hồi tốt nhất'),
                        _tipItem('Không dùng điện thoại 30 phút trước khi ngủ'),
                        _tipItem('Giữ phòng tối, mát (18-22°C) để ngủ sâu hơn'),
                        if (data.quality == SleepQuality.poor)
                          _tipItem('⚠️ Chất lượng giấc ngủ kém – hãy thử thư giãn trước giờ ngủ'),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _stageBar(double fraction, Color color, String label) {
    return Expanded(
      flex: (fraction * 100).round().clamp(1, 100),
      child: Tooltip(
        message: '$label: ${(fraction * 100).toStringAsFixed(0)}%',
        child: Container(height: 14, color: color),
      ),
    );
  }

  Widget _sleepStageRow(String title, double hours, Color color, IconData icon, String desc) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color)),
              Text(desc, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
            ],
          ),
        ),
        Text('${hours.toStringAsFixed(1)}h', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _metricCard({
    required IconData icon,
    required String title,
    required String value,
    required String unit,
    required String subtitle,
    required Color color,
  }) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(title, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
            const SizedBox(height: 6),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(text: value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color)),
                  TextSpan(text: ' $unit', style: TextStyle(fontSize: 14, color: Colors.grey.shade500)),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
          ],
        ),
      ),
    );
  }

  Widget _tipItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle_outline, size: 18, color: Colors.indigo.shade400),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14, height: 1.4))),
        ],
      ),
    );
  }
}

// === DATA MODEL ===

enum SleepQuality { excellent, good, fair, poor }

class SleepData {
  final DateTime date;
  final TimeOfDay bedTime;
  final TimeOfDay wakeTime;
  final double totalHours;
  final double deepSleep;
  final double lightSleep;
  final double remSleep;
  final double awake;
  final int heartRateAvg;
  final int heartRateMin;
  final double spo2Avg;
  final SleepQuality quality;

  const SleepData({
    required this.date,
    required this.bedTime,
    required this.wakeTime,
    required this.totalHours,
    required this.deepSleep,
    required this.lightSleep,
    required this.remSleep,
    required this.awake,
    required this.heartRateAvg,
    required this.heartRateMin,
    required this.spo2Avg,
    required this.quality,
  });
}
