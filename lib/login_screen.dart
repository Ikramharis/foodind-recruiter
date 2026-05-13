import 'package:flutter/material.dart';
import 'package:http/http.dart' as https;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

const Color kPrimary = Color(0xFF1A5F7A);
const Color kPrimaryLight = Color(0xFF2E86AB);
const Color kAccent = Color(0xFF00BFA5);
const Color kBackground = Color(0xFFF0F7FA);
const Color kSurface = Colors.white;
const Color kTextMain = Color(0xFF1A1A2E);
const Color kTextSub = Color(0xFF6B7280);
const Color kError = Color(0xFFEF4444);

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String error = '';
  bool isLoading = false;
  bool _obscure = true;

  Future<void> login() async {
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      setState(() => error = 'Please enter your username and password.');
      return;
    }

    setState(() {
      isLoading = true;
      error = '';
    });

    final response = await https.post(
      Uri.parse('https://snow-duck-522249.hostingersite.com/login.php'),
      body: {
        'login': usernameController.text,
        'password': passwordController.text,
      },
    );

    final data = json.decode(response.body);
    setState(() => isLoading = false);

    if (data['success']) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('session_username', data['username']);
      Navigator.pushReplacementNamed(
        context,
        '/home',
        arguments: {'username': data['username']},
      );
    } else {
      setState(() => error = data['message']);
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
      padding: const EdgeInsets.only(top: 70, bottom: 40, left: 24, right: 24),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(24),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.asset('image/LogoApp1.png', height: 110),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'FoodInd Recruiter',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Your journey starts here',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.85),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildFormCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
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
              'Welcome back',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: kTextMain,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Sign in to your candidate account',
              style: TextStyle(fontSize: 13, color: kTextSub),
            ),
            const SizedBox(height: 28),
            _inputField(
              controller: usernameController,
              label: 'Username or Email',
              icon: Icons.person_outline_rounded,
            ),
            const SizedBox(height: 16),
            _inputField(
              controller: passwordController,
              label: 'Password',
              icon: Icons.lock_outline_rounded,
              isPassword: true,
            ),
            const SizedBox(height: 10),
            if (error.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 8),
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
                      child: Text(
                        error,
                        style: const TextStyle(color: kError, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 24),
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
                  onPressed: isLoading ? null : login,
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
                          'Login',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: TextButton(
                onPressed: () => Navigator.pushNamed(context, '/register'),
                child: RichText(
                  text: const TextSpan(
                    text: "Don't have an account? ",
                    style: TextStyle(color: kTextSub, fontSize: 13),
                    children: [
                      TextSpan(
                        text: 'Register',
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
            Center(
              child: TextButton(
                onPressed: () => Navigator.pushNamed(context, '/admin-login'),
                child: const Text(
                  'Admin Login →',
                  style: TextStyle(
                    color: kPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword && _obscure,
      style: const TextStyle(color: kTextMain, fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: kTextSub, fontSize: 14),
        prefixIcon: Icon(icon, color: kPrimaryLight, size: 20),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: kTextSub,
                  size: 20,
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
              )
            : null,
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
