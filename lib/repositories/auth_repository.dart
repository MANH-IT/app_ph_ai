import 'dart:async';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_model.dart';

class AuthRepository {
  // Lấy box lưu user hiện tại
  Box<UserModel> get _userBox => Hive.box<UserModel>('userBox');
  
  // Lấy box lưu danh sách users
  Box get _usersDatabase => Hive.box('usersDatabase');
  
  // StreamController để listen theo dõi đăng nhập
  final _authStateController = StreamController<UserModel?>.broadcast();

  // Hàm chuẩn hóa số điện thoại
  String _normalizePhone(String phone) {
    // Xóa tất cả ký tự không phải số
    var s = phone.replaceAll(RegExp(r'[^0-9]'), '');
    
    // Nếu bắt đầu bằng 0, chuyển thành 84
    if (s.startsWith('0')) {
      s = '84${s.substring(1)}';
    }
    
    // Đảm bảo có độ dài đúng (84 + 9 số = 11 số)
    if (s.length == 10 && !s.startsWith('84')) {
      s = '84$s';
    }
    
    return s;
  }

  // Kiểm tra số điện thoại đã tồn tại
  Future<bool> isPhoneExist(String phone) async {
    final allUsers = getAllUsers();
    final normalizedPhone = _normalizePhone(phone);
    
    for (var user in allUsers) {
      final userEmail = user.email.replaceAll('@healthai.com', '');
      final normalizedUserPhone = _normalizePhone(userEmail);
      
      if (normalizedUserPhone == normalizedPhone) {
        return true;
      }
    }
    return false;
  }
  
  // Đăng ký user mới
  Future<UserModel?> signUp(String email, String password, String name) async {
    try {
      print('🚀 BẮT ĐẦU signUp');
      print('📧 Email: $email');
      print('👤 Name: $name');
      
      final phone = email.replaceAll('@healthai.com', '');
      print('📞 Phone trích xuất: $phone');
      
      // Kiểm tra trùng số điện thoại
      final exists = await isPhoneExist(phone);
      print('🔍 isPhoneExist result: $exists');
      
      if (exists) {
        print('❌ TRÙNG SĐT, trả về null');
        return null;
      }
      
      // Mã hóa mật khẩu
      final bytes = utf8.encode(password);
      final encryptedPassword = md5.convert(bytes).toString();

      // Tạo user mới
      final user = UserModel(
        uid: DateTime.now().millisecondsSinceEpoch.toString(),
        email: email,
        displayName: name,
        createdAt: DateTime.now(),
        password: encryptedPassword,
      );
      print('👤 User instance created: uid=${user.uid}');
      
      // Lưu vào usersDatabase
      final userJson = user.toJson();
      userJson['password'] = encryptedPassword;
      
      await _usersDatabase.put(user.uid, userJson);
      print('💾 Đã lưu vào usersDatabase thành công');
      
      // Lưu vào userBox
      await _userBox.put('currentUser', user);
      print('💾 Đã lưu vào userBox thành công');
      
      _authStateController.add(user);
      print('✅ SIGNUP SUCCESS!');
      
      return user;
    } catch (e, stackTrace) {
      print('❌ EXCEPTION trong signUp: $e');
      print('📚 StackTrace: $stackTrace');
      return null;
    }
  }

  // Đăng nhập
  Future<UserModel?> signIn(String email, String password) async {
    try {
      print('🔑 BẮT ĐẦU signIn: $email');
      
      // Chuẩn hóa email đầu vào
      String normalizedEmail = email;
      if (email.contains('@')) {
        final phonePart = email.split('@')[0];
        final normalizedPhone = _normalizePhone(phonePart);
        normalizedEmail = '$normalizedPhone@healthai.com';
      }
      
      print('🔍 Email chuẩn hóa: $normalizedEmail');
      
      final bytes = utf8.encode(password);
      final encryptedPassword = md5.convert(bytes).toString();

      // Tìm kiếm user
      final allData = _usersDatabase.values.toList();
      Map<String, dynamic>? foundUser;
      
      for (var data in allData) {
        if (data is Map) {
          final dbEmail = data['email'] as String;
          // So sánh cả email gốc và email đã chuẩn hóa
          if (dbEmail == email || dbEmail == normalizedEmail) {
            foundUser = Map<String, dynamic>.from(data);
            print('✅ Tìm thấy user với email: $dbEmail');
            break;
          }
        }
      }

      if (foundUser == null) {
        print('❌ Không tìm thấy user trong database!');
        print('📋 Danh sách email trong DB:');
        for (var data in allData) {
          if (data is Map) {
            print('   - ${data['email']}');
          }
        }
        return null;
      }

      if (foundUser['password'] == encryptedPassword) {
        final user = UserModel(
          uid: foundUser['uid'],
          email: foundUser['email'],
          displayName: foundUser['displayName'],
          createdAt: DateTime.parse(foundUser['createdAt']),
          password: foundUser['password'],
        );
        
        await _userBox.put('currentUser', user);
        _authStateController.add(user);
        print('✅ LOGIN SUCCESS!');
        return user;
      }
      print('❌ Sai mật khẩu!');
      return null;
    } catch (e) {
      print('❌ Lỗi signIn: $e');
      return null;
    }
  }
  
  UserModel? get currentUser => _userBox.get('currentUser');
  Stream<UserModel?> get authStateChanges => _authStateController.stream;
  
  Future<void> signOut() async {
    await _userBox.delete('currentUser');
    _authStateController.add(null);
  }
  
  List<UserModel> getAllUsers() {
    final users = <UserModel>[];
    for (var key in _usersDatabase.keys) {
      final data = _usersDatabase.get(key);
      if (data is Map) {
        users.add(UserModel(
          uid: data['uid'],
          email: data['email'],
          displayName: data['displayName'],
          createdAt: DateTime.parse(data['createdAt']),
          password: data['password'] ?? '',
        ));
      }
    }
    return users;
  }
}