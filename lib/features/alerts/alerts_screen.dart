// lib/features/alerts/alerts_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> with SingleTickerProviderStateMixin {
  String _filter = 'all'; // all, critical, warning, info

  final List<SoilAlert> _alerts = [
    SoilAlert(
      id: '1',
      title: 'Độ chua (pH) quá cao',
      message: 'Chỉ số pH đo được là 4.2 lúc 08:30. Đất đang bị chua nghiêm trọng, có thể gây bó rễ cho cây Cà phê. Cần bón vôi cải tạo.',
      type: AlertType.critical,
      category: AlertCategory.phLevel,
      time: DateTime.now().subtract(const Duration(minutes: 28)),
      isRead: false,
      actionRoute: '/dashboard',
      actionLabel: 'Đo lại ngay',
    ),
    SoilAlert(
      id: '2',
      title: 'Độ ẩm đất giảm thấp',
      message: 'Độ ẩm đất đo được 32%, thấp hơn ngưỡng lý tưởng (45-60%). Hãy kiểm tra hệ thống tưới.',
      type: AlertType.warning,
      category: AlertCategory.moisture,
      time: DateTime.now().subtract(const Duration(hours: 2)),
      isRead: false,
      actionRoute: '/ai-analysis',
      actionLabel: 'Phân tích AI',
    ),
    SoilAlert(
      id: '3',
      title: 'Thiếu hụt Đạm (N)',
      message: 'Hàm lượng Nitơ đang ở mức thấp (15 mg/kg). Cần bổ sung phân bón lá hoặc NPK cao đạm cho giai đoạn phát triển.',
      type: AlertType.critical,
      category: AlertCategory.nutrients,
      time: DateTime.now().subtract(const Duration(hours: 5)),
      isRead: true,
      actionRoute: '/history',
      actionLabel: 'Xem lịch sử',
    ),
    SoilAlert(
      id: '4',
      title: 'Dự báo bão sắp tới',
      message: 'Dự báo khu vực Đắk Lắk có mưa lớn trong 2 ngày tới. Hãy kiểm tra hệ thống thoát nước vườn để tránh ngập úng.',
      type: AlertType.info,
      category: AlertCategory.weather,
      time: DateTime.now().subtract(const Duration(hours: 8)),
      isRead: true,
    ),
    SoilAlert(
      id: '5',
      title: 'Cảnh báo sâu bệnh vùng lân cận',
      message: 'Phát hiện bệnh Rỉ sắt đang bùng phát ở các vườn lân cận. Hãy dùng tính năng "Soi lá cây" để kiểm tra vườn của bạn.',
      type: AlertType.warning,
      category: AlertCategory.pests,
      time: DateTime.now().subtract(const Duration(hours: 12)),
      isRead: true,
      actionRoute: '/vision',
      actionLabel: 'Soi lá cây',
    ),
    SoilAlert(
      id: '6',
      title: 'Chỉ số vườn rất tốt! 🎉',
      message: 'Tuần qua các chỉ số pH, NPK và độ ẩm luôn ở mức lý tưởng. Cây trồng đang phát triển rất tốt!',
      type: AlertType.success,
      category: AlertCategory.summary,
      time: DateTime.now().subtract(const Duration(days: 1)),
      isRead: true,
      actionRoute: '/ai-analysis',
      actionLabel: 'Xem báo cáo',
    ),
    SoilAlert(
      id: '8',
      title: 'Chưa đo đất hôm nay',
      message: 'Bạn chưa thực hiện đo các chỉ số đất hôm nay. Hãy đo định kỳ để AI theo dõi sức khỏe khu vườn tốt hơn.',
      type: AlertType.info,
      category: AlertCategory.reminder,
      time: DateTime.now().subtract(const Duration(days: 2)),
      isRead: true,
      actionRoute: '/dashboard',
      actionLabel: 'Đo ngay',
    ),
  ];

  @override
  void initState() {
    super.initState();
  }

  List<SoilAlert> get _filteredAlerts {
    if (_filter == 'all') return _alerts;
    if (_filter == 'critical') return _alerts.where((a) => a.type == AlertType.critical).toList();
    if (_filter == 'warning') return _alerts.where((a) => a.type == AlertType.warning).toList();
    return _alerts.where((a) => a.type == AlertType.info || a.type == AlertType.success).toList();
  }

  int get _unreadCount => _alerts.where((a) => !a.isRead).length;

  void _markAsRead(String id) {
    setState(() {
      final index = _alerts.indexWhere((a) => a.id == id);
      if (index != -1) _alerts[index] = _alerts[index].copyWith(isRead: true);
    });
  }

  void _markAllAsRead() {
    setState(() {
      for (var i = 0; i < _alerts.length; i++) {
        _alerts[i] = _alerts[i].copyWith(isRead: true);
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã đánh dấu tất cả là đã đọc'), backgroundColor: AppColors.primary),
    );
  }

  void _deleteAlert(String id) {
    setState(() {
      _alerts.removeWhere((a) => a.id == id);
    });
  }

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'Vừa xong';
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
    if (diff.inHours < 24) return '${diff.inHours} giờ trước';
    if (diff.inDays < 7) return '${diff.inDays} ngày trước';
    return '${time.day}/${time.month}/${time.year}';
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredAlerts;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 24),
          onPressed: () => context.go('/dashboard'),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Cảnh báo Vườn", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20)),
            if (_unreadCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(12)),
                child: Text('$_unreadCount', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: LinearGradient(colors: AppColors.primaryGradient)),
        ),
        actions: [
          if (_unreadCount > 0)
            IconButton(icon: const Icon(Icons.done_all, color: Colors.white), onPressed: _markAllAsRead),
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onSelected: (value) => setState(() => _filter = value),
            itemBuilder: (_) => [
              _popupMenuItem('all', 'Tất cả', Icons.list),
              _popupMenuItem('critical', 'Nguy hiểm', Icons.error),
              _popupMenuItem('warning', 'Cảnh báo', Icons.warning_amber),
              _popupMenuItem('info', 'Thông tin', Icons.info_outline),
            ],
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(colors: AppColors.backgroundGradient, begin: Alignment.topCenter, end: Alignment.bottomCenter)),
        child: SafeArea(
          child: filtered.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) => _buildAlertCard(filtered[index]),
                ),
        ),
      ),
    );
  }

  PopupMenuItem<String> _popupMenuItem(String value, String text, IconData icon) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 20, color: _filter == value ? AppColors.primary : Colors.grey),
          const SizedBox(width: 10),
          Text(text, style: TextStyle(fontWeight: _filter == value ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.primary.withValues(alpha: 0.1)),
            child: Icon(Icons.notifications_off_outlined, size: 72, color: AppColors.primary.withValues(alpha: 0.4)),
          ),
          const SizedBox(height: 24),
          const Text("Không có cảnh báo nào", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          const Text("Mọi chỉ số vườn đang ổn định 👍", style: TextStyle(fontSize: 15, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildAlertCard(SoilAlert alert) {
    final config = _getAlertConfig(alert.type);

    return Dismissible(
      key: Key(alert.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => _deleteAlert(alert.id),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(20)),
        child: const Icon(Icons.delete_sweep, color: Colors.white, size: 32),
      ),
      child: Card(
        elevation: alert.isRead ? 3 : 8,
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            _markAsRead(alert.id);
            _showAlertDetail(alert);
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: alert.isRead ? null : Border.all(color: config.color.withValues(alpha: 0.4), width: 2),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: config.color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(14)),
                  child: Icon(config.icon, color: config.color, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (!alert.isRead)
                            Container(width: 8, height: 8, margin: const EdgeInsets.only(right: 8), decoration: BoxDecoration(color: config.color, shape: BoxShape.circle)),
                          Expanded(child: Text(alert.title, style: TextStyle(fontSize: 15.5, fontWeight: alert.isRead ? FontWeight.w600 : FontWeight.bold))),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(alert.message, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13.5, color: AppColors.textSecondary, height: 1.4)),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 14, color: Colors.grey.shade400),
                          const SizedBox(width: 4),
                          Text(_formatTime(alert.time), style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: config.color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                            child: Text(config.label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: config.color)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAlertDetail(SoilAlert alert) {
    final config = _getAlertConfig(alert.type);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 24),
            Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: config.color.withValues(alpha: 0.1), shape: BoxShape.circle), child: Icon(config.icon, color: config.color, size: 48)),
            const SizedBox(height: 16),
            Text(alert.title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Text(alert.message, textAlign: TextAlign.center, style: const TextStyle(fontSize: 15.5, color: AppColors.textSecondary, height: 1.6)),
            const SizedBox(height: 24),
            if (alert.actionRoute != null)
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    context.go(alert.actionRoute!);
                  },
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: Text(alert.actionLabel ?? 'Xem chi tiết', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(backgroundColor: config.color, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                ),
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  _AlertConfig _getAlertConfig(AlertType type) {
    return switch (type) {
      AlertType.critical => _AlertConfig(icon: Icons.error_rounded, color: AppColors.error, label: 'Nguy hiểm'),
      AlertType.warning => _AlertConfig(icon: Icons.warning_amber_rounded, color: AppColors.warning, label: 'Cảnh báo'),
      AlertType.success => _AlertConfig(icon: Icons.check_circle_rounded, color: AppColors.primary, label: 'Tốt'),
      AlertType.info => _AlertConfig(icon: Icons.info_rounded, color: AppColors.info, label: 'Thông tin'),
    };
  }
}

enum AlertType { critical, warning, info, success }
enum AlertCategory { phLevel, moisture, nutrients, weather, pests, summary, reminder }

class _AlertConfig {
  final IconData icon;
  final Color color;
  final String label;
  const _AlertConfig({required this.icon, required this.color, required this.label});
}

class SoilAlert {
  final String id, title, message;
  final AlertType type;
  final AlertCategory category;
  final DateTime time;
  final bool isRead;
  final String? actionRoute, actionLabel;

  const SoilAlert({required this.id, required this.title, required this.message, required this.type, required this.category, required this.time, this.isRead = false, this.actionRoute, this.actionLabel});

  SoilAlert copyWith({String? id, String? title, String? message, AlertType? type, AlertCategory? category, DateTime? time, bool? isRead, String? actionRoute, String? actionLabel}) {
    return SoilAlert(id: id ?? this.id, title: title ?? this.title, message: message ?? this.message, type: type ?? this.type, category: category ?? this.category, time: time ?? this.time, isRead: isRead ?? this.isRead, actionRoute: actionRoute ?? this.actionRoute, actionLabel: actionLabel ?? this.actionLabel);
  }
}
