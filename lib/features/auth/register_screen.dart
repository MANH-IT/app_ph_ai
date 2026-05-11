// lib/features/auth/register_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';
import '../dashboard/dashboard_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});
  
  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> with TickerProviderStateMixin {
  final _formKeyStep1 = GlobalKey<FormState>();
  final _formKeyStep2 = GlobalKey<FormState>();
  int _step = 1;

  final _phoneCtr = TextEditingController();
  final _passwordCtr = TextEditingController();
  final _confirmPwdCtr = TextEditingController();

  bool _otpSent = false;
  int _otpSecondsLeft = 300;
  Timer? _otpTimer;
  final _otpCtr = TextEditingController();
  bool _verifyingOtp = false;
  bool _isRegistering = false;

  final _nameCtr = TextEditingController();
  String? _province;
  double _area = 1000;
  double _treeCount = 50;
  final List<String> _crops = [];

  late final AnimationController _slideController;
  late final Animation<Offset> _slideAnim;

  final List<String> provinces = const [
    'TP Hà Nội', 'TP Hồ Chí Minh', 'TP Hải Phòng', 'TP Đà Nẵng', 'TP Cần Thơ',
    'Tỉnh An Giang', 'Tỉnh Bà Rịa - Vũng Tàu', 'Tỉnh Bắc Giang', 'Tỉnh Bắc Kạn',
    'Tỉnh Bạc Liêu', 'Tỉnh Bắc Ninh', 'Tỉnh Bến Tre', 'Tỉnh Bình Định',
    'Tỉnh Bình Dương', 'Tỉnh Bình Phước', 'Tỉnh Bình Thuận', 'Tỉnh Cà Mau',
    'Tỉnh Cao Bằng', 'Tỉnh Đắk Lắk', 'Tỉnh Đắk Nông', 'Tỉnh Điện Biên',
    'Tỉnh Đồng Nai', 'Tỉnh Đồng Tháp', 'Tỉnh Gia Lai', 'Tỉnh Hà Giang',
    'Tỉnh Hà Nam', 'Tỉnh Hà Tĩnh', 'Tỉnh Hải Dương', 'Tỉnh Hậu Giang',
    'Tỉnh Hòa Bình', 'Tỉnh Hưng Yên', 'Tỉnh Khánh Hòa', 'Tỉnh Kiên Giang',
    'Tỉnh Kon Tum', 'Tỉnh Lai Châu', 'Tỉnh Lâm Đồng', 'Tỉnh Lạng Sơn',
    'Tỉnh Lào Cai', 'Tỉnh Long An', 'Tỉnh Nam Định', 'Tỉnh Nghệ An',
    'Tỉnh Ninh Bình', 'Tỉnh Ninh Thuận', 'Tỉnh Phú Thọ', 'Tỉnh Phú Yên',
    'Tỉnh Quảng Bình', 'Tỉnh Quảng Nam', 'Tỉnh Quảng Ngãi', 'Tỉnh Quảng Ninh',
    'Tỉnh Quảng Trị', 'Tỉnh Sóc Trăng', 'Tỉnh Sơn La', 'Tỉnh Tây Ninh',
    'Tỉnh Thái Bình', 'Tỉnh Thái Nguyên', 'Tỉnh Thanh Hóa', 'Tỉnh Thừa Thiên Huế',
    'Tỉnh Tiền Giang', 'Tỉnh Trà Vinh', 'Tỉnh Tuyên Quang', 'Tỉnh Vĩnh Long',
    'Tỉnh Vĩnh Phúc', 'Tỉnh Yên Bái',
  ];

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _slideAnim = Tween<Offset>(begin: const Offset(1.0, 0), end: Offset.zero)
        .animate(CurvedAnimation(parent: _slideController, curve: Curves.easeInOut));
    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _otpTimer?.cancel();
    _phoneCtr.dispose(); 
    _passwordCtr.dispose(); 
    _confirmPwdCtr.dispose();
    _otpCtr.dispose(); 
    _nameCtr.dispose(); 
    super.dispose();
  }

  String _normalizePhone(String p) {
    var s = p.trim().replaceAll(RegExp(r'[^0-9+]'), '');
    if (s.startsWith('0')) s = '+84${s.substring(1)}';
    if (!s.startsWith('+84')) s = '+84$s';
    return s;
  }

  bool _validatePhone(String p) => RegExp(r'^\+84\d{9}$').hasMatch(_normalizePhone(p));

  void _startOtpCountdown() {
    _otpTimer?.cancel();
    setState(() { _otpSecondsLeft = 300; _otpSent = true; });
    _otpTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_otpSecondsLeft <= 0) {
        t.cancel();
        if (mounted) setState(() => _otpSent = false);
      } else {
        if (mounted) setState(() => _otpSecondsLeft--);
      }
    });
  }

  Future<void> _sendOtp() async {
    if (!_validatePhone(_phoneCtr.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Số điện thoại phải đúng định dạng +84xxxxxxxxx')),
      );
      return;
    }
    _startOtpCountdown();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã gửi mã OTP (demo)'), backgroundColor: AppColors.primary),
    );
  }

  Future<void> _verifyOtpAndNext() async {
    if (_otpCtr.text.trim().length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('OTP phải 6 số')));
      return;
    }
    setState(() => _verifyingOtp = true);
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => _verifyingOtp = false);
    _goToStep(2);
  }

  void _goToStep(int step) {
    if (_step == step) return;
    _slideController.value = 0;
    setState(() => _step = step);
    _slideController.forward();
  }

  double get _density => (_treeCount / _area) * 100;
  
  Color get _densityColor => switch (_density) {
    < 2 => Colors.orange.shade700,
    < 10 => AppColors.primaryLight,
    < 30 => Colors.orange,
    _ => AppColors.error,
  };
  
  String get _densityLabel => switch (_density) {
    < 2 => 'Thưa thớt',
    < 10 => 'Lý tưởng',
    < 30 => 'Dày',
    _ => 'Quá dày',
  };

  Future<void> _submitProfile() async {
    if (!_formKeyStep2.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập đầy đủ thông tin vườn')),
      );
      return;
    }

    final profileData = {
      'name': _nameCtr.text.trim(),
      'phone': _normalizePhone(_phoneCtr.text),
      'province': _province ?? '',
      'area': _area,
      'treeCount': _treeCount.toInt(),
      'density': _density,
      'crops': _crops,
    };

    setState(() => _isRegistering = true);
    
    final String phoneBase = _normalizePhone(_phoneCtr.text).replaceAll('+', '');
    final String fakeEmail = '$phoneBase@agritechai.com';
    
    final authRepo = ref.read(authRepositoryProvider);
    
    UserModel? userModel;
    try {
      userModel = await authRepo.signUp(
        fakeEmail, 
        _passwordCtr.text,
        _nameCtr.text.trim(),
      );
    } catch (e) {
      debugPrint('Lỗi signUp: $e');
    }

    if (!mounted) return;
    setState(() => _isRegistering = false);

    if (userModel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đăng ký thất bại: Số điện thoại này đã tồn tại.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // Cập nhật UserProfile trong DashboardProvider
    final updatedProfile = UserProfile(
      name: _nameCtr.text.trim(),
      treeCount: _treeCount.toInt(),
      area: _area,
      density: _density,
      performance: _density,
      isOrganic: true,
    );
    ref.read(dashboardProvider.notifier).updateUserProfile(updatedProfile);

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Chào mừng Nhà nông!', style: TextStyle(color: AppColors.primary)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Khởi tạo hồ sơ vườn thành công!'),
          const SizedBox(height: 12),
          Text('Mật độ: ${_density.toStringAsFixed(1)} cây/100m2 - $_densityLabel', 
            style: TextStyle(color: _densityColor, fontWeight: FontWeight.bold)),
        ]),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Vào Dashboard', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      context.go('/dashboard');
    }
  }

  void _handleNext() {
    if (_step == 1) {
      if (!_formKeyStep1.currentState!.validate()) return;
      _otpSent ? _verifyOtpAndNext() : _sendOtp();
    } else {
      _submitProfile();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: AppColors.primaryGradientExtended,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20, 30, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 32),
                _buildProgressBar(),
                const SizedBox(height: 24),
                SlideTransition(
                  position: _slideAnim,
                  child: Card(
                    elevation: 12,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: _step == 1 ? _buildStep1() : _buildStep2(),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                _buildNavigationButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(children: [
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white, 
          borderRadius: BorderRadius.circular(16), 
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 12, offset: const Offset(0, 6))
          ]
        ),
        child: const Icon(Icons.agriculture, color: AppColors.primary, size: 40),
      ),
      const SizedBox(width: 16),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Khởi tạo Hồ sơ Nhà nông', 
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)
          ),
          const Text('Chỉ mất 1 phút • Dữ liệu được mã hóa', 
            style: TextStyle(fontSize: 13, color: Colors.white70)
          ),
        ]),
      ),
    ]);
  }

  Widget _buildProgressBar() {
    return Row(children: [
      Expanded(
        child: LinearProgressIndicator(
          value: _step == 1 ? 0.5 : 1.0,
          backgroundColor: Colors.white24,
          valueColor: const AlwaysStoppedAnimation(AppColors.primaryLight),
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      const SizedBox(width: 12),
      Text('Bước $_step/2', 
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)
      ),
    ]);
  }

  Widget _buildNavigationButtons() {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      TextButton(
        onPressed: _step == 1 ? () => context.go('/') : () => _goToStep(1),
        child: Text(_step == 1 ? 'Hủy' : 'Quay lại', 
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)
        ),
      ),
      ElevatedButton(
        onPressed: (_verifyingOtp || _isRegistering) ? null : _handleNext,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryLight,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          elevation: 8,
        ),
        child: (_verifyingOtp || _isRegistering)
            ? const SizedBox(width: 20, height: 20, 
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3)
              )
            : Text(_step == 1 ? (_otpSent ? 'Xác minh OTP' : 'Gửi mã OTP') : 'Hoàn tất đăng ký', 
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
              ),
      ),
    ]);
  }

  Widget _buildStep1() => Form(
    key: _formKeyStep1,
    child: Column(children: [
      const Text('Thông tin đăng nhập', 
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)
      ),
      const SizedBox(height: 20),
      TextFormField(
        controller: _phoneCtr,
        keyboardType: TextInputType.phone,
        decoration: InputDecoration(
          labelText: 'Số điện thoại',
          hintText: '+84 9xxx xxx xx',
          prefixIcon: Icon(Icons.phone_android, color: AppColors.primary),
          filled: true,
          fillColor: AppColors.surfaceVariant,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        ),
        validator: (v) => _validatePhone(v ?? '') ? null : 'Số điện thoại không hợp lệ',
      ),
      const SizedBox(height: 16),
      Row(children: [
        Expanded(child: TextFormField(
          controller: _passwordCtr,
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'Mật khẩu',
            prefixIcon: Icon(Icons.lock_outline, color: AppColors.primary),
            filled: true,
            fillColor: AppColors.surfaceVariant,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          ),
          validator: (v) => v?.length == null || v!.length < 6 ? 'Mật khẩu ≥ 6 ký tự' : null,
        )),
        const SizedBox(width: 12),
        Expanded(child: TextFormField(
          controller: _confirmPwdCtr,
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'Xác nhận',
            prefixIcon: Icon(Icons.lock_outline, color: AppColors.primary),
            filled: true,
            fillColor: AppColors.surfaceVariant,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          ),
          validator: (v) => v == _passwordCtr.text ? null : 'Mật khẩu không khớp',
        )),
      ]),
      if (_otpSent) ...[
        const SizedBox(height: 20),
        TextFormField(
          controller: _otpCtr,
          keyboardType: TextInputType.number,
          maxLength: 6,
          decoration: InputDecoration(
            labelText: 'Mã OTP (6 số)',
            prefixIcon: Icon(Icons.sms, color: AppColors.primary),
            filled: true,
            fillColor: AppColors.surfaceVariant,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            counterText: '${(_otpSecondsLeft ~/ 60).toString().padLeft(2, '0')}:${(_otpSecondsLeft % 60).toString().padLeft(2, '0')}',
          ),
        ),
      ],
      const SizedBox(height: 24),
      const Text('Hoặc đăng ký nhanh qua mạng xã hội', style: TextStyle(color: Colors.black54, fontSize: 12)),
      const SizedBox(height: 12),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        _socialIcon(Icons.g_mobiledata),
        _socialIcon(Icons.apple),
        _socialIcon(Icons.message),
      ]),
    ]),
  );

  Widget _socialIcon(IconData icon) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 10),
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
      child: Icon(icon, color: AppColors.primary),
    ),
  );

  Widget _buildStep2() => Form(
    key: _formKeyStep2,
    child: Column(children: [
      const Text('Hồ sơ Khu vườn', 
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)
      ),
      const SizedBox(height: 20),

      TextFormField(
        controller: _nameCtr,
        decoration: InputDecoration(
          labelText: 'Tên chủ vườn / Tên vườn',
          prefixIcon: Icon(Icons.person_outline, color: AppColors.primary),
          filled: true,
          fillColor: AppColors.surfaceVariant,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        ),
        validator: (v) => v?.trim().isEmpty ?? true ? 'Vui lòng nhập tên' : null,
      ),
      const SizedBox(height: 16),

      DropdownButtonFormField<String>(
        value: _province,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: 'Vị trí (Tỉnh / Thành)', 
          filled: true, 
          fillColor: AppColors.surfaceVariant, 
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none)
        ),
        items: provinces.map((p) => DropdownMenuItem(value: p, child: Text(p, overflow: TextOverflow.ellipsis))).toList(),
        onChanged: (v) => setState(() => _province = v),
        validator: (v) => v == null ? 'Chọn địa điểm' : null,
      ),

      const SizedBox(height: 20),
      Row(children: [
        const Text('Diện tích canh tác (m2): ', style: TextStyle(fontWeight: FontWeight.w600)),
        Text(_area.round().toString(), style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
      ]),
      Slider(
        value: _area, min: 100, max: 10000, divisions: 99, 
        onChanged: (v) => setState(() => _area = v), activeColor: AppColors.primaryLight
      ),
      
      Row(children: [
        const Text('Số lượng gốc cây: ', style: TextStyle(fontWeight: FontWeight.w600)),
        Text(_treeCount.round().toString(), style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
      ]),
      Slider(
        value: _treeCount, min: 10, max: 2000, divisions: 199, 
        onChanged: (v) => setState(() => _treeCount = v), activeColor: AppColors.primaryLight
      ),

      const SizedBox(height: 20),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
        child: Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Mật độ canh tác', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('${_density.toStringAsFixed(1)} cây/100m2', 
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary)),
          ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            const Text('Đánh giá', style: TextStyle(fontSize: 12)),
            Text(_densityLabel, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _densityColor)),
          ]),
        ]),
      ),

      const SizedBox(height: 20),
      const Align(alignment: Alignment.centerLeft, child: Text('Loại cây chủ lực:', style: TextStyle(fontWeight: FontWeight.w600))),
      const SizedBox(height: 10),
      Wrap(spacing: 8, children: ['Lúa', 'Cà phê', 'Sầu riêng', 'Hồ tiêu', 'Bơ'].map((c) {
        final sel = _crops.contains(c);
        return FilterChip(
          label: Text(c), selected: sel,
          onSelected: (v) => setState(() => v ? _crops.add(c) : _crops.remove(c)),
          selectedColor: AppColors.primaryLight.withValues(alpha: 0.2),
          checkmarkColor: AppColors.primary,
        );
      }).toList()),
      
      const SizedBox(height: 20),
    ]),
  );
}