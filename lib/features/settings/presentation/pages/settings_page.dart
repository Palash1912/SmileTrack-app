import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/constants/country_data.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../../../../shared/providers/theme_provider.dart';
import '../../../../shared/providers/timezone_provider.dart';
import '../../../../shared/widgets/app_header.dart';
import '../../../../shared/widgets/country_picker_sheet.dart';
import '../../../auth/data/repositories/auth_repository.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool _isLoading = false;
  NotificationPreferences _notifPrefs = const NotificationPreferences(
    remindersEnabled: true,
    morningTime: TimeOfDay(hour: 8, minute: 0),
    eveningTime: TimeOfDay(hour: 21, minute: 30),
    streakAlerts: true,
    quizReminders: false,
  );

  @override
  void initState() {
    super.initState();
    _loadNotificationPreferences();
  }

  Future<void> _loadNotificationPreferences() async {
    final prefs = await NotificationService().loadPreferences();
    if (mounted) setState(() => _notifPrefs = prefs);
  }

  Future<void> _toggleReminders(bool value) async {
    final user = ref.read(currentUserProvider);
    final updated = _notifPrefs.copyWith(remindersEnabled: value);
    setState(() => _notifPrefs = updated);
    if (value) {
      final granted = await NotificationService().requestPermissions();
      if (!granted && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please allow notifications in system settings'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
    await NotificationService().savePreferences(updated, timezone: user?.timezone);
  }

  Future<void> _pickMorningTime() async {
    final user = ref.read(currentUserProvider);
    final picked = await showTimePicker(
      context: context,
      initialTime: _notifPrefs.morningTime,
    );
    if (picked != null && mounted) {
      final updated = _notifPrefs.copyWith(morningTime: picked);
      setState(() => _notifPrefs = updated);
      await NotificationService().savePreferences(updated, timezone: user?.timezone);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Morning reminder set to ${picked.format(context)}'),
          backgroundColor: AppTheme.primaryMint,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _pickEveningTime() async {
    final user = ref.read(currentUserProvider);
    final picked = await showTimePicker(
      context: context,
      initialTime: _notifPrefs.eveningTime,
    );
    if (picked != null && mounted) {
      final updated = _notifPrefs.copyWith(eveningTime: picked);
      setState(() => _notifPrefs = updated);
      await NotificationService().savePreferences(updated, timezone: user?.timezone);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Evening reminder set to ${picked.format(context)}'),
          backgroundColor: AppTheme.primaryMint,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _toggleStreakAlerts(bool value) async {
    final updated = _notifPrefs.copyWith(streakAlerts: value);
    setState(() => _notifPrefs = updated);
    await NotificationService().savePreferences(updated);
  }

  Future<void> _toggleQuizReminders(bool value) async {
    final updated = _notifPrefs.copyWith(quizReminders: value);
    setState(() => _notifPrefs = updated);
    await NotificationService().savePreferences(updated);
  }

  Future<void> _sendTestNotification() async {
    await NotificationService().showInstantTestNotification();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Test notification sent! Check your notification bar.'),
          backgroundColor: AppTheme.primaryMint,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = ref.watch(currentUserProvider);
    final themeState = ref.watch(themeProvider);
    final primary = theme.colorScheme.primary;
    final isDark = themeState.isDark;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppHeader(),

                // User avatar + name
                if (user != null)
                  Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [primary, theme.colorScheme.secondary],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            user.displayName.isNotEmpty
                                ? user.displayName[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                                fontFamily: 'Sora',
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user.displayName,
                                style: theme.textTheme.headlineLarge),
                            Text(user.email ?? '',
                                style: theme.textTheme.bodyMedium),
                          ],
                        ),
                      ),
                      // Points
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                              colors: [
                                AppTheme.accentYellow,
                                Color(0xFFFFB347)
                              ]),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            const Text('⭐', style: TextStyle(fontSize: 14)),
                            const SizedBox(width: 4),
                            Text('${user.totalPoints}',
                                style: const TextStyle(
                                    fontFamily: 'Sora',
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    fontSize: 13)),
                          ],
                        ),
                      ),
                    ],
                  ).animate().fadeIn(),

                const SizedBox(height: 24),
                Text('Account',
                    style: theme.textTheme.labelLarge?.copyWith(color: primary))
                    .animate()
                    .fadeIn(delay: 100.ms),
                const SizedBox(height: 8),

                _SettingsCard(
                  children: [
                    _SettingsTile(
                      icon: Icons.email_outlined,
                      title: 'Change Email',
                      subtitle: 'OTP verification required',
                      color: theme.colorScheme.secondary,
                      onTap: () => _showChangeEmailDialog(context),
                    ),
                    _SettingsTile(
                      icon: Icons.lock_outline,
                      title: 'Change Password',
                      subtitle: 'Email OTP required',
                      color: const Color(0xFF6C63FF),
                      onTap: () => _showChangePasswordDialog(context),
                    ),
                  ],
                ).animate().fadeIn(delay: 150.ms),

                const SizedBox(height: 20),
                Text('Preferences',
                    style: theme.textTheme.labelLarge?.copyWith(color: primary))
                    .animate()
                    .fadeIn(delay: 200.ms),
                const SizedBox(height: 8),

                _SettingsCard(
                  children: [
                    _SettingsTile(
                      icon: Icons.flag_outlined,
                      title: 'Country',
                      subtitle: user?.country != null && user!.country.isNotEmpty
                          ? (() {
                              final match = findCountry(user.country);
                              return match != null
                                  ? '${match.flag}  ${match.name}'
                                  : user.country;
                            })()
                          : 'Not set',
                      color: AppTheme.accentYellow,
                      onTap: () => _showChangeCountryDialog(context),
                    ),
                    _SettingsTile(
                      icon: Icons.schedule_outlined,
                      title: 'Timezone',
                      subtitle: user?.timezone ?? 'UTC',
                      color: AppTheme.accentCoral,
                      onTap: () => _showChangeTimezoneDialog(context),
                    ),

                    // ── Dark Mode Toggle ──────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF9B59B6).withOpacity(0.2)
                                  : const Color(0xFF9B59B6).withOpacity(0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isDark
                                  ? Icons.dark_mode_rounded
                                  : Icons.light_mode_rounded,
                              color: isDark
                                  ? const Color(0xFFCE93D8)
                                  : const Color(0xFF9B59B6),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Dark Mode',
                                    style: theme.textTheme.bodyLarge),
                                Text(
                                  isDark ? 'Currently dark' : 'Currently light',
                                  style: theme.textTheme.bodyMedium
                                      ?.copyWith(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: isDark,
                            activeThumbColor: primary,
                            onChanged: (_) => ref
                                .read(themeProvider.notifier)
                                .toggleDarkMode(),
                          ),
                        ],
                      ),
                    ),

                    // ── Theme Colour Picker ───────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      child: Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: primary.withOpacity(0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.palette_outlined,
                                color: primary, size: 20),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('App Theme',
                                    style: theme.textTheme.bodyLarge),
                                Text('Choose your colour',
                                    style: theme.textTheme.bodyMedium
                                        ?.copyWith(fontSize: 12)),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              _ThemeCircle(
                                color: AppTheme.primaryMint,
                                label: 'Mint',
                                isSelected:
                                    themeState.type == AppThemeType.mint,
                                onTap: () => ref
                                    .read(themeProvider.notifier)
                                    .setTheme(AppThemeType.mint),
                              ),
                              const SizedBox(width: 8),
                              _ThemeCircle(
                                color: AppTheme.bluePrimary,
                                label: 'Blue',
                                isSelected:
                                    themeState.type == AppThemeType.blue,
                                onTap: () => ref
                                    .read(themeProvider.notifier)
                                    .setTheme(AppThemeType.blue),
                              ),
                              const SizedBox(width: 8),
                              _ThemeCircle(
                                color: AppTheme.pinkPrimary,
                                label: 'Pink',
                                isSelected:
                                    themeState.type == AppThemeType.pink,
                                onTap: () => ref
                                    .read(themeProvider.notifier)
                                    .setTheme(AppThemeType.pink),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 250.ms),

                const SizedBox(height: 20),
                Text('Notifications',
                    style: theme.textTheme.labelLarge?.copyWith(color: primary))
                    .animate()
                    .fadeIn(delay: 300.ms),
                const SizedBox(height: 8),

                _SettingsCard(
                  children: [
                    _SwitchTile(
                      icon: Icons.notifications_outlined,
                      iconColor: primary,
                      title: 'Brushing Reminders',
                      subtitle: _notifPrefs.remindersEnabled
                          ? 'Morning: ${_notifPrefs.morningTime.format(context)} • Evening: ${_notifPrefs.eveningTime.format(context)}'
                          : 'Morning & evening alerts disabled',
                      value: _notifPrefs.remindersEnabled,
                      onChanged: _toggleReminders,
                    ),
                    if (_notifPrefs.remindersEnabled) ...[
                      Divider(
                        height: 1,
                        indent: 64,
                        color: theme.colorScheme.outline.withOpacity(0.12),
                      ),
                      _SettingsTile(
                        icon: Icons.wb_sunny_outlined,
                        title: 'Morning Reminder Time',
                        subtitle: _notifPrefs.morningTime.format(context),
                        color: AppTheme.accentYellow,
                        onTap: _pickMorningTime,
                      ),
                      _SettingsTile(
                        icon: Icons.nightlight_outlined,
                        title: 'Evening Reminder Time',
                        subtitle: _notifPrefs.eveningTime.format(context),
                        color: const Color(0xFF6C63FF),
                        onTap: _pickEveningTime,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            right: 16, top: 4, bottom: 8),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: _sendTestNotification,
                            icon: const Icon(Icons.send_rounded, size: 16),
                            label: const Text(
                              'Send Test Alert',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ),
                      ),
                    ],
                    _SwitchTile(
                      icon: Icons.emoji_events_outlined,
                      iconColor: AppTheme.accentYellow,
                      title: 'Streak Alerts',
                      subtitle: 'Don\'t break your streak!',
                      value: _notifPrefs.streakAlerts,
                      onChanged: _toggleStreakAlerts,
                    ),
                    _SwitchTile(
                      icon: Icons.quiz_outlined,
                      iconColor: const Color(0xFF6C63FF),
                      title: 'Daily Quiz Reminder',
                      subtitle: 'Earn extra points',
                      value: _notifPrefs.quizReminders,
                      onChanged: _toggleQuizReminders,
                    ),
                  ],
                ).animate().fadeIn(delay: 350.ms),

                const SizedBox(height: 20),
                Text('About',
                    style: theme.textTheme.labelLarge?.copyWith(color: primary))
                    .animate()
                    .fadeIn(delay: 400.ms),
                const SizedBox(height: 8),

                _SettingsCard(
                  children: [
                    _SettingsTile(
                      icon: Icons.info_outline,
                      title: 'About smileTrack',
                      subtitle: 'Version 1.0.0',
                      color: theme.colorScheme.secondary,
                      onTap: () => _showAboutDialog(context),
                    ),
                    _SettingsTile(
                      icon: Icons.privacy_tip_outlined,
                      title: 'Privacy Policy',
                      subtitle: 'How we protect your data',
                      color: primary,
                      onTap: () {},
                    ),
                    _SettingsTile(
                      icon: Icons.description_outlined,
                      title: 'Terms of Service',
                      subtitle: 'Read our terms',
                      color: AppTheme.accentCoral,
                      onTap: () {},
                    ),
                  ],
                ).animate().fadeIn(delay: 450.ms),

                const SizedBox(height: 24),

                // Logout
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed:
                        _isLoading ? null : () => _confirmLogout(context),
                    icon: _isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppTheme.accentCoral))
                        : const Icon(Icons.logout_rounded,
                            color: AppTheme.accentCoral),
                    label: const Text('Sign Out',
                        style: TextStyle(color: AppTheme.accentCoral)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: AppTheme.accentCoral),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ).animate().fadeIn(delay: 500.ms),

                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Sign Out?'),
        content:
            const Text('You\'ll need to sign in again to track your brushing.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentCoral),
            onPressed: () async {
              Navigator.pop(ctx);
              setState(() => _isLoading = true);
              final repo = ref.read(authRepositoryProvider);
              await repo.signOut();
              ref.read(currentUserProvider.notifier).state = null;
              if (mounted) context.go(AppRoutes.login);
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }



  void _showChangeEmailDialog(BuildContext context) {
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Change Email"),
        content: TextField(
          controller: emailController,
          decoration: const InputDecoration(labelText: "New Email"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final email = emailController.text.trim();
              if (email.isEmpty) return;

              Navigator.pop(ctx);
              setState(() => _isLoading = true);

              try {
                final repo = ref.read(authRepositoryProvider);
                final user = ref.read(currentUserProvider);

                await repo.sendEmailOtp(
                  context:context,
                  email: email,
                  password: '',
                  displayName: user?.displayName ?? '',
                  age: user?.age ?? 0,
                  country: user?.country ?? '',
                  timezone: user?.timezone ?? '',
                );

                context.push('/otp', extra: {
                  'email': email,
                  'type': 'updateEmail',
                });
              } catch (e) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(e.toString())));
              }

              setState(() => _isLoading = false);
            },
            child: const Text("Send OTP"),
          )
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final current = TextEditingController();
    final newPass = TextEditingController();
    final confirm = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Change Password"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
          TextField(
            controller: current,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: "Current Password",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: newPass,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: "New Password",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: confirm,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: "Confirm Password",
              border: OutlineInputBorder(),
            ),
          ),
        ]
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (newPass.text != confirm.text) return;

              Navigator.pop(ctx);
              setState(() => _isLoading = true);

              try {
                final repo = ref.read(authRepositoryProvider);
                final user = ref.read(currentUserProvider);

                await repo.verifyPassword(current.text);

                await repo.sendEmailOtp(
                  context:context,
                  email: user?.email ?? '',
                  password: '',
                  displayName: user?.displayName ?? '',
                  age: user?.age ?? 0,
                  country: user?.country ?? '',
                  timezone: user?.timezone ?? '',
                );

                context.push('/otp', extra: {
                  'type': 'updatePassword',
                  'newPassword': newPass.text,
                  'email': user?.email,
                });
              } catch (e) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(e.toString())));
              }

              setState(() => _isLoading = false);
            },
            child: const Text("Verify via OTP"),
          )
        ],
      ),
    );
  }
  
  Future<void> _showChangeCountryDialog(BuildContext context) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    final picked = await showCountryPickerSheet(
      context: context,
      selectedCountry: user.country,
    );

    if (picked != null && mounted) {
      final updatedUser = user.copyWith(country: picked.name);
      ref.read(currentUserProvider.notifier).setUser(updatedUser);

      try {
        await ref.read(authRepositoryProvider).updateUserProfile(updatedUser);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Country updated to ${picked.flag} ${picked.name}'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: AppTheme.primaryMint,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to save country: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _showChangeTimezoneDialog(BuildContext context) {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    String selected = user.timezone.isNotEmpty ? user.timezone : 'UTC';

    final timezones = [
      {'label': 'UTC (London, UTC+0)', 'value': 'UTC', 'offset': 0},
      {'label': 'EST (New York, UTC-5)', 'value': 'America/New_York', 'offset': -300},
      {'label': 'CST (Chicago, UTC-6)', 'value': 'America/Chicago', 'offset': -360},
      {'label': 'MST (Denver, UTC-7)', 'value': 'America/Denver', 'offset': -420},
      {'label': 'PST (Los Angeles, UTC-8)', 'value': 'America/Los_Angeles', 'offset': -480},
      {'label': 'IST (India, UTC+5:30)', 'value': 'Asia/Kolkata', 'offset': 330},
      {'label': 'CET (Paris, Berlin, UTC+1)', 'value': 'Europe/Paris', 'offset': 60},
      {'label': 'GMT (London, UTC+0)', 'value': 'Europe/London', 'offset': 0},
      {'label': 'JST (Tokyo, UTC+9)', 'value': 'Asia/Tokyo', 'offset': 540},
      {'label': 'CST (Beijing, Shanghai, UTC+8)', 'value': 'Asia/Shanghai', 'offset': 480},
      {'label': 'SGT (Singapore, UTC+8)', 'value': 'Asia/Singapore', 'offset': 480},
      {'label': 'GST (Dubai, UTC+4)', 'value': 'Asia/Dubai', 'offset': 240},
      {'label': 'AEST (Sydney, UTC+10)', 'value': 'Australia/Sydney', 'offset': 600},
      {'label': 'NZST (Auckland, UTC+12)', 'value': 'Pacific/Auckland', 'offset': 720},
    ];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(children: [
            Text('🕐 ', style: TextStyle(fontSize: 22)),
            Text('Change Timezone')
          ]),
          content: SizedBox(
            width: 320,
            child: DropdownButtonFormField<String>(
              isExpanded: true,
              value: timezones.any((t) => t['value'] == selected)
                  ? selected
                  : 'UTC',
              decoration: const InputDecoration(
                labelText: 'Select Timezone',
                prefixIcon: Icon(Icons.schedule_outlined),
              ),
              items: timezones
                  .map((tz) => DropdownMenuItem(
                        value: tz['value'] as String,
                        child: Text(
                          tz['label'] as String,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ))
                  .toList(),
              onChanged: (v) =>
                  setDialogState(() => selected = v ?? selected),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                final updatedUser = user.copyWith(timezone: selected);
                ref.read(currentUserProvider.notifier).setUser(updatedUser);

                final tzMatch = timezones.firstWhere(
                  (t) => t['value'] == selected,
                  orElse: () => {'offset': 0},
                );
                final offset = tzMatch['offset'] as int? ?? 0;
                ref.read(timezoneOffsetProvider.notifier).setOffset(offset);

                try {
                  await ref
                      .read(authRepositoryProvider)
                      .updateUserProfile(updatedUser);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Timezone updated to $selected'),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: AppTheme.primaryMint,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to save timezone: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final secondary = Theme.of(context).colorScheme.secondary;
    showAboutDialog(
      context: context,
      applicationName: 'smileTrack',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [primary, secondary]),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
            child: Text('🦷', style: TextStyle(fontSize: 32))),
      ),
      children: [
        const Text(
            'smileTrack helps you build life-long oral hygiene habits through gamification, education, and community support.'),
      ],
    );
  }
}

// ── Theme Circle Picker ───────────────────────────────────────────
class _ThemeCircle extends StatelessWidget {
  final Color color;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeCircle({
    required this.color,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.white : Colors.transparent,
            width: 2.5,
          ),
          boxShadow: isSelected
              ? [BoxShadow(
                  color: color.withOpacity(0.6),
                  blurRadius: 8,
                  spreadRadius: 1)]
              : [],
        ),
        child: isSelected
            ? const Icon(Icons.check_rounded, color: Colors.white, size: 16)
            : null,
      ),
    );
  }
}

// ── Settings Card ─────────────────────────────────────────────────
class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.4)),
      ),
      child: Column(
        children: children.asMap().entries.map((e) {
          final isLast = e.key == children.length - 1;
          return Column(
            children: [
              e.value,
              if (!isLast)
                Divider(
                    height: 1,
                    indent: 68,
                    color: theme.colorScheme.outline.withOpacity(0.3)),
            ],
          );
        }).toList(),
      ),
    );
  }
}

// ── Settings Tile ─────────────────────────────────────────────────
class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final Color color;
  final VoidCallback onTap;
  const _SettingsTile(
      {required this.icon,
      required this.title,
      required this.subtitle,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                  color: color.withOpacity(0.12), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.bodyLarge),
                  Text(subtitle,
                      style:
                          theme.textTheme.bodyMedium?.copyWith(fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded,
                size: 14,
                color: theme.colorScheme.onSurface.withOpacity(0.35)),
          ],
        ),
      ),
    );
  }
}

// ── Switch Tile ───────────────────────────────────────────────────
class _SwitchTile extends StatefulWidget {
  final IconData icon;
  final Color iconColor;
  final String title, subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _SwitchTile(
      {required this.icon,
      required this.iconColor,
      required this.title,
      required this.subtitle,
      required this.value,
      required this.onChanged});

  @override
  State<_SwitchTile> createState() => _SwitchTileState();
}

class _SwitchTileState extends State<_SwitchTile> {
  late bool _value;

  @override
  void initState() {
    super.initState();
    _value = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
                color: widget.iconColor.withOpacity(0.12),
                shape: BoxShape.circle),
            child: Icon(widget.icon, color: widget.iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.title, style: theme.textTheme.bodyLarge),
                Text(widget.subtitle,
                    style:
                        theme.textTheme.bodyMedium?.copyWith(fontSize: 12)),
              ],
            ),
          ),
          Switch(
            value: _value,
            activeThumbColor: primary,
            onChanged: (v) {
              setState(() => _value = v);
              widget.onChanged(v);
            },
          ),
        ],
      ),
    );
  }
}