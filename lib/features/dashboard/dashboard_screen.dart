import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/soil_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/soil_record_model.dart';
import 'dashboard_provider.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  final String? initialUserName;
  const DashboardScreen({super.key, this.initialUserName});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
  void _startMeasurement() {
    final agriData = ref.read(dashboardProvider);
    if (agriData.isMeasuring) return;

    ref.read(dashboardProvider.notifier).startMeasurement(
      onComplete: () {
        if (!mounted) return;
        
        ref.invalidate(soilRecordsProvider);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Đo hoàn tất và dữ liệu đã được lưu!"),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final recordsAsync = ref.watch(soilRecordsProvider);
    final agriData = ref.watch(dashboardProvider);
    
    final double currentNitrogen = agriData.nitrogen;
    final double currentPhosphorus = agriData.phosphorus;
    final double currentPotassium = agriData.potassium;
    final double currentPH = agriData.phLevel;
    final double currentMoisture = agriData.moisture;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.white70),
                const SizedBox(width: 4),
                Text(
                  agriData.locationName,
                  style: const TextStyle(fontSize: 14, color: Colors.white70),
                ),
              ],
            ),
            Text(
              "GPS: ${agriData.gpsCoords}",
              style: const TextStyle(fontSize: 10, color: Colors.white54, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: LinearGradient(colors: AppColors.primaryGradient)),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
          ),
        ],
      ),
      endDrawer: _buildDrawer(context, user?.displayName ?? widget.initialUserName ?? 'Chủ vườn'),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(soilRecordsProvider),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Weather & Location Header
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [Colors.blue.shade400, Colors.blue.shade700]),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.wb_sunny, color: Colors.white, size: 24),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Thời tiết", style: TextStyle(color: Colors.white70, fontSize: 10)),
                              Text(agriData.weatherInfo, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: agriData.selectedCrop,
                          isExpanded: true,
                          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                          items: ["Lúa", "Cà phê", "Sầu riêng", "Hồ tiêu", "Bơ"].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            if (newValue != null) {
                              ref.read(dashboardProvider.notifier).updateSelectedCrop(newValue);
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Location & Time Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.brown.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.brown.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.access_time, size: 20, color: Colors.brown),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Thời gian đo: ${DateFormat('HH:mm - dd/MM/yyyy').format(DateTime.now())}",
                        style: TextStyle(color: Colors.brown.shade800, fontWeight: FontWeight.w500, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text('Chỉ số đất vườn của bạn', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              
              // 5 Soil Metric Cards
              Row(
                children: [
                  Expanded(child: _buildMetricCard(
                    'Nitơ (N)', 
                    currentNitrogen.toStringAsFixed(1), 
                    'mg/kg', 
                    Icons.grass, 
                    AppColors.primaryGreen,
                    currentNitrogen > 50 ? 'Tốt' : 'Thấp'
                  )),
                  const SizedBox(width: 12),
                  Expanded(child: _buildMetricCard(
                    'Lân (P)', 
                    currentPhosphorus.toStringAsFixed(1), 
                    'mg/kg', 
                    Icons.agriculture, 
                    AppColors.primaryOrange,
                    currentPhosphorus > 30 ? 'Tốt' : 'Thấp'
                  )),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildMetricCard(
                    'Kali (K)', 
                    currentPotassium.toStringAsFixed(1), 
                    'mg/kg', 
                    Icons.water_drop, 
                    AppColors.primaryBlue,
                    currentPotassium > 40 ? 'Tốt' : 'Thấp'
                  )),
                  const SizedBox(width: 12),
                  Expanded(child: _buildMetricCard(
                    'pH Đất', 
                    currentPH.toStringAsFixed(1), 
                    '', 
                    Icons.science, 
                    AppColors.primaryAccent,
                    currentPH >= 5.5 && currentPH <= 7.5 ? 'Lý tưởng' : 'Cần điều chỉnh'
                  )),
                ],
              ),
              const SizedBox(height: 12),
              _buildMetricCard(
                'Độ ẩm Đất', 
                currentMoisture.toStringAsFixed(1), 
                '%', 
                Icons.opacity, 
                AppColors.primaryLight,
                currentMoisture >= 40 && currentMoisture <= 80 ? 'Đủ ẩm' : 'Cần tưới',
                isFullWidth: true,
              ),

              const SizedBox(height: 24),

              // Measure Button
              agriData.isMeasuring
                  ? const Center(
                      child: Column(
                        children: [
                          CircularProgressIndicator(color: AppColors.primary),
                          SizedBox(height: 8),
                          Text('Đang phân tích...', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    )
                  : ElevatedButton.icon(
                      onPressed: _startMeasurement,
                      icon: const Icon(Icons.sensors),
                      label: const Text('BẮT ĐẦU ĐO ĐẤT', style: TextStyle(fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 56),
                        backgroundColor: Colors.brown.shade600,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 4,
                      ),
                    ),

              const SizedBox(height: 24),

              // Trend Chart
              recordsAsync.when(
                loading: () => const SizedBox(height: 100, child: Center(child: CircularProgressIndicator())),
                error: (err, _) => Center(child: Text('Lỗi tải dữ liệu: $err')),
                data: (records) => _buildTrendChart(records),
              ),

              const SizedBox(height: 24),
              
              // AI Advice Section
              const Text('Khuyến nghị từ Chuyên gia AI', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                ),
                child: Column(
                  children: [
                    _adviceItem(Icons.tips_and_updates, "Bón phân", _getFertilizerAdvice(agriData)),
                    const Divider(),
                    _adviceItem(Icons.water_drop, "Tưới tiêu", _getWateringAdvice(agriData)),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              
              // AI Buttons Section
              const Text('Tiện ích AI', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Row(
                children: [
                  _aiButton(Icons.analytics_outlined, "Phân tích AI", AppColors.secondary, () {
                    context.push('/ai-analysis');
                  }),
                  const SizedBox(width: 12),
                  _aiButton(Icons.camera_alt_outlined, "Soi lá cây", AppColors.primaryAccent, () => context.push('/vision')),
                  const SizedBox(width: 12),
                  _aiButton(Icons.chat_bubble_outline, "Chuyên gia AI", AppColors.warning, () => context.push('/chat')),
                ],
              ),

              const SizedBox(height: 24),

              // Recent History
              _buildRecentHistory(recordsAsync),
              
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, String unit, IconData icon, Color color, String status, {bool isFullWidth = false}) {
    Widget card = Container(
      width: isFullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Icon(icon, size: 20, color: color), const SizedBox(width: 8), Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600]))]),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: RichText(text: TextSpan(children: [
              TextSpan(text: value == '0.0' ? '?' : value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black)),
              TextSpan(text: ' $unit', style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ])),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: Text(status, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
    
    return isFullWidth ? card : Expanded(child: card);
  }

  Widget _buildTrendChart(List<SoilRecord> records) {
    final last7Days = records.where((r) => r.timestamp.isAfter(DateTime.now().subtract(const Duration(days: 7)))).toList();
    last7Days.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.trending_up, color: Colors.blue),
            const SizedBox(width: 8),
            const Text('Xu hướng pH Đất', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ]),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: last7Days.isEmpty 
              ? const Center(child: Text("Chưa đủ dữ liệu để vẽ biểu đồ", style: TextStyle(color: Colors.grey)))
              : LineChart(LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (val, meta) {
                        int index = val.toInt();
                        if (index < 0 || index >= last7Days.length) return const Text('');
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(DateFormat('dd/MM').format(last7Days[index].timestamp), style: const TextStyle(fontSize: 9)),
                        );
                      }
                    )),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [LineChartBarData(
                    spots: last7Days.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.phLevel)).toList(),
                    isCurved: true,
                    color: Colors.redAccent,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(show: true, color: Colors.redAccent.withValues(alpha: 0.1)),
                  )],
                )),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentHistory(AsyncValue<List<SoilRecord>> recordsAsync) {
    return recordsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (records) {
        final recent = records.take(3).toList();
        if (recent.isEmpty) return const SizedBox.shrink();
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('📋 Lịch sử gần đây', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...recent.map((r) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.brown.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.terrain, color: Colors.brown)),
              title: Text('PH: ${r.phLevel.toStringAsFixed(1)} | Độ ẩm: ${r.moisture.toStringAsFixed(1)}%', style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(DateFormat('HH:mm - dd/MM/yyyy').format(r.timestamp)),
              trailing: Chip(label: Text('N: ${r.nitrogen.round()}', style: const TextStyle(fontSize: 10)), backgroundColor: Colors.green.withValues(alpha: 0.2)),
            )),
            TextButton(
              onPressed: () => context.push('/history'),
              child: const Text('Xem tất cả →', style: TextStyle(color: AppColors.primary)),
            ),
          ],
        );
      },
    );
  }

  Widget _aiButton(IconData icon, String title, Color color, VoidCallback onTap) {
    return Expanded(
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(children: [
              Icon(icon, size: 28, color: color),
              const SizedBox(height: 4),
              Text(title, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, String name) {
    final agriData = ref.watch(dashboardProvider);
    final performance = agriData.userProfile.performance;
    
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: AppColors.primaryGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              radius: 35,
              child: Icon(Icons.person, size: 40, color: AppColors.primary),
            ),
            accountName: Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            accountEmail: Text(
              performance > 0 
                ? "Mật độ: ${performance.toStringAsFixed(1)} cây/100m2"
                : "Cập nhật hồ sơ vườn",
              style: const TextStyle(color: Colors.white70),
            ),
          ),
          
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _drawerItem(Icons.person_outline, 'Hồ sơ Khu vườn', () {
                  Navigator.pop(context);
                  context.push('/profile');
                }),
                _drawerItem(Icons.history, 'Lịch sử đo đạc', () {
                  Navigator.pop(context);
                  context.push('/history');
                }),
                _drawerItem(Icons.analytics_outlined, 'Phân tích AI', () {
                  Navigator.pop(context);
                  context.push('/ai-analysis');
                }),
                _drawerItem(Icons.chat_bubble_outline, 'Chuyên gia AI', () {
                  Navigator.pop(context);
                  context.push('/chat');
                }),
                const Divider(),
                _drawerItem(Icons.settings, 'Cài đặt', () {
                  Navigator.pop(context);
                  context.push('/settings');
                }),
                _drawerItem(Icons.help_outline, 'Hướng dẫn sử dụng', () {
                  Navigator.pop(context);
                  _showHelpDialog(context);
                }),
              ],
            ),
          ),
          
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text(
              'Đăng xuất',
              style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
            ),
            onTap: () async {
              await ref.read(authRepositoryProvider).signOut();
              if (mounted) {
                context.go('/');
              }
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
  
  Widget _drawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
      onTap: onTap,
    );
  }
  
  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hướng dẫn sử dụng'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _helpItem('📊', 'Dashboard', 'Xem các chỉ số dinh dưỡng đất'),
            _helpItem('🌱', 'Bắt đầu đo', 'Nhấn để đo NPK, pH, Độ ẩm trong 60 giây'),
            _helpItem('📈', 'Phân tích AI', 'Xem đánh giá chất lượng đất và rủi ro'),
            _helpItem('💬', 'Chuyên gia AI', 'Hỏi đáp về kỹ thuật canh tác với AI'),
            _helpItem('📋', 'Lịch sử', 'Xem lại các lần đo trước theo vị trí'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đã hiểu', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }
  
  Widget _helpItem(String emoji, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(desc, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _adviceItem(IconData icon, String title, String advice) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.green, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Text(advice, style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getFertilizerAdvice(AgriData data) {
    if (data.nitrogen < 30) {
      return "Đất đang thiếu Đạm (N) nghiêm trọng cho cây ${data.selectedCrop}. Hãy bổ sung phân Ure hoặc NPK cao đạm.";
    }
    if (data.phLevel < 5.0) {
      return "Đất quá chua (pH thấp). Cần bón thêm vôi bột để cải tạo đất trước khi bón phân.";
    }
    return "Chỉ số dinh dưỡng đang ở mức ổn định cho cây ${data.selectedCrop}. Duy trì chế độ bón phân định kỳ.";
  }

  String _getWateringAdvice(AgriData data) {
    if (data.moisture < 30) {
      return "Độ ẩm đất thấp (${data.moisture.toStringAsFixed(1)}%). Cần tưới nước ngay để đảm bảo cây không bị héo.";
    }
    if (data.moisture > 85) {
      return "Đất đang quá ẩm. Tạm dừng tưới và kiểm tra hệ thống thoát nước để tránh thối rễ.";
    }
    return "Độ ẩm lý tưởng. Không cần tưới thêm vào lúc này.";
  }
}