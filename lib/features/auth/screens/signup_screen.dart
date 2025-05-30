import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/custom_widgets.dart';
import '../../../core/utils/validators.dart';
import '../../../core/utils/helpers.dart';
import '../../../core/navigation/route_names.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _leaderEmailController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _leaderEmailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authLoadingProvider);

    // Listen to auth state changes
    ref.listen<AsyncValue<UserModel?>>(authNotifierProvider, (previous, next) {
      next.when(
        data: (user) {
          if (user != null && user.isPending) {
            AppHelpers.showSuccessSnackbar(
              context,
              'Account created! Waiting for leader approval.',
            );
            context.go(RouteNames.pendingApproval);
          }
        },
        loading: () {},
        error: (error, _) {
          AppHelpers.showErrorSnackbar(context, error.toString());
        },
      );
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  _buildHeader()
                      .animate()
                      .fadeIn(duration: 600.ms)
                      .slideY(begin: -0.3, duration: 600.ms),

                  const SizedBox(height: 32),

                  // Signup Form
                  _buildSignupForm(isLoading)
                      .animate()
                      .fadeIn(duration: 600.ms, delay: 200.ms)
                      .slideY(begin: 0.3, duration: 600.ms),

                  const SizedBox(height: 24),

                  // Sign In Link
                  _buildSignInLink()
                      .animate()
                      .fadeIn(duration: 600.ms, delay: 400.ms),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Back Button
        Row(
          children: [
            IconButton(
              onPressed: () => context.pop(),
              icon: const Icon(LucideIcons.arrowLeft),
              style: IconButton.styleFrom(
                backgroundColor: AppColors.backgroundSecondary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const Spacer(),
          ],
        ),

        const SizedBox(height: 16),

        // App Logo
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(
            LucideIcons.building2,
            color: AppColors.textOnPrimary,
            size: 32,
          ),
        ),

        const SizedBox(height: 16),

        // Title
        Text(
          'Join IGPL Monday',
          style: AppTextStyles.displaySmall.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        // Subtitle
        Text(
          'Create your account to get started',
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildSignupForm(bool isLoading) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Full Name Field
            MinimalTextField(
              label: 'Full Name',
              hint: 'Enter your full name',
              controller: _nameController,
              prefixIcon: LucideIcons.user,
              validator: AppValidators.validateName,
              enabled: !isLoading,
            ),

            const SizedBox(height: 20),

            // Email Field
            MinimalTextField(
              label: 'Email Address',
              hint: 'Enter your email',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              prefixIcon: LucideIcons.mail,
              validator: AppValidators.validateEmail,
              enabled: !isLoading,
            ),

            const SizedBox(height: 20),

            // Leader Email Field
            MinimalTextField(
              label: 'Leader\'s Email',
              hint: 'Enter your leader\'s email',
              controller: _leaderEmailController,
              keyboardType: TextInputType.emailAddress,
              prefixIcon: LucideIcons.userCheck,
              validator: AppValidators.validateEmail,
              enabled: !isLoading,
            ),

            const SizedBox(height: 8),

            // Leader Email Info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.infoSurface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.info.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    LucideIcons.info,
                    size: 16,
                    color: AppColors.info,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Your account will need approval from this leader before you can access the system.',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.info,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Password Field
            MinimalTextField(
              label: 'Password',
              hint: 'Create a strong password',
              controller: _passwordController,
              obscureText: _obscurePassword,
              prefixIcon: LucideIcons.lock,
              suffixIcon: _obscurePassword
                  ? LucideIcons.eyeOff
                  : LucideIcons.eye,
              onSuffixTap: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
              validator: AppValidators.validatePassword,
              enabled: !isLoading,
            ),

            const SizedBox(height: 20),

            // Confirm Password Field
            MinimalTextField(
              label: 'Confirm Password',
              hint: 'Confirm your password',
              controller: _confirmPasswordController,
              obscureText: _obscureConfirmPassword,
              prefixIcon: LucideIcons.lock,
              suffixIcon: _obscureConfirmPassword
                  ? LucideIcons.eyeOff
                  : LucideIcons.eye,
              onSuffixTap: () {
                setState(() {
                  _obscureConfirmPassword = !_obscureConfirmPassword;
                });
              },
              validator: (value) => AppValidators.validateConfirmPassword(
                value,
                _passwordController.text,
              ),
              enabled: !isLoading,
            ),

            const SizedBox(height: 20),

            // Terms and Conditions
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: Checkbox(
                    value: _acceptTerms,
                    onChanged: isLoading ? null : (value) {
                      setState(() {
                        _acceptTerms = value ?? false;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      children: [
                        const TextSpan(text: 'I agree to the '),
                        TextSpan(
                          text: 'Terms of Service',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.primary,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        const TextSpan(text: ' and '),
                        TextSpan(
                          text: 'Privacy Policy',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.primary,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Sign Up Button
            MinimalButton(
              text: 'Create Account',
              onPressed: (_acceptTerms && !isLoading) ? _handleSignUp : null,
              isLoading: isLoading,
              icon: LucideIcons.userPlus,
              width: double.infinity,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignInLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Already have an account? ',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        TextButton(
          onPressed: () => context.go(RouteNames.login),
          child: Text(
            'Sign In',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_acceptTerms) {
      AppHelpers.showErrorSnackbar(
        context,
        'Please accept the Terms of Service and Privacy Policy to continue.',
      );
      return;
    }

    final authNotifier = ref.read(authNotifierProvider.notifier);

    await authNotifier.signUp(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      name: _nameController.text.trim(),
      leaderEmail: _leaderEmailController.text.trim(),
    );
  }
}