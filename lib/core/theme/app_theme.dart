// lib/core/theme/app_theme.dart
// HỆ THỐNG MÀU SẮC THỐNG NHẤT CHO TOÀN BỘ APP

import 'package:flutter/material.dart';

/// Màu sắc chính của ứng dụng - AgriTech Theme (Xanh lá nông nghiệp)
class AppColors {
  AppColors._(); // Private constructor để không thể khởi tạo

  // === MÀU CHÍNH (PRIMARY) ===
  static const Color primary = Color(0xFF4CAF50);        // Xanh lá chính
  static const Color primaryLight = Color(0xFF66BB6A);    // Xanh lá nhạt
  static const Color primaryDark = Color(0xFF388E3C);     // Xanh lá đậm
  static const Color primaryAccent = Color(0xFF8BC34A);   // Xanh lá accent

  static const Color primaryRed = Color(0xFFE53935);
  static const Color primaryBlue = Color(0xFF1E88E5);
  static const Color primaryGreen = Color(0xFF43A047);
  static const Color primaryOrange = Color(0xFFFB8C00);

  // === MÀU PHỤ (SECONDARY) ===
  static const Color secondary = Color(0xFF4A90E2);      // Xanh dương
  static const Color secondaryLight = Color(0xFF6BA3E8);
  static const Color secondaryDark = Color(0xFF2E6BC4);

  // === MÀU NỀN (BACKGROUND) ===
  static const Color background = Color(0xFFE8F5E8);     // Nền chính (xanh lá nhạt)
  static const Color backgroundLight = Color(0xFFF5F9F5); // Nền sáng
  static const Color backgroundDark = Color(0xFFC8E6C9);  // Nền tối
  static const Color surface = backgroundLight;              // Mặt phẳng (card, container)
  static const Color surfaceVariant = Color(0xFFE2EFE2);   // Mặt phẳng biến thể

  // === MÀU VĂN BẢN (TEXT) ===
  static const Color textPrimary = Color(0xFF212121);    // Văn bản chính
  static const Color textSecondary = Color(0xFF757575);   // Văn bản phụ
  static const Color textHint = Color(0xFF9E9E9E);        // Văn bản gợi ý
  static const Color textOnPrimary = Colors.white;        // Văn bản trên nền primary

  // === MÀU TRẠNG THÁI (STATUS) ===
  static const Color success = Color(0xFF4CAF50);         // Thành công
  static const Color warning = Color(0xFFF5A623);        // Cảnh báo
  static const Color error = Color(0xFFE74C3C);          // Lỗi
  static const Color info = Color(0xFF2196F3);            // Thông tin

  // === MÀU CHỈ SỐ ĐẤT ===
  static const Color nitrogenGood = Color(0xFF4CAF50);    // Nitơ tốt
  static const Color nitrogenWarning = Color(0xFFF5A623); // Nitơ cảnh báo
  static const Color nitrogenDanger = Color(0xFFE74C3C);  // Nitơ nguy hiểm

  static const Color phGood = Color(0xFF4CAF50);
  static const Color phWarning = Color(0xFFF5A623);
  static const Color phDanger = Color(0xFFE74C3C);

  static const Color moistureGood = Color(0xFF4CAF50);
  static const Color moistureWarning = Color(0xFFF5A623);
  static const Color moistureDanger = Color(0xFFE74C3C);

  // === MÀU GRADIENT ===
  static const List<Color> primaryGradient = [
    Color(0xFF4CAF50),
    Color(0xFF66BB6A),
  ];

  static const List<Color> primaryGradientExtended = [
    Color(0xFF4CAF50),
    Color(0xFF8BC34A),
    Color(0xFFE8F5E8),
  ];

  static const List<Color> backgroundGradient = [
    Color(0xFFE8F5E9),
    Color(0xFFC8E6C9),
  ];

  static const List<Color> secondaryGradient = [
    Color(0xFF1976D2),
    Color(0xFF42A5F5),
  ];

  // === MÀU CHAT ===
  static const Color chatUser = Color(0xFF4A90E2);       // Tin nhắn người dùng
  static const Color chatBot = Color(0xFFF8F9FA);         // Tin nhắn bot
  static const Color chatBotText = Color(0xFF2C3E50);

  // === MÀU BUTTON ===
  static const Color buttonPrimary = Color(0xFF4CAF50);
  static const Color buttonSecondary = Color(0xFF4A90E2);
  static const Color buttonDanger = Color(0xFFE74C3C);

  // === MÀU CARD ===
  static const Color cardBackground = backgroundLight;
  static const Color cardShadow = Color(0x1A000000);       // Shadow nhẹ

  // === MÀU DIVIDER ===
  static const Color divider = Color(0xFFE0E0E0);
  static const Color dividerLight = Color(0xFFF5F5F5);
}

/// Theme cho ứng dụng AgriTech Smart Soil
class AppTheme {
  AppTheme._(); // Private constructor

  /// Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Roboto',
      
      // Color Scheme
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        primaryContainer: AppColors.primaryLight,
        secondary: AppColors.secondary,
        secondaryContainer: AppColors.secondaryLight,
        surface: AppColors.surface,
        surfaceContainerHighest: AppColors.surfaceVariant,
        error: AppColors.error,
        onPrimary: AppColors.textOnPrimary,
        onSecondary: AppColors.textOnPrimary,
        onSurface: AppColors.textPrimary,
        onError: AppColors.textOnPrimary,
      ),

      // Scaffold
      scaffoldBackgroundColor: AppColors.background,

      // AppBar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        foregroundColor: AppColors.textOnPrimary,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.textOnPrimary,
          fontFamily: 'Roboto',
        ),
        iconTheme: IconThemeData(
          color: AppColors.textOnPrimary,
          size: 24,
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: AppColors.cardBackground,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.buttonPrimary,
          foregroundColor: AppColors.textOnPrimary,
          elevation: 4,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Roboto',
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Roboto',
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Roboto',
          ),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        hintStyle: const TextStyle(color: AppColors.textHint),
      ),

      // Text Theme
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
          fontFamily: 'Roboto',
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
          fontFamily: 'Roboto',
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
          fontFamily: 'Roboto',
        ),
        headlineMedium: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
          fontFamily: 'Roboto',
        ),
        headlineSmall: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
          fontFamily: 'Roboto',
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
          fontFamily: 'Roboto',
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
          fontFamily: 'Roboto',
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: AppColors.textPrimary,
          fontFamily: 'Roboto',
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: AppColors.textPrimary,
          fontFamily: 'Roboto',
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: AppColors.textSecondary,
          fontFamily: 'Roboto',
        ),
      ),

      // Icon Theme
      iconTheme: const IconThemeData(
        color: AppColors.textPrimary,
        size: 24,
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 1,
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 6,
      ),

      // Switch Theme
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return Colors.grey;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primaryLight;
          }
          return Colors.grey.shade300;
        }),
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceVariant,
        selectedColor: AppColors.primaryLight,
        labelStyle: const TextStyle(color: AppColors.textPrimary),
        secondaryLabelStyle: const TextStyle(color: AppColors.textOnPrimary),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  /// Dark Theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Roboto',
      brightness: Brightness.dark,

      // Color Scheme
      colorScheme: ColorScheme.dark(
        primary: AppColors.primaryLight,
        primaryContainer: AppColors.primaryDark,
        secondary: AppColors.secondaryLight,
        secondaryContainer: AppColors.secondaryDark,
        surface: const Color(0xFF1E1E1E),
        surfaceContainerHighest: const Color(0xFF2C2C2C),
        error: AppColors.error,
        onPrimary: AppColors.textOnPrimary,
        onSecondary: AppColors.textOnPrimary,
        onSurface: Colors.white,
        onError: AppColors.textOnPrimary,
      ),

      // Scaffold
      scaffoldBackgroundColor: const Color(0xFF121212),

      // AppBar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        foregroundColor: Colors.white,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontFamily: 'Roboto',
        ),
      ),

      // Text Theme
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontFamily: 'Roboto',
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: Colors.white,
          fontFamily: 'Roboto',
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: Colors.white70,
          fontFamily: 'Roboto',
        ),
      ),
    );
  }
}

/// Extension để dễ dàng truy cập theme colors từ context
extension ThemeExtension on BuildContext {
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;
  
  // Quick access to AppColors
  Color get primaryColor => AppColors.primary;
  Color get primaryLightColor => AppColors.primaryLight;
  Color get backgroundColor => AppColors.background;
}
