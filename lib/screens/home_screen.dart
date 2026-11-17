import 'package:flutter/material.dart';
import 'timer_screen.dart';
import 'calendar_screen.dart';
import 'tips_screen.dart';
import 'faq_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("SmileTrack 🦷")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TimerScreen()),
                );
              },
              child: const Text("Start Brushing Timer"),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CalendarScreen()),
                );
              },
              child: const Text("Brushing Calendar"),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TipsScreen()),
                );
              },
              child: const Text("Dental Tips"),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FAQScreen()),
                );
              },
              child: const Text("FAQ"),
            ),
          ],
        ),
      ),
    );
  }
}