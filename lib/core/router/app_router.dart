// lib/core/router/app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:apps_health_ai/core/theme/app_theme.dart';

// ==== CÁC MÀN HÌNH ====
import 'package:apps_health_ai/features/onboarding/onboarding_screen.dart';
import 'package:apps_health_ai/features/auth/register_screen.dart';
import 'package:apps_health_ai/features/dashboard/dashboard_screen.dart';
import 'package:apps_health_ai/features/profile/profile_screen.dart';
import 'package:apps_health_ai/features/chat/chat_screen.dart';
import 'package:apps_health_ai/features/history/history_screen.dart';
import 'package:apps_health_ai/features/settings/settings_screen.dart';
import 'package:apps_health_ai/features/medication/medication_screen.dart';
import 'package:apps_health_ai/features/analytics/analytics_screen.dart';
import 'package:apps_health_ai/features/settings/language_screen.dart';
import 'package:apps_health_ai/features/alerts/alerts_screen.dart';
import 'package:apps_health_ai/features/device/device_screen.dart';
import 'package:apps_health_ai/features/share/share_screen.dart';
import 'package:apps_health_ai/features/feedback/feedback_screen.dart';
import 'package:apps_health_ai/features/tutorial/tutorial_screen.dart';
import 'package:apps_health_ai/features/vision/vision_screen.dart';

import 'package:apps_health_ai/core/router/main_layout.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', name: 'onboarding', builder: (context, state) => const OnboardingScreen()),
    GoRoute(path: '/register', name: 'register', builder: (context, state) => const RegisterScreen()),

    // Nhóm giao diện chính với BottomNavigationBar
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainLayout(navigationShell: navigationShell);
      },
      branches: [
        // Nhánh 0: Trang chủ
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/dashboard',
              name: 'dashboard',
              builder: (context, state) {
                final extra = state.extra;
                final userName = (extra is Map) ? extra['userName'] as String? : null;
                return DashboardScreen(initialUserName: userName);
              },
            ),
          ],
        ),
        // Nhánh 1: Lịch sử
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/history',
              name: 'history',
              builder: (context, state) => const HistoryScreen(),
            ),
          ],
        ),
        // Nhánh 2: Chat AI
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/chat',
              name: 'chat',
              builder: (context, state) => const ChatScreen(),
            ),
          ],
        ),
        // Nhánh 3: Hồ sơ
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              name: 'profile',
              builder: (context, state) => ProfileScreen(initialData: state.extra as Map<String, dynamic>?),
            ),
          ],
        ),
      ],
    ),

    // Các routes khác
    GoRoute(path: '/settings', name: 'settings', builder: (context, state) => const SettingsScreen()),
    GoRoute(path: '/language', name: 'language', builder: (context, state) => const LanguageScreen()),
    GoRoute(path: '/dongy', name: 'dongy', builder: (context, state) => const MedicationScreen()),
    GoRoute(path: '/ai-analysis', name: 'ai-analysis', builder: (context, state) => AnalyticsScreen(extra: state.extra as Map<String, dynamic>?)),
    GoRoute(path: '/alerts', name: 'alerts', builder: (_, __) => const AlertsScreen()),
    GoRoute(path: '/device', name: 'device', builder: (_, __) => const DeviceScreen()),
    GoRoute(path: '/share', name: 'share', builder: (_, state) => ShareScreen(healthData: state.extra as Map<String, dynamic>?)),
    GoRoute(path: '/feedback', name: 'feedback', builder: (_, __) => const FeedbackScreen()),
    GoRoute(path: '/tutorial', name: 'tutorial', builder: (_, __) => const TutorialScreen()),
    GoRoute(path: '/vision', name: 'vision', builder: (_, __) => const VisionScreen()),
  ],

  errorBuilder: (context, state) => Scaffold(
    backgroundColor: AppColors.background,
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.sentiment_dissatisfied, size: 90, color: Colors.grey.shade400),
          const SizedBox(height: 24),
          const Text('404 – Không tìm thấy trang', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => context.go('/dashboard'),
            icon: const Icon(Icons.home),
            label: const Text("Về trang chủ"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade600),
          ),
        ],
      ),
    ),
  ),
);