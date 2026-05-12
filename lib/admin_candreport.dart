import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'admin_homepage.dart';

// Define the color palette
const Color kBackgroundColor = Color(0xFFE0E0E0); // Updated background color
const Color kPrimaryColor = Color(0xFF3C6B82); // Updated primary color
const Color kAccentColor = Color(0xFF00ADB5); // Updated accent color
const Color kTextMainColor = Color(0xFF212121); // Main text color
const Color kTextSubtleColor = Color(0xFF9E9E9E); // Subtle text color
const Color kErrorColor = Color(0xFFFF6B6B); // Error color

class CandidateReportPage extends StatelessWidget {
  final String candidateName;

  // Example of candidate answers (scores out of 10 for each criterion)
  final Map<String, int> candidateScores = {
    'Criteria 1: Data Literacy and Analytics': 8,
    'Criteria 2: AI and Machine Learning': 7,
    'Criteria 3: IoT & Smart Sensors': 6,
    'Criteria 4: Blockchain Technology': 9,
    'Criteria 5: Digital Communication & Collaboration Tools': 7,
    'Criteria 6: Cybersecurity Awareness': 8,
    'Criteria 7: E-commerce & Digital Marketing': 6,
    'Criteria 8: Programming and Automation': 9,
    'Criteria 9: Sustainable Food Production Technologies': 7,
  };

  // Constructor to receive candidate name
  CandidateReportPage({super.key, required this.candidateName});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Report for $candidateName'),
        backgroundColor:
            kPrimaryColor, // Updated primary color for navigation bar
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Candidate: $candidateName',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Displaying criteria and candidate's scores
            _buildCriteriaReport(
              'Criteria 1: Data Literacy and Analytics',
              candidateScores['Criteria 1: Data Literacy and Analytics']!,
              context,
            ),
            const SizedBox(height: 20),
            _buildCriteriaReport(
              'Criteria 2: AI and Machine Learning',
              candidateScores['Criteria 2: AI and Machine Learning']!,
              context,
            ),
            const SizedBox(height: 20),
            _buildCriteriaReport(
              'Criteria 3: IoT & Smart Sensors',
              candidateScores['Criteria 3: IoT & Smart Sensors']!,
              context,
            ),
            const SizedBox(height: 20),
            _buildCriteriaReport(
              'Criteria 4: Blockchain Technology',
              candidateScores['Criteria 4: Blockchain Technology']!,
              context,
            ),
            const SizedBox(height: 20),
            _buildCriteriaReport(
              'Criteria 5: Digital Communication & Collaboration Tools',
              candidateScores['Criteria 5: Digital Communication & Collaboration Tools']!,
              context,
            ),
            const SizedBox(height: 20),
            _buildCriteriaReport(
              'Criteria 6: Cybersecurity Awareness',
              candidateScores['Criteria 6: Cybersecurity Awareness']!,
              context,
            ),
            const SizedBox(height: 20),
            _buildCriteriaReport(
              'Criteria 7: E-commerce & Digital Marketing',
              candidateScores['Criteria 7: E-commerce & Digital Marketing']!,
              context,
            ),
            const SizedBox(height: 20),
            _buildCriteriaReport(
              'Criteria 8: Programming and Automation',
              candidateScores['Criteria 8: Programming and Automation']!,
              context,
            ),
            const SizedBox(height: 20),
            _buildCriteriaReport(
              'Criteria 9: Sustainable Food Production Technologies',
              candidateScores['Criteria 9: Sustainable Food Production Technologies']!,
              context,
            ),
            const SizedBox(height: 40),

            // Button to go back to the homepage
            CupertinoButton.filled(
              onPressed: () {
                // Navigate back to the Admin Home Page
                Navigator.pushReplacement(
                  context,
                  CupertinoPageRoute(builder: (context) => Admin_Homepage()),
                );
              },
              child: const Text(
                'Back to Homepage',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Function to build criteria report display
  Widget _buildCriteriaReport(
    String criteria,
    int score,
    BuildContext context,
  ) {
    return CupertinoButton(
      padding: const EdgeInsets.symmetric(vertical: 20),
      color: kPrimaryColor, // Primary color for buttons
      onPressed: () {
        // Handle clicking the criteria (e.g., navigate to more details or edit page)
        _showCriteriaDetail(criteria, score, context);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            criteria,
            style: const TextStyle(fontSize: 18, color: Colors.white),
          ), // White text for criteria
          Text(
            '$score/10',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ), // White text for score
        ],
      ),
    );
  }

  // Function to show criteria detail or navigate for editing
  void _showCriteriaDetail(String criteria, int score, BuildContext context) {
    // Show a dialog with the criteria details
    showCupertinoDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return CupertinoAlertDialog(
          title: Text(
            'Details for $criteria',
            style: TextStyle(color: kPrimaryColor),
          ), // Primary color for dialog title
          content: Text('Score: $score/10'),
          actions: <Widget>[
            CupertinoDialogAction(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
