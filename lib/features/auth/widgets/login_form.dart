import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/custom_widgets.dart';
import '../../../core/utils/validators.dart';

class LoginForm extends StatefulWidget {
  final VoidCallback? onSubmit;
  final bool isLoading;
  final TextEditingController? emailController;
  final TextEditingController? passwordController;

  const LoginForm({
    super.key,
    this.onSubmit,
    this.isLoading = false,
    this.emailController,
    this.passwordController,
  });

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _emailController = widget.emailController ?? TextEditingController();
    _passwordController = widget.passwordController ?? TextEditingController();
  }

  @override
  void dispose() {
    if (widget.emailController == null) {
      _emailController.dispose();
    }
    if (widget.passwordController == null) {
      _passwordController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Email Field
          MinimalTextField(
            label: 'Email Address',
            hint: 'Enter your email',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: LucideIcons.mail,
            validator: AppValidators.validateEmail,
            enabled: !widget.isLoading,
          ),

          const SizedBox(height: 20),

          // Password Field
          MinimalTextField(
            label: 'Password',
            hint: 'Enter your password',
            controller: _passwordController,
            obscureText: _obscurePassword,
            prefixIcon: LucideIcons.lock,
            suffixIcon: _obscurePassword
                ? LucideIcons.eyeOff
                : LucideIcons.eye,
            onSuffixTap: _togglePasswordVisibility,
            validator: AppValidators.validatePassword,
            enabled: !widget.isLoading,
          ),

          const SizedBox(height: 16),

          // Remember Me & Forgot Password Row
          _buildOptionsRow(),

          const SizedBox(height: 24),

          // Login Button
          MinimalButton(
            text: 'Sign In',
            onPressed: widget.isLoading ? null : _handleSubmit,
            isLoading: widget.isLoading,
            icon: LucideIcons.logIn,
            width: double.infinity,
          ),
        ],
      ),
    );
  }

  Widget _buildOptionsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Remember Me Checkbox
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: Checkbox(
                value: _rememberMe,
                onChanged: widget.isLoading ? null : (value) {
                  setState(() {
                    _rememberMe = value ?? false;
                  });
                },
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Remember me',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),

        // Forgot Password Link
        TextButton(
          onPressed: widget.isLoading ? null : _showForgotPasswordDialog,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            'Forgot Password?',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.primary,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() == true) {
      widget.onSubmit?.call();
    }
  }

  Future<void> _showForgotPasswordDialog() async {
    final emailController = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              LucideIcons.key,
              color: AppColors.primary,
              size: 24,
            ),
            const SizedBox(width: 8),
            const Text('Reset Password'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter your email address and we\'ll send you a link to reset your password.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            MinimalTextField(
              label: 'Email Address',
              hint: 'Enter your email',
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              prefixIcon: LucideIcons.mail,
              validator: AppValidators.validateEmail,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: AppTextStyles.buttonMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          MinimalButton(
            text: 'Send Reset Link',
            onPressed: () {
              if (AppValidators.validateEmail(emailController.text) == null) {
                Navigator.of(context).pop();
                _handlePasswordReset(emailController.text);
              }
            },
            icon: LucideIcons.send,
          ),
        ],
      ),
    );
  }

  void _handlePasswordReset(String email) {
    // This would typically call the auth service
    // For now, just show a success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Password reset link sent to $email'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  // Getters for parent widget to access form data
  String get email => _emailController.text.trim();
  String get password => _passwordController.text;
  bool get rememberMe => _rememberMe;
  bool get isValid => _formKey.currentState?.validate() == true;
}