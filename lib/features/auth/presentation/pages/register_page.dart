import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/constants/country_data.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../../../../shared/widgets/app_header.dart';
import '../../../../shared/widgets/country_picker_sheet.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  int _age = 18;
  String _country = 'United States';
  late final TextEditingController _countryController =
      TextEditingController(text: '🇺🇸  United States');
  String _timezone = 'America/New_York';
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  final List<Map<String, String>> _timezones = [
    {'label': 'UTC (London, Reykjavik)', 'value': 'UTC'},
    {'label': 'EST (New York, Miami)', 'value': 'America/New_York'},
    {'label': 'CST (Chicago, Dallas)', 'value': 'America/Chicago'},
    {'label': 'MST (Denver, Phoenix)', 'value': 'America/Denver'},
    {'label': 'PST (Los Angeles, Seattle)', 'value': 'America/Los_Angeles'},
    {'label': 'IST (India)', 'value': 'Asia/Kolkata'},
    {'label': 'JST (Japan)', 'value': 'Asia/Tokyo'},
    {'label': 'CST (China)', 'value': 'Asia/Shanghai'},
    {'label': 'GST (Dubai)', 'value': 'Asia/Dubai'},
    {'label': 'AEST (Sydney)', 'value': 'Australia/Sydney'},
    {'label': 'CET (Paris, Berlin)', 'value': 'Europe/Paris'},
    {'label': 'NZST (Auckland)', 'value': 'Pacific/Auckland'},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  Future<void> _pickCountry() async {
    final picked = await showCountryPickerSheet(
      context: context,
      selectedCountry: _country,
    );
    if (picked != null) {
      setState(() {
        _country = picked.name;
        _countryController.text = '${picked.flag}  ${picked.name}';
      });
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.sendEmailOtp(
        context:context,
        email: _emailController.text.trim(),
        password: _passwordController.text,
        displayName: _nameController.text.trim(),
        age: _age,
        country: _country,
        timezone: _timezone,
      );
      if (mounted) {
        context.go(AppRoutes.otp, extra: {
          'email': _emailController.text.trim(),
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppTheme.accentCoral,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppHeader(showBackButton: true),
                const SizedBox(height: 24),
                Text('Create Account', style: theme.textTheme.displaySmall)
                    .animate()
                    .fadeIn(delay: 100.ms),
                const SizedBox(height: 8),
                Text('Start your smile journey today! 🌟',
                        style: theme.textTheme.bodyMedium)
                    .animate()
                    .fadeIn(delay: 200.ms),
                const SizedBox(height: 32),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(
                          labelText: 'Display Name',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: (v) => v == null || v.isEmpty
                            ? 'Please enter your name'
                            : null,
                      ).animate().fadeIn(delay: 200.ms),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email Address',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!v.contains('@')) return 'Enter a valid email';
                          return null;
                        },
                      ).animate().fadeIn(delay: 250.ms),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined),
                            onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.length < 8) {
                            return 'Password must be at least 8 characters';
                          }
                          return null;
                        },
                      ).animate().fadeIn(delay: 300.ms),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirm,
                        decoration: InputDecoration(
                          labelText: 'Confirm Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(_obscureConfirm
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined),
                            onPressed: () => setState(
                                () => _obscureConfirm = !_obscureConfirm),
                          ),
                        ),
                        validator: (v) {
                          if (v != _passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ).animate().fadeIn(delay: 350.ms),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Age: $_age',
                                    style: theme.textTheme.labelLarge),
                                Slider(
                                  value: _age.toDouble(),
                                  min: 5,
                                  max: 100,
                                  divisions: 95,
                                  activeColor: colorScheme.primary,
                                  onChanged: (v) =>
                                      setState(() => _age = v.round()),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ).animate().fadeIn(delay: 400.ms),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: _pickCountry,
                        child: AbsorbPointer(
                          child: TextFormField(
                            controller: _countryController,
                            decoration: const InputDecoration(
                              labelText: 'Country',
                              prefixIcon: Icon(Icons.flag_outlined),
                              suffixIcon:
                                  Icon(Icons.arrow_drop_down_rounded, size: 28),
                            ),
                          ),
                        ),
                      ).animate().fadeIn(delay: 450.ms),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        initialValue: _timezone,
                        decoration: const InputDecoration(
                          labelText: 'Timezone',
                          prefixIcon: Icon(Icons.schedule_outlined),
                        ),
                        items: _timezones
                            .map((tz) => DropdownMenuItem(
                                  value: tz['value'],
                                  child: Text(tz['label']!,
                                      overflow: TextOverflow.ellipsis),
                                ))
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _timezone = v ?? _timezone),
                      ).animate().fadeIn(delay: 500.ms),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _register,
                          child: _isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2.5),
                                )
                              : const Text('Send Verification Code'),
                        ),
                      ).animate().fadeIn(delay: 550.ms),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Already have an account? ',
                              style: theme.textTheme.bodyMedium),
                          TextButton(
                            onPressed: () => context.go(AppRoutes.login),
                            child: const Text('Sign In'),
                          ),
                        ],
                      ).animate().fadeIn(delay: 600.ms),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
