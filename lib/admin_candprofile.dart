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

class CandidateProfilePage extends StatefulWidget {
  final String candidateId;

  const CandidateProfilePage({super.key, required this.candidateId});

  @override
  State<CandidateProfilePage> createState() => _CandidateProfilePageState();
}

class _CandidateProfilePageState extends State<CandidateProfilePage> {
  Map<String, dynamic>? candidateData;
  bool _isLoading = true;

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
      });
    } else {
      setState(() => _isLoading = false);
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
    } catch (e) {
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
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not download resume')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kAdminBackground,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: kAdminPrimary))
          : Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _buildInfoCard(),
                        const SizedBox(height: 16),
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
      padding: const EdgeInsets.only(top: 52, bottom: 28, left: 20, right: 20),
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
                'Candidate Profile',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(
                  color: Colors.white.withOpacity(0.5), width: 2),
            ),
            child: Center(
              child: Text(
                initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '@${candidateData?['username'] ?? ''}',
            style: const TextStyle(fontSize: 13, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
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
          const Row(
            children: [
              Icon(Icons.person_outline_rounded, color: kAdminPrimary, size: 20),
              SizedBox(width: 8),
              Text(
                'Personal Information',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: kAdminText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _infoRow(Icons.badge_outlined, 'Full Name',
              candidateData?['name'] ?? ''),
          _infoRow(Icons.email_outlined, 'Email',
              candidateData?['email'] ?? ''),
          _infoRow(Icons.phone_outlined, 'Phone',
              candidateData?['phone_no'] ?? ''),
          _infoRow(Icons.alternate_email_rounded, 'Username',
              candidateData?['username'] ?? ''),
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
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: kAdminSub,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value.isNotEmpty ? value : '—',
                  style: const TextStyle(
                    fontSize: 14,
                    color: kAdminText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResumeCard() {
    final hasResume = candidateData?['resume'] != null &&
        candidateData!['resume'].toString().isNotEmpty;

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
          const Row(
            children: [
              Icon(Icons.description_outlined,
                  color: kAdminPrimary, size: 20),
              SizedBox(width: 8),
              Text(
                'Resume',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: kAdminText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (hasResume) ...[
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
            const SizedBox(height: 14),
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
          ] else
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline_rounded,
                      color: kAdminSub, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'No resume uploaded by this candidate',
                    style: TextStyle(color: kAdminSub, fontSize: 13),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
