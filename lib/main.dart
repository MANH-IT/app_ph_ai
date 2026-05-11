import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/user_model.dart';
import 'models/soil_record_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // ========== KHỞI TẠO HIVE ==========
  await Hive.initFlutter();
  
  // Đăng ký adapters
  Hive.registerAdapter(UserModelAdapter());
  Hive.registerAdapter(SoilRecordAdapter());
  
  // Mở các boxes
  await Hive.openBox<UserModel>('userBox'); // Để lưu user hiện tại
  await Hive.openBox('usersDatabase'); // Để lưu danh sách user đăng ký offline
  await Hive.openBox<SoilRecord>('soilRecordsBox');
  // ===================================
  
  runApp(const ProviderScope(child: AgriTechApp()));
}

class AgriTechApp extends StatelessWidget {
  const AgriTechApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'AgriTech AI',
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
    );
  }
}
