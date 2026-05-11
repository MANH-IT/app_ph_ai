// lib/features/device/device_screen.dart
// QUẢN LÝ THIẾT BỊ ESP32 BLE – KẾT NỐI & THEO DÕI – 2025
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';

class DeviceScreen extends StatefulWidget {
  const DeviceScreen({super.key});

  @override
  State<DeviceScreen> createState() => _DeviceScreenState();
}

class _DeviceScreenState extends State<DeviceScreen> with TickerProviderStateMixin {
  bool _isScanning = false;
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  final List<BleDevice> _connectedDevices = [
    BleDevice(
      id: 'esp32-001',
      name: 'HealthAI Sensor #1',
      macAddress: 'AA:BB:CC:DD:EE:01',
      status: DeviceStatus.connected,
      battery: 87,
      signalStrength: -45,
      firmwareVersion: '1.2.0',
      lastSync: DateTime.now().subtract(const Duration(minutes: 5)),
      sensorType: SensorType.multiSensor,
    ),
  ];

  final List<BleDevice> _availableDevices = [];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _startScan() async {
    if (_isScanning) return;
    setState(() {
      _isScanning = true;
      _availableDevices.clear();
    });
    _pulseController.repeat(reverse: true);

    // Giả lập tìm thiết bị
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() {
      _availableDevices.add(BleDevice(
        id: 'esp32-002',
        name: 'HealthAI Sensor #2',
        macAddress: 'AA:BB:CC:DD:EE:02',
        status: DeviceStatus.available,
        battery: 0,
        signalStrength: -62,
        firmwareVersion: '1.1.0',
        sensorType: SensorType.heartRate,
      ));
    });

    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() {
      _availableDevices.add(BleDevice(
        id: 'esp32-003',
        name: 'HealthAI SpO₂ Band',
        macAddress: 'AA:BB:CC:DD:EE:03',
        status: DeviceStatus.available,
        battery: 0,
        signalStrength: -78,
        firmwareVersion: '1.0.5',
        sensorType: SensorType.spo2,
      ));
    });

    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    _pulseController.stop();
    _pulseController.reset();
    setState(() => _isScanning = false);
  }

  Future<void> _connectDevice(BleDevice device) async {
    setState(() {
      final idx = _availableDevices.indexWhere((d) => d.id == device.id);
      if (idx != -1) _availableDevices[idx] = device.copyWith(status: DeviceStatus.connecting);
    });

    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    setState(() {
      _availableDevices.removeWhere((d) => d.id == device.id);
      _connectedDevices.add(device.copyWith(
        status: DeviceStatus.connected,
        battery: 72,
        lastSync: DateTime.now(),
      ));
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã kết nối ${device.name}'),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _disconnectDevice(BleDevice device) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Ngắt kết nối?', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Bạn có muốn ngắt kết nối với ${device.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _connectedDevices.removeWhere((d) => d.id == device.id);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Đã ngắt ${device.name}'),
                  backgroundColor: AppColors.warning,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Ngắt kết nối'),
          ),
        ],
      ),
    );
  }

  String _signalLabel(int rssi) {
    if (rssi > -50) return 'Rất mạnh';
    if (rssi > -65) return 'Mạnh';
    if (rssi > -75) return 'Trung bình';
    return 'Yếu';
  }

  Color _signalColor(int rssi) {
    if (rssi > -50) return AppColors.primary;
    if (rssi > -65) return AppColors.primaryLight;
    if (rssi > -75) return AppColors.warning;
    return AppColors.error;
  }

  IconData _sensorIcon(SensorType type) {
    return switch (type) {
      SensorType.heartRate => Icons.favorite,
      SensorType.spo2 => Icons.air,
      SensorType.temperature => Icons.thermostat,
      SensorType.bloodPressure => Icons.monitor_heart,
      SensorType.multiSensor => Icons.sensors,
    };
  }

  String _formatLastSync(DateTime? time) {
    if (time == null) return 'Chưa đồng bộ';
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'Vừa xong';
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
    if (diff.inHours < 24) return '${diff.inHours} giờ trước';
    return '${diff.inDays} ngày trước';
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
        title: const Text("Thiết bị", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: AppColors.primaryGradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white),
            tooltip: "Hướng dẫn",
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Bật Bluetooth và đặt thiết bị gần điện thoại để ghép nối'),
                  backgroundColor: AppColors.info,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
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
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // === SCAN BUTTON ===
                _buildScanButton(),
                const SizedBox(height: 24),

                // === THIẾT BỊ ĐÃ KẾT NỐI ===
                _buildSectionTitle('Thiết bị đã kết nối', Icons.bluetooth_connected, _connectedDevices.length),
                const SizedBox(height: 12),
                if (_connectedDevices.isEmpty)
                  _buildEmptyConnected()
                else
                  ..._connectedDevices.map(_buildConnectedCard),

                const SizedBox(height: 28),

                // === THIẾT BỊ KHẢ DỤNG ===
                if (_isScanning || _availableDevices.isNotEmpty) ...[
                  _buildSectionTitle('Thiết bị tìm thấy', Icons.bluetooth_searching, _availableDevices.length),
                  const SizedBox(height: 12),
                  if (_isScanning && _availableDevices.isEmpty)
                    _buildScanningIndicator()
                  else
                    ..._availableDevices.map(_buildAvailableCard),
                ],

                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScanButton() {
    return Card(
      elevation: 10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: _isScanning ? null : _startScan,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              colors: _isScanning ? AppColors.secondaryGradient : AppColors.primaryGradient,
            ),
          ),
          child: Row(
            children: [
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (_, child) => Transform.scale(
                  scale: _isScanning ? _pulseAnimation.value : 1.0,
                  child: child,
                ),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isScanning ? Icons.bluetooth_searching : Icons.bluetooth,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isScanning ? "Đang tìm kiếm..." : "Tìm thiết bị mới",
                      style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _isScanning ? "Vui lòng đợi..." : "Nhấn để quét thiết bị ESP32 xung quanh",
                      style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.8)),
                    ),
                  ],
                ),
              ),
              if (_isScanning)
                const SizedBox(
                  width: 24, height: 24,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                )
              else
                const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, int count) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 22),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text('$count', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary)),
        ),
      ],
    );
  }

  Widget _buildEmptyConnected() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          children: [
            Icon(Icons.bluetooth_disabled, size: 56, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text("Chưa có thiết bị nào", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
            const SizedBox(height: 6),
            Text("Nhấn 'Tìm thiết bị mới' để bắt đầu", style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
          ],
        ),
      ),
    );
  }

  Widget _buildScanningIndicator() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          children: [
            const SizedBox(
              width: 48, height: 48,
              child: CircularProgressIndicator(strokeWidth: 3, color: AppColors.primary),
            ),
            const SizedBox(height: 16),
            const Text("Đang quét...", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
            const SizedBox(height: 6),
            Text("Tìm thiết bị BLE xung quanh", style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectedCard(BleDevice device) {
    return Card(
      elevation: 8,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 1.5),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(_sensorIcon(device.sensorType), color: AppColors.primary, size: 30),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(device.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(device.macAddress, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
                      const SizedBox(width: 6),
                      const Text('Kết nối', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Info row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _infoChip(Icons.battery_std, '${device.battery}%', device.battery > 20 ? AppColors.primary : AppColors.error),
                _infoChip(Icons.signal_cellular_alt, _signalLabel(device.signalStrength), _signalColor(device.signalStrength)),
                _infoChip(Icons.system_update, 'v${device.firmwareVersion}', AppColors.info),
                _infoChip(Icons.sync, _formatLastSync(device.lastSync), AppColors.textSecondary),
              ],
            ),
            const SizedBox(height: 12),
            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Đang đồng bộ dữ liệu...'),
                          backgroundColor: AppColors.primary,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      );
                    },
                    icon: const Icon(Icons.sync, size: 18),
                    label: const Text('Đồng bộ'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _disconnectDevice(device),
                    icon: const Icon(Icons.link_off, size: 18),
                    label: const Text('Ngắt'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailableCard(BleDevice device) {
    final isConnecting = device.status == DeviceStatus.connecting;

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(_sensorIcon(device.sensorType), color: Colors.grey.shade600, size: 26),
        ),
        title: Text(device.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(device.macAddress, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.signal_cellular_alt, size: 14, color: _signalColor(device.signalStrength)),
                const SizedBox(width: 4),
                Text(_signalLabel(device.signalStrength), style: TextStyle(fontSize: 12, color: _signalColor(device.signalStrength))),
              ],
            ),
          ],
        ),
        trailing: isConnecting
            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5))
            : ElevatedButton(
                onPressed: () => _connectDevice(device),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
                child: const Text('Kết nối', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String text, Color color) {
    return Column(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(height: 4),
        Text(text, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
      ],
    );
  }
}

// === DATA MODELS ===

enum DeviceStatus { available, connecting, connected, disconnected }
enum SensorType { heartRate, spo2, temperature, bloodPressure, multiSensor }

class BleDevice {
  final String id;
  final String name;
  final String macAddress;
  final DeviceStatus status;
  final int battery;
  final int signalStrength;
  final String firmwareVersion;
  final DateTime? lastSync;
  final SensorType sensorType;

  const BleDevice({
    required this.id,
    required this.name,
    required this.macAddress,
    required this.status,
    required this.battery,
    required this.signalStrength,
    required this.firmwareVersion,
    this.lastSync,
    required this.sensorType,
  });

  BleDevice copyWith({
    String? id,
    String? name,
    String? macAddress,
    DeviceStatus? status,
    int? battery,
    int? signalStrength,
    String? firmwareVersion,
    DateTime? lastSync,
    SensorType? sensorType,
  }) {
    return BleDevice(
      id: id ?? this.id,
      name: name ?? this.name,
      macAddress: macAddress ?? this.macAddress,
      status: status ?? this.status,
      battery: battery ?? this.battery,
      signalStrength: signalStrength ?? this.signalStrength,
      firmwareVersion: firmwareVersion ?? this.firmwareVersion,
      lastSync: lastSync ?? this.lastSync,
      sensorType: sensorType ?? this.sensorType,
    );
  }
}
