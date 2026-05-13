import 'package:flutter/material.dart';
import 'package:http/http.dart' as https;
import 'dart:convert';
import 'admin_candidate_detail.dart';

const Color kAdminPrimary = Color(0xFF1E3A5F);
const Color kAdminPrimaryLight = Color(0xFF2E6DA4);
const Color kAdminAccent = Color(0xFF00C4B4);
const Color kAdminBackground = Color(0xFFF0F4FF);
const Color kAdminSurface = Colors.white;
const Color kAdminText = Color(0xFF1A1A2E);
const Color kAdminSub = Color(0xFF6B7280);
const Color kAdminError = Color(0xFFEF4444);

class AdminProgressPage extends StatefulWidget {
  const AdminProgressPage({super.key});

  @override
  State<AdminProgressPage> createState() => _AdminProgressPageState();
}

class _AdminProgressPageState extends State<AdminProgressPage> {
  List<dynamic> candidates = [];
  bool isLoading = true;
  String? selectedMonth;
  final TextEditingController searchController = TextEditingController();
  List<dynamic> filteredCandidates = [];

  @override
  void initState() {
    super.initState();
    fetchCandidatesWithMarks();
    searchController.addListener(applyFilters);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> fetchCandidatesWithMarks() async {
    final response = await https.get(
      Uri.parse(
          'https://snow-duck-522249.hostingersite.com/get_all_candidates_scores.php'),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success']) {
        setState(() {
          candidates = data['candidates'];
          applyFilters();
          isLoading = false;
        });
      }
    } else {
      setState(() => isLoading = false);
    }
  }

  List<DropdownMenuItem<String>> _getMonthOptions() {
    final months = <String>{};
    for (var c in candidates) {
      final completedAt = c['completed_at'];
      if (completedAt != null) {
        final date = DateTime.tryParse(completedAt);
        if (date != null) {
          months.add(
              "${date.year}-${date.month.toString().padLeft(2, '0')}");
        }
      }
    }
    final sorted = months.toList()..sort();
    return [
      const DropdownMenuItem(value: '', child: Text('All Months')),
      ...sorted.map((m) => DropdownMenuItem(value: m, child: Text(m))),
    ];
  }

  void applyFilters() {
    List<dynamic> temp = List.from(candidates);
    if (selectedMonth != null && selectedMonth!.isNotEmpty) {
      temp = temp.where((c) {
        final completedAt = c['completed_at'];
        if (completedAt == null) return false;
        final date = DateTime.tryParse(completedAt);
        if (date == null) return false;
        return "${date.year}-${date.month.toString().padLeft(2, '0')}" ==
            selectedMonth;
      }).toList();
    }
    final search = searchController.text.trim().toLowerCase();
    if (search.isNotEmpty) {
      temp = temp
          .where((c) =>
              (c['username'] ?? '').toLowerCase().contains(search) ||
              (c['name'] ?? '').toLowerCase().contains(search))
          .toList();
    }
    temp.sort((a, b) {
      final aScore = (a['total_marks'] as num?)?.toDouble() ?? 0;
      final bScore = (b['total_marks'] as num?)?.toDouble() ?? 0;
      return bScore.compareTo(aScore);
    });
    setState(() => filteredCandidates = temp);
  }

  Color _scoreColor(dynamic score) {
    final s = (score as num?)?.toDouble() ?? 0;
    if (s >= 72) return const Color(0xFF00897B);
    if (s >= 54) return const Color(0xFF1565C0);
    if (s >= 36) return const Color(0xFFF59E0B);
    return kAdminError;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kAdminBackground,
      body: Column(
        children: [
          _buildHeader(context),
          _buildFilters(),
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: kAdminPrimary))
                : filteredCandidates.isEmpty
                    ? _buildEmpty()
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          final isTablet = constraints.maxWidth >= 600;
                          final horizontalPadding = isTablet ? constraints.maxWidth * 0.08 : 16.0;
                          return ListView.builder(
                            padding: EdgeInsets.fromLTRB(horizontalPadding, 8, horizontalPadding, 16),
                            itemCount: filteredCandidates.length,
                            itemBuilder: (context, index) {
                              final c = filteredCandidates[index];
                              return _buildCandidateCard(c, index);
                            },
                          );
                        },
                      ),
          ),
        ],
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
                  'Candidate Progress',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '${filteredCandidates.length} of ${candidates.length} results',
                  style:
                      const TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() => isLoading = true);
              fetchCandidatesWithMarks();
            },
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: searchController,
              style: const TextStyle(color: kAdminText, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search candidates...',
                hintStyle:
                    const TextStyle(color: kAdminSub, fontSize: 14),
                prefixIcon: const Icon(Icons.search_rounded,
                    color: kAdminSub, size: 20),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close,
                            color: kAdminSub, size: 18),
                        onPressed: () {
                          searchController.clear();
                          applyFilters();
                        },
                      )
                    : null,
                filled: true,
                fillColor: kAdminSurface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                      color: kAdminPrimaryLight, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: kAdminSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedMonth ?? '',
                items: _getMonthOptions(),
                onChanged: (val) {
                  setState(() {
                    selectedMonth = val;
                    applyFilters();
                  });
                },
                hint: const Text('Month',
                    style: TextStyle(color: kAdminSub, fontSize: 13)),
                style:
                    const TextStyle(color: kAdminText, fontSize: 13),
                icon: const Icon(Icons.keyboard_arrow_down_rounded,
                    color: kAdminSub),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCandidateCard(dynamic c, int index) {
    final totalMarks = c['total_marks'];
    final scoreColor = _scoreColor(totalMarks);
    final initials = (c['name'] ?? c['username'] ?? '?')
        .split(' ')
        .take(2)
        .map((w) => (w as String).isNotEmpty ? w[0].toUpperCase() : '')
        .join();

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
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AdminCandidateDetailPage(
                candidateId: c['id'].toString(),
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [kAdminPrimary, kAdminPrimaryLight],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      index < 3 ? ['🥇', '🥈', '🥉'][index] : initials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
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
                        c['name'] ?? c['username'] ?? '',
                        style: const TextStyle(
                          color: kAdminText,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '@${c['username'] ?? ''}',
                        style: const TextStyle(
                            color: kAdminSub, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: scoreColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${totalMarks ?? 0}/90',
                        style: TextStyle(
                          color: scoreColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'tap to review',
                      style:
                          TextStyle(color: kAdminSub, fontSize: 10),
                    ),
                  ],
                ),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right_rounded,
                    color: kAdminSub, size: 20),
              ],
            ),
          ),
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
            child: const Icon(Icons.bar_chart_rounded,
                color: kAdminPrimary, size: 52),
          ),
          const SizedBox(height: 16),
          const Text(
            'No results found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: kAdminText,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Try adjusting your search or filter',
            style: TextStyle(fontSize: 13, color: kAdminSub),
          ),
        ],
      ),
    );
  }
}
