import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/app_bootstrap.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../services/auth_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isCreateMode = false;
  bool _busy = false;
  String? _message;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (!AppBootstrap.firebaseAvailable) {
      setState(() {
        _message =
            'Firebase configuration is not connected yet. Run flutterfire configure, then rebuild the app.';
      });
      return;
    }

    setState(() {
      _busy = true;
      _message = null;
    });

    try {
      if (_isCreateMode) {
        await AuthService.instance.createAccount(
          email: _emailController.text,
          password: _passwordController.text,
        );
      } else {
        await AuthService.instance.signInWithEmailPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
      }

      if (!mounted) return;
      context.go('/dashboard');
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;
      setState(() {
        _message = _friendlyFirebaseError(error);
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _message = 'Authentication could not be completed. Please try again.';
      });
      debugPrint('Authentication error: $error');
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
        });
      }
    }
  }

  String _friendlyFirebaseError(FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
        return 'Email किंवा password चुकीचा आहे.';
      case 'email-already-in-use':
        return 'हा email आधीपासून वापरात आहे.';
      case 'weak-password':
        return 'Password अधिक मजबूत ठेवा.';
      case 'invalid-email':
        return 'Valid email address द्या.';
      default:
        return 'Authentication could not be completed. Please try again.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final compact = width < 800;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 980),
              child: compact
                  ? _mobileLayout(context)
                  : _desktopLayout(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget _desktopLayout(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.divider),
        boxShadow: const [
          BoxShadow(
            blurRadius: 40,
            spreadRadius: -18,
            offset: Offset(0, 20),
            color: Color(0x26000000),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(flex: 5, child: _brandPanel(context)),
          Expanded(flex: 4, child: _formPanel(context)),
        ],
      ),
    );
  }

  Widget _mobileLayout(BuildContext context) {
    return Column(
      children: [
        _brandPanel(context),
        const SizedBox(height: 16),
        _formPanel(context),
      ],
    );
  }

  Widget _brandPanel(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxxl),
      constraints: const BoxConstraints(minHeight: 540),
      decoration: const BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppRadius.xl),
          bottomLeft: Radius.circular(AppRadius.xl),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 92,
            height: 92,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.asset(
                'assets/logo/satva_dhara_logo.jpg',
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'SATVA DHARA',
            style: TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'DAIRY FARM ERP',
            style: TextStyle(
              color: AppColors.accent,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: 28),
          Text(
            'A digital operating system for the farm.',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            'Offline-first operations, secure cloud sync and an intelligence layer built for real dairy workflows.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                  height: 1.55,
                ),
          ),
        ],
      ),
    );
  }

  Widget _formPanel(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxxl),
      constraints: const BoxConstraints(minHeight: 540),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _isCreateMode ? 'Create account' : 'Welcome back',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              _isCreateMode
                  ? 'Start your Satva Dhara workspace.'
                  : 'Sign in to continue to your farm workspace.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 28),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.mail_outline_rounded),
              ),
              validator: (value) {
                final email = value?.trim() ?? '';
                if (email.isEmpty || !email.contains('@')) {
                  return 'Valid email address द्या.';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              autofillHints: const [AutofillHints.password],
              decoration: const InputDecoration(
                labelText: 'Password',
                prefixIcon: Icon(Icons.lock_outline_rounded),
              ),
              validator: (value) {
                if ((value ?? '').length < 6) {
                  return 'Password किमान 6 characters असावा.';
                }
                return null;
              },
            ),
            if (_message != null) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF4E5),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Text(
                  _message!,
                  style: const TextStyle(color: AppColors.warning),
                ),
              ),
            ],
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _busy ? null : _submit,
              icon: _busy
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.arrow_forward_rounded),
              label: Text(_isCreateMode ? 'Create account' : 'Sign in'),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: _busy
                  ? null
                  : () {
                      setState(() {
                        _isCreateMode = !_isCreateMode;
                        _message = null;
                      });
                    },
              child: Text(
                _isCreateMode
                    ? 'Already have an account? Sign in'
                    : 'New here? Create account',
              ),
            ),
            if (!AppBootstrap.firebaseAvailable) ...[
              const SizedBox(height: 18),
              const Row(
                children: [
                  Icon(Icons.info_outline_rounded, size: 18, color: AppColors.warning),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Firebase is not configured for this build yet.',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
