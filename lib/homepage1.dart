import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as https;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'tips_page.dart';

const Color kPrimary = Color(0xFF1A5F7A);
const Color kPrimaryLight = Color(0xFF2E86AB);
const Color kAccent = Color(0xFF00BFA5);
const Color kBackground = Color(0xFFF0F7FA);
const Color kSurface = Colors.white;
const Color kTextMain = Color(0xFF1A1A2E);
const Color kTextSub = Color(0xFF6B7280);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> showStatusNotification(String status, String remarks) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'status_channel',
    'Status Updates',
    importance: Importance.max,
    priority: Priority.high,
  );
  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);
  await flutterLocalNotificationsPlugin.show(
    0,
    'Remarks',
    remarks.isNotEmpty ? remarks : 'No remarks yet.',
    platformChannelSpecifics,
  );
}

Future<void> initNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

class HomePageUser extends StatelessWidget {
  const HomePageUser({super.key});

  @override
  Widget build(BuildContext context) {
    initNotifications();
    final args = ModalRoute.of(context)!.settings.arguments as Map?;
    final username = args?['username'];
    final width = MediaQuery.of(context).size.width;
    final isTablet = width >= 600;
    final horizontalPadding = isTablet ? 32.0 : 20.0;

    final cards = [
      _DashboardCardData(
        icon: Icons.assignment_turned_in_outlined,
        label: 'Start Test',
        subtitle: 'Take your assessment',
        color: const Color(0xFF2E86AB),
        onTap: () => Navigator.pushNamed(
          context,
          '/criteria',
          arguments: {
            'criteriaId': 1,
            'answers': <String, String>{'username': username ?? ''},
          },
        ),
      ),
      _DashboardCardData(
        icon: Icons.manage_accounts_outlined,
        label: 'Edit Profile',
        subtitle: 'Update your details',
        color: const Color(0xFF7B2D8B),
        onTap: () => Navigator.pushNamed(
          context,
          '/edit-profile',
          arguments: {'username': username},
        ),
      ),
      _DashboardCardData(
        icon: Icons.bar_chart_rounded,
        label: 'View Progress',
        subtitle: 'Check your status',
        color: const Color(0xFF00897B),
        onTap: () async {
          final response = await https.get(
            Uri.parse(
              'https://snow-duck-522249.hostingersite.com/get_candidate_status.php?username=$username',
            ),
          );
          String status = 'Unknown';
          String remarks = '';
          if (response.statusCode == 200) {
            final data = json.decode(response.body);
            if (data['success']) {
              status = data['status'];
              remarks = data['remarks'] ?? '';
            } else {
              status = data['message'] ?? 'Unknown';
            }
          }
          await showStatusNotification(status, remarks);
          Navigator.pushNamed(
            context,
            '/view-progress',
            arguments: {'username': username},
          );
        },
      ),
      _DashboardCardData(
        icon: Icons.lightbulb_outline_rounded,
        label: 'Tips',
        subtitle: 'Interview & career tips',
        color: const Color(0xFFE65100),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const TipsPage(isAdmin: false),
          ),
        ),
      ),
    ];

    return Scaffold(
      backgroundColor: kBackground,
      body: Column(
        children: [
          _buildHeader(context, username),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'What would you like to do?',
                    style: TextStyle(
                      fontSize: isTablet ? 20 : 17,
                      fontWeight: FontWeight.w600,
                      color: kTextMain,
                    ),
                  ),
                  const SizedBox(height: 16),
                  isTablet
                      ? SizedBox(
                          height: 160,
                          child: Row(
                            children: cards
                                .map((c) => Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 6),
                                        child: _DashboardCard(
                                          icon: c.icon,
                                          label: c.label,
                                          subtitle: c.subtitle,
                                          color: c.color,
                                          onTap: c.onTap,
                                        ),
                                      ),
                                    ))
                                .toList(),
                          ),
                        )
                      : GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          childAspectRatio: 0.95,
                          children: cards
                              .map((c) => _DashboardCard(
                                    icon: c.icon,
                                    label: c.label,
                                    subtitle: c.subtitle,
                                    color: c.color,
                                    onTap: c.onTap,
                                  ))
                              .toList(),
                        ),
                  const SizedBox(height: 20),
                  _buildInfoBanner(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: kPrimary),
            SizedBox(width: 8),
            Text('Logout'),
          ],
        ),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: kTextSub)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('session_username');
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  Widget _buildHeader(BuildContext context, String? username) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, ${username ?? 'Candidate'} 👋',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Welcome to FoodInd Recruiter',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.85),
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.logout_rounded, color: Colors.white, size: 22),
                  tooltip: 'Logout',
                  onPressed: () => _confirmLogout(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [kAccent.withOpacity(0.15), kPrimaryLight.withOpacity(0.1)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kAccent.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: kAccent.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.info_outline_rounded, color: kAccent, size: 22),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Complete your profile',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: kTextMain,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Make sure your resume is uploaded for a better chance.',
                  style: TextStyle(color: kTextSub, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardCardData {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  _DashboardCardData({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });
}

class _DashboardCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: kSurface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.15),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const Spacer(),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: kTextMain,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 11, color: kTextSub),
            ),
          ],
        ),
      ),
    );
  }
}
