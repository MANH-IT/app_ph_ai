// lib/features/settings/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_theme.dart'; // ✅ Import theme thống nhất

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkMode = false;
  String _appVersion = "1.0.0";

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadAppVersion();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications') ?? true;
      _darkMode = prefs.getBool('darkMode') ?? false;
    });
  }

  Future<void> _loadAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = "${packageInfo.version} (${packageInfo.buildNumber})";
    });
  }

  Future<void> _toggleNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications', value);
    setState(() => _notificationsEnabled = value);
    _showSnackBar(value ? "Đã bật thông báo" : "Đã tắt thông báo");
  }

  Future<void> _toggleDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', value);
    setState(() => _darkMode = value);
    _showSnackBar(value ? "Chế độ tối đã bật" : "Chế độ sáng đã bật");
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showComingSoon(String feature) {
    _showSnackBar("$feature đang được phát triển...");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cài đặt", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: const LinearGradient(colors: AppColors.primaryGradient)),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          tooltip: "Quay lại Dashboard",
          onPressed: () {
            // ĐÃ ĐÚNG: VỀ DASHBOARD
            // Dùng canPop để tránh lỗi nếu không có route nào để pop
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/dashboard');
            }
          },
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
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // === Tài khoản ===
            _buildSectionTitle("Tài khoản"),
            _buildListTile(
              icon: Icons.person_outline,
              title: "Hồ sơ Khu vườn",
              onTap: () => context.go('/profile'),

            ),
            _buildListTile(
              icon: Icons.security_outlined,
              title: "Bảo mật & Quyền riêng tư",
              onTap: () => _showComingSoon("Bảo mật"),
            ),

            const SizedBox(height: 20),

            // === Tùy chỉnh ===
            _buildSectionTitle("Tùy chỉnh"),
            _buildSwitchTile(
              icon: Icons.notifications_outlined,
              title: "Thông báo",
              subtitle: "Cảnh báo chỉ số đất, nhắc bón phân",
              value: _notificationsEnabled,
              onChanged: _toggleNotifications,
            ),
            _buildSwitchTile(
              icon: Icons.dark_mode_outlined,
              title: "Chế độ tối",
              subtitle: "Tiết kiệm pin & dễ nhìn vào ban đêm",
              value: _darkMode,
              onChanged: _toggleDarkMode,
            ),
            _buildListTile(
              icon: Icons.language,
              title: "Ngôn ngữ",
              subtitle: "Tiếng Việt",
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => context.push('/language'),
            ),

            const SizedBox(height: 20),

            // === Hỗ trợ ===
            _buildSectionTitle("Hỗ trợ"),
            _buildListTile(
              icon: Icons.help_outline,
              title: "Trợ giúp & Hướng dẫn",
              onTap: () => _showComingSoon("Hướng dẫn"),
            ),
            _buildListTile(
              icon: Icons.chat_bubble_outline,
              title: "Liên hệ hỗ trợ",
              onTap: () => _showComingSoon("Hỗ trợ"),
            ),
            _buildListTile(
              icon: Icons.star_outline,
              title: "Đánh giá ứng dụng",
              onTap: () => _showComingSoon("Đánh giá"),
            ),

            const SizedBox(height: 20),

            // === Về ứng dụng ===
            _buildSectionTitle("Về ứng dụng"),
            _buildListTile(
              icon: Icons.info_outline,
              title: "Phiên bản",
              subtitle: _appVersion,
              onTap: () {},
            ),
            _buildListTile(
              icon: Icons.favorite_border,
              title: "BlueMind AgriTech AI",
              subtitle: "© 2025 Qverse Team. All rights reserved.",
              onTap: () {},
            ),

            const SizedBox(height: 30),

            // Nút Đăng xuất
            Center(
              child: OutlinedButton.icon(
                onPressed: () {
                  context.go('/');
                  _showSnackBar("Đã đăng xuất thành công!");
                },
                icon: Icon(Icons.logout, color: AppColors.error),
                label: Text("Đăng xuất", style: TextStyle(color: AppColors.error)),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.error),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primaryLight.withValues(alpha: 0.2),
          child: Icon(icon, color: AppColors.primary),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(color: Colors.grey)) : null,
        trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primaryLight.withValues(alpha: 0.2),
          child: Icon(icon, color: AppColors.primary),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(color: Colors.grey)) : null,
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: AppColors.primary,
        ),
        onTap: () => onChanged(!value),
      ),
    );
  }
}