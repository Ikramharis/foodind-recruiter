import 'package:flutter/material.dart';
import 'package:http/http.dart' as https;
import 'dart:convert';
import 'package:file_picker/file_picker.dart';

const Color kPrimary = Color(0xFF1A5F7A);
const Color kPrimaryLight = Color(0xFF2E86AB);
const Color kAccent = Color(0xFF00BFA5);
const Color kBackground = Color(0xFFF0F7FA);
const Color kSurface = Colors.white;
const Color kTextMain = Color(0xFF1A1A2E);
const Color kTextSub = Color(0xFF6B7280);
const Color kError = Color(0xFFEF4444);

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String error = '';
  bool isLoading = false;
  bool _obscure = true;
  PlatformFile? resumeFile;

  Future<void> pickResume() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
      withData: true,
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        resumeFile = result.files.first;
      });
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w.-]+@[\w.-]+\.\w{2,}$').hasMatch(email);
  }

  Future<void> register() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || phone.isEmpty || username.isEmpty || password.isEmpty) {
      setState(() => error = 'Please fill in all fields.');
      return;
    }
    if (!_isValidEmail(email)) {
      setState(() => error = 'Please enter a valid email address.');
      return;
    }
    if (password.length < 6) {
      setState(() => error = 'Password must be at least 6 characters.');
      return;
    }
    if (resumeFile == null) {
      setState(() => error = 'Please upload your resume.');
      return;
    }

    setState(() {
      isLoading = true;
      error = '';
    });

    var uri = Uri.parse('https://snow-duck-522249.hostingersite.com/register.php');
    var request = https.MultipartRequest('POST', uri);

    request.fields['name'] = nameController.text;
    request.fields['email'] = emailController.text;
    request.fields['phone_no'] = phoneController.text;
    request.fields['username'] = usernameController.text;
    request.fields['password'] = passwordController.text;

    if (resumeFile != null) {
      if (resumeFile!.path != null) {
        request.files.add(
          await https.MultipartFile.fromPath(
            'resume',
            resumeFile!.path!,
            filename: resumeFile!.name,
          ),
        );
      } else if (resumeFile!.bytes != null) {
        request.files.add(
          https.MultipartFile.fromBytes(
            'resume',
            resumeFile!.bytes!,
            filename: resumeFile!.name,
          ),
        );
      }
    }

    try {
      var streamedResponse = await request.send();
      var response = await https.Response.fromStream(streamedResponse);
      final data = json.decode(response.body);
      setState(() => isLoading = false);

      if (data['success']) {
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        setState(() => error = data['message']);
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        error = 'Failed to connect to server: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isTablet = width >= 600;
    return Scaffold(
      backgroundColor: kBackground,
      body: SingleChildScrollView(
        child: isTablet
            ? Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: Column(
                    children: [
                      _buildHeader(),
                      _buildFormCard(),
                    ],
                  ),
                ),
              )
            : Column(
                children: [
                  _buildHeader(),
                  _buildFormCard(),
                ],
              ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [kPrimary, kPrimaryLight],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      padding: const EdgeInsets.only(top: 60, bottom: 32, left: 24, right: 24),
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
                  child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Icon(Icons.person_add_alt_1_rounded, size: 56, color: Colors.white),
          const SizedBox(height: 12),
          const Text(
            'Create Account',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Join FoodInd Recruiter today',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withOpacity(0.85),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildFormCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        decoration: BoxDecoration(
          color: kSurface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Personal Information',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: kTextMain,
              ),
            ),
            const SizedBox(height: 18),
            _inputField(nameController, 'Full Name', Icons.badge_outlined),
            const SizedBox(height: 14),
            _inputField(emailController, 'Email Address', Icons.email_outlined,
                keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 14),
            _inputField(phoneController, 'Phone Number', Icons.phone_outlined,
                keyboardType: TextInputType.phone),
            const SizedBox(height: 22),
            const Text(
              'Account Details',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: kTextMain,
              ),
            ),
            const SizedBox(height: 18),
            _inputField(usernameController, 'Username', Icons.alternate_email_rounded),
            const SizedBox(height: 14),
            TextField(
              controller: passwordController,
              obscureText: _obscure,
              style: const TextStyle(color: kTextMain, fontSize: 15),
              decoration: InputDecoration(
                labelText: 'Password',
                labelStyle: const TextStyle(color: kTextSub, fontSize: 14),
                prefixIcon: const Icon(Icons.lock_outline_rounded, color: kPrimaryLight, size: 20),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
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
            const SizedBox(height: 22),
            const Text(
              'Resume',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: kTextMain,
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: pickResume,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: resumeFile != null
                      ? kAccent.withOpacity(0.08)
                      : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: resumeFile != null ? kAccent : const Color(0xFFE2E8F0),
                    width: resumeFile != null ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      resumeFile != null
                          ? Icons.check_circle_rounded
                          : Icons.upload_file_rounded,
                      color: resumeFile != null ? kAccent : kTextSub,
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        resumeFile == null
                            ? 'Tap to upload resume (PDF, DOC)'
                            : resumeFile!.name,
                        style: TextStyle(
                          color: resumeFile != null ? kAccent : kTextSub,
                          fontSize: 14,
                          fontWeight: resumeFile != null
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (resumeFile != null)
                      GestureDetector(
                        onTap: () => setState(() => resumeFile = null),
                        child: const Icon(Icons.close, color: kTextSub, size: 18),
                      ),
                  ],
                ),
              ),
            ),
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
            const SizedBox(height: 26),
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
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: isLoading ? null : register,
                  child: isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          'Create Account',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: () =>
                    Navigator.pushReplacementNamed(context, '/login'),
                child: RichText(
                  text: const TextSpan(
                    text: 'Already have an account? ',
                    style: TextStyle(color: kTextSub, fontSize: 13),
                    children: [
                      TextSpan(
                        text: 'Login',
                        style: TextStyle(
                          color: kAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
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
