import 'package:hive/hive.dart';
import '../models/soil_record_model.dart';
import 'auth_repository.dart';

class SoilRepository {
  final AuthRepository _authRepo;

  SoilRepository(this._authRepo);

  Box<SoilRecord> get _recordBox => Hive.box<SoilRecord>('soilRecordsBox');

  // Lưu kết quả đo trực tiếp vào Hive (Offline Only)
  Future<void> saveSoilRecord(SoilRecord record) async {
    await _recordBox.put(record.id, record);
  }

  // Lấy tất cả records của user từ Hive (Lọc theo userId)
  Future<List<SoilRecord>> getAllRecords() async {
    final userId = _authRepo.currentUser?.uid;
    if (userId == null) return [];

    final localRecords = _recordBox.values
        .where((r) => r.userId == userId)
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return localRecords;
  }

  // Xóa record khỏi Hive
  Future<void> deleteRecord(String recordId) async {
    await _recordBox.delete(recordId);
  }
}
