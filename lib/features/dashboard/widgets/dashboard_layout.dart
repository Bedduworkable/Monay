import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/dashboard_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/custom_widgets.dart';
import '../../../core/utils/helpers.dart';
import '../../../core/utils/enums.dart';
import '../../../core/models/user_model.dart';

class DashboardLayout extends ConsumerStatefulWidget {
  final String title;
  final String? subtitle;
  final Widget body;
  final UserModel? user;

  const DashboardLayout({
    super.key,
    required this.title,
    this.subtitle,
    required this.body,
    this.user,
  });

  @override
  ConsumerState<DashboardLayout> createState() => _DashboardLayoutState();
}

class _DashboardLayoutState extends ConsumerState<DashboardLayout>
    with TickerProviderStateMixin {
  bool _isSidebarExpanded = true;
  late AnimationController _sidebarController;

  @override
  void initState() {
    super.initState();
    _sidebarController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _sidebarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final notifications = ref.watch(dashboardNotificationsProvider);

    if (isMobile) {
      return _buildMobileLayout(notifications);
    } else {
      return _buildDesktopLayout(notifications);
    }
  }

  Widget _buildMobileLayout(List<Map<String, dynamic>> notifications) {
    return Scaffold(
      appBar: _buildMobileAppBar(),
      drawer: _buildSidebar(isMobile: true),
      body: Column(
        children: [
          if (notifications.isNotEmpty) _buildNotificationBanner(notifications),
          Expanded(child: widget.body),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildDesktopLayout(List<Map<String, dynamic>> notifications) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: _isSidebarExpanded ? 280 : 72,
            child: _buildSidebar(),
          ),

          // Main Content
          Expanded(
            child: Column(
              children: [
                // Top Bar
                _buildTopBar(),

                // Notifications
                if (notifications.isNotEmpty)
                  _buildNotificationBanner(notifications),

                // Body
                Expanded(child: widget.body),
              ],
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildMobileAppBar() {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: AppTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          if (widget.subtitle != null)
            Text(
              widget.subtitle!,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(LucideIcons.bell),
        ),
        IconButton(
          onPressed: _showProfileMenu,
          icon: UserAvatar(
            name: widget.user?.name ?? 'User',
            radius: 16,
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildTopBar() {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Sidebar Toggle
          IconButton(
            onPressed: _toggleSidebar,
            icon: Icon(
              _isSidebarExpanded ? LucideIcons.panelLeftClose : LucideIcons.panelLeftOpen,
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(width: 16),

          // Title & Subtitle
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: AppTextStyles.headlineSmall.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (widget.subtitle != null)
                  Text(
                    widget.subtitle!,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),

          // Search Bar
          SizedBox(
            width: 300,
            child: MinimalTextField(
              hint: 'Search leads, users...',
              prefixIcon: LucideIcons.search,
            ),
          ),

          const SizedBox(width: 16),

          // Notifications
          IconButton(
            onPressed: () {},
            icon: const Icon(LucideIcons.bell),
          ),

          const SizedBox(width: 8),

          // Profile Menu
          GestureDetector(
            onTap: _showProfileMenu,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                UserAvatar(
                  name: widget.user?.name ?? 'User',
                  radius: 18,
                ),
                const SizedBox(width: 8),
                if (_isSidebarExpanded) ...[
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.user?.name ?? 'User',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        widget.user?.displayRole ?? 'Role',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                ],
                Icon(
                  LucideIcons.chevronDown,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar({bool isMobile = false}) {
    final currentUser = widget.user;
    if (currentUser == null) return const SizedBox();

    return Container(
      width: isMobile ? 280 : (_isSidebarExpanded ? 280 : 72),
      decoration: const BoxDecoration(
        color: AppColors.sidebarBackground,
        border: Border(
          right: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: Column(
        children: [
          // Logo Section
          _buildLogoSection(isMobile),

          // Navigation Items
          Expanded(
            child: _buildNavigationItems(currentUser, isMobile),
          ),

          // Bottom Section
          _buildBottomSection(currentUser, isMobile),
        ],
      ),
    );
  }

  Widget _buildLogoSection(bool isMobile) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              LucideIcons.building2,
              color: AppColors.textOnPrimary,
              size: 18,
            ),
          ),
          if (isMobile || _isSidebarExpanded) ...[
            const SizedBox(width: 12),
            Text(
              'IGPL Monday',
              style: AppTextStyles.titleLarge.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNavigationItems(UserModel user, bool isMobile) {
    final items = _getNavigationItems(user);

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildNavigationItem(item, isMobile);
      },
    );
  }

  Widget _buildNavigationItem(Map<String, dynamic> item, bool isMobile) {
    final isSelected = item['isSelected'] ?? false;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: InkWell(
        onTap: () => _handleNavigation(item['route']),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.sidebarItemActive : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                item['icon'] as IconData,
                size: 20,
                color: isSelected
                    ? AppColors.sidebarItemActiveText
                    : AppColors.sidebarItemText,
              ),
              if (isMobile || _isSidebarExpanded) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item['title'] as String,
                    style: (isSelected
                        ? AppTextStyles.sidebarItemActive
                        : AppTextStyles.sidebarItem),
                  ),
                ),
                if (item['badge'] != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${item['badge']}',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textOnPrimary,
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomSection(UserModel user, bool isMobile) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (user.isExpiringSoon)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.warningSurface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.warning.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    LucideIcons.alertTriangle,
                    color: AppColors.warning,
                    size: 16,
                  ),
                  if (isMobile || _isSidebarExpanded) ...[
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Account expires in ${user.daysUntilExpiry} days',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.warning,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

          const SizedBox(height: 16),

          // Sign Out
          InkWell(
            onTap: _handleSignOut,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Row(
                children: [
                  Icon(
                    LucideIcons.logOut,
                    size: 20,
                    color: AppColors.error,
                  ),
                  if (isMobile || _isSidebarExpanded) ...[
                    const SizedBox(width: 12),
                    Text(
                      'Sign Out',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationBanner(List<Map<String, dynamic>> notifications) {
    return Container(
      color: AppColors.infoSurface,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: notifications.take(3).map((notification) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Icon(
                  _getNotificationIcon(notification['type']),
                  size: 16,
                  color: _getNotificationColor(notification['type']),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    notification['message'],
                    style: AppTextStyles.bodySmall.copyWith(
                      color: _getNotificationColor(notification['type']),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => _handleNotificationAction(notification['action']),
                  child: const Text('View'),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () => _handleNavigation('add_lead'),
      backgroundColor: AppColors.primary,
      child: const Icon(
        LucideIcons.plus,
        color: AppColors.textOnPrimary,
      ),
    );
  }

  List<Map<String, dynamic>> _getNavigationItems(UserModel user) {
    final items = <Map<String, dynamic>>[
      {
        'title': 'Dashboard',
        'icon': LucideIcons.layoutDashboard,
        'route': 'dashboard',
        'isSelected': true,
      },
      {
        'title': 'Leads',
        'icon': LucideIcons.target,
        'route': 'leads',
        'isSelected': false,
      },
    ];

    if (user.canManageUsers) {
      items.addAll([
        {
          'title': 'Team',
          'icon': LucideIcons.users,
          'route': 'users',
          'isSelected': false,
        },
        {
          'title': 'Join Requests',
          'icon': LucideIcons.userPlus,
          'route': 'join_requests',
          'isSelected': false,
          'badge': 3, // This would come from actual data
        },
      ]);
    }

    if (user.canManageSettings) {
      items.add({
        'title': 'Settings',
        'icon': LucideIcons.settings,
        'route': 'settings',
        'isSelected': false,
      });
    }

    items.addAll([
      {
        'title': 'Reports',
        'icon': LucideIcons.barChart,
        'route': 'reports',
        'isSelected': false,
      },
      {
        'title': 'Profile',
        'icon': LucideIcons.user,
        'route': 'profile',
        'isSelected': false,
      },
    ]);

    return items;
  }

  void _toggleSidebar() {
    setState(() {
      _isSidebarExpanded = !_isSidebarExpanded;
    });
  }

  void _handleNavigation(String route) {
    AppHelpers.showInfoSnackbar(context, 'Navigate to: $route');
  }

  void _handleNotificationAction(String action) {
    AppHelpers.showInfoSnackbar(context, 'Notification action: $action');
  }

  void _showProfileMenu() {
    // Show profile menu
    AppHelpers.showInfoSnackbar(context, 'Profile menu');
  }

  Future<void> _handleSignOut() async {
    final confirm = await AppHelpers.showConfirmDialog(
      context,
      title: 'Sign Out',
      content: 'Are you sure you want to sign out?',
      confirmText: 'Sign Out',
    );

    if (confirm == true) {
      final authNotifier = ref.read(authNotifierProvider.notifier);
      await authNotifier.signOut();
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'warning':
        return LucideIcons.alertTriangle;
      case 'error':
        return LucideIcons.alertCircle;
      case 'info':
        return LucideIcons.info;
      default:
        return LucideIcons.bell;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'warning':
        return AppColors.warning;
      case 'error':
        return AppColors.error;
      case 'info':
        return AppColors.info;
      default:
        return AppColors.textSecondary;
    }
  }
}