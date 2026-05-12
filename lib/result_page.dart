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

class ResultPage extends StatelessWidget {
  final Map<String, String> answers;

  const ResultPage({super.key, required this.answers});

  int calculateTotalScore() {
    int totalScore = 0;
    for (int criteria = 1; criteria <= 9; criteria++) {
      for (int question = 1; question <= 2; question++) {
        String key = "criteria${criteria}_q$question";
        String? answer = answers[key];
        if (answer != null) {
          totalScore += int.tryParse(answer) ?? 0;
        }
      }
    }
    return totalScore;
  }

  String getResultCategory(int totalScore) {
    double percentage = (totalScore / 100) * 100;
    if (percentage >= 80) return "Excellent";
    if (percentage >= 60) return "Good";
    if (percentage >= 40) return "Average";
    if (percentage >= 20) return "Below Average";
    return "Needs Improvement";
  }

  Color _categoryColor(String category) {
    switch (category) {
      case 'Excellent':
        return const Color(0xFF00897B);
      case 'Good':
        return const Color(0xFF1565C0);
      case 'Average':
        return const Color(0xFFF59E0B);
      case 'Below Average':
        return const Color(0xFFE65100);
      default:
        return const Color(0xFFEF4444);
    }
  }

  IconData _categoryIcon(String category) {
    switch (category) {
      case 'Excellent':
        return Icons.star_rounded;
      case 'Good':
        return Icons.thumb_up_rounded;
      case 'Average':
        return Icons.trending_flat_rounded;
      case 'Below Average':
        return Icons.trending_down_rounded;
      default:
        return Icons.refresh_rounded;
    }
  }

  Future<Map<String, dynamic>?> fetchCriteriaScores(String username) async {
    final response = await https.get(
      Uri.parse(
          'https://snow-duck-522249.hostingersite.com/get_criteria_scores.php?username=$username'),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success']) return data['scores'];
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final username = answers['username'] ?? '';
    return FutureBuilder<Map<String, dynamic>?>(
      future: fetchCriteriaScores(username),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: kBackground,
            body: Center(
              child: Text('Error: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red)),
            ),
          );
        }
        if (!snapshot.hasData) {
          return const Scaffold(
            backgroundColor: kBackground,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: kPrimary),
                  SizedBox(height: 16),
                  Text('Calculating results...',
                      style: TextStyle(color: kTextSub)),
                ],
              ),
            ),
          );
        }

        final scores = snapshot.data!;
        final totalScore = calculateTotalScore();
        final category = getResultCategory(totalScore);
        final catColor = _categoryColor(category);
        final catIcon = _categoryIcon(category);
        final serverTotal = scores['total_score'] ?? totalScore;

        return Scaffold(
          backgroundColor: kBackground,
          body: Column(
            children: [
              _buildHeader(catColor, catIcon, category, serverTotal),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                  children: [
                    _buildScoreBreakdown(scores),
                    const SizedBox(height: 16),
                    _buildCategoryCard(category, catColor),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: _buildBottomBar(context),
        );
      },
    );
  }

  Widget _buildHeader(
      Color catColor, IconData catIcon, String category, dynamic total) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [catColor.withOpacity(0.9), catColor],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(36),
          bottomRight: Radius.circular(36),
        ),
      ),
      padding: const EdgeInsets.only(top: 60, bottom: 32, left: 24, right: 24),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(catIcon, color: Colors.white, size: 48),
          ),
          const SizedBox(height: 16),
          const Text(
            'Assessment Complete!',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Total Score: $total / 90',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreBreakdown(Map<String, dynamic> scores) {
    final criteriaNames = [
      'Communication',
      'Teamwork',
      'Leadership',
      'Problem Solving',
      'Adaptability',
      'Technical Skills',
      'Work Ethic',
      'Creativity',
      'Professionalism',
    ];

    return Container(
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.bar_chart_rounded, color: kPrimary, size: 20),
              SizedBox(width: 8),
              Text(
                'Score Breakdown',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: kTextMain,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...List.generate(9, (i) {
            final score = scores['criteria${i + 1}'] ?? 0;
            final maxScore = 10;
            final pct = (score as num).toDouble() / maxScore;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        criteriaNames[i],
                        style: const TextStyle(fontSize: 13, color: kTextMain),
                      ),
                      Text(
                        '$score / $maxScore',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: kPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: pct.clamp(0.0, 1.0),
                      backgroundColor: const Color(0xFFE2E8F0),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        pct >= 0.8
                            ? const Color(0xFF00897B)
                            : pct >= 0.6
                                ? kPrimary
                                : pct >= 0.4
                                    ? const Color(0xFFF59E0B)
                                    : const Color(0xFFEF4444),
                      ),
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(String category, Color catColor) {
    final messages = {
      'Excellent': 'Outstanding performance! You are a top candidate.',
      'Good': 'Great job! You have strong potential.',
      'Average': 'Decent performance. Keep improving your skills.',
      'Below Average': 'There is room for improvement. Keep practicing.',
      'Needs Improvement': 'Focus on building your core competencies.',
    };

    return Container(
      decoration: BoxDecoration(
        color: catColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: catColor.withOpacity(0.3)),
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: catColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.emoji_events_rounded, color: catColor, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: catColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  messages[category] ?? '',
                  style: TextStyle(
                    fontSize: 13,
                    color: catColor.withOpacity(0.8),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
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
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [kPrimary, kPrimaryLight]),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: kPrimary.withOpacity(0.35),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            icon: const Icon(Icons.home_rounded, color: Colors.white),
            label: const Text(
              'Back to Home',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/home',
                (route) => false,
                arguments: {'username': answers['username']},
              );
            },
          ),
        ),
      ),
    );
  }
}
