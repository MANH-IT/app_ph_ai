// lib/features/onboarding/onboarding_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart'; 

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});
  
  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscure = true;
  bool _isFaceScanning = false;
  bool _isLoggingIn = false;

  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _startFaceLogin() async {
    if (_isFaceScanning) return;
    setState(() => _isFaceScanning = true);
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    setState(() => _isFaceScanning = false);
    context.go('/dashboard');
  }

  void _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoggingIn = true);
    
    final String email = _phoneController.text.trim();
    // Chuẩn hóa email nếu người dùng nhập số điện thoại
    final String loginEmail = email.contains('@') ? email : '${email.replaceAll('+', '')}@agritechai.com';
    
    // Gọi AuthRepository để đăng nhập thực tế
    final authRepo = ref.read(authRepositoryProvider);
    final user = await authRepo.signIn(
      loginEmail,
      _passwordController.text,
    );
    
    if (!mounted) return;
    setState(() => _isLoggingIn = false);

    if (user != null) {
      ref.read(currentUserProvider.notifier).state = user;
      context.go('/dashboard');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đăng nhập thất bại: Sai thông tin hoặc tài khoản không tồn tại!'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Widget _buildIntroPage(IconData icon, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.background,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.1), 
                  blurRadius: 20
                )
              ],
            ),
            child: Icon(icon, size: 100, color: AppColors.primary),
          ),
          const SizedBox(height: 60),
          Text(
            title, 
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28, 
              fontWeight: FontWeight.bold, 
              color: Color(0xFF2E7D32), 
              height: 1.2
            ),
          ),
          const SizedBox(height: 20),
          Text(
            desc, 
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16, 
              color: Colors.grey.shade700, 
              height: 1.5
            ),
          ),
        ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              // Logo placeholder
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.28,
                child: Image.asset(
                  'assets/icons/logo2.png',
                  height: MediaQuery.of(context).size.height * 0.28,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.agriculture,
                      size: 120,
                      color: AppColors.primary,
                    );
                  },
                ),
              ),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'Số điện thoại',
                        hintText: '+84 9xxx xxx xx',
                        prefixIcon: Icon(Icons.phone_android, color: AppColors.primary),
                        filled: true,
                        fillColor: AppColors.surfaceVariant,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16), 
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (v) => v?.trim().isEmpty == true ? 'Vui lòng nhập số điện thoại' : null,
                    ),
                    const SizedBox(height: 12),
                    
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscure,
                      decoration: InputDecoration(
                        labelText: 'Mật khẩu',
                        prefixIcon: Icon(Icons.lock_outline, color: AppColors.primary),
                        suffixIcon: IconButton(
                          icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                        filled: true,
                        fillColor: AppColors.surfaceVariant,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16), 
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (v) => v?.isEmpty == true ? 'Vui lòng nhập mật khẩu' : null,
                    ),
                    
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Tính năng quên mật khẩu đang phát triển'),
                              backgroundColor: AppColors.primary,
                            ),
                          );
                        },
                        child: Text(
                          "Quên mật khẩu?", 
                          style: TextStyle(
                            color: AppColors.primary, 
                            fontWeight: FontWeight.w600
                          ),
                        ),
                      ),
                    ),
                    
                    if (!_isFaceScanning)
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: _startFaceLogin,
                          icon: const Icon(Icons.face_retouching_natural, size: 24),
                          label: const Text("Đăng nhập bằng khuôn mặt", 
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryDark,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)
                            ),
                            elevation: 2,
                          ),
                        ),
                      )
                    else
                      Column(
                        children: [
                          const Icon(Icons.face, size: 80, color: AppColors.primary),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(color: AppColors.primary),
                        ],
                      ),
                    const SizedBox(height: 16),
                    
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoggingIn ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryLight,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)
                          ),
                          elevation: 4,
                        ),
                        child: _isLoggingIn
                            ? const SizedBox(
                                height: 24, 
                                width: 24, 
                                child: CircularProgressIndicator(
                                  color: Colors.white, 
                                  strokeWidth: 3
                                )
                              )
                            : const Text(
                                "Đăng nhập", 
                                style: TextStyle(
                                  fontSize: 18, 
                                  fontWeight: FontWeight.bold, 
                                  color: Colors.white
                                )
                              ),
                      ),
                    ),
                    
                    TextButton(
                      onPressed: () => context.go('/register'),
                      child: const Text(
                        "Chưa có tài khoản? Đăng ký", 
                        style: TextStyle(color: AppColors.primary, fontSize: 14)
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    const Text(
                      'Hoặc tiếp tục với',
                      style: TextStyle(color: Colors.black54),
                    ),
                    const SizedBox(height: 12),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _socialIcon(Icons.g_mobiledata, 'Google'),
                        _socialIcon(Icons.apple, 'Apple'),
                        _socialIcon(Icons.message, 'Zalo'),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _socialIcon(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đăng nhập bằng $label đang phát triển'),
              backgroundColor: AppColors.primary,
            ),
          );
        },
        borderRadius: BorderRadius.circular(30),
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12), 
                blurRadius: 10, 
                offset: const Offset(0, 4)
              ),
            ],
          ),
          child: Icon(icon, color: AppColors.primary, size: 30),
        ),
      ),
    );
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
          child: Column(
            children: [
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (idx) => setState(() => _currentPage = idx),
                  children: [
                    _buildIntroPage(
                      Icons.terrain, 
                      "Quản Lý\nDinh Dưỡng Đất", 
                      "Theo dõi NPK, pH và độ ẩm liên tục. AI phân tích và cảnh báo rủi ro thổ nhưỡng 24/7."
                    ),
                    _buildIntroPage(
                      Icons.camera_alt, 
                      "AI Camera\nSâu Bệnh", 
                      "Chỉ cần chụp ảnh lá cây, hệ thống AI tự động nhận diện sâu bệnh và đưa ra giải pháp điều trị."
                    ),
                    _buildLoginForm(),
                  ],
                ),
              ),
              
              if (_currentPage < 2)
                Padding(
                  padding: const EdgeInsets.only(bottom: 40, left: 30, right: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () => _pageController.animateToPage(
                          2, 
                          duration: const Duration(milliseconds: 600), 
                          curve: Curves.easeInOut
                        ),
                        child: const Text(
                          "BỎ QUA", 
                          style: TextStyle(
                            color: Colors.grey, 
                            fontWeight: FontWeight.bold
                          )
                        ),
                      ),
                      
                      Row(
                        children: List.generate(3, (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: _currentPage == index ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _currentPage == index 
                                ? AppColors.primary 
                                : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        )),
                      ),
                      
                      ElevatedButton(
                        onPressed: () => _pageController.nextPage(
                          duration: const Duration(milliseconds: 500), 
                          curve: Curves.ease
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)
                          ),
                        ),
                        child: const Text(
                          "TIẾP", 
                          style: TextStyle(fontWeight: FontWeight.bold)
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}