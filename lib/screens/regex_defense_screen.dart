import 'package:flutter/material.dart';

class RegexDefenseScreen extends StatelessWidget {
  const RegexDefenseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Regex Defense Cheat Sheet'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              context,
              'Email Validation',
              'r\'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}\$\'',
              'Standard email pattern ensuring @ and a valid domain extension.',
              'example@student.edu',
            ),
            _buildSection(
              context,
              'Phone Number',
              'r\'^\\+?[0-9]{10,15}\$\'',
              'Accepts optional "+" and 10 to 15 digits. Perfect for campus global IDs.',
              '+12345678901, 01712345678',
            ),
            _buildSection(
              context,
              'Password Strength',
              'r\'^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[@\$!%*?&])[A-Za-z\\d@\$!%*?&]{8,}\$\'',
              'Mandatory: 8+ chars, 1 Uppercase, 1 Lowercase, 1 Digit, 1 Special character.',
              'Campus#2023!',
            ),
            _buildSection(
              context,
              'Item Title',
              'r\'^.{5,60}\$\'',
              'Limits title length between 5 and 60 characters for UI consistency.',
              'Blue Sony Headphones',
            ),
            _buildSection(
              context,
              'Date (ISO)',
              'r\'^\\d{4}-(0[1-9]|1[0-2])-(0[1-9]|[12]\\d|3[01])\$\'',
              'Ensures YYYY-MM-DD format with valid month/day ranges.',
              '2023-11-09',
            ),
            _buildSection(
              context,
              'Numeric (Price/Qty)',
              'r\'^\\d+(\\.\\d{1,2})?\$\'',
              'Allows integers or decimals with up to 2 decimal places.',
              '45.50, 100',
            ),
            const SizedBox(height: 30),
            const Card(
              color: Colors.blueAccent,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Defense Strategy',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'By implementing these RegEx patterns at the front-end (Flutter) and back-end level, we prevent injection attacks, ensure data integrity, and provide real-time feedback to users via "Toast Alerts" and "Validation Messages".',
                      style: TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String regex,
      String description, String example) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(4),
              ),
              child: SelectableText(
                regex,
                style: const TextStyle(
                    fontFamily: 'monospace', fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            Text(description),
            const SizedBox(height: 4),
            Text(
              'Example: $example',
              style: const TextStyle(
                  fontStyle: FontStyle.italic, color: Colors.blueGrey),
            ),
          ],
        ),
      ),
    );
  }
}
