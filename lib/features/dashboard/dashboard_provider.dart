// lib/features/dashboard/dashboard_provider.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../models/soil_record_model.dart';
import '../../repositories/soil_repository.dart';
import '../../providers/auth_provider.dart';
import '../../providers/soil_provider.dart';

// --- DATA CLASSES ---

class AgriData {
  final double nitrogen;
  final double phosphorus;
  final double potassium;
  final double phLevel;
  final double moisture;
  final bool isMeasuring;
  final UserProfile userProfile;
  final String locationName;
  final String gpsCoords;
  final String weatherInfo;
  final String selectedCrop;

  AgriData({
    this.nitrogen = 0.0,
    this.phosphorus = 0.0,
    this.potassium = 0.0,
    this.phLevel = 7.0,
    this.moisture = 0.0,
    this.isMeasuring = false,
    UserProfile? userProfile,
    this.locationName = "Đắk Lắk, Việt Nam",
    this.gpsCoords = "12.6667° N, 108.0500° E",
    this.weatherInfo = "28°C, Nắng nhẹ",
    this.selectedCrop = "Cà phê",
  }) : userProfile = userProfile ?? UserProfile();

  AgriData copyWith({
    double? nitrogen,
    double? phosphorus,
    double? potassium,
    double? phLevel,
    double? moisture,
    bool? isMeasuring,
    UserProfile? userProfile,
    String? locationName,
    String? gpsCoords,
    String? weatherInfo,
    String? selectedCrop,
  }) {
    return AgriData(
      nitrogen: nitrogen ?? this.nitrogen,
      phosphorus: phosphorus ?? this.phosphorus,
      potassium: potassium ?? this.potassium,
      phLevel: phLevel ?? this.phLevel,
      moisture: moisture ?? this.moisture,
      isMeasuring: isMeasuring ?? this.isMeasuring,
      userProfile: userProfile ?? this.userProfile,
      locationName: locationName ?? this.locationName,
      gpsCoords: gpsCoords ?? this.gpsCoords,
      weatherInfo: weatherInfo ?? this.weatherInfo,
      selectedCrop: selectedCrop ?? this.selectedCrop,
    );
  }
}

class UserProfile {
  final String name;
  final int treeCount;
  final double area;
  final double density;
  final double performance;
  final bool isAcidSoil;
  final bool isSalineSoil;
  final bool isOrganic;

  UserProfile({
    this.name = "Chủ vườn",
    this.treeCount = 0,
    this.area = 0.0,
    this.density = 0.0,
    this.performance = 0.0,
    this.isAcidSoil = false,
    this.isSalineSoil = false,
    this.isOrganic = true,
  });
}

// --- NOTIFIER ---

class DashboardNotifier extends StateNotifier<AgriData> {
  final SoilRepository _soilRepo;
  final String? _userId;

  DashboardNotifier(this._soilRepo, this._userId) : super(AgriData());

  void updateSelectedCrop(String crop) {
    state = state.copyWith(selectedCrop: crop);
  }

  void updateUserProfile(UserProfile profile) {
    state = state.copyWith(userProfile: profile);
  }

  Future<void> startMeasurement({VoidCallback? onComplete}) async {
    if (state.isMeasuring) return;

    state = state.copyWith(isMeasuring: true);

    // Giả lập quá trình đo trong 3 giây
    await Future.delayed(const Duration(seconds: 3));

    final random = Random();
    final newNitrogen = 20.0 + random.nextDouble() * 60.0;
    final newPhosphorus = 10.0 + random.nextDouble() * 40.0;
    final newPotassium = 15.0 + random.nextDouble() * 50.0;
    final newPH = 4.5 + random.nextDouble() * 4.0;
    final newMoisture = 30.0 + random.nextDouble() * 60.0;

    final newRecord = SoilRecord(
      id: const Uuid().v4(),
      userId: _userId ?? 'anonymous',
      timestamp: DateTime.now(),
      nitrogen: newNitrogen,
      phosphorus: newPhosphorus,
      potassium: newPotassium,
      phLevel: newPH,
      moisture: newMoisture,
      locationName: state.locationName,
      latitude: 12.6667,
      longitude: 108.0500,
    );

    await _soilRepo.saveSoilRecord(newRecord);

    state = state.copyWith(
      nitrogen: newNitrogen,
      phosphorus: newPhosphorus,
      potassium: newPotassium,
      phLevel: newPH,
      moisture: newMoisture,
      isMeasuring: false,
    );

    onComplete?.call();
  }
}

// --- PROVIDER ---

final dashboardProvider = StateNotifierProvider<DashboardNotifier, AgriData>((ref) {
  final repo = ref.watch(soilRepositoryProvider);
  final user = ref.watch(currentUserProvider);
  return DashboardNotifier(repo, user?.uid);
});