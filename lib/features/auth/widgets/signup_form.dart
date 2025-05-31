import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/custom_widgets.dart'; // For MinimalTextField, MinimalButton
import '../../../core/utils/validators.dart'; // For AppValidators

class SignupForm extends ConsumerStatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final TextEditingController leaderEmailController;
  final bool isLoading;
  final ValueChanged<bool> onAcceptTermsChanged;
  final bool acceptTerms;
  final VoidCallback onSubmit;

  const SignupForm({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.leaderEmailController,
    required this.isLoading,
    required this.onAcceptTermsChanged,
    required this.acceptTerms,
    required this.onSubmit,
  });

  @override
  ConsumerState<SignupForm> createState() => _SignupFormState();
}

class _SignupFormState extends ConsumerState<SignupForm> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Full Name Field
          MinimalTextField(
            label: 'Full Name',
            hint: 'Enter your full name',
            controller: widget.nameController,
            prefixIcon: LucideIcons.user,
            validator: AppValidators.validateName,
            enabled: !widget.isLoading,
          ),

          const SizedBox(height: 20),

          // Email Field
          MinimalTextField(
            label: 'Email Address',
            hint: 'Enter your email',
            controller: widget.emailController,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: LucideIcons.mail,
            validator: AppValidators.validateEmail,
            enabled: !widget.isLoading,
          ),

          const SizedBox(height: 20),

          // Leader Email Field
          MinimalTextField(
            label: 'Leader\'s Email',
            hint: 'Enter your leader\'s email',
            controller: widget.leaderEmailController,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: LucideIcons.userCheck,
            validator: AppValidators.validateEmail,
            enabled: !widget.isLoading,
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
            controller: widget.passwordController,
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
            enabled: !widget.isLoading,
          ),

          const SizedBox(height: 20),

          // Confirm Password Field
          MinimalTextField(
            label: 'Confirm Password',
            hint: 'Confirm your password',
            controller: widget.confirmPasswordController,
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
              widget.passwordController.text,
            ),
            enabled: !widget.isLoading,
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
                  value: widget.acceptTerms,
                  onChanged: widget.isLoading ? null : widget.onAcceptTermsChanged,
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
            onPressed: (widget.acceptTerms && !widget.isLoading) ? widget.onSubmit : null,
            isLoading: widget.isLoading,
            icon: LucideIcons.userPlus,
            width: double.infinity,
          ),
        ],
      ),
    );
  }
}