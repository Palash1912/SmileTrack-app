import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../../../../shared/widgets/app_header.dart';

class OtpPage extends ConsumerStatefulWidget {
  final String email;

  const OtpPage({
    super.key,
    required this.email,
  });

  @override
  ConsumerState<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends ConsumerState<OtpPage> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool _isLoading = false;
  bool _isResending = false;

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _otp => _controllers.map((c) => c.text).join();

  Future<void> _verify() async {
    if (_otp.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the 6-digit code')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final repo = ref.read(authRepositoryProvider);
      final user = await repo.verifyEmailOtp(
        email: widget.email,
        otp: _otp,
      );
      if (mounted) {
        ref.read(currentUserProvider.notifier).state = user;
        context.go(AppRoutes.home);
      }
    } catch (e) {
      if (mounted) {
        final message = e.toString().contains('email-not-verified')
            ? 'Email not verified yet. Please check your inbox and click the link first.'
            : 'Verification failed. Please try again.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: AppTheme.accentCoral,
            behavior: SnackBarBehavior.floating,
          ),
        );
        for (final c in _controllers) {
          c.clear();
        }
        _focusNodes[0].requestFocus();
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resend() async {
    setState(() => _isResending = true);
    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.resendEmailOtp(context:context, email: widget.email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Verification email resent. Please check your inbox.'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppTheme.accentCoral,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppHeader(showBackButton: true),
              const SizedBox(height: 40),
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryMint.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                            color: AppTheme.primaryMint.withOpacity(0.3),
                            width: 2),
                      ),
                      child: const Center(
                        child: Text('📧', style: TextStyle(fontSize: 40)),
                      ),
                    )
                        .animate()
                        .scale(duration: 500.ms, curve: Curves.elasticOut),
                    const SizedBox(height: 24),
                    Text('Check Your Email',
                            style: theme.textTheme.displaySmall)
                        .animate()
                        .fadeIn(delay: 200.ms),
                    const SizedBox(height: 12),
                    Text(
                      'We sent a verification link to\n${widget.email}\n\nClick the link in your email, then tap Verify below.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium,
                    ).animate().fadeIn(delay: 300.ms),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(6, (i) => _buildOtpField(i)),
              ).animate().fadeIn(delay: 400.ms),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _verify,
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.5),
                        )
                      : const Text('Verify Email'),
                ),
              ).animate().fadeIn(delay: 500.ms),
              const SizedBox(height: 20),
              Center(
                child: TextButton.icon(
                  icon: _isResending
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh),
                  label: const Text('Resend Email'),
                  onPressed: _isResending ? null : _resend,
                ),
              ).animate().fadeIn(delay: 600.ms),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOtpField(int index) {
    return SizedBox(
      width: 48,
      height: 60,
      child: TextFormField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: const TextStyle(
          fontFamily: 'Sora',
          fontSize: 22,
          fontWeight: FontWeight.w700,
        ),
        decoration: InputDecoration(
          counterText: '',
          contentPadding: EdgeInsets.zero,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide:
                BorderSide(color: Theme.of(context).colorScheme.outline),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppTheme.primaryMint, width: 2),
          ),
        ),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: (value) {
          if (value.isNotEmpty && index < 5) {
            _focusNodes[index + 1].requestFocus();
          } else if (value.isEmpty && index > 0) {
            _focusNodes[index - 1].requestFocus();
          }
          if (index == 5 && value.isNotEmpty) {
            _verify();
          }
        },
      ),
    );
  }
}
