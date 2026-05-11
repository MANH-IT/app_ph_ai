// lib/features/analytics/analytics_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../models/soil_record_model.dart';
import '../../repositories/soil_repository.dart';
import '../../providers/auth_provider.dart';
import 'widgets/radar_chart_widget.dart';
import 'widgets/risk_card.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? extra;
  const AnalyticsScreen({super.key, this.extra});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;
  
  SoilRecord? _newestRecord;
  SoilRecord? _oldestRecord;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _controller.forward();
    
    // Load dữ liệu
    _loadRecords();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadRecords() async {
    setState(() => _isLoading = true);
    
    final authRepo = ref.read(authRepositoryProvider);
    final soilRepo = SoilRepository(authRepo);
    
    final allRecords = await soilRepo.getAllRecords();
    
    if (allRecords.isNotEmpty) {
      // SoilRepository đã sort mới nhất lên đầu (index 0)
      _newestRecord = allRecords.first;
      if (allRecords.length > 1) {
        _oldestRecord = allRecords.last;
      }
    }
    
    setState(() => _isLoading = false);
  }

  // Các chỉ số từ record mới nhất
  double get _nitrogen => _newestRecord?.nitrogen ?? 0.0;
  double get _phosphorus => _newestRecord?.phosphorus ?? 0.0;
  double get _potassium => _newestRecord?.potassium ?? 0.0;
  double get _phLevel => _newestRecord?.phLevel ?? 7.0;
  double get _moisture => _newestRecord?.moisture ?? 0.0;

  // Tính toán điểm chất lượng đất (Logic đơn giản)
  double get nutrientRisk {
    double score = 100.0;
    if (_nitrogen < 30) score -= 20;
    if (_phosphorus < 20) score -= 20;
    if (_potassium < 30) score -= 20;
    return (100 - score).clamp(0, 100);
  }

  double get acidityRisk {
    double risk = 0.0;
    if (_phLevel < 5.5 || _phLevel > 7.5) risk += 40;
    if (_phLevel < 4.5 || _phLevel > 8.5) risk += 30;
    return risk.clamp(0, 100);
  }

  double get moistureRisk {
    double risk = 0.0;
    if (_moisture < 40) risk += 35;
    if (_moisture > 85) risk += 25;
    return risk.clamp(0, 100);
  }

  double get soilBalanceRisk {
    double risk = 20.0;
    double avgNutrient = (_nitrogen + _phosphorus + _potassium) / 3;
    if (avgNutrient < 40) risk += 40;
    return risk.clamp(0, 100);
  }

  double get overallRisk => (nutrientRisk + acidityRisk + moistureRisk + soilBalanceRisk) / 4;

  String _getRiskLevel(double risk) {
    if (risk < 35) return "Rất thấp";
    if (risk < 50) return "Trung bình";
    if (risk < 75) return "Nguy cơ cao";
    return "Cảnh báo đỏ";
  }

  Color _riskColor(double risk) {
    if (risk < 35) return AppColors.primary;
    if (risk < 50) return AppColors.primaryLight;
    if (risk < 75) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    if (_newestRecord == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text("Phân tích AI"),
          leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go('/dashboard')),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.analytics_outlined, size: 80, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              const Text("Bạn chưa có dữ liệu đo nào!", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text("Hãy thực hiện đo tại Dashboard để bắt đầu phân tích."),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go('/dashboard'),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                child: const Text("Bắt đầu đo ngay"),
              )
            ],
          ),
        ),
      );
    }

    final String dateStr = DateFormat('dd/MM HH:mm').format(_newestRecord!.timestamp);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => context.go('/dashboard'),
        ),
        title: const Text("Phân tích AI Chuyên sâu", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: AppColors.primaryGradient),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE8F5E9), Color(0xFFF1F8E9), AppColors.background],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              children: [
                FadeTransition(
                  opacity: _animation,
                  child: Card(
                    elevation: 12,
                    shadowColor: AppColors.primary.withValues(alpha: 0.2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _riskColor(overallRisk).withValues(alpha: 0.1),
                            ),
                            child: Icon(Icons.psychology_rounded, size: 64, color: _riskColor(overallRisk)),
                          ),
                          const SizedBox(height: 16),
                          Text("Điểm chất lượng đất AI", style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
                          Text("${(100 - overallRisk).toStringAsFixed(0)} / 100", 
                            style: TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: _riskColor(overallRisk))),
                          Text(_getRiskLevel(overallRisk) == "Rất thấp" ? "Rất Tốt" : _getRiskLevel(overallRisk), 
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _riskColor(overallRisk))),
                          const SizedBox(height: 8),
                          Text("Cập nhật: $dateStr", style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                if (_oldestRecord != null && _oldestRecord!.id != _newestRecord!.id) ...[
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Xu hướng gần đây", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                           _buildTrendRow("Đạm (Nitơ)", _oldestRecord!.nitrogen, _newestRecord!.nitrogen, "mg/kg", isHigherBetter: true),
                           const Divider(),
                           _buildTrendRow("Lân (P)", _oldestRecord!.phosphorus, _newestRecord!.phosphorus, "mg/kg", isHigherBetter: true),
                           const Divider(),
                           _buildTrendRow("Kali (K)", _oldestRecord!.potassium, _newestRecord!.potassium, "mg/kg", isHigherBetter: true),
                           const Divider(),
                           _buildTrendRow("pH Đất", _oldestRecord!.phLevel, _newestRecord!.phLevel, "", isHigherBetter: true),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Mạng lưới Nguy cơ", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
                ),
                const SizedBox(height: 12),
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: AnalyticsRadarChart(
                        moistureRisk: moistureRisk,
                        nutrientRisk: nutrientRisk,
                        acidityRisk: acidityRisk,
                        balanceRisk: soilBalanceRisk,
                      ),
                    ),
                  ),

                const SizedBox(height: 24),

                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Chi tiết các cảnh báo", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
                ),
                const SizedBox(height: 12),
                 RiskCard(title: "Tổng hợp Dinh dưỡng", risk: nutrientRisk, icon: Icons.grass, color: _riskColor(nutrientRisk), riskLevelStr: _getRiskLevel(nutrientRisk)),
                 RiskCard(title: "Độ chua (pH)", risk: acidityRisk, icon: Icons.science, color: _riskColor(acidityRisk), riskLevelStr: _getRiskLevel(acidityRisk)),
                 RiskCard(title: "Độ ẩm Đất", risk: moistureRisk, icon: Icons.opacity, color: _riskColor(moistureRisk), riskLevelStr: _getRiskLevel(moistureRisk)),
                 RiskCard(title: "Cân bằng Đất", risk: soilBalanceRisk, icon: Icons.balance, color: _riskColor(soilBalanceRisk), riskLevelStr: _getRiskLevel(soilBalanceRisk)),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTrendRow(String label, double oldVal, double newVal, String unit, {bool isHigherBetter = true, String? customText}) {
    final diff = newVal - oldVal;
    final bool isGood = isHigherBetter ? diff >= 0 : diff <= 0;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          if (customText != null)
            Text(customText, style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold))
          else
            Row(
              children: [
                Text("${oldVal.toInt()} → ${newVal.toInt()} $unit", style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 8),
                Icon(
                  diff >= 0 ? Icons.trending_up : Icons.trending_down,
                  size: 18,
                  color: isGood ? Colors.green : Colors.red,
                ),
              ],
            ),
        ],
      ),
    );
  }
}
