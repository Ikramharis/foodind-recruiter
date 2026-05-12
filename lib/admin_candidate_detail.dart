import 'package:flutter/material.dart';
import 'package:http/http.dart' as https;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

const Color kAdminPrimary = Color(0xFF1E3A5F);
const Color kAdminPrimaryLight = Color(0xFF2E6DA4);
const Color kAdminAccent = Color(0xFF00C4B4);
const Color kAdminBackground = Color(0xFFF0F4FF);
const Color kAdminSurface = Colors.white;
const Color kAdminText = Color(0xFF1A1A2E);
const Color kAdminSub = Color(0xFF6B7280);
const Color kAdminError = Color(0xFFEF4444);

class AdminCandidateDetailPage extends StatefulWidget {
  final String candidateId;

  const AdminCandidateDetailPage({super.key, required this.candidateId});

  @override
  State<AdminCandidateDetailPage> createState() =>
      _AdminCandidateDetailPageState();
}

class _AdminCandidateDetailPageState
    extends State<AdminCandidateDetailPage> {
  Map<String, dynamic>? candidateData;
  Map<String, dynamic>? criteriaScores;
  bool _isLoading = true;
  TextEditingController? _remarksController;
  String? _selectedStatus;

  final List<String> criteriaTitles = [
    'Internet of Things',
    'Blockchain Technology',
    'Robotic Automation',
    'Digital Platform & E-commerce',
    'Cybersecurity',
    'Digital Literacy and Inclusive Access',
    'Data Analytics and Big Data',
    'Artificial Intelligence and Machine Learning',
    'Precision Agriculture and Geospatial Technology',
  ];

  final List<String> statusOptions = [
    'Pending',
    'Accepted',
    'Rejected',
  ];

  @override
  void initState() {
    super.initState();
    fetchCandidateDetails();
  }

  Future<void> fetchCandidateDetails() async {
    final response = await https.get(
      Uri.parse(
          'https://snow-duck-522249.hostingersite.com/get_candidate_detail.php?id=${widget.candidateId}'),
    );
    if (response.statusCode == 200) {
      setState(() {
        candidateData = json.decode(response.body);
        _isLoading = false;
        _remarksController = TextEditingController(
          text: candidateData?['remarks'] ?? '',
        );
        _selectedStatus = candidateData?['status'] ?? 'Pending';
      });
      fetchCriteriaScores();
    }
  }

  Future<void> fetchCriteriaScores() async {
    final username = candidateData?['username'];
    if (username == null) return;
    final response = await https.get(
      Uri.parse(
          'https://snow-duck-522249.hostingersite.com/get_criteria_scores.php?username=$username'),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success']) {
        setState(() => criteriaScores = data['scores']);
      }
    }
  }

  void _openResume() async {
    final String resumeUrl = candidateData?['resume'] ?? '';
    if (resumeUrl.isEmpty) return;
    final String url = resumeUrl.startsWith('https')
        ? resumeUrl
        : 'https://snow-duck-522249.hostingersite.com/$resumeUrl';
    try {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open resume')),
        );
      }
    }
  }

  void _downloadResume() async {
    final String resumeUrl = candidateData?['resume'] ?? '';
    if (resumeUrl.isEmpty) return;
    final String url = resumeUrl.startsWith('https')
        ? resumeUrl
        : 'https://snow-duck-522249.hostingersite.com/$resumeUrl';
    try {
      await launchUrl(Uri.parse(url), mode: LaunchMode.platformDefault);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not download resume')),
        );
      }
    }
  }

  Future<void> updateRemarks() async {
    final response = await https.post(
      Uri.parse(
          'https://snow-duck-522249.hostingersite.com/update_candidate_remarks.php'),
      body: {
        'id': widget.candidateId,
        'remarks': _remarksController?.text ?? '',
        if (_selectedStatus != null) 'status': _selectedStatus!,
      },
    );
    if (response.statusCode == 200) {
      await fetchCandidateDetails();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white),
                SizedBox(width: 8),
                Text('Remarks & status updated!'),
              ],
            ),
            backgroundColor: kAdminAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  Color _scoreColor(dynamic score) {
    final s = (score as num?)?.toDouble() ?? 0;
    if (s >= 8) return const Color(0xFF00897B);
    if (s >= 6) return const Color(0xFF1565C0);
    if (s >= 4) return const Color(0xFFF59E0B);
    return kAdminError;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kAdminBackground,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: kAdminPrimary))
          : Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    child: Column(
                      children: [
                        _buildInfoCard(),
                        const SizedBox(height: 16),
                        if (criteriaScores != null) _buildScoresCard(),
                        const SizedBox(height: 16),
                        _buildRemarksCard(),
                        const SizedBox(height: 16),
                        if (candidateData?['resume'] != null &&
                            candidateData!['resume'].toString().isNotEmpty)
                          _buildResumeCard(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final name = candidateData?['name'] ?? '';
    final initials = name
        .split(' ')
        .take(2)
        .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
        .join();
    final totalMarks = candidateData?['total_marks'] ?? 0;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [kAdminPrimary, kAdminPrimaryLight],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      padding:
          const EdgeInsets.only(top: 52, bottom: 24, left: 20, right: 20),
      child: Column(
        children: [
          Row(
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
              const Text(
                'Candidate Detail',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                onPressed: () {
                  setState(() => _isLoading = true);
                  fetchCandidateDetails();
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: Colors.white.withOpacity(0.4), width: 2),
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '@${candidateData?['username'] ?? ''}',
                      style: const TextStyle(
                          fontSize: 12, color: Colors.white70),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      '$totalMarks',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'Total',
                      style:
                          TextStyle(color: Colors.white70, fontSize: 10),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return _card(
      icon: Icons.person_outline_rounded,
      title: 'Personal Information',
      child: Column(
        children: [
          _infoRow(Icons.badge_outlined, 'Full Name',
              candidateData?['name'] ?? ''),
          _infoRow(Icons.email_outlined, 'Email',
              candidateData?['email'] ?? ''),
          _infoRow(Icons.phone_outlined, 'Phone',
              candidateData?['phone_no'] ?? ''),
          _infoRow(Icons.alternate_email_rounded, 'Username',
              candidateData?['username'] ?? ''),
          if (candidateData?['completed_at'] != null &&
              candidateData!['completed_at'].toString().isNotEmpty)
            _infoRow(Icons.calendar_today_outlined, 'Test Completed',
                candidateData!['completed_at'].toString()),
        ],
      ),
    );
  }

  Widget _buildScoresCard() {
    return _card(
      icon: Icons.bar_chart_rounded,
      title: 'Criteria Scores',
      child: Column(
        children: List.generate(criteriaTitles.length, (i) {
          final score = criteriaScores?['criteria${i + 1}'] ?? 0;
          final pct = (score as num).toDouble() / 10;
          final color = _scoreColor(score);
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '${i + 1}. ${criteriaTitles[i]}',
                        style: const TextStyle(
                            fontSize: 12, color: kAdminText),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '$score/10',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: pct.clamp(0.0, 1.0),
                    backgroundColor: const Color(0xFFE2E8F0),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    minHeight: 7,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildRemarksCard() {
    return _card(
      icon: Icons.edit_note_rounded,
      title: 'Remarks & Status',
      child: Column(
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedStatus,
                isExpanded: true,
                items: statusOptions.map((s) {
                  Color c = s == 'Accepted'
                      ? const Color(0xFF00897B)
                      : s == 'Rejected'
                          ? kAdminError
                          : const Color(0xFFF59E0B);
                  return DropdownMenuItem(
                    value: s,
                    child: Row(
                      children: [
                        Icon(
                          s == 'Accepted'
                              ? Icons.check_circle_rounded
                              : s == 'Rejected'
                                  ? Icons.cancel_rounded
                                  : Icons.hourglass_top_rounded,
                          color: c,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(s,
                            style: TextStyle(
                                color: c, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (val) =>
                    setState(() => _selectedStatus = val),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _remarksController,
            maxLines: 3,
            style: const TextStyle(color: kAdminText, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Write remarks for this candidate...',
              hintStyle:
                  const TextStyle(color: kAdminSub, fontSize: 13),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                    color: kAdminPrimaryLight, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [kAdminPrimary, kAdminPrimaryLight]),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: kAdminPrimary.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.save_rounded,
                    color: Colors.white, size: 18),
                label: const Text(
                  'Save Remarks & Status',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                onPressed: updateRemarks,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResumeCard() {
    return _card(
      icon: Icons.description_outlined,
      title: 'Resume',
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: kAdminAccent.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: kAdminAccent.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.attach_file_rounded,
                    color: kAdminAccent, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    candidateData!['resume'].split('/').last,
                    style: const TextStyle(
                      color: kAdminText,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.visibility_outlined, size: 18),
                  label: const Text('View'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: kAdminPrimary,
                    side: const BorderSide(color: kAdminPrimary),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: _openResume,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.download_rounded,
                      size: 18, color: Colors.white),
                  label: const Text('Download',
                      style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kAdminPrimary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: _downloadResume,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _card({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: kAdminSurface,
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
          Row(
            children: [
              Icon(icon, color: kAdminPrimary, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: kAdminText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: kAdminPrimaryLight, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 11,
                        color: kAdminSub,
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(
                  value.isNotEmpty ? value : '—',
                  style: const TextStyle(
                      fontSize: 14,
                      color: kAdminText,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
