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

class CriteriaScreen extends StatefulWidget {
  final int criteriaId;
  final Map<String, String> answers;

  const CriteriaScreen({
    super.key,
    required this.criteriaId,
    required this.answers,
  });

  @override
  State<CriteriaScreen> createState() => _CriteriaScreenState();
}

class _CriteriaScreenState extends State<CriteriaScreen> {
  late Map<String, String> answers;
  List<Map<String, dynamic>> questions = [];
  bool isLoading = false;
  String criteriaTitle = "";

  @override
  void initState() {
    super.initState();
    answers = Map<String, String>.from(widget.answers);
    fetchCriteriaTitle();
    fetchQuestions();
  }

  Future<void> fetchCriteriaTitle() async {
    setState(() => isLoading = true);
    try {
      final response = await https.get(
        Uri.parse(
          'https://snow-duck-522249.hostingersite.com/get_criteria.php?criteria_id=${widget.criteriaId}',
        ),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          criteriaTitle =
              data['criteria']?['title'] ?? "Criteria ${widget.criteriaId}";
        });
      } else {
        setState(() => criteriaTitle = "Criteria ${widget.criteriaId}");
      }
    } catch (e) {
      setState(() => criteriaTitle = "Criteria ${widget.criteriaId}");
    }
    setState(() => isLoading = false);
  }

  Future<void> fetchQuestions() async {
    setState(() => isLoading = true);
    try {
      final response = await https.get(
        Uri.parse(
          'https://snow-duck-522249.hostingersite.com/get_questions.php?criteria_id=${widget.criteriaId}',
        ),
      );
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        setState(() {
          questions = List<Map<String, dynamic>>.from(data);
        });
      }
    } catch (_) {}
    setState(() => isLoading = false);
  }

  void updateAnswer(String questionKey, String value) {
    setState(() {
      answers[questionKey] = value;
    });
  }

  Future<void> submitAnswers() async {
    final username = answers['username'];
    List<Map<String, dynamic>> answerList = [];
    for (var q in questions) {
      String key = "criteria${widget.criteriaId}_q${questions.indexOf(q) + 1}";
      String? selected = answers[key];
      if (selected != null) {
        answerList.add({
          'question_id': q['id'].toString(),
          'selected_value': selected,
          'criteria_id': widget.criteriaId.toString(),
        });
      }
    }
    await https.post(
      Uri.parse('https://snow-duck-522249.hostingersite.com/submit_answers.php'),
      body: {'username': username ?? '', 'answers': jsonEncode(answerList)},
    );
  }

  void goToNextCriteria() async {
    await submitAnswers();
    int nextId = widget.criteriaId + 1;
    if (nextId <= 9) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              CriteriaScreen(criteriaId: nextId, answers: answers),
        ),
      );
    } else {
      Navigator.pushReplacementNamed(context, "/result_page", arguments: answers);
    }
  }

  Future<void> submitResult() async {
    await submitAnswers();
    final response = await https.get(
      Uri.parse(
        'https://snow-duck-522249.hostingersite.com/get_total_score.php?username=${answers['username']}',
      ),
    );
    int totalScore = 0;
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success']) {
        totalScore = int.tryParse(data['total_score'].toString()) ?? 0;
      }
    }
    Navigator.pushReplacementNamed(
      context,
      "/result_page",
      arguments: {...answers, 'total_score': totalScore.toString()},
    );
  }

  bool _allQuestionsAnswered() {
    for (int i = 0; i < questions.length; i++) {
      String key = "criteria${widget.criteriaId}_q${i + 1}";
      if (!answers.containsKey(key) || answers[key]!.isEmpty) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    if ((answers['username'] ?? '').isEmpty) {
      answers['username'] = widget.answers['username'] ?? '';
    }

    final progress = widget.criteriaId / 9;

    return Scaffold(
      backgroundColor: kBackground,
      body: Column(
        children: [
          _buildHeader(context, progress),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator(color: kPrimary))
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                    children: [
                      if (criteriaTitle.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: kPrimary.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                                color: kPrimary.withOpacity(0.2)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.quiz_outlined,
                                  color: kPrimary, size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  criteriaTitle,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: kPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      for (int i = 0; i < questions.length; i++) ...[
                        _buildQuestionCard(i),
                        const SizedBox(height: 12),
                      ],
                    ],
                  ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildHeader(BuildContext context, double progress) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [kPrimary, kPrimaryLight],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      padding: const EdgeInsets.only(top: 52, bottom: 20, left: 20, right: 20),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context, answers),
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
                    Text(
                      criteriaTitle.isNotEmpty
                          ? criteriaTitle
                          : 'Section ${widget.criteriaId}',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Step ${widget.criteriaId} of 9',
                      style: const TextStyle(
                          fontSize: 12, color: Colors.white70),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${widget.criteriaId}/9',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withOpacity(0.25),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(int i) {
    final qNum = (widget.criteriaId - 1) * 2 + (i + 1);
    final key = "criteria${widget.criteriaId}_q${i + 1}";
    final answered = answers.containsKey(key) && answers[key]!.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: answered ? kAccent.withOpacity(0.4) : const Color(0xFFE2E8F0),
          width: answered ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: kPrimary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Q$qNum',
                  style: const TextStyle(
                    color: kPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  questions[i]['question_text'] ?? '',
                  style: const TextStyle(
                    fontSize: 14,
                    color: kTextMain,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
              ),
              if (answered)
                const Icon(Icons.check_circle_rounded,
                    color: kAccent, size: 20),
            ],
          ),
          const SizedBox(height: 12),
          ..._buildLikertOptions(key),
        ],
      ),
    );
  }

  List<Widget> _buildLikertOptions(String questionKey) {
    final likertOptions = [
      {'label': 'Strongly Agree', 'value': 5},
      {'label': 'Agree', 'value': 4},
      {'label': 'Neutral', 'value': 3},
      {'label': 'Disagree', 'value': 2},
      {'label': 'Strongly Disagree', 'value': 1},
    ];

    return likertOptions.map((opt) {
      final val = opt['value'] as int;
      final selected = int.tryParse(answers[questionKey] ?? '') == val;

      return GestureDetector(
        onTap: () => updateAnswer(questionKey, val.toString()),
        child: Container(
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? kPrimary.withOpacity(0.08) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? kPrimary : const Color(0xFFE2E8F0),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected ? kPrimary : const Color(0xFFCBD5E1),
                    width: 2,
                  ),
                  color: selected ? kPrimary : Colors.transparent,
                ),
                child: selected
                    ? const Icon(Icons.check, color: Colors.white, size: 12)
                    : null,
              ),
              const SizedBox(width: 12),
              Text(
                opt['label']!.toString(),
                style: TextStyle(
                  fontSize: 14,
                  color: selected ? kPrimary : kTextMain,
                  fontWeight:
                      selected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  Widget _buildBottomBar() {
    final canProceed = questions.isNotEmpty && _allQuestionsAnswered();

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: BoxDecoration(
        color: kSurface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: kPrimary,
                side: const BorderSide(color: kPrimary),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () => Navigator.pop(context, answers),
              child: const Text('Back',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: canProceed
                    ? const LinearGradient(colors: [kPrimary, kPrimaryLight])
                    : const LinearGradient(
                        colors: [Color(0xFFCBD5E1), Color(0xFFCBD5E1)]),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: canProceed
                    ? (widget.criteriaId < 9 ? goToNextCriteria : submitResult)
                    : null,
                child: Text(
                  widget.criteriaId < 9 ? 'Next Section →' : 'Submit Test',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
