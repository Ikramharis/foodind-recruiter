import 'package:flutter/material.dart';
import 'package:http/http.dart' as https;
import 'dart:convert';

const Color kAdminPrimary = Color(0xFF1E3A5F);
const Color kAdminPrimaryLight = Color(0xFF2E6DA4);
const Color kAdminAccent = Color(0xFF00C4B4);
const Color kAdminBackground = Color(0xFFF0F4FF);
const Color kAdminSurface = Colors.white;
const Color kAdminText = Color(0xFF1A1A2E);
const Color kAdminSub = Color(0xFF6B7280);
const Color kAdminError = Color(0xFFEF4444);

class AdminQuestionPage extends StatefulWidget {
  const AdminQuestionPage({super.key});

  @override
  State<AdminQuestionPage> createState() => _AdminQuestionPageState();
}

class _AdminQuestionPageState extends State<AdminQuestionPage> {
  int selectedCriteriaId = 1;
  final List<String> criteriaTitles = [
    'Internet of Things',
    'Blockchain Technology',
    'Robotic Automation',
    'Digital Platform & E-commerce',
    'Cybersecurity',
    'Digital Literacy and Inclusive Access',
    'Data Analytics and Big Data',
    'AI and Machine Learning',
    'Precision Agriculture & Geospatial',
  ];

  List<Map<String, dynamic>> questions = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchQuestions();
  }

  Future<void> fetchQuestions() async {
    setState(() => isLoading = true);
    try {
      final response = await https.get(
        Uri.parse(
            'https://snow-duck-522249.hostingersite.com/get_questions.php?criteria_id=$selectedCriteriaId'),
      );
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        setState(() {
          questions = List<Map<String, dynamic>>.from(data);
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Future<void> addQuestion(String text) async {
    final response = await https.post(
      Uri.parse(
          'https://snow-duck-522249.hostingersite.com/add_question.php'),
      body: {
        'criteria_id': selectedCriteriaId.toString(),
        'question_text': text,
        'option_a': 'Very Agree',
        'option_b': 'Agree',
        'option_c': 'Neutral',
        'option_d': 'Disagree',
        'option_e': 'Very Disagree',
      },
    );
    final data = json.decode(response.body);
    if (!data['success']) throw Exception(data['message']);
  }

  Future<void> updateQuestion(int id, String text) async {
    final response = await https.post(
      Uri.parse(
          'https://snow-duck-522249.hostingersite.com/update_question.php'),
      body: {
        'id': id.toString(),
        'question_text': text,
        'option_a': 'Very Agree',
        'option_b': 'Agree',
        'option_c': 'Neutral',
        'option_d': 'Disagree',
        'option_e': 'Very Disagree',
      },
    );
    if (response.statusCode == 200) fetchQuestions();
  }

  Future<void> deleteQuestion(int id) async {
    final response = await https.post(
      Uri.parse(
          'https://snow-duck-522249.hostingersite.com/delete_question.php'),
      body: {'id': id.toString()},
    );
    if (response.statusCode == 200) fetchQuestions();
  }

  void showQuestionDialog({int? id, Map<String, dynamic>? initialData}) {
    final questionController = TextEditingController(
      text: initialData?['question_text'] ?? '',
    );
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              id == null ? Icons.add_circle_outline : Icons.edit_outlined,
              color: kAdminPrimary,
            ),
            const SizedBox(width: 10),
            Text(id == null ? 'Add Question' : 'Edit Question'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: questionController,
              maxLines: 3,
              style: const TextStyle(color: kAdminText, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Enter question text...',
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                      color: kAdminPrimaryLight, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: kAdminPrimary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: kAdminPrimary.withOpacity(0.15)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Likert Scale (auto-applied):',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: kAdminPrimary,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text('5 — Strongly Agree',
                      style: TextStyle(fontSize: 12, color: kAdminSub)),
                  Text('4 — Agree',
                      style: TextStyle(fontSize: 12, color: kAdminSub)),
                  Text('3 — Neutral',
                      style: TextStyle(fontSize: 12, color: kAdminSub)),
                  Text('2 — Disagree',
                      style: TextStyle(fontSize: 12, color: kAdminSub)),
                  Text('1 — Strongly Disagree',
                      style: TextStyle(fontSize: 12, color: kAdminSub)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: kAdminSub)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: kAdminPrimary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              if (questionController.text.trim().isEmpty) return;
              try {
                if (id == null) {
                  await addQuestion(questionController.text.trim());
                } else {
                  await updateQuestion(
                      id, questionController.text.trim());
                }
                Navigator.pop(context);
                fetchQuestions();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString())));
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kAdminBackground,
      body: Column(
        children: [
          _buildHeader(context),
          _buildCriteriaSelector(),
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: kAdminPrimary))
                : questions.isEmpty
                    ? _buildEmpty()
                    : ListView.builder(
                        padding:
                            const EdgeInsets.fromLTRB(16, 8, 16, 80),
                        itemCount: questions.length,
                        itemBuilder: (context, i) {
                          return _buildQuestionCard(questions[i], i);
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showQuestionDialog(),
        backgroundColor: kAdminPrimary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Add Question',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [kAdminPrimary, kAdminPrimaryLight],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      padding: const EdgeInsets.only(top: 52, bottom: 20, left: 20, right: 20),
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
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Manage Questions',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '${questions.length} questions in this section',
                  style:
                      const TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCriteriaSelector() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: kAdminSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: selectedCriteriaId,
          isExpanded: true,
          items: List.generate(
            criteriaTitles.length,
            (i) => DropdownMenuItem(
              value: i + 1,
              child: Text(
                'Section ${i + 1}: ${criteriaTitles[i]}',
                style: const TextStyle(
                    color: kAdminText,
                    fontSize: 14,
                    fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          onChanged: (val) {
            if (val != null) {
              setState(() => selectedCriteriaId = val);
              fetchQuestions();
            }
          },
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              color: kAdminPrimary),
        ),
      ),
    );
  }

  Widget _buildQuestionCard(Map<String, dynamic> q, int index) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        color: kAdminSurface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 5,
              decoration: BoxDecoration(
                color: kAdminPrimary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: kAdminPrimary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: kAdminPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            q['question_text'] ?? '',
                            style: const TextStyle(
                              fontSize: 14,
                              color: kAdminText,
                              fontWeight: FontWeight.w500,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Likert scale: 1–5',
                            style: TextStyle(
                                fontSize: 11, color: kAdminSub),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        GestureDetector(
                          onTap: () => showQuestionDialog(
                              id: q['id'], initialData: q),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: kAdminPrimary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.edit_outlined,
                                color: kAdminPrimary, size: 16),
                          ),
                        ),
                        const SizedBox(height: 6),
                        GestureDetector(
                          onTap: () => showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(20)),
                              title: const Text('Delete Question'),
                              content: const Text(
                                  'Are you sure you want to delete this question?'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context),
                                  child: const Text('Cancel',
                                      style: TextStyle(
                                          color: kAdminSub)),
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    await deleteQuestion(q['id']);
                                    Navigator.pop(context);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: kAdminError,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(
                                                10)),
                                  ),
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: kAdminError.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                                Icons.delete_outline_rounded,
                                color: kAdminError,
                                size: 16),
                          ),
                        ),
                      ],
                    ),
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
              color: kAdminPrimary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.quiz_outlined,
                color: kAdminPrimary, size: 52),
          ),
          const SizedBox(height: 16),
          const Text(
            'No questions yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: kAdminText,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Tap + Add Question to get started',
            style: TextStyle(fontSize: 13, color: kAdminSub),
          ),
        ],
      ),
    );
  }
}
