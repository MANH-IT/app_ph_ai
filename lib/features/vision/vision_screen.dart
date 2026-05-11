// lib/features/vision/vision_screen.dart
// AI CAMERA – NHẬN DIỆN SÂU BỆNH & DINH DƯỠNG CÂY TRỒNG
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';

class VisionScreen extends StatefulWidget {
  const VisionScreen({super.key});

  @override
  State<VisionScreen> createState() => _VisionScreenState();
}

class _VisionScreenState extends State<VisionScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _scanController;
  bool _isAnalyzing = false;
  bool _hasResult = false;
  PlantAnalysisResult? _result;

  // Kết quả giả lập các loại bệnh cây trồng
  final List<PlantAnalysisResult> _mockResults = [
    PlantAnalysisResult(
      name: 'Bệnh đạo ôn (Lúa)',
      category: 'Nấm bệnh',
      severity: 75,
      confidence: 92.5,
      symptoms: [
        'Vết bệnh hình thoi, tâm màu xám trắng',
        'Lá bị cháy khô khi bệnh nặng',
        'Ảnh hưởng đến năng suất hạt'
      ],
      treatments: [
        'Sử dụng thuốc đặc trị nấm (Beam, Filia)',
        'Giảm bón phân đạm (N)',
        'Giữ mực nước ruộng ổn định'
      ],
      prevention: 'Sử dụng giống kháng bệnh, xử lý hạt giống trước khi gieo.',
    ),
    PlantAnalysisResult(
      name: 'Rỉ sắt (Cà phê)',
      category: 'Nấm bệnh',
      severity: 45,
      confidence: 88.0,
      symptoms: [
        'Mặt dưới lá có các ổ bột màu cam',
        'Lá bị vàng và rụng sớm',
        'Cây còi cọc, kém phát triển'
      ],
      treatments: [
        'Phun thuốc gốc đồng hoặc Anvil',
        'Cắt tỉa cành bị bệnh và tiêu hủy'
      ],
      prevention: 'Trồng cây che bóng, bón phân cân đối NPK.',
    ),
    PlantAnalysisResult(
      name: 'Thiếu Magiê (Sầu riêng)',
      category: 'Dinh dưỡng',
      severity: 30,
      confidence: 85.0,
      symptoms: [
        'Vàng lá gân xanh',
        'Lá già bị ảnh hưởng trước',
        'Mép lá có thể bị cháy'
      ],
      treatments: [
        'Bổ sung phân bón lá có chứa Magie',
        'Kiểm tra và điều chỉnh độ pH đất'
      ],
      prevention: 'Bón phân hữu cơ định kỳ để cải thiện cấu trúc đất.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void dispose() {
    _scanController.dispose();
    super.dispose();
  }

  Future<void> _takePhoto() async {
    setState(() {
      _isAnalyzing = true;
      _hasResult = false;
    });
    _scanController.repeat();

    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    _scanController.stop();
    _scanController.reset();

    // Chọn ngẫu nhiên 1 kết quả
    final result = _mockResults[DateTime.now().second % _mockResults.length];

    setState(() {
      _isAnalyzing = false;
      _hasResult = true;
      _result = result;
    });
  }

  Color _severityColor(int severity) {
    if (severity < 40) return AppColors.primaryGreen;
    if (severity < 70) return AppColors.primaryOrange;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 24),
          onPressed: () => context.go('/dashboard'),
          tooltip: "Quay lại Dashboard",
        ),
        title: const Text("AI Plant Vision", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green, Colors.teal],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.shade50, Colors.teal.shade50],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                if (_isAnalyzing)
                  _buildAnalyzing()
                else if (_hasResult && _result != null)
                  _buildResult()
                else
                  _buildInitial(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInitial() {
    return Column(
      children: [
        // Camera preview placeholder
        Card(
          elevation: 10,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Container(
            height: 320,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                colors: [Colors.black87, Colors.grey.shade800],
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Corner markers
                _cornerMark(Alignment.topLeft),
                _cornerMark(Alignment.topRight),
                _cornerMark(Alignment.bottomLeft),
                _cornerMark(Alignment.bottomRight),
                // Center icon
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.filter_center_focus, size: 64, color: Colors.green.shade400),
                    const SizedBox(height: 16),
                    const Text(
                      'Đặt lá cây hoặc vùng bệnh vào khung hình',
                      style: TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 32),

        // Capture button
        GestureDetector(
          onTap: _takePhoto,
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.green.shade400, width: 4),
            ),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.green.shade600,
              ),
              child: const Icon(Icons.camera_alt, color: Colors.white, size: 36),
            ),
          ),
        ),

        const SizedBox(height: 40),

        // Features
        Card(
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("AI Plant Vision có thể", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _featureItem(Icons.bug_report, 'Nhận diện sâu bệnh', 'Xác định loại nấm, vi khuẩn, sâu hại', Colors.orange),
                _featureItem(Icons.grass, 'Thiếu hụt dinh dưỡng', 'Phân tích lá để đoán thiếu NPK, vi lượng', Colors.green),
                _featureItem(Icons.agriculture, 'Gợi ý thuốc/phân', 'Đưa ra giải pháp đặc trị phù hợp', Colors.blue),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnalyzing() {
    return Card(
      elevation: 10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            colors: [Colors.green, Colors.teal],
          ),
        ),
        child: Column(
          children: [
            AnimatedBuilder(
              animation: _scanController,
              builder: (_, __) => Transform.scale(
                scale: 0.8 + (_scanController.value * 0.4),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 3),
                  ),
                  child: const Icon(Icons.psychology, size: 64, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 28),
            const Text("Đang phân tích...", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 10),
            Text("AI đang quét bề mặt lá cây", style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.7))),
            const SizedBox(height: 20),
            const LinearProgressIndicator(color: Colors.white, backgroundColor: Colors.white24),
          ],
        ),
      ),
    );
  }

  Widget _buildResult() {
    final r = _result!;
    final sevColor = _severityColor(r.severity);

    return Column(
      children: [
        // Result header
        Card(
          elevation: 10,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(r.category, style: TextStyle(fontSize: 13, color: Colors.green.shade700, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(height: 12),
                Text(r.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _resultStat('Mức độ hại', '${r.severity}%', sevColor),
                    _resultStat('Độ tin cậy AI', '${r.confidence}%', Colors.blue),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Triệu chứng
        Card(
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Triệu chứng nhận diện", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                ...r.symptoms.map((s) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.fiber_manual_record, size: 12, color: Colors.grey),
                      const SizedBox(width: 8),
                      Expanded(child: Text(s, style: const TextStyle(fontSize: 14))),
                    ],
                  ),
                )),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Cách xử lý
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
                    const Icon(Icons.verified_user, color: Colors.green, size: 24),
                    const SizedBox(width: 8),
                    const Text("Giải pháp đặc trị", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 12),
                ...r.treatments.map((t) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_outline, size: 18, color: Colors.green),
                      const SizedBox(width: 8),
                      Expanded(child: Text(t, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500))),
                    ],
                  ),
                )),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Phòng ngừa
        Card(
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.blue.shade50,
            ),
            child: Row(
              children: [
                const Icon(Icons.tips_and_updates, color: Colors.blue, size: 28),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    r.prevention,
                    style: TextStyle(fontSize: 14, color: Colors.blue.shade800, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Nút hành động
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _hasResult = false;
                _result = null;
              });
            },
            icon: const Icon(Icons.camera_alt),
            label: const Text("Chụp lá cây khác", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 4,
            ),
          ),
        ),

        const SizedBox(height: 80),
      ],
    );
  }

  Widget _resultStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
      ],
    );
  }

  Widget _cornerMark(Alignment alignment) {
    return Positioned(
      top: alignment == Alignment.topLeft || alignment == Alignment.topRight ? 24 : null,
      bottom: alignment == Alignment.bottomLeft || alignment == Alignment.bottomRight ? 24 : null,
      left: alignment == Alignment.topLeft || alignment == Alignment.bottomLeft ? 24 : null,
      right: alignment == Alignment.topRight || alignment == Alignment.bottomRight ? 24 : null,
      child: Container(
        width: 30, height: 30,
        decoration: BoxDecoration(
          border: Border(
            top: alignment == Alignment.topLeft || alignment == Alignment.topRight
                ? const BorderSide(color: Colors.green, width: 4) : BorderSide.none,
            bottom: alignment == Alignment.bottomLeft || alignment == Alignment.bottomRight
                ? const BorderSide(color: Colors.green, width: 4) : BorderSide.none,
            left: alignment == Alignment.topLeft || alignment == Alignment.bottomLeft
                ? const BorderSide(color: Colors.green, width: 4) : BorderSide.none,
            right: alignment == Alignment.topRight || alignment == Alignment.bottomRight
                ? const BorderSide(color: Colors.green, width: 4) : BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _featureItem(IconData icon, String title, String desc, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5)),
                Text(desc, style: TextStyle(fontSize: 12.5, color: Colors.grey.shade600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PlantAnalysisResult {
  final String name;
  final String category;
  final int severity;
  final double confidence;
  final List<String> symptoms;
  final List<String> treatments;
  final String prevention;

  PlantAnalysisResult({
    required this.name,
    required this.category,
    required this.severity,
    required this.confidence,
    required this.symptoms,
    required this.treatments,
    required this.prevention,
  });
}
