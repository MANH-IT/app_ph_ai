import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/soil_repository.dart';
import '../models/soil_record_model.dart';
import 'auth_provider.dart';

final soilRepositoryProvider = Provider((ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  return SoilRepository(authRepo);
});

final soilRecordsProvider = FutureProvider<List<SoilRecord>>((ref) async {
  final repo = ref.watch(soilRepositoryProvider);
  return await repo.getAllRecords();
});
