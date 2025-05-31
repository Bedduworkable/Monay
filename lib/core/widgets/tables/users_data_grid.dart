import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../models/user_model.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/custom_widgets.dart'; // For EmptyState and MinimalLoader, UserAvatar, StatusBadge
import '../../utils/helpers.dart'; // For AppHelpers
import '../../utils/enums.dart'; // For UserRole

class UsersDataGrid extends ConsumerStatefulWidget {
  final List<UserModel> users;
  final bool isLoading;
  final String emptyStateTitle;
  final String emptyStateSubtitle;
  final IconData emptyStateIcon;
  final VoidCallback? onRefresh;
  final Function(UserModel)? onUserTap;

  const UsersDataGrid({
    super.key,
    required this.users,
    this.isLoading = false,
    this.emptyStateTitle = 'No Users to Display',
    this.emptyStateSubtitle = 'Adjust your filters or add new users to see data here.',
    this.emptyStateIcon = LucideIcons.table,
    this.onRefresh,
    this.onUserTap,
  });

  @override
  ConsumerState<UsersDataGrid> createState() => _UsersDataGridState();
}

class _UsersDataGridState extends ConsumerState<UsersDataGrid> {
  late UserDataSource _userDataSource;
  late List<GridColumn> _columns;

  @override
  void initState() {
    super.initState();
    _columns = _getColumns();
    _userDataSource = UserDataSource(
      users: widget.users,
      onRowTap: (user) {
        widget.onUserTap?.call(user);
      },
    );
  }

  @override
  void didUpdateWidget(covariant UsersDataGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.users != widget.users) {
      _userDataSource = UserDataSource(
        users: widget.users,
        onRowTap: (user) {
          widget.onUserTap?.call(user);
        },
      );
    }
  }

  List<GridColumn> _getColumns() {
    return <GridColumn>[
      GridColumn(
        columnName: 'name',
        label: Container(
          padding: const EdgeInsets.all(8.0),
          alignment: Alignment.centerLeft,
          child: Text(
            'Name',
            style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
      ),
      GridColumn(
        columnName: 'email',
        label: Container(
          padding: const EdgeInsets.all(8.0),
          alignment: Alignment.centerLeft,
          child: Text(
            'Email',
            style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
      ),
      GridColumn(
        columnName: 'role',
        label: Container(
          padding: const EdgeInsets.all(8.0),
          alignment: Alignment.centerLeft,
          child: Text(
            'Role',
            style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
      ),
      GridColumn(
        columnName: 'status',
        label: Container(
          padding: const EdgeInsets.all(8.0),
          alignment: Alignment.centerLeft,
          child: Text(
            'Status',
            style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
      ),
      GridColumn(
        columnName: 'createdAt',
        label: Container(
          padding: const EdgeInsets.all(8.0),
          alignment: Alignment.centerLeft,
          child: Text(
            'Joined At',
            style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
      ),
      GridColumn(
        columnName: 'expiresAt',
        label: Container(
          padding: const EdgeInsets.all(8.0),
          alignment: Alignment.centerLeft,
          child: Text(
            'Expiry',
            style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
      ),
      GridColumn(
        columnName: 'actions',
        label: Container(
          padding: const EdgeInsets.all(8.0),
          alignment: Alignment.center,
          child: Text(
            'Actions',
            style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return const Center(child: MinimalLoader());
    }

    if (widget.users.isEmpty) {
      return EmptyState(
        icon: widget.emptyStateIcon,
        title: widget.emptyStateTitle,
        subtitle: widget.emptyStateSubtitle,
        actionText: widget.onRefresh != null ? 'Refresh Data' : null,
        onAction: widget.onRefresh,
      );
    }

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.cardBorder, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SfDataGrid(
          source: _userDataSource,
          columns: _columns,
          headerRowHeight: 50,
          rowHeight: 60,
          columnWidthMode: ColumnWidthMode.fill,
          allowSorting: true,
          gridLinesVisibility: GridLinesVisibility.both,
          headerGridLinesVisibility: GridLinesVisibility.both,
          onQueryRowHeight: (details) {
            // Adjust row height based on content if needed
            return details.getIntrinsicRowHeight(details.rowIndex);
          },
        ).animate().fadeIn(duration: const Duration(milliseconds: 600)),
      ),
    );
  }
}

class UserDataSource extends DataGridSource {
  List<UserModel> users = [];
  Function(UserModel)? onRowTap;

  UserDataSource({required this.users, this.onRowTap}) {
    _buildDataGridRows();
  }

  List<DataGridRow> _userDataGridRows = [];

  @override
  List<DataGridRow> get rows => _userDataGridRows;

  void _buildDataGridRows() {
    _userDataGridRows = users.map<DataGridRow>((user) {
      return DataGridRow(cells: [
        DataGridCell<String>(columnName: 'name', value: user.name),
        DataGridCell<String>(columnName: 'email', value: user.email),
        DataGridCell<String>(columnName: 'role', value: user.displayRole),
        DataGridCell<String>(columnName: 'status', value: user.approvalStatus.displayName),
        DataGridCell<DateTime>(columnName: 'createdAt', value: user.createdAt),
        DataGridCell<DateTime?>(columnName: 'expiresAt', value: user.expiresAt),
        DataGridCell<UserModel>(columnName: 'actions', value: user),
      ]);
    }).toList();
  }

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    final UserModel user = row.getCells().last.value as UserModel; // Get the UserModel from the last cell ('actions')
    final Color roleColor = AppHelpers.getRoleColor(user.role);

    return DataGridRowAdapter(
        cells: row.getCells().map<Widget>((e) {
          if (e.columnName == 'name') {
            return Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  UserAvatar(name: e.value.toString(), radius: 16),
                  const SizedBox(width: 8),
                  Expanded(child: Text(e.value.toString(), style: AppTextStyles.bodyMedium, maxLines: 1, overflow: TextOverflow.ellipsis)),
                ],
              ),
            );
          } else if (e.columnName == 'role') {
            return Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: roleColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(e.value.toString(), style: AppTextStyles.labelSmall.copyWith(color: roleColor)),
              ),
            );
          } else if (e.columnName == 'status') {
            final Color statusColor = user.approvalStatus.color;
            return Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: StatusBadge(
                status: e.value.toString(),
                backgroundColor: statusColor.withOpacity(0.1),
                textColor: statusColor,
              ),
            );
          } else if (e.columnName == 'createdAt') {
            final DateTime date = e.value as DateTime;
            return Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Text(AppHelpers.formatDate(date), style: AppTextStyles.bodyMedium),
            );
          } else if (e.columnName == 'expiresAt') {
            final DateTime? date = e.value as DateTime?;
            if (date != null) {
              return Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  AppHelpers.formatDate(date),
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: user.isExpired ? AppColors.error : (user.isExpiringSoon ? AppColors.warning : AppColors.textPrimary),
                  ),
                ),
              );
            } else {
              return Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.all(8.0),
                child: Text('N/A', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary)),
              );
            }
          } else if (e.columnName == 'actions') {
            return Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(8.0),
              child: IconButton(
                icon: const Icon(LucideIcons.eye, size: 20, color: AppColors.primary),
                onPressed: () {
                  onRowTap?.call(user);
                },
              ),
            );
          } else {
            return Container(
              padding: const EdgeInsets.all(8.0),
              alignment: Alignment.centerLeft,
              child: Text(e.value?.toString() ?? '', style: AppTextStyles.bodyMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
            );
          }
        }).toList());
  }

  @override
  Future<void> onSortChange(SfDataGridSortDetails dataGridSortDetails) async {
    // Implement custom sorting if default is not sufficient
    // For basic sorting, SfDataGrid handles it automatically if allowSorting is true
  }
}