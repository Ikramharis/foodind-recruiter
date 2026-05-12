import 'package:flutter/material.dart';
import 'homepage1.dart';
import 'admin_login.dart';
import 'admin_homepage.dart';
import 'admin_cand.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import 'edit_profile.dart';
import 'viewprogress.dart';
import 'result_page.dart';
import 'criteria_screen.dart';
import 'admin_progress.dart';
import 'splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FoodInd Recruiter App',
      home: const SplashScreen(),
      routes: {
        '/login': (context) => LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/admin-login': (context) => AdminLoginPage(),
        '/admin-home': (context) => Admin_Homepage(),
        '/admin-cand': (context) => CandidatePage(),
        '/home': (context) => const HomePageUser(),
        '/edit-profile': (context) => const EditProfileScreen(),
        '/view-progress': (context) => const ViewProgressPage(),
        '/admin-progress': (context) => const AdminProgressPage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/criteria') {
          final args = settings.arguments as Map<String, dynamic>?;
          if (args == null ||
              !args.containsKey('criteriaId') ||
              !args.containsKey('answers')) {
            return MaterialPageRoute(
              builder: (_) => const Scaffold(
                body: Center(child: Text('Invalid arguments for criteria screen')),
              ),
            );
          }
          return MaterialPageRoute(
            builder: (_) => CriteriaScreen(
              criteriaId: args['criteriaId'] as int,
              answers: args['answers'] as Map<String, String>,
            ),
          );
        }
        if (settings.name == '/result_page') {
          final answers = settings.arguments as Map<String, String>? ?? {};
          return MaterialPageRoute(
            builder: (_) => ResultPage(answers: answers),
          );
        }
        return null;
      },
    );
  }
}
