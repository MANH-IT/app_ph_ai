// lib/features/history/history_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart'; 

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/soil_provider.dart';
import '../../models/soil_record_model.dart' as model;

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordsAsync = ref.watch(soilRecordsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Lịch sử đo", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: LinearGradient(colors: AppColors.primaryGradient)),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => context.go('/dashboard'),
          tooltip: "Về trang chủ",
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Bộ lọc theo ngày/tuần/tháng – Sắp có!")),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: AppColors.backgroundGradient,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: recordsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text("Lỗi: $err")),
          data: (records) => records.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.terrain, size: 80, color: Colors.grey),
                      SizedBox(height: 16),
                      Text("Chưa có dữ liệu đo đất", style: TextStyle(fontSize: 18, color: Colors.grey)),
                      Text("Hãy bắt đầu đo để theo dõi dinh dưỡng đất!", style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: records.length,
                  itemBuilder: (context, index) {
                    final record = records[index];
                    return _buildHistoryCard(context, record);
                  },
                ),
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        elevation: 8,
        onPressed: () => context.go('/dashboard'),
        icon: const Icon(Icons.add_chart, color: Colors.white),
        label: const Text("Đo mới ngay", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildHistoryCard(BuildContext context, model.SoilRecord record) {
    final statusColor = _getStatusColor(record);
    final statusText = _getStatusText(record);

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [Colors.white, Colors.grey.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ExpansionTile(
          leading: CircleAvatar(
            radius: 22,
            backgroundColor: statusColor.withValues(alpha: 0.2),
            child: Icon(
              record.phLevel < 5.0 || record.phLevel > 8.0 ? Icons.warning_amber : Icons.terrain,
              color: statusColor,
              size: 26,
            ),
          ),
          title: Text(
            DateFormat('dd/MM, HH:mm').format(record.timestamp),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.5),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              "Tình trạng: $statusText",
              style: TextStyle(color: statusColor, fontWeight: FontWeight.w600),
            ),
          ),
          trailing: const Icon(Icons.keyboard_arrow_down, size: 28),
          childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          children: [
            _buildInfoRow(
              Icons.location_on, 
              "Vị trí", 
              record.locationName ?? "Không xác định", 
              Colors.brown,
            ),
            const Divider(height: 16),
            _buildInfoRow(
              Icons.map, 
              "GPS", 
              (record.latitude != null && record.longitude != null) 
                  ? "${record.latitude!.toStringAsFixed(4)}, ${record.longitude!.toStringAsFixed(4)}" 
                  : "--", 
              Colors.blueGrey,
            ),
            const Divider(height: 16),
            _buildInfoRow(Icons.grass, "Nitơ (N)", "${record.nitrogen.toStringAsFixed(1)} mg/kg", Colors.green),
            const Divider(height: 24),
            _buildInfoRow(Icons.agriculture, "Lân (P)", "${record.phosphorus.toStringAsFixed(1)} mg/kg", Colors.orange),
            const Divider(height: 24),
            _buildInfoRow(
              Icons.water_drop, 
              "Kali (K)", 
              "${record.potassium.toStringAsFixed(1)} mg/kg", 
              Colors.blue,
            ),
            const Divider(height: 16),
            _buildInfoRow(
              Icons.opacity, 
              "Độ ẩm", 
              "${record.moisture.toStringAsFixed(1)}%", 
              AppColors.primaryLight,
            ),
            const Divider(height: 16),
            _buildInfoRow(
              Icons.science, 
              "pH Đất", 
              record.phLevel.toStringAsFixed(1), 
              AppColors.primaryAccent,
            ),
            const SizedBox(height: 12),
            Text(
              "Đo lúc: ${DateFormat('HH:mm, EEEE, dd/MM/yyyy').format(record.timestamp)}",
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }

  String _getStatusText(model.SoilRecord record) {
    if (record.phLevel < 5.0 || record.phLevel > 8.0 || record.moisture < 20) return "Cần chăm sóc";
    if (record.phLevel < 5.5 || record.phLevel > 7.5) return "Bình thường";
    return "Tốt";
  }

  Color _getStatusColor(model.SoilRecord record) {
    if (record.phLevel < 5.0 || record.phLevel > 8.0 || record.moisture < 20) return Colors.red;
    if (record.phLevel < 5.5 || record.phLevel > 7.5) return Colors.orange;
    return Colors.green;
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Icon(icon, size: 30, color: color),
        const SizedBox(width: 16),
        Expanded(
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
        ),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: color)),
      ],
    );
  }
}