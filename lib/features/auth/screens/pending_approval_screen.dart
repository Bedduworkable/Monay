import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/custom_widgets.dart';
import '../../../core/utils/helpers.dart';
import '../../../core/navigation/route_names.dart';

class PendingApprovalScreen extends ConsumerStatefulWidget {
  const PendingApprovalScreen({super.key});

  @override
  ConsumerState<PendingApprovalScreen> createState() => _PendingApprovalScreenState();
}

class _PendingApprovalScreenState extends ConsumerState<PendingApprovalScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);

    // Listen to auth state changes to redirect when approved
    ref.listen<AsyncValue<UserModel?>>(currentUserProvider, (previous, next) {
      next.when(
        data: (user) {
          if (user != null && user.isApproved) {
            AppHelpers.showSuccessSnackbar(
              context,
              'Your account has been approved! Welcome to IGPL Monday.',
            );
            // Navigation will be handled by router redirect
          } else if (user != null && user.isRejected) {
            AppHelpers.showErrorSnackbar(
              context,
              'Your account request was rejected. Please contact your leader.',
            );
          }
        },
        loading: () {},
        error: (error, _) {},
      );
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated Waiting Icon
                  _buildWaitingIcon()
                      .animate()
                      .fadeIn(duration: 800.ms)
                      .scale(begin: const Offset(0.8, 0.8), duration: 800.ms),

                  const SizedBox(height: 32),

                  // Main Content
                  _buildMainContent(currentUser)
                      .animate()
                      .fadeIn(duration: 800.ms, delay: 200.ms)
                      .slideY(begin: 0.3, duration: 800.ms),

                  const SizedBox(height: 40),

                  // Actions
                  _buildActions()
                      .animate()
                      .fadeIn(duration: 800.ms, delay: 400.ms)
                      .slideY(begin: 0.3, duration: 800.ms),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWaitingIcon() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (_pulseController.value * 0.1),
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.warning.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Icon(
              LucideIcons.clock,
              size: 60,
              color: AppColors.warning,
            ),
          ),
        );
      },
    );
  }

  Widget _buildMainContent(AsyncValue<UserModel?> currentUser) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Title
          Text(
            'Account Pending Approval',
            style: AppTextStyles.headlineLarge.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          // Description
          Text(
            'Your account has been created successfully and is waiting for approval from your leader.',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 24),

          // User Info Card
          currentUser.when(
            data: (user) => user != null ? _buildUserInfoCard(user) : const SizedBox(),
            loading: () => const MinimalLoader(),
            error: (_, __) => const SizedBox(),
          ),

          const SizedBox(height: 24),

          // What happens next
          _buildWhatNextSection(),
        ],
      ),
    );
  }

  Widget _buildUserInfoCard(UserModel user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          // User Avatar
          UserAvatar(
            name: user.name,
            radius: 30,
            backgroundColor: AppColors.primary,
          ),

          const SizedBox(height: 12),

          // User Name
          Text(
            user.name,
            style: AppTextStyles.titleLarge.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 4),

          // User Email
          Text(
            user.email,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: 12),

          // Status Badge
          StatusBadge(
            status: user.approvalStatus.displayName,
            backgroundColor: AppColors.warning.withOpacity(0.1),
            textColor: AppColors.warning,
          ),

          const SizedBox(height: 8),

          // Created Date
          Text(
            'Account created on ${AppHelpers.formatDate(user.createdAt)}',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWhatNextSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What happens next?',
          style: AppTextStyles.titleMedium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 12),

        ..._buildSteps(),
      ],
    );
  }

  List<Widget> _buildSteps() {
    final steps = [
      {
        'icon': LucideIcons.mail,
        'title': 'Notification Sent',
        'description': 'Your leader has been notified of your join request.',
      },
      {
        'icon': LucideIcons.userCheck,
        'title': 'Leader Review',
        'description': 'Your leader will review and approve your account.',
      },
      {
        'icon': LucideIcons.checkCircle,
        'title': 'Account Activated',
        'description': 'Once approved, you can access all CRM features.',
      },
    ];

    return steps.asMap().entries.map((entry) {
      final index = entry.key;
      final step = entry.value;
      final isLast = index == steps.length - 1;

      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step Icon
          Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: index == 0
                      ? AppColors.success
                      : AppColors.neutral300,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  step['icon'] as IconData,
                  size: 16,
                  color: index == 0
                      ? AppColors.textOnPrimary
                      : AppColors.textSecondary,
                ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 24,
                  color: AppColors.neutral300,
                  margin: const EdgeInsets.symmetric(vertical: 4),
                ),
            ],
          ),

          const SizedBox(width: 12),

          // Step Content
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step['title'] as String,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    step['description'] as String,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }).toList();
  }

  Widget _buildActions() {
    return Column(
      children: [
        // Refresh Button
        MinimalButton(
          text: 'Check Status',
          onPressed: _refreshStatus,
          icon: LucideIcons.refreshCw,
          isOutlined: true,
          width: double.infinity,
        ),

        const SizedBox(height: 16),

        // Contact Support
        TextButton.icon(
          onPressed: _showContactDialog,
          icon: const Icon(LucideIcons.helpCircle, size: 18),
          label: const Text('Need Help? Contact Support'),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.textSecondary,
          ),
        ),

        const SizedBox(height: 16),

        // Sign Out
        TextButton.icon(
          onPressed: _handleSignOut,
          icon: const Icon(LucideIcons.logOut, size: 18),
          label: const Text('Sign Out'),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.error,
          ),
        ),
      ],
    );
  }

  Future<void> _refreshStatus() async {
    final authNotifier = ref.read(authNotifierProvider.notifier);
    await authNotifier.refreshUserData();

    if (mounted) {
      AppHelpers.showInfoSnackbar(context, 'Status updated');
    }
  }

  Future<void> _showContactDialog() async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contact Support'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('If you need assistance with your account approval:'),
            SizedBox(height: 12),
            Text('• Contact your leader directly'),
            Text('• Email: support@igplmonday.com'),
            Text('• Phone: +91 12345 67890'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSignOut() async {
    final confirm = await AppHelpers.showConfirmDialog(
      context,
      title: 'Sign Out',
      content: 'Are you sure you want to sign out? You can sign back in anytime to check your approval status.',
      confirmText: 'Sign Out',
    );

    if (confirm == true) {
      final authNotifier = ref.read(authNotifierProvider.notifier);
      await authNotifier.signOut();

      if (mounted) {
        context.go(RouteNames.login);
      }
    }
  }
}