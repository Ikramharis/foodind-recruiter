import 'package:flutter/material.dart';
import 'package:http/http.dart' as https;
import 'dart:convert';

const Color kPrimary = Color(0xFF1A5F7A);
const Color kPrimaryLight = Color(0xFF2E86AB);
const Color kAccent = Color(0xFF00BFA5);
const Color kBackground = Color(0xFFF0F7FA);
const Color kSurface = Colors.white;
const Color kTextMain = Color(0xFF1A1A2E);
const Color kTextSub = Color(0xFF6B7280);
const Color kError = Color(0xFFEF4444);

final List<Color> _tipColors = [
  const Color(0xFF2E86AB),
  const Color(0xFF00897B),
  const Color(0xFF7B2D8B),
  const Color(0xFFE65100),
  const Color(0xFF1565C0),
  const Color(0xFF558B2F),
];

class TipsPage extends StatefulWidget {
  final bool isAdmin;
  const TipsPage({super.key, required this.isAdmin});

  @override
  State<TipsPage> createState() => _TipsPageState();
}

class _TipsPageState extends State<TipsPage> {
  List tips = [];
  bool isLoading = true;
  String error = '';

  @override
  void initState() {
    super.initState();
    fetchTips();
  }

  Future<void> fetchTips() async {
    setState(() {
      isLoading = true;
      error = '';
    });
    final response = await https.get(
      Uri.parse('https://snow-duck-522249.hostingersite.com/get_tips.php'),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success']) {
        setState(() {
          tips = data['tips'];
          isLoading = false;
        });
      } else {
        setState(() {
          error = data['message'] ?? 'Failed to load tips';
          isLoading = false;
        });
      }
    } else {
      setState(() {
        error = 'Server error: ${response.statusCode}';
        isLoading = false;
      });
    }
  }

  Future<void> addTip(String content) async {
    final response = await https.post(
      Uri.parse('https://snow-duck-522249.hostingersite.com/add_tip.php'),
      body: {'content': content},
    );
    if (response.statusCode == 200) fetchTips();
  }

  Future<void> editTip(int id, String content) async {
    final response = await https.post(
      Uri.parse('https://snow-duck-522249.hostingersite.com/edit_tip.php'),
      body: {'id': id.toString(), 'content': content},
    );
    if (response.statusCode == 200) fetchTips();
  }

  Future<void> deleteTip(int id) async {
    final response = await https.post(
      Uri.parse('https://snow-duck-522249.hostingersite.com/delete_tip.php'),
      body: {'id': id.toString()},
    );
    if (response.statusCode == 200) fetchTips();
  }

  void showTipDialog({int? id, String? initialContent}) {
    final controller = TextEditingController(text: initialContent ?? '');
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(id == null ? Icons.add_circle_outline : Icons.edit_outlined,
                color: kPrimary),
            const SizedBox(width: 10),
            Text(id == null ? 'Add Tip' : 'Edit Tip'),
          ],
        ),
        content: TextField(
          controller: controller,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Enter tip content...',
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: kPrimaryLight, width: 2),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: kTextSub)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim().isEmpty) return;
              if (id == null) {
                await addTip(controller.text.trim());
              } else {
                await editTip(id, controller.text.trim());
              }
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator(color: kPrimary))
                : error.isNotEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline_rounded,
                                color: kError, size: 48),
                            const SizedBox(height: 12),
                            Text(error,
                                style: const TextStyle(color: kError, fontSize: 14)),
                          ],
                        ),
                      )
                    : tips.isEmpty
                        ? _buildEmpty()
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                            itemCount: tips.length,
                            itemBuilder: (context, i) {
                              final tip = tips[i];
                              final color = _tipColors[i % _tipColors.length];
                              return _buildTipCard(tip, i, color);
                            },
                          ),
          ),
        ],
      ),
      floatingActionButton: widget.isAdmin
          ? FloatingActionButton.extended(
              onPressed: () => showTipDialog(),
              backgroundColor: kPrimary,
              icon: const Icon(Icons.add_rounded, color: Colors.white),
              label: const Text('Add Tip',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            )
          : null,
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [kPrimary, kPrimaryLight],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      padding: const EdgeInsets.only(top: 56, bottom: 28, left: 24, right: 24),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.arrow_back_ios_new,
                  color: Colors.white, size: 18),
            ),
          ),
          const SizedBox(width: 16),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Career Tips',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Advice to help you succeed',
                style: TextStyle(fontSize: 12, color: Colors.white70),
              ),
            ],
          ),
          const Spacer(),
          const Icon(Icons.lightbulb_rounded, color: Colors.white70, size: 28),
        ],
      ),
    );
  }

  Widget _buildTipCard(dynamic tip, int index, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 5,
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        tip['content'],
                        style: const TextStyle(
                          fontSize: 14,
                          color: kTextMain,
                          height: 1.5,
                        ),
                      ),
                    ),
                    if (widget.isAdmin) ...[
                      const SizedBox(width: 8),
                      Column(
                        children: [
                          GestureDetector(
                            onTap: () => showTipDialog(
                              id: int.parse(tip['id'].toString()),
                              initialContent: tip['content'],
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: kPrimary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.edit_outlined,
                                  color: kPrimary, size: 16),
                            ),
                          ),
                          const SizedBox(height: 6),
                          GestureDetector(
                            onTap: () => showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20)),
                                title: const Text('Delete Tip'),
                                content: const Text(
                                    'Are you sure you want to delete this tip?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Cancel',
                                        style: TextStyle(color: kTextSub)),
                                  ),
                                  ElevatedButton(
                                    onPressed: () async {
                                      await deleteTip(
                                          int.parse(tip['id'].toString()));
                                      Navigator.pop(context);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: kError,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                    ),
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: kError.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.delete_outline_rounded,
                                  color: kError, size: 16),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: kPrimary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.lightbulb_outline_rounded,
                color: kPrimary, size: 52),
          ),
          const SizedBox(height: 16),
          const Text(
            'No tips available yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: kTextMain,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Check back soon for career advice',
            style: TextStyle(fontSize: 13, color: kTextSub),
          ),
        ],
      ),
    );
  }
}
