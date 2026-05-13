import 'package:flutter/material.dart';
import 'package:http/http.dart' as https;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin _notifPlugin =
    FlutterLocalNotificationsPlugin();

const Color kPrimary = Color(0xFF1A5F7A);
const Color kPrimaryLight = Color(0xFF2E86AB);
const Color kAccent = Color(0xFF00BFA5);
const Color kBackground = Color(0xFFF0F7FA);
const Color kSurface = Colors.white;
const Color kTextMain = Color(0xFF1A1A2E);
const Color kTextSub = Color(0xFF6B7280);
const Color kError = Color(0xFFEF4444);

class ViewProgressPage extends StatefulWidget {
  const ViewProgressPage({super.key});

  @override
  State<ViewProgressPage> createState() => _ViewProgressPageState();
}

class _ViewProgressPageState extends State<ViewProgressPage> {
  String? remarks;
  String? status;
  bool isLoading = true;
  String error = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    final username = args?['username'];
    if (username != null) {
      fetchRemarks(username);
    } else {
      setState(() {
        isLoading = false;
        error = 'No username found';
      });
    }
  }

  Future<void> _initNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    await _notifPlugin.initialize(
        const InitializationSettings(android: androidSettings));
  }

  Future<void> _fireStatusNotification(String newStatus) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'status_update_channel',
      'Status Updates',
      importance: Importance.high,
      priority: Priority.high,
    );
    await _notifPlugin.show(
      1,
      'Application Status Changed',
      'Your status has been updated to: $newStatus',
      const NotificationDetails(android: androidDetails),
    );
  }

  Future<void> fetchRemarks(String username) async {
    setState(() {
      isLoading = true;
      error = '';
    });
    final response = await https.get(
      Uri.parse(
          'https://snow-duck-522249.hostingersite.com/get_candidate_status.php?username=$username'),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success']) {
        final newStatus = data['status'] as String?;

        // Check if status changed since last visit
        final prefs = await SharedPreferences.getInstance();
        final lastStatus = prefs.getString('last_status_$username');
        if (lastStatus != null && lastStatus != newStatus && newStatus != null) {
          await _initNotifications();
          await _fireStatusNotification(newStatus);
        }
        if (newStatus != null) {
          await prefs.setString('last_status_$username', newStatus);
        }

        setState(() {
          status = newStatus;
          remarks = data['remarks'];
          isLoading = false;
        });
      } else {
        setState(() {
          error = data['message'];
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

  Color _statusColor(String? s) {
    switch ((s ?? '').toLowerCase()) {
      case 'accepted':
        return const Color(0xFF00897B);
      case 'rejected':
        return kError;
      case 'pending':
        return const Color(0xFFF59E0B);
      default:
        return kTextSub;
    }
  }

  IconData _statusIcon(String? s) {
    switch ((s ?? '').toLowerCase()) {
      case 'accepted':
        return Icons.check_circle_rounded;
      case 'rejected':
        return Icons.cancel_rounded;
      case 'pending':
        return Icons.hourglass_top_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    final username = args?['username'];

    final width = MediaQuery.of(context).size.width;
    final isTablet = width >= 600;

    return Scaffold(
      backgroundColor: kBackground,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: kPrimary))
                : error.isNotEmpty
                    ? _buildError()
                    : isTablet
                        ? Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 640),
                              child: _buildContent(),
                            ),
                          )
                        : _buildContent(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (username != null) fetchRemarks(username);
        },
        backgroundColor: kPrimary,
        icon: const Icon(Icons.refresh_rounded, color: Colors.white),
        label: const Text('Refresh',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                'My Progress',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Track your application status',
                style: TextStyle(fontSize: 12, color: Colors.white70),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final statusColor = _statusColor(status);
    final statusIcon = _statusIcon(status);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: kSurface,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: statusColor.withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            padding: const EdgeInsets.all(28),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(statusIcon, color: statusColor, size: 48),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Application Status',
                  style: TextStyle(
                    fontSize: 14,
                    color: kTextSub,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor.withOpacity(0.4)),
                  ),
                  child: Text(
                    (status ?? 'Unknown').toUpperCase(),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
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
                    Icon(Icons.comment_outlined, color: kPrimary, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Remarks from Admin',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: kTextMain,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border:
                        Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Text(
                    (remarks?.isNotEmpty == true)
                        ? remarks!
                        : 'No remarks yet. Check back later.',
                    style: TextStyle(
                      fontSize: 15,
                      color: (remarks?.isNotEmpty == true)
                          ? kTextMain
                          : kTextSub,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off_rounded, color: kError, size: 56),
            const SizedBox(height: 16),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(color: kError, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}
