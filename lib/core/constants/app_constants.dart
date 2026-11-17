class AppConstants {
  AppConstants._();

  static const String appName = 'SmileTrack';
  static const String geminiApiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: 'YOUR_GEMINI_API_KEY',
  );

  // Firestore Collections
  static const String usersCollection = 'users';
  static const String brushingCollection = 'brushing_logs';
  static const String quizCollection = 'quiz_attempts';
  static const String communityCollection = 'community_posts';
  static const String commentsCollection = 'comments';
  static const String reportsCollection = 'reports';

  // SharedPreferences Keys
  static const String themeKey = 'theme_mode';
  static const String onboardingKey = 'onboarding_done';

  // Time definitions
  static const int morningStartHour = 0;
  static const int morningEndHour = 11;
  static const int eveningStartHour = 12;
  static const int eveningEndHour = 23;

  // Gemini quiz prompt
  static const String quizPrompt = '''
    Generate a single dental hygiene / oral health multiple-choice question.
    Return ONLY valid JSON (no markdown, no backticks) in exactly this format:
    {
      "question": "...",
      "options": ["A. ...", "B. ...", "C. ...", "D. ..."],
      "correct_index": 0,
      "fun_fact": "..."
    }
    Make it educational, accurate, and appropriate for all ages.
    The fun_fact should be an interesting, scientifically grounded dental fact.
  ''';

  // Timer soundtracks
  static const List<Map<String, String>> timerSoundtracks = [
    {'label': 'No Sound', 'value': 'none'},
    {'label': '🎵 Calm Piano', 'value': 'calm_piano'},
    {'label': '🌊 Ocean Waves', 'value': 'ocean_waves'},
    {'label': '🌧 Soft Rain', 'value': 'soft_rain'},
    {'label': '🎶 Upbeat Pop', 'value': 'upbeat_pop'},
    {'label': '🔔 Morning Bell', 'value': 'morning_bell'},
  ];
}
