// lib/features/share/share_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';

class ShareScreen extends StatefulWidget {
  final Map<String, dynamic>? healthData;
  const ShareScreen({super.key, this.healthData});

  @override
  State<ShareScreen> createState() => _ShareScreenState();
}

class _ShareScreenState extends State<ShareScreen> {
  bool _isGenerating = false;
  bool _hasReport = false;
  String _selectedFormat = 'pdf';
  final Set<String> _selectedSections = {'soil', 'analysis', 'history', 'advice'};

  late final Map<String, dynamic> _data;

  @override
  void initState() {
    super.initState();
    _data = widget.healthData ?? {
      'name': 'Chủ vườn',
      'nitrogen': 45.0,
      'phosphorus': 28.5,
      'potassium': 35.2,
      'phLevel': 6.2,
      'moisture': 55.0,
    };
  }

  Future<void> _generateReport() async {
    if (_selectedSections.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ít nhất 1 mục để xuất'), backgroundColor: AppColors.warning),
      );
      return;
    }

    setState(() => _isGenerating = true);
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    setState(() { _isGenerating = false; _hasReport = true; });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã tạo báo cáo nông vụ thành công! 📋'), backgroundColor: AppColors.primary),
    );
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
        ),
        title: const Text("Chia sẻ báo cáo", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: LinearGradient(colors: AppColors.primaryGradient)),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(colors: AppColors.backgroundGradient, begin: Alignment.topCenter, end: Alignment.bottomCenter)),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildPreviewCard(),
                const SizedBox(height: 20),
                _buildSectionSelector(),
                const SizedBox(height: 20),
                _buildFormatSelector(),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity, height: 56,
                  child: ElevatedButton.icon(
                    onPressed: _isGenerating ? null : _generateReport,
                    icon: _isGenerating ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white)) : const Icon(Icons.auto_awesome),
                    label: Text(_isGenerating ? 'Đang tạo báo cáo...' : 'Tạo báo cáo Nông vụ', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  ),
                ),
                if (_hasReport) ...[
                  const SizedBox(height: 28),
                  _buildShareOptions(),
                ],
                const SizedBox(height: 20),
                Card(
                  elevation: 4, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(children: [
                      const Icon(Icons.security, color: AppColors.primary, size: 22),
                      const SizedBox(width: 12),
                      Expanded(child: Text('Dữ liệu vườn của bạn được bảo mật. Chỉ người nhận mới có thể xem báo cáo.', style: TextStyle(fontSize: 13, color: Colors.grey.shade600))),
                    ]),
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

  Widget _buildPreviewCard() {
    return Card(
      elevation: 10, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), color: Colors.white),
        child: Column(
          children: [
            Row(children: [
              Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.description, color: AppColors.primary)),
              const SizedBox(width: 14),
              const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("Báo cáo Thổ nhưỡng", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), Text("AgriTech AI Ecosystem", style: TextStyle(fontSize: 13, color: AppColors.textSecondary))])),
              Text('${DateTime.now().day}/${DateTime.now().month}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary)),
            ]),
            const Divider(height: 28),
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              _miniMetric(Icons.grass, '${_data['nitrogen'].toInt()}', 'N', Colors.green),
              _miniMetric(Icons.agriculture, '${_data['phosphorus'].toInt()}', 'P', Colors.orange),
              _miniMetric(Icons.water_drop, '${_data['potassium'].toInt()}', 'K', Colors.blue),
              _miniMetric(Icons.science, '${_data['phLevel']}', 'pH', AppColors.primaryAccent),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _miniMetric(IconData icon, String value, String unit, Color color) {
    return Column(children: [Icon(icon, color: color, size: 22), const SizedBox(height: 6), Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)), Text(unit, style: const TextStyle(fontSize: 11, color: Colors.grey))]);
  }

  Widget _buildSectionSelector() {
    final sections = [
      {'key': 'soil', 'title': 'Chỉ số Đất', 'icon': Icons.terrain},
      {'key': 'analysis', 'title': 'Phân tích AI', 'icon': Icons.analytics},
      {'key': 'history', 'title': 'Lịch sử đo', 'icon': Icons.history},
      {'key': 'advice', 'title': 'Khuyến nghị', 'icon': Icons.tips_and_updates},
      {'key': 'weather', 'title': 'Thời tiết', 'icon': Icons.wb_sunny},
    ];

    return Card(
      elevation: 6, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text("Chọn nội dung báo cáo", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          const SizedBox(height: 14),
          Wrap(spacing: 8, runSpacing: 8, children: sections.map((s) {
            final selected = _selectedSections.contains(s['key']);
            return FilterChip(
              label: Text(s['title'] as String), selected: selected,
              onSelected: (v) => setState(() => v ? _selectedSections.add(s['key'] as String) : _selectedSections.remove(s['key'] as String)),
              selectedColor: AppColors.primary, checkmarkColor: Colors.white,
              labelStyle: TextStyle(color: selected ? Colors.white : AppColors.textPrimary),
            );
          }).toList()),
        ]),
      ),
    );
  }

  Widget _buildFormatSelector() {
    final formats = [
      {'key': 'pdf', 'title': 'PDF', 'icon': Icons.picture_as_pdf},
      {'key': 'image', 'title': 'Ảnh', 'icon': Icons.image},
    ];

    return Card(
      elevation: 6, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text("Định dạng xuất", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          const SizedBox(height: 14),
          Row(children: formats.map((f) {
            final selected = _selectedFormat == f['key'];
            return Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: InkWell(
              onTap: () => setState(() => _selectedFormat = f['key'] as String),
              child: Container(padding: const EdgeInsets.symmetric(vertical: 14), decoration: BoxDecoration(color: selected ? AppColors.primary.withValues(alpha: 0.1) : Colors.grey.shade50, borderRadius: BorderRadius.circular(14), border: Border.all(color: selected ? AppColors.primary : Colors.grey.shade300, width: selected ? 2 : 1)), child: Column(children: [Icon(f['icon'] as IconData, color: selected ? AppColors.primary : Colors.grey), const SizedBox(height: 6), Text(f['title'] as String, style: TextStyle(fontWeight: selected ? FontWeight.bold : FontWeight.normal))])),
            )));
          }).toList()),
        ]),
      ),
    );
  }

  Widget _buildShareOptions() {
    return Card(
      elevation: 8, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Row(children: [Icon(Icons.check_circle, color: AppColors.primary), SizedBox(width: 10), Text("Báo cáo đã sẵn sàng!", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.primary))]),
          const SizedBox(height: 16),
          _shareOption(Icons.person, 'Gửi Kỹ thuật viên', 'Chia sẻ qua Email', Colors.blue, () {}),
          _shareOption(Icons.download, 'Lưu vào thiết bị', 'Tải xuống ${_selectedFormat.toUpperCase()}', Colors.green, () {}),
          _shareOption(Icons.share, 'Chia sẻ nhanh', 'Gửi qua Zalo/Facebook', Colors.orange, () {}),
        ]),
      ),
    );
  }

  Widget _shareOption(IconData icon, String title, String subtitle, Color color, VoidCallback onTap) {
    return ListTile(onTap: onTap, leading: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color)), title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)), subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)), trailing: const Icon(Icons.chevron_right));
  }
}
