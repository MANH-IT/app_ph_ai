import 'package:hive/hive.dart';

part 'chat_models.g.dart';

@HiveType(typeId: 0)
class Message extends HiveObject {
  @HiveField(0)
  final String text;
  
  @HiveField(1)
  final bool isUser;
  
  Message({required this.text, required this.isUser});
}

class ChatState {
  final List<Message> messages;
  final bool isLoading;
  final String? error;
  
  ChatState({
    required this.messages,
    this.isLoading = false,
    this.error,
  });
}
