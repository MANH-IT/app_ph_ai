// lib/features/feedback/feedback_screen.dart
// GÓP Ý & ĐÁNH GIÁ ỨNG DỤNG – 2025
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  int _rating = 0;
  String _selectedCategory = '';
  final _feedbackController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isSending = false;
  bool _sent = false;

  final List<FeedbackCategory> _categories = const [
    FeedbackCategory(key: 'ui', label: 'Giao diện', icon: Icons.palette),
    FeedbackCategory(key: 'accuracy', label: 'Độ chính xác', icon: Icons.verified),
    FeedbackCategory(key: 'performance', label: 'Hiệu suất', icon: Icons.speed),
    FeedbackCategory(key: 'feature', label: 'Tính năng mới', icon: Icons.add_circle_outline),
    FeedbackCategory(key: 'bug', label: 'Lỗi / Bug', icon: Icons.bug_report),
    FeedbackCategory(key: 'other', label: 'Khác', icon: Icons.more_horiz),
  ];

  @override
  void dispose() {
    _feedbackController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submitFeedback() async {
    if (_rating == 0) {
      _showSnack('Vui lòng đánh giá sao', AppColors.warning);
      return;
    }
    if (_feedbackController.text.trim().isEmpty) {
      _showSnack('Vui lòng nhập nội dung góp ý', AppColors.warning);
      return;
    }

    setState(() => _isSending = true);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    setState(() {
      _isSending = false;
      _sent = true;
    });
  }

  void _showSnack(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _resetForm() {
    setState(() {
      _rating = 0;
      _selectedCategory = '';
      _feedbackController.clear();
      _emailController.clear();
      _sent = false;
    });
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
        title: const Text("Góp ý & Đánh giá", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: AppColors.primaryGradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: AppColors.backgroundGradient,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: _sent ? _buildThankYou() : _buildForm(),
          ),
        ),
      ),
    );
  }

  Widget _buildThankYou() {
    return Card(
      elevation: 12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.all(36),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle, color: AppColors.primary, size: 72),
            ),
            const SizedBox(height: 24),
            const Text(
              "Cảm ơn bạn! 🎉",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.primary),
            ),
            const SizedBox(height: 12),
            const Text(
              "Góp ý của bạn rất quan trọng với chúng tôi.\nChúng tôi sẽ phản hồi trong vòng 24 giờ.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: AppColors.textSecondary, height: 1.5),
            ),
            const SizedBox(height: 6),
            // Star display
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) => Icon(
                i < _rating ? Icons.star : Icons.star_border,
                color: Colors.amber,
                size: 32,
              )),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _resetForm,
                icon: const Icon(Icons.edit),
                label: const Text("Gửi thêm ý kiến", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => context.go('/dashboard'),
              child: const Text("Về trang chủ", style: TextStyle(fontSize: 15)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      children: [
        // === ĐÁNH GIÁ SAO ===
        Card(
          elevation: 8,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Text("Bạn đánh giá HealthAI thế nào?", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (i) {
                    final starIndex = i + 1;
                    return GestureDetector(
                      onTap: () => setState(() => _rating = starIndex),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: AnimatedScale(
                          scale: _rating >= starIndex ? 1.2 : 1.0,
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            _rating >= starIndex ? Icons.star : Icons.star_border,
                            color: Colors.amber.shade600,
                            size: 44,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                if (_rating > 0) ...[
                  const SizedBox(height: 12),
                  Text(
                    _ratingLabel(_rating),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _rating >= 4 ? AppColors.primary : _rating >= 3 ? AppColors.warning : AppColors.error,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        // === CHỌN DANH MỤC ===
        Card(
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Về vấn đề gì?", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _categories.map((cat) {
                    final selected = _selectedCategory == cat.key;
                    return ChoiceChip(
                      avatar: Icon(cat.icon, size: 18, color: selected ? Colors.white : AppColors.primary),
                      label: Text(cat.label),
                      selected: selected,
                      onSelected: (_) => setState(() => _selectedCategory = selected ? '' : cat.key),
                      selectedColor: AppColors.primary,
                      backgroundColor: Colors.grey.shade100,
                      labelStyle: TextStyle(
                        color: selected ? Colors.white : AppColors.textPrimary,
                        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        // === NỘI DUNG GÓP Ý ===
        Card(
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Chi tiết", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                const SizedBox(height: 14),
                TextField(
                  controller: _feedbackController,
                  maxLines: 5,
                  maxLength: 500,
                  decoration: InputDecoration(
                    hintText: 'Mô tả chi tiết ý kiến của bạn...',
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: AppColors.primary, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email (tùy chọn - để nhận phản hồi)',
                    prefixIcon: Icon(Icons.email_outlined, color: Colors.grey.shade500),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: AppColors.primary, width: 2),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        // === NÚT GỬI ===
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: _isSending ? null : _submitFeedback,
            icon: _isSending
                ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                : const Icon(Icons.send_rounded, size: 24),
            label: Text(
              _isSending ? 'Đang gửi...' : 'Gửi góp ý',
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 6,
              disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.6),
            ),
          ),
        ),
        const SizedBox(height: 80),
      ],
    );
  }

  String _ratingLabel(int rating) => switch (rating) {
    1 => 'Rất tệ 😞',
    2 => 'Chưa tốt 😕',
    3 => 'Bình thường 😐',
    4 => 'Tốt 😊',
    5 => 'Tuyệt vời! 🤩',
    _ => '',
  };
}

class FeedbackCategory {
  final String key;
  final String label;
  final IconData icon;
  const FeedbackCategory({required this.key, required this.label, required this.icon});
}
