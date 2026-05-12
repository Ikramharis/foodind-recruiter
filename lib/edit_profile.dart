import 'package:flutter/material.dart';
import 'package:http/http.dart' as https;
import 'dart:convert';
import 'homepage1.dart';
import 'package:url_launcher/url_launcher.dart';

const Color kPrimary = Color(0xFF1A5F7A);
const Color kPrimaryLight = Color(0xFF2E86AB);
const Color kAccent = Color(0xFF00BFA5);
const Color kBackground = Color(0xFFF0F7FA);
const Color kSurface = Colors.white;
const Color kTextMain = Color(0xFF1A1A2E);
const Color kTextSub = Color(0xFF6B7280);
const Color kError = Color(0xFFEF4444);

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String? resumePath;
  String error = '';
  bool isLoading = true;
  bool _obscure = true;
  String originalUsername = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as Map?;
    final username = args?['username'];
    if (username != null) {
      originalUsername = username;
      fetchProfile(username);
    }
  }

  Future<void> fetchProfile(String username) async {
    try {
      final response = await https.get(
        Uri.parse(
          'https://snow-duck-522249.hostingersite.com/get_profile.php?username=$username',
        ),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          setState(() {
            nameController.text = data['data']['name'];
            emailController.text = data['data']['email'];
            phoneController.text = data['data']['phone_no'];
            usernameController.text = data['data']['username'];
            resumePath = data['data']['resume'];
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
    } catch (e) {
      setState(() {
        error = 'An error occurred: $e';
        isLoading = false;
      });
    }
  }

  Future<void> saveChanges() async {
    final response = await https.post(
      Uri.parse('https://snow-duck-522249.hostingersite.com/update_profile.php'),
      body: {
        'original_username': originalUsername,
        'name': nameController.text,
        'email': emailController.text,
        'phone_no': phoneController.text,
        'username': usernameController.text,
        'password': passwordController.text,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white),
                SizedBox(width: 10),
                Text('Profile updated successfully!'),
              ],
            ),
            backgroundColor: kAccent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const HomePageUser(),
            settings: RouteSettings(
              arguments: {'username': usernameController.text},
            ),
          ),
        );
      } else {
        setState(() => error = data['message']);
      }
    } else {
      setState(() => error = 'Server error: ${response.statusCode}');
    }
  }

  Future<void> downloadResume() async {
    if (resumePath == null || resumePath!.isEmpty) return;
    final url = 'https://snow-duck-522249.hostingersite.com/$resumePath';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch resume link')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: kBackground,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: kPrimary),
              const SizedBox(height: 16),
              Text('Loading profile...', style: TextStyle(color: kTextSub)),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: kBackground,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(context),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildSection(
                    title: 'Personal Information',
                    icon: Icons.person_outline_rounded,
                    children: [
                      _inputField(nameController, 'Full Name', Icons.badge_outlined),
                      const SizedBox(height: 14),
                      _inputField(emailController, 'Email Address', Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress),
                      const SizedBox(height: 14),
                      _inputField(phoneController, 'Phone Number', Icons.phone_outlined,
                          keyboardType: TextInputType.phone),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildSection(
                    title: 'Account Details',
                    icon: Icons.lock_outline_rounded,
                    children: [
                      _inputField(usernameController, 'Username', Icons.alternate_email_rounded),
                      const SizedBox(height: 14),
                      TextField(
                        controller: passwordController,
                        obscureText: _obscure,
                        style: const TextStyle(color: kTextMain, fontSize: 15),
                        decoration: InputDecoration(
                          labelText: 'New Password (optional)',
                          labelStyle: const TextStyle(color: kTextSub, fontSize: 14),
                          prefixIcon: const Icon(Icons.lock_outline_rounded,
                              color: kPrimaryLight, size: 20),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscure
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: kTextSub,
                              size: 20,
                            ),
                            onPressed: () => setState(() => _obscure = !_obscure),
                          ),
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
                            borderSide: const BorderSide(color: kPrimaryLight, width: 2),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (resumePath != null && resumePath!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildSection(
                      title: 'Resume',
                      icon: Icons.description_outlined,
                      children: [
                        GestureDetector(
                          onTap: downloadResume,
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: kAccent.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: kAccent.withOpacity(0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.attach_file_rounded,
                                    color: kAccent, size: 20),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    resumePath!,
                                    style: const TextStyle(
                                        color: kAccent,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: kAccent,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    'Download',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (error.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: kError.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: kError.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: kError, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(error,
                                style: const TextStyle(color: kError, fontSize: 13)),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [kPrimary, kPrimaryLight],
                        ),
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
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        icon: const Icon(Icons.save_rounded, color: Colors.white),
                        label: const Text(
                          'Save Changes',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        onPressed: saveChanges,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
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
              const SizedBox(width: 16),
              const Text(
                'Edit Profile',
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
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
            ),
            child: const Icon(Icons.person_rounded, color: Colors.white, size: 44),
          ),
          const SizedBox(height: 8),
          Text(
            originalUsername,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
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
          Row(
            children: [
              Icon(icon, color: kPrimary, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: kTextMain,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _inputField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: kTextMain, fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: kTextSub, fontSize: 14),
        prefixIcon: Icon(icon, color: kPrimaryLight, size: 20),
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
          borderSide: const BorderSide(color: kPrimaryLight, width: 2),
        ),
      ),
    );
  }
}
