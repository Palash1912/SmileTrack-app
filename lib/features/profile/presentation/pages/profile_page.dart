import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/constants/country_data.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../../../../shared/providers/theme_provider.dart';
import '../../../../shared/widgets/app_header.dart';
import '../../../brushing/presentation/providers/brushing_provider.dart';
import '../../../quiz/data/repositories/quiz_repository.dart';
import '../../../quiz/presentation/providers/quiz_provider.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final streaks = ref.watch(streakProvider);
    final theme = Theme.of(context);

    if (user == null) {
      return Scaffold(
        body: Center(
          child: ElevatedButton(
            onPressed: () => context.go(AppRoutes.login),
            child: const Text('Sign In'),
          ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const AppHeader(),

                // Avatar & Name
                Column(
                  children: [
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          width: 90,
                          height: 90,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [AppTheme.primaryMint, AppTheme.accentBlue],
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
                                fontSize: 36,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: AppTheme.accentYellow,
                            shape: BoxShape.circle,
                            border: Border.all(color: theme.scaffoldBackgroundColor, width: 2),
                          ),
                          child: const Center(child: Text('✨', style: TextStyle(fontSize: 13))),
                        ),
                      ],
                    ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),

                    const SizedBox(height: 14),

                    Text(user.displayName, style: theme.textTheme.displaySmall)
                        .animate().fadeIn(delay: 200.ms),

                    Text(
                      user.email ?? '',
                      style: theme.textTheme.bodyMedium,
                    ).animate().fadeIn(delay: 300.ms),
                  ],
                ),

                const SizedBox(height: 24),

                // Points & Streak overview
                Row(
                  children: [
                    _StatCard(
                      emoji: '⭐',
                      value: '${user.totalPoints}',
                      label: 'Total Points',
                      color: AppTheme.accentYellow,
                    ),
                    const SizedBox(width: 12),
                    _StatCard(
                      emoji: '🔥',
                      value: '${streaks['current'] ?? 0}',
                      label: 'Day Streak',
                      color: const Color(0xFFFF6B35),
                    ),
                    const SizedBox(width: 12),
                    _StatCard(
                      emoji: '🏆',
                      value: '${streaks['max'] ?? 0}',
                      label: 'Best Streak',
                      color: AppTheme.primaryMint,
                    ),
                  ],
                ).animate().fadeIn(delay: 400.ms),

                const SizedBox(height: 24),

                // Badges
                if (user.badges.isNotEmpty) ...[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Badges', style: theme.textTheme.headlineLarge),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: user.badges.map((b) => _BadgeChip(badge: b)).toList(),
                  ),
                  const SizedBox(height: 24),
                ],

                // Info Section
                _InfoSection(
                  items: [
                    _InfoItem(icon: Icons.cake_outlined, label: 'Age', value: '${user.age} years'),
                    _InfoItem(
                      icon: Icons.flag_outlined,
                      label: 'Country',
                      value: (() {
                        final match = findCountry(user.country);
                        return match != null
                            ? '${match.flag}  ${match.name}'
                            : (user.country.isNotEmpty ? user.country : 'Not set');
                      })(),
                    ),
                    _InfoItem(icon: Icons.schedule_outlined, label: 'Timezone', value: user.timezone),
                  ],
                  theme: theme,
                ).animate().fadeIn(delay: 500.ms),

                const SizedBox(height: 24),

                // Settings / Actions
                _SettingsCard(theme: theme),

                const SizedBox(height: 16),

                // Sign out
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final repo = ref.read(authRepositoryProvider);
                      await repo.signOut();
                      ref.read(currentUserProvider.notifier).state = null;
                      if (context.mounted) context.go(AppRoutes.login);
                    },
                    icon: const Icon(Icons.logout_rounded, color: AppTheme.accentCoral),
                    label: const Text('Sign Out', style: TextStyle(color: AppTheme.accentCoral)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: AppTheme.accentCoral),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ).animate().fadeIn(delay: 600.ms),

                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String emoji;
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.emoji,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontFamily: 'Sora',
                fontWeight: FontWeight.w800,
                fontSize: 22,
                color: color,
              ),
            ),
            Text(label, style: theme.textTheme.bodyMedium?.copyWith(fontSize: 11), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _BadgeChip extends StatelessWidget {
  final String badge;

  const _BadgeChip({required this.badge});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryMint.withOpacity(0.2), AppTheme.accentBlue.withOpacity(0.15)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primaryMint.withOpacity(0.4)),
      ),
      child: Text(
        badge,
        style: const TextStyle(
          fontFamily: 'Nunito',
          fontWeight: FontWeight.w700,
          fontSize: 12,
          color: AppTheme.primaryMint,
        ),
      ),
    );
  }
}

class _InfoItem {
  final IconData icon;
  final String label;
  final String value;
  _InfoItem({required this.icon, required this.label, required this.value});
}

class _InfoSection extends StatelessWidget {
  final List<_InfoItem> items;
  final ThemeData theme;

  const _InfoSection({required this.items, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Column(
          children: items.asMap().entries.map((e) {
            final item = e.value;
            final isLast = e.key == items.length - 1;
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Icon(item.icon, color: AppTheme.primaryMint, size: 20),
                      const SizedBox(width: 12),
                      Text(item.label, style: theme.textTheme.bodyMedium),
                      const Spacer(),
                      Text(item.value, style: theme.textTheme.labelLarge),
                    ],
                  ),
                ),
                if (!isLast)
                  Divider(height: 1, color: theme.colorScheme.outline.withOpacity(0.5)),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _SettingsCard extends ConsumerWidget {
  final ThemeData theme;

  const _SettingsCard({required this.theme});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
                      color: AppTheme.primaryMint, size: 20),
                  const SizedBox(width: 12),
                  Text('Dark Mode', style: theme.textTheme.bodyLarge),
                  const Spacer(),
                  Switch(
                    value: isDark,
                    activeThumbColor: AppTheme.primaryMint,
                    onChanged: (_) => ref.read(themeProvider.notifier).toggleTheme(),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: theme.colorScheme.outline.withOpacity(0.5)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  const Icon(Icons.notifications_outlined, color: AppTheme.primaryMint, size: 20),
                  const SizedBox(width: 12),
                  Text('Notifications', style: theme.textTheme.bodyLarge),
                  const Spacer(),
                  Switch(
                    value: true,
                    activeThumbColor: AppTheme.primaryMint,
                    onChanged: (_) {},
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: theme.colorScheme.outline.withOpacity(0.5)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.info_outline, color: AppTheme.primaryMint, size: 20),
                title: Text('About smileTrack', style: theme.textTheme.bodyLarge),
                trailing: Icon(Icons.arrow_forward_ios_rounded, size: 14,
                    color: theme.colorScheme.onSurface.withOpacity(0.4)),
                onTap: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}