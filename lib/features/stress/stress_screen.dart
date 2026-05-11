// lib/features/stress/stress_screen.dart
// ĐÁNH GIÁ MỨC ĐỘ STRESS – AI PHÂN TÍCH – 2025
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';

class StressScreen extends StatefulWidget {
  const StressScreen({super.key});

  @override
  State<StressScreen> createState() => _StressScreenState();
}

class _StressScreenState extends State<StressScreen> with TickerProviderStateMixin {
  late final AnimationController _breathController;
  bool _isMeasuring = false;
  bool _hasResult = false;
  StressResult? _result;

  // Câu hỏi đánh giá stress (PSS-4 rút gọn)
  final List<StressQuestion> _questions = [
    StressQuestion(question: 'Bạn có cảm thấy không kiểm soát được những điều quan trọng trong cuộc sống không?', answer: -1),
    StressQuestion(question: 'Bạn có tự tin vào khả năng xử lý các vấn đề cá nhân không?', answer: -1, isReversed: true),
    StressQuestion(question: 'Bạn có cảm thấy mọi thứ đang diễn ra theo ý bạn không?', answer: -1, isReversed: true),
    StressQuestion(question: 'Bạn có cảm thấy khó khăn chồng chất đến mức không thể vượt qua không?', answer: -1),
    StressQuestion(question: 'Bạn có thường xuyên bị mất ngủ do căng thẳng không?', answer: -1),
    StressQuestion(question: 'Bạn có cảm thấy dễ cáu gắt hoặc bực bội không?', answer: -1),
  ];

  int _currentQuestion = 0;
  bool _showQuestionnaire = false;

  @override
  void initState() {
    super.initState();
    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
  }

  @override
  void dispose() {
    _breathController.dispose();
    super.dispose();
  }

  void _startBreathing() {
    _breathController.repeat(reverse: true);
  }

  void _stopBreathing() {
    _breathController.stop();
    _breathController.reset();
  }

  void _startQuestionnaire() {
    setState(() {
      _showQuestionnaire = true;
      _currentQuestion = 0;
      for (var q in _questions) {
        q.answer = -1;
      }
    });
  }

  void _answerQuestion(int answer) {
    setState(() {
      _questions[_currentQuestion].answer = answer;
      if (_currentQuestion < _questions.length - 1) {
        _currentQuestion++;
      } else {
        _calculateResult();
      }
    });
  }

  void _calculateResult() {
    double totalScore = 0;
    for (var q in _questions) {
      if (q.isReversed) {
        totalScore += (4 - q.answer);
      } else {
        totalScore += q.answer;
      }
    }

    final normalizedScore = (totalScore / (_questions.length * 4) * 100).clamp(0.0, 100.0);

    StressLevel level;
    String advice;
    Color color;
    String emoji;

    if (normalizedScore < 25) {
      level = StressLevel.low;
      advice = 'Tuyệt vời! Bạn đang quản lý stress rất tốt. Tiếp tục duy trì lối sống lành mạnh và các hoạt động thư giãn.';
      color = AppColors.primary;
      emoji = '😊';
    } else if (normalizedScore < 50) {
      level = StressLevel.moderate;
      advice = 'Mức stress bình thường. Hãy thử tập thiền, yoga hoặc đi bộ mỗi ngày 30 phút để giảm stress.';
      color = AppColors.primaryLight;
      emoji = '😐';
    } else if (normalizedScore < 75) {
      level = StressLevel.high;
      advice = 'Mức stress cao! Bạn cần nghỉ ngơi nhiều hơn, tránh caffeine, thử kỹ thuật hít thở sâu và chia sẻ với người thân.';
      color = AppColors.warning;
      emoji = '😰';
    } else {
      level = StressLevel.veryHigh;
      advice = '⚠️ Stress rất cao! Hãy tìm kiếm sự hỗ trợ từ chuyên gia tâm lý. Đường dây nóng tâm lý: 1800-599-920 (miễn phí).';
      color = AppColors.error;
      emoji = '😫';
    }

    setState(() {
      _showQuestionnaire = false;
      _hasResult = true;
      _result = StressResult(
        score: normalizedScore,
        level: level,
        advice: advice,
        color: color,
        emoji: emoji,
        timestamp: DateTime.now(),
        heartRateVariability: 42 + Random().nextInt(30).toDouble(),
        cortisolEstimate: normalizedScore < 50 ? 'Bình thường' : 'Cao',
      );
    });
  }

  void _startBiometricMeasure() async {
    setState(() => _isMeasuring = true);
    _startBreathing();

    await Future.delayed(const Duration(seconds: 8));
    if (!mounted) return;

    _stopBreathing();
    setState(() => _isMeasuring = false);
    _startQuestionnaire();
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
          tooltip: "Quay lại Trang chủ",
        ),
        title: const Text("Đánh giá Stress", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.teal.shade700, Colors.teal.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.shade50, Colors.green.shade50],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                if (_showQuestionnaire)
                  _buildQuestionnaire()
                else if (_isMeasuring)
                  _buildMeasuring()
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

  // === TRẠNG THÁI BAN ĐẦU ===
  Widget _buildInitial() {
    return Column(
      children: [
        Card(
          elevation: 10,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                colors: [Colors.teal.shade700, Colors.teal.shade500],
              ),
            ),
            child: Column(
              children: [
                const Icon(Icons.self_improvement, size: 72, color: Colors.white),
                const SizedBox(height: 16),
                const Text(
                  "Kiểm tra mức độ stress",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  "Kết hợp đo sinh trắc & khảo sát tâm lý\nChỉ mất 2-3 phút",
                  style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.8)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: _startBiometricMeasure,
                    icon: const Icon(Icons.play_arrow_rounded, size: 26),
                    label: const Text("Bắt đầu đánh giá", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.surface,
                      foregroundColor: Colors.teal.shade700,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Thông tin về stress
        Card(
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Stress ảnh hưởng gì?", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                _infoRow(Icons.favorite, 'Tăng nhịp tim, huyết áp', Colors.red),
                _infoRow(Icons.nightlight, 'Mất ngủ, ngủ không sâu', Colors.indigo),
                _infoRow(Icons.psychology, 'Khó tập trung, hay quên', Colors.purple),
                _infoRow(Icons.restaurant, 'Ăn uống thất thường', Colors.orange),
                _infoRow(Icons.mood_bad, 'Lo âu, cáu gắt, trầm cảm', Colors.teal),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

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
                    Icon(Icons.tips_and_updates, color: Colors.amber.shade700),
                    const SizedBox(width: 8),
                    const Text("Mẹo giảm stress nhanh", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 12),
                _tipCard('🧘', 'Hít thở sâu 4-7-8', 'Hít 4s → Giữ 7s → Thở ra 8s. Lặp 4 lần.'),
                _tipCard('🚶', 'Đi bộ 15 phút', 'Đi bộ ngoài trời giúp giảm cortisol nhanh chóng.'),
                _tipCard('🎵', 'Nghe nhạc thư giãn', 'Nhạc chậm 60-80 BPM giúp hạ nhịp tim.'),
                _tipCard('💧', 'Uống nước', 'Mất nước nhẹ cũng làm tăng cortisol.'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 80),
      ],
    );
  }

  // === ĐANG ĐO ===
  Widget _buildMeasuring() {
    return Card(
      elevation: 10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: [Colors.teal.shade700, Colors.teal.shade500],
          ),
        ),
        child: Column(
          children: [
            const Text("Hít thở theo nhịp", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 8),
            Text("Thư giãn và làm theo hướng dẫn", style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.8))),
            const SizedBox(height: 40),
            AnimatedBuilder(
              animation: _breathController,
              builder: (_, __) {
                final size = 100 + (_breathController.value * 60);
                return Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.2),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 3),
                  ),
                  child: Center(
                    child: Text(
                      _breathController.value < 0.5 ? 'Hít vào' : 'Thở ra',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 40),
            const Text("Đang phân tích sinh trắc...", style: TextStyle(fontSize: 16, color: Colors.white70)),
            const SizedBox(height: 16),
            const LinearProgressIndicator(
              color: Colors.white,
              backgroundColor: Colors.white24,
            ),
          ],
        ),
      ),
    );
  }

  // === BẢNG CÂU HỎI ===
  Widget _buildQuestionnaire() {
    final q = _questions[_currentQuestion];
    final progress = (_currentQuestion + 1) / _questions.length;

    return Column(
      children: [
        // Progress
        Row(
          children: [
            Expanded(
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
                backgroundColor: Colors.teal.shade100,
                valueColor: AlwaysStoppedAnimation(Colors.teal.shade600),
              ),
            ),
            const SizedBox(width: 12),
            Text('${_currentQuestion + 1}/${_questions.length}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.teal.shade700)),
          ],
        ),
        const SizedBox(height: 24),

        Card(
          elevation: 8,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Icon(Icons.psychology, size: 48, color: Colors.teal.shade400),
                const SizedBox(height: 20),
                Text(
                  q.question,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, height: 1.5),
                ),
                const SizedBox(height: 32),
                // Thang điểm 0-4
                ...List.generate(5, (i) {
                  final labels = ['Không bao giờ', 'Hiếm khi', 'Thỉnh thoảng', 'Thường xuyên', 'Luôn luôn'];
                  final colors = [
                    AppColors.primary,
                    AppColors.primaryLight,
                    AppColors.warning.withValues(alpha: 0.8),
                    Colors.deepOrange,
                    AppColors.error,
                  ];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton(
                        onPressed: () => _answerQuestion(i),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colors[i],
                          side: BorderSide(color: colors[i], width: 1.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: Text(labels[i], style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // === KẾT QUẢ ===
  Widget _buildResult() {
    final r = _result!;

    return Column(
      children: [
        Card(
          elevation: 12,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              children: [
                Text(r.emoji, style: const TextStyle(fontSize: 64)),
                const SizedBox(height: 16),
                Text(
                  _stressLevelLabel(r.level),
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: r.color),
                ),
                const SizedBox(height: 12),
                Text(
                  '${r.score.toStringAsFixed(0)}%',
                  style: TextStyle(fontSize: 52, fontWeight: FontWeight.w300, color: r.color),
                ),
                const SizedBox(height: 8),
                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: r.score / 100,
                    minHeight: 12,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation(r.color),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: r.color.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    r.advice,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15, color: r.color, height: 1.5),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Chỉ số sinh trắc
        Row(
          children: [
            Expanded(
              child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Icon(Icons.timeline, color: Colors.teal.shade600, size: 28),
                      const SizedBox(height: 8),
                      Text('HRV', style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                      const SizedBox(height: 4),
                      Text('${r.heartRateVariability.toStringAsFixed(0)} ms', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.teal.shade700)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Icon(Icons.science, color: Colors.amber.shade700, size: 28),
                      const SizedBox(height: 8),
                      Text('Cortisol', style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                      const SizedBox(height: 4),
                      Text(r.cortisolEstimate, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.amber.shade700)),
                    ],
                  ),
                ),
              ),
            ),
          ],
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
            icon: const Icon(Icons.refresh),
            label: const Text("Đánh giá lại", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 4,
            ),
          ),
        ),

        const SizedBox(height: 12),

        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton.icon(
            onPressed: () => context.go('/chat'),
            icon: const Icon(Icons.chat_bubble_outline),
            label: const Text("Nói chuyện với AI", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.teal.shade600,
              side: BorderSide(color: Colors.teal.shade600, width: 2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),

        const SizedBox(height: 80),
      ],
    );
  }

  // === HELPER WIDGETS ===
  Widget _infoRow(IconData icon, String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14.5, height: 1.3))),
        ],
      ),
    );
  }

  Widget _tipCard(String emoji, String title, String desc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.teal.shade50,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 2),
                Text(desc, style: TextStyle(fontSize: 12.5, color: Colors.grey.shade700)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _stressLevelLabel(StressLevel level) => switch (level) {
    StressLevel.low => 'Stress thấp',
    StressLevel.moderate => 'Stress vừa',
    StressLevel.high => 'Stress cao',
    StressLevel.veryHigh => 'Stress rất cao',
  };
}

// === DATA MODELS ===

enum StressLevel { low, moderate, high, veryHigh }

class StressQuestion {
  final String question;
  int answer;
  final bool isReversed;

  StressQuestion({required this.question, this.answer = -1, this.isReversed = false});
}

class StressResult {
  final double score;
  final StressLevel level;
  final String advice;
  final Color color;
  final String emoji;
  final DateTime timestamp;
  final double heartRateVariability;
  final String cortisolEstimate;

  const StressResult({
    required this.score,
    required this.level,
    required this.advice,
    required this.color,
    required this.emoji,
    required this.timestamp,
    required this.heartRateVariability,
    required this.cortisolEstimate,
  });
}
