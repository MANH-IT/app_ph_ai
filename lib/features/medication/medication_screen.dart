// lib/features/medication/medication_screen.dart
// THƯ VIỆN KỸ THUẬT CANH TÁC & PHÒNG TRỪ SÂU BỆNH
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MedicationScreen extends StatefulWidget {
  const MedicationScreen({super.key});

  @override
  State<MedicationScreen> createState() => _MedicationScreenState();
}

class _MedicationScreenState extends State<MedicationScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  final List<AgriGuide> _allGuides = [
    AgriGuide(
      name: "Ủ phân hữu cơ",
      vietnameseName: "Kỹ thuật ủ phân Compost tại nhà",
      targets: ["Cải tạo đất", "Tiết kiệm chi phí", "Bền vững"],
      requirements: "Rác thải hữu cơ, chế phẩm Trichoderma, bạt che, xẻng",
      instructions: "Trộn rác hữu cơ với chế phẩm vi sinh, giữ độ ẩm 50-60%. Đảo trộn 1 lần/tuần. Sau 1-2 tháng có thể sử dụng bón cho cây.",
      imageUrl: "https://i.imgur.com/8k0J5pL.jpg",
    ),
    AgriGuide(
      name: "Trị rầy nâu bằng tỏi ớt",
      vietnameseName: "Thuốc trừ sâu sinh học từ tỏi, ớt, gừng",
      targets: ["Rầy nâu", "Sâu cuốn lá", "Rệp sáp"],
      requirements: "500g tỏi, 500g ớt, 500g gừng, 3 lít rượu trắng",
      instructions: "Giã nát các nguyên liệu, ngâm với rượu trong 15 ngày. Khi dùng pha 20-30ml dung dịch với 10 lít nước để phun.",
      imageUrl: "https://i.imgur.com/3qR7vZ9.jpg",
    ),
    AgriGuide(
      name: "Xử lý đất chua",
      vietnameseName: "Kỹ thuật khử chua bằng vôi bột",
      targets: ["Nâng pH", "Khử trùng đất", "Diệt mầm bệnh"],
      requirements: "Vôi bột nông nghiệp (CaO), máy đo pH",
      instructions: "Rắc vôi đều trên mặt ruộng (10-20kg/100m2 tùy độ chua). Cày xới để vôi trộn đều với đất. Nghỉ đất 7-10 ngày trước khi gieo trồng.",
      imageUrl: "https://i.imgur.com/9xY2kLm.jpg",
    ),
    AgriGuide(
      name: "Tưới nhỏ giọt",
      vietnameseName: "Hệ thống tưới nhỏ giọt tiết kiệm nước",
      targets: ["Tiết kiệm nước", "Độ ẩm ổn định", "Giảm sâu bệnh"],
      requirements: "Ống dẫn nước, béc nhỏ giọt, bộ lọc, bơm",
      instructions: "Lắp đặt hệ thống ống đi dọc hàng cây. Điều chỉnh béc nhỏ giọt phù hợp với nhu cầu nước từng giai đoạn của cây.",
      imageUrl: "https://i.imgur.com/fP8mN2r.jpg",
    ),
  ];

  List<AgriGuide> get _filteredGuides {
    if (_searchQuery.isEmpty) return _allGuides;
    return _allGuides.where((guide) {
      return guide.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          guide.vietnameseName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          guide.targets.any((t) => t.toLowerCase().contains(_searchQuery.toLowerCase()));
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 26),
            tooltip: "Quay lại Trang chủ",
            onPressed: () => context.goNamed('dashboard'),
          ),
        ),
        title: const Text(
          "Kỹ thuật & Phòng trừ",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green.shade800, Colors.green.shade600],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: InputDecoration(
                    hintText: "Tìm kỹ thuật, sâu bệnh...",
                    prefixIcon: const Icon(Icons.search, color: Colors.green),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: _filteredGuides.isEmpty
                    ? Center(child: Text("Không tìm thấy hướng dẫn nào", style: TextStyle(color: Colors.grey.shade600)))
                    : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _filteredGuides.length,
                  itemBuilder: (context, index) {
                    final guide = _filteredGuides[index];
                    return _buildGuideCard(guide);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGuideCard(AgriGuide guide) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: () => _showGuideDetail(guide),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(color: Colors.green.shade100, borderRadius: BorderRadius.circular(16)),
                child: const Icon(Icons.menu_book, size: 36, color: Colors.green),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(guide.vietnameseName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green)),
                    const SizedBox(height: 4),
                    Text("Mục tiêu: ${guide.targets.join(", ")}", style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  void _showGuideDetail(AgriGuide guide) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(guide.vietnameseName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green)),
              const SizedBox(height: 16),
              const Text("Chuẩn bị:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text(guide.requirements, style: const TextStyle(fontSize: 15, height: 1.5)),
              const SizedBox(height: 20),
              const Text("Hướng dẫn chi tiết:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text(guide.instructions, style: const TextStyle(fontSize: 15, height: 1.5)),
              const SizedBox(height: 32),
              Center(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                  child: const Text("Đã lưu lại kỹ thuật"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AgriGuide {
  final String name;
  final String vietnameseName;
  final List<String> targets;
  final String requirements;
  final String instructions;
  final String imageUrl;

  AgriGuide({
    required this.name,
    required this.vietnameseName,
    required this.targets,
    required this.requirements,
    required this.instructions,
    required this.imageUrl,
  });
}