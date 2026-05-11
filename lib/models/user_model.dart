import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 0)
class UserModel {
  @HiveField(0)
  final String uid;

  @HiveField(1)
  final String email;

  @HiveField(2)
  final String displayName;

  @HiveField(3)
  final DateTime createdAt;

  @HiveField(4)
  final String password; // Lưu mật khẩu để verify local

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.createdAt,
    this.password = '',
  });

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'email': email,
        'displayName': displayName,
        'createdAt': createdAt.toIso8601String(),
      };
}
