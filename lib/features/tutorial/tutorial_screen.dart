// lib/features/tutorial/tutorial_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';

class TutorialScreen extends StatefulWidget {
  const TutorialScreen({super.key});

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<TutorialStep> _steps = const [
    TutorialStep(
      title: 'Chào mừng đến AgriTech AI!',
      description: 'Giải pháp nông nghiệp thông minh thế hệ mới.\nTheo dõi NPK, pH và độ ẩm đất bằng công nghệ AI.',
      icon: Icons.agriculture,
      color: Color(0xFF4CAF50),
      tips: [
        'Kết nối sensor ESP32 để đo chính xác nhất',
        'Dữ liệu được lưu trữ offline an toàn',
        'Cảnh báo tức thì khi đất có dấu hiệu bất thường',
      ],
    ),
    TutorialStep(
      title: 'Đo đất định kỳ',
      description: 'Nhấn "Bắt đầu đo" trên Dashboard.\nCắm sensor vào đất và đợi AI phân tích trong 60 giây.',
      icon: Icons.sensors,
      color: Color(0xFF795548),
      tips: [
        'Đo tại nhiều điểm khác nhau trong vườn',
        'Đảm bảo sensor sạch trước khi đo',
        'Ghi lại vị trí GPS để theo dõi theo vùng',
      ],
    ),
    TutorialStep(
      title: 'Phân tích AI Chuyên sâu',
      description: 'AI đánh giá chất lượng đất và đưa ra khuyến nghị\nbón phân, tưới nước phù hợp cho từng loại cây.',
      icon: Icons.psychology,
      color: Color(0xFF2E7D32),
      tips: [
        'Cập nhật hồ sơ vườn để AI hiểu rõ loại cây trồng',
        'Theo dõi biểu đồ xu hướng hàng tuần',
        'Lắng nghe các cảnh báo đỏ về dinh dưỡng',
      ],
    ),
    TutorialStep(
      title: 'Soi lá - Diệt trừ sâu bệnh',
      description: 'Dùng Camera AI để nhận diện sâu bệnh trên lá.\nNhận ngay phác đồ điều trị an toàn và hiệu quả.',
      icon: Icons.camera_alt,
      color: Color(0xFF8BC34A),
      tips: [
        'Chụp ảnh rõ nét trong điều kiện đủ sáng',
        'AI có thể nhận diện hơn 100 loại sâu bệnh',
        'Lưu lại lịch sử để theo dõi tiến triển bệnh',
      ],
    ),
    TutorialStep(
      title: 'Chuyên gia AI 24/7',
      description: 'Hỏi bất kỳ thắc mắc nào về kỹ thuật canh tác.\nAI được huấn luyện từ kho dữ liệu nông nghiệp khổng lồ.',
      icon: Icons.chat_bubble,
      color: Color(0xFFFF9800),
      tips: [
        'Hỏi về cách ủ phân hữu cơ hoặc diệt côn trùng',
        'Dùng giọng nói để hỏi nhanh khi đang làm vườn',
        'Tư vấn phù hợp với thổ nhưỡng Việt Nam',
      ],
    ),
    TutorialStep(
      title: 'Thời tiết & Cảnh báo',
      description: 'Nhận thông tin thời tiết nông vụ chính xác.\nCảnh báo thiên tai, mưa lớn để chủ động bảo vệ vườn.',
      icon: Icons.wb_sunny,
      color: Color(0xFF2196F3),
      tips: [
        'Xem dự báo mưa trong 7 ngày tới',
        'Nhận nhắc nhở lịch bón phân định kỳ',
        'Bật thông báo để không bỏ lỡ cảnh báo quan trọng',
      ],
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _steps.length - 1) {
      _pageController.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOutCubic);
    } else {
      context.go('/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [_steps[_currentPage].color.withValues(alpha: 0.15), Colors.white])),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (_currentPage > 0) IconButton(onPressed: () => _pageController.previousPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOutCubic), icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 22)) else const SizedBox(width: 48),
                    Text('${_currentPage + 1} / ${_steps.length}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _steps[_currentPage].color)),
                    TextButton(onPressed: () => context.go('/dashboard'), child: const Text('Bỏ qua', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(children: List.generate(_steps.length, (i) => Expanded(child: Container(height: 4, margin: const EdgeInsets.symmetric(horizontal: 2), decoration: BoxDecoration(color: i <= _currentPage ? _steps[_currentPage].color : Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))))),
              ),
              Expanded(child: PageView.builder(controller: _pageController, onPageChanged: (page) => setState(() => _currentPage = page), itemCount: _steps.length, itemBuilder: (context, index) => _buildPage(_steps[index]))),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: SizedBox(
                  width: double.infinity, height: 56,
                  child: ElevatedButton(
                    onPressed: _nextPage,
                    style: ElevatedButton.styleFrom(backgroundColor: _steps[_currentPage].color, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)), elevation: 6),
                    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text(_currentPage < _steps.length - 1 ? 'Tiếp tục' : 'Bắt đầu ngay!', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8),
                      Icon(_currentPage < _steps.length - 1 ? Icons.arrow_forward_rounded : Icons.grass),
                    ]),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPage(TutorialStep step) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(children: [
        const SizedBox(height: 16),
        Container(padding: const EdgeInsets.all(28), decoration: BoxDecoration(color: step.color.withValues(alpha: 0.1), shape: BoxShape.circle), child: Icon(step.icon, size: 72, color: step.color)),
        const SizedBox(height: 32),
        Text(step.title, textAlign: TextAlign.center, style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: step.color)),
        const SizedBox(height: 14),
        Text(step.description, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, color: AppColors.textSecondary, height: 1.6)),
        const SizedBox(height: 28),
        Card(
          elevation: 4, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [const Icon(Icons.lightbulb, color: Colors.amber, size: 22), const SizedBox(width: 8), const Text("Mẹo canh tác", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))]),
              const SizedBox(height: 14),
              ...step.tips.map((tip) => Padding(padding: const EdgeInsets.only(bottom: 10), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Container(margin: const EdgeInsets.only(top: 6), width: 6, height: 6, decoration: BoxDecoration(color: step.color, shape: BoxShape.circle)), const SizedBox(width: 12), Expanded(child: Text(tip, style: const TextStyle(fontSize: 14.5, height: 1.4)))]))),
            ]),
          ),
        ),
      ]),
    );
  }
}

class TutorialStep {
  final String title, description;
  final IconData icon;
  final Color color;
  final List<String> tips;
  const TutorialStep({required this.title, required this.description, required this.icon, required this.color, required this.tips});
}
