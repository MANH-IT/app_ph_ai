// lib/features/profile/profile_screen.dart
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../dashboard/dashboard_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? initialData;
  const ProfileScreen({super.key, this.initialData});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtr = TextEditingController();
  final _areaCtr = TextEditingController();
  final _treeCountCtr = TextEditingController();
  final _customHistoryCtr = TextEditingController();
  final _customNoteCtr = TextEditingController();

  int? _day, _month, _year;

  bool _isAcidSoil = false;
  bool _isSalineSoil = false;
  bool _isOrganic = true;
  bool _useDripIrrigation = false;
  bool _useGreenhouse = false;
  bool _hasPestHistory = false;

  XFile? _avatar;
  bool _saving = false;

  final List<DeviceInfo> _devices = [
    DeviceInfo(id: 'esp32-soil-01', name: 'Cảm biến Khu A', online: true, battery: 87, fwVersion: '2.1.0'),
    DeviceInfo(id: 'esp32-soil-02', name: 'Cảm biến Khu B', online: false, battery: 0, fwVersion: '2.0.5'),
  ];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() {
    final data = widget.initialData ?? {};
    _nameCtr.text = data['name']?.toString().trim() ?? 'Vườn của tôi';
    _areaCtr.text = data['area']?.toString() ?? '1000';
    _treeCountCtr.text = data['treeCount']?.toString() ?? '50';

    if (data['startDate'] is DateTime) {
      final start = data['startDate'] as DateTime;
      _day = start.day; _month = start.month; _year = start.year;
    } else {
      final now = DateTime.now();
      _day = now.day; _month = now.month; _year = now.year;
    }

    _isAcidSoil = data['isAcidSoil'] == true;
    _isSalineSoil = data['isSalineSoil'] == true;
    _isOrganic = data['isOrganic'] ?? true;
    _useDripIrrigation = data['useDripIrrigation'] == true;

    _customHistoryCtr.text = data['soilHistory'] ?? '';
    _customNoteCtr.text = data['notes'] ?? '';
  }

  double get _landIndex {
    final area = double.tryParse(_areaCtr.text.replaceAll(',', '.')) ?? 0.0;
    final trees = double.tryParse(_treeCountCtr.text.replaceAll(',', '.')) ?? 0.0;
    if (area <= 0 || trees <= 0) return 0.0;
    // Chỉ số mật độ canh tác (cây/100m2)
    final index = (trees / area) * 100;
    return double.parse(index.toStringAsFixed(1));
  }

  Future<void> _pickAvatar() async {
    try {
      final file = await ImagePicker().pickImage(source: ImageSource.camera, imageQuality: 80);
      if (file == null || !mounted) return;
      setState(() => _avatar = file);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Không thể mở camera')));
    }
  }

  Future<void> _saveAndSync() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    await Future.delayed(const Duration(seconds: 1, milliseconds: 500));
    if (!mounted) return;
    setState(() => _saving = false);
    HapticFeedback.mediumImpact();

    if (mounted) {
      final area = double.tryParse(_areaCtr.text.replaceAll(',', '.')) ?? 0.0;
      final trees = double.tryParse(_treeCountCtr.text.replaceAll(',', '.')) ?? 0.0;
      
      final updatedProfile = UserProfile(
        name: _nameCtr.text.trim().isNotEmpty ? _nameCtr.text.trim() : 'Chủ vườn',
        treeCount: trees.toInt(),
        area: area,
        density: _landIndex,
        performance: _landIndex,
        isAcidSoil: _isAcidSoil,
        isSalineSoil: _isSalineSoil,
        isOrganic: _isOrganic,
      );

      ref.read(dashboardProvider.notifier).updateUserProfile(updatedProfile);

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã cập nhật hồ sơ vườn thành công!')));
      context.go('/dashboard');
    }
  }

  @override
  void dispose() {
    _nameCtr.dispose(); _areaCtr.dispose(); _treeCountCtr.dispose();
    _customHistoryCtr.dispose(); _customNoteCtr.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 26),
          onPressed: () => context.go('/dashboard'),
        ),
        title: const Text('Hồ sơ Khu vườn', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
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
        decoration: const BoxDecoration(color: Color(0xFFF1F8E9)),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildHeader(),
                  const SizedBox(height: 20),
                  _buildBasicInfoCard(),
                  const SizedBox(height: 20),
                  _buildSoilHabitsCard(),
                  const SizedBox(height: 20),
                  _buildDevicesCard(),
                  const SizedBox(height: 30),
                  _buildSaveButton(),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() => Row(
    children: [
      GestureDetector(
        onTap: _pickAvatar,
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(colors: [Colors.green, Colors.lime]),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: CircleAvatar(
            radius: 52,
            backgroundColor: Colors.white,
            backgroundImage: _avatar != null ? FileImage(File(_avatar!.path)) : null,
            child: _avatar == null ? const Icon(Icons.grass, size: 56, color: Colors.green) : null,
          ),
        ),
      ),
      const SizedBox(width: 20),
      Expanded(
        child: TextFormField(
          controller: _nameCtr,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green),
          decoration: const InputDecoration(
            labelText: 'Tên khu vườn / Chủ vườn',
            labelStyle: TextStyle(color: Colors.green),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.green)),
          ),
          validator: (v) => v?.trim().isEmpty ?? true ? 'Vui lòng nhập tên' : null,
        ),
      ),
    ],
  );

  Widget _buildBasicInfoCard() => Card(
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Thông số canh tác', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _areaCtr,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Diện tích (m2)', border: OutlineInputBorder()),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _treeCountCtr,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Số gốc cây', border: OutlineInputBorder()),
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Text('Mật độ: ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text(_landIndex.toStringAsFixed(1), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.green)),
              const Text(' cây/100m2', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ],
      ),
    ),
  );

  Widget _buildSoilHabitsCard() => Card(
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Đặc điểm đất & Kỹ thuật', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
          const SizedBox(height: 16),
          Wrap(spacing: 8, runSpacing: 8, children: [
            _chip('Đất phèn', _isAcidSoil, (v) => setState(() => _isAcidSoil = v!)),
            _chip('Đất mặn', _isSalineSoil, (v) => setState(() => _isSalineSoil = v!)),
            _chip('Canh tác hữu cơ', _isOrganic, (v) => setState(() => _isOrganic = v!)),
            _chip('Tưới nhỏ giọt', _useDripIrrigation, (v) => setState(() => _useDripIrrigation = v!)),
            _chip('Trong nhà màng', _useGreenhouse, (v) => setState(() => _useGreenhouse = v!)),
            _chip('Tiền sử sâu bệnh', _hasPestHistory, (v) => setState(() => _hasPestHistory = v!)),
          ]),
          const SizedBox(height: 16),
          TextFormField(
            controller: _customHistoryCtr,
            maxLines: 2,
            decoration: const InputDecoration(labelText: 'Ghi chú thổ nhưỡng', border: OutlineInputBorder()),
          ),
        ],
      ),
    ),
  );

  Widget _chip(String label, bool selected, ValueChanged<bool?> onSelected) => FilterChip(
    label: Text(label, style: TextStyle(fontSize: 12, color: selected ? Colors.white : Colors.black)),
    selected: selected,
    onSelected: onSelected,
    selectedColor: Colors.green,
    checkmarkColor: Colors.white,
    backgroundColor: Colors.grey.shade100,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
  );

  Widget _buildDevicesCard() => Card(
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Trạm cảm biến kết nối', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
          const SizedBox(height: 16),
          ..._devices.map((d) => ListTile(
            leading: Icon(d.online ? Icons.sensors : Icons.sensors_off, color: d.online ? Colors.green : Colors.grey),
            title: Text(d.name),
            subtitle: Text('Pin: ${d.battery}% • FW ${d.fwVersion}'),
            trailing: d.online ? const Icon(Icons.check_circle, color: Colors.green, size: 16) : null,
          )),
        ],
      ),
    ),
  );

  Widget _buildSaveButton() => SizedBox(
    width: double.infinity,
    height: 56,
    child: ElevatedButton(
      onPressed: _saving ? null : _saveAndSync,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: _saving ? const CircularProgressIndicator(color: Colors.white) : const Text('LƯU HỒ SƠ VƯỜN', style: TextStyle(fontWeight: FontWeight.bold)),
    ),
  );
}

class DeviceInfo {
  final String id, name;
  final bool online;
  final int battery;
  final String fwVersion;
  const DeviceInfo({required this.id, required this.name, required this.online, required this.battery, required this.fwVersion});
}