// lib/features/chat/chat_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];

  bool _isBotTyping = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 600), () {
      _addBotMessage("Xin chào! Tôi là chuyên gia nông nghiệp AI.\nBạn cần tư vấn gì về cây trồng và đất đai hôm nay?");
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;
    final text = _controller.text.trim();
    _addUserMessage(text);
    _controller.clear();
    _handleUserInput(text);
  }

  void _addUserMessage(String text) {
    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
    });
    _scrollToBottom();
  }

  void _addBotMessage(String text) {
    setState(() {
      _messages.add(ChatMessage(text: text, isUser: false));
      _isBotTyping = false;
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleUserInput(String input) async {
    final lower = input.toLowerCase();
    setState(() => _isBotTyping = true);

    await Future.delayed(const Duration(seconds: 1, milliseconds: 500));

    String reply;

    if (lower.contains("bón phân") || lower.contains("npk") || lower.contains("đạm") || lower.contains("lân") || lower.contains("kali")) {
      reply = "Việc bón phân cần cân đối dựa trên giai đoạn phát triển của cây.\n\n"
          "💡 Hướng xử lý chung:\n"
          "• Giai đoạn cây con: Cần nhiều Đạm (N) để phát triển lá.\n"
          "• Giai đoạn ra hoa: Cần nhiều Lân (P) và Kali (K).\n"
          "• Luôn tưới nước sau khi bón phân để tránh cháy rễ.\n\n"
          "Bạn nên kiểm tra chỉ số NPK trên Dashboard để biết đất đang thiếu hụt chất gì.";
    }
    else if (lower.contains("sâu") || lower.contains("bệnh") || lower.contains("rầy") || lower.contains("nấm")) {
      reply = "Sâu bệnh cần được phát hiện sớm để xử lý kịp thời.\n\n"
          "💡 Gợi ý:\n"
          "• Bạn hãy dùng tính năng 'Soi lá cây' để tôi nhận diện chính xác loại bệnh.\n"
          "• Ưu tiên sử dụng thuốc trừ sâu sinh học (tỏi, ớt, gừng).\n"
          "• Cắt tỉa và tiêu hủy các bộ phận bị bệnh để tránh lây lan.\n\n"
          "⚠️ LƯU Ý: Nếu bệnh nặng trên diện rộng, hãy tham khảo ý kiến chuyên gia bảo vệ thực vật tại địa phương.";
    }
    else if (lower.contains("ph") || lower.contains("đất chua") || lower.contains("vôi")) {
      reply = "Độ pH ảnh hưởng trực tiếp đến khả năng hấp thụ dinh dưỡng của cây.\n\n"
          "💡 Lời khuyên:\n"
          "• pH lý tưởng cho hầu hết cây trồng là 5.5 - 7.0.\n"
          "• Nếu pH < 5.0 (đất chua): Cần bón vôi bột để nâng pH.\n"
          "• Nếu pH > 7.5 (đất kiềm): Bón thêm phân hữu cơ hoặc lưu huỳnh để hạ pH.\n\n"
          "⚠️ Hãy xem hướng dẫn 'Xử lý đất chua' trong thư viện kỹ thuật.";
    }
    else if (lower.contains("tưới") || lower.contains("nước") || lower.contains("khô") || lower.contains("ngập")) {
      reply = "Quản lý nước là yếu tố then chốt cho năng suất cây trồng.\n\n"
          "💡 Lời khuyên:\n"
          "• Tưới vào sáng sớm hoặc chiều mát.\n"
          "• Tránh tưới đẫm khi trời sắp mưa to.\n"
          "• Kiểm tra độ ẩm trên ứng dụng: Nếu < 40% là lúc cần tưới.\n\n"
          "⚠️ Lưu ý: Đất quá ẩm kéo dài dễ gây thối rễ và nấm bệnh.";
    }
    else if (lower.contains("hi") || lower.contains("chào") || lower.contains("hello") || lower.contains("thử")) {
      reply = "Chào bạn! Tôi là chuyên gia nông nghiệp AI.\n\nTôi có thể hỗ trợ bạn về:\n• Kỹ thuật bón phân NPK cân đối.\n• Nhận diện và xử lý sâu bệnh.\n• Cải tạo đất và quản lý nguồn nước.\n\nBạn đang quan tâm đến loại cây trồng nào?";
    }
    else {
      reply = "Tôi đã ghi nhận vấn đề về: '$input'.\n\n"
          "Để hỗ trợ tốt nhất, bạn có thể mô tả rõ hơn về loại cây trồng và biểu hiện cụ thể không?\n\n"
          "💡 Gợi ý:\n"
          "• Bạn có thể dùng 'Soi lá cây' để chụp ảnh bệnh.\n"
          "• Kiểm tra 'Phân tích AI' để xem tình trạng đất hiện tại.\n"
          "• Tra cứu 'Kỹ thuật canh tác' để tìm hiểu quy trình chuẩn.";
    }

    _addBotMessage(reply);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: 26,
            ),
            tooltip: "Quay lại Trang chủ",
            onPressed: () {
              context.goNamed('dashboard');
            },
          ),
        ),
        title: const Text(
          "Chuyên gia Nông nghiệp AI",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green, Colors.teal],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: AppColors.backgroundLight,
        ),
        child: Column(
          children: [
            SizedBox(height: MediaQuery.of(context).padding.top + 56),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.eco, color: Colors.green, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "LƯU Ý: Mọi phản hồi của AI chỉ dựa trên dữ liệu phân tích và thông tin chung về nông nghiệp. Kết quả có thể thay đổi tùy thuộc vào điều kiện thổ nhưỡng và khí hậu thực tế của bạn.",
                      style: TextStyle(fontSize: 12, color: Colors.black87, height: 1.3, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: _messages.length + (_isBotTyping ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _messages.length && _isBotTyping) {
                    return const BotTypingBubble();
                  }
                  return _messages[index];
                },
              ),
            ),
            if (_messages.length <= 2)
              Container(
                height: 48,
                margin: const EdgeInsets.only(bottom: 8),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _quickChip("Kỹ thuật bón phân"),
                    const SizedBox(width: 8),
                    _quickChip("Cách xử lý đất chua"),
                    const SizedBox(width: 8),
                    _quickChip("Phòng trừ sâu bệnh"),
                    const SizedBox(width: 8),
                    _quickChip("Lịch tưới nước"),
                  ],
                ),
              ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -2))
                ],
              ),
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 12,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.mic_none, color: Colors.green),
                            onPressed: () {},
                          ),
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              decoration: const InputDecoration(
                                hintText: "Hỏi chuyên gia nông nghiệp...",
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(vertical: 14),
                              ),
                              textInputAction: TextInputAction.send,
                              onSubmitted: (_) => _sendMessage(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(colors: [Colors.green, Colors.teal]),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Colors.green, blurRadius: 8, offset: Offset(0, 4))
                        ],
                      ),
                      child: const Icon(Icons.send_rounded, color: Colors.white, size: 22),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickChip(String text) {
    return GestureDetector(
      onTap: () {
        _controller.text = text;
        _sendMessage();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.green),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 13.5, color: Colors.green),
        ),
      ),
    );
  }
}

class ChatMessage extends StatelessWidget {
  final String text;
  final bool isUser;
  const ChatMessage({super.key, required this.text, required this.isUser});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) const BotAvatar(),
          const SizedBox(width: 12),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                gradient: isUser
                    ? const LinearGradient(colors: [Colors.green, Colors.teal])
                    : null,
                color: isUser ? null : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: isUser ? Colors.green.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isUser ? 20 : 0),
                  bottomRight: Radius.circular(isUser ? 0 : 20),
                ),
                border: isUser ? null : Border.all(color: Colors.grey.shade100),
              ),
              child: SelectableText(
                text,
                style: TextStyle(
                  color: isUser ? Colors.white : AppColors.textPrimary,
                  fontSize: 15.5,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BotAvatar extends StatelessWidget {
  const BotAvatar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Colors.green, Colors.teal],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(color: Colors.green.withValues(alpha: 0.3), blurRadius: 6, offset: const Offset(0, 2))
        ],
      ),
      child: const Icon(Icons.psychology, color: Colors.white, size: 20),
    );
  }
}

class BotTypingBubble extends StatelessWidget {
  const BotTypingBubble({super.key});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const BotAvatar(),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                )
              ],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(0),
                bottomRight: Radius.circular(20),
              ),
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Dot(),
                SizedBox(width: 6),
                Dot(delay: 200),
                SizedBox(width: 6),
                Dot(delay: 400),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Dot extends StatefulWidget {
  final int delay;
  const Dot({super.key, this.delay = 0});
  @override 
  State<Dot> createState() => _DotState();
}

class _DotState extends State<Dot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) => Transform.translate(
        offset: Offset(0, -(_controller.value * 4)),
        child: Opacity(
          opacity: 0.4 + (_controller.value * 0.6),
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Colors.green, 
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}