import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  bool morningDone = false;
  bool eveningDone = false;

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      morningDone = prefs.getBool(_morningKey()) ?? false;
      eveningDone = prefs.getBool(_eveningKey()) ?? false;
    });
  }

  Future<void> _saveMorning(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_morningKey(), value);
    setState(() => morningDone = value);
  }

  Future<void> _saveEvening(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_eveningKey(), value);
    setState(() => eveningDone = value);
  }

  String _todayKey() {
    final now = DateTime.now();
    return "${now.year}-${now.month}-${now.day}";
  }

  String _morningKey() => "${_todayKey()}_morning";
  String _eveningKey() => "${_todayKey()}_evening";

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Brushing Calendar"),
        backgroundColor: const Color(0xFF4A90D9),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Today: ${today.day}/${today.month}/${today.year}",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            Card(
              child: Column(
                children: [
                  CheckboxListTile(
                    title: const Text("☀️ Morning Brush"),
                    value: morningDone,
                    onChanged: (v) {
                      if (v != null) _saveMorning(v);
                    },
                  ),
                  const Divider(height: 1),
                  CheckboxListTile(
                    title: const Text("🌙 Evening Brush"),
                    value: eveningDone,
                    onChanged: (v) {
                      if (v != null) _saveEvening(v);
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "✔ These will be auto-checked when your 2-minute timer completes.",
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}