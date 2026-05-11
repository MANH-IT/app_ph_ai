import 'package:hive/hive.dart';

part 'soil_record_model.g.dart';

@HiveType(typeId: 1)
class SoilRecord {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  final DateTime timestamp;

  @HiveField(3)
  final double nitrogen; // Nitơ (N) - Đạm

  @HiveField(4)
  final double phosphorus; // Lân (P)

  @HiveField(5)
  final double potassium; // Kali (K)

  @HiveField(6)
  final double phLevel; // pH

  @HiveField(7)
  final double moisture; // Độ ẩm (%)

  @HiveField(8)
  final String? locationName; // Địa điểm/Địa chỉ

  @HiveField(9)
  final double? latitude; // Kinh độ

  @HiveField(10)
  final double? longitude; // Vĩ độ

  @HiveField(11)
  final String? cropType; // Loại cây trồng

  SoilRecord({
    required this.id,
    required this.userId,
    required this.timestamp,
    required this.nitrogen,
    required this.phosphorus,
    required this.potassium,
    required this.phLevel,
    required this.moisture,
    this.locationName,
    this.latitude,
    this.longitude,
    this.cropType,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'timestamp': timestamp.toIso8601String(),
        'nitrogen': nitrogen,
        'phosphorus': phosphorus,
        'potassium': potassium,
        'phLevel': phLevel,
        'moisture': moisture,
        'locationName': locationName,
        'latitude': latitude,
        'longitude': longitude,
        'cropType': cropType,
      };
}
