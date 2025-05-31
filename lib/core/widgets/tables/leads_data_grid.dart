import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../models/lead_model.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/custom_widgets.dart'; // For EmptyState and MinimalLoader
import '../../utils/helpers.dart'; // For AppHelpers

class LeadsDataGrid extends ConsumerStatefulWidget {
  final List<LeadModel> leads;
  final bool isLoading;
  final String emptyStateTitle;
  final String emptyStateSubtitle;
  final IconData emptyStateIcon;
  final VoidCallback? onRefresh;
  final Function(LeadModel)? onLeadTap;

  const LeadsDataGrid({
    super.key,
    required this.leads,
    this.isLoading = false,
    this.emptyStateTitle = 'No Leads to Display',
    this.emptyStateSubtitle = 'Adjust your filters or add new leads to see data here.',
    this.emptyStateIcon = LucideIcons.table,
    this.onRefresh,
    this.onLeadTap,
  });

  @override
  ConsumerState<LeadsDataGrid> createState() => _LeadsDataGridState();
}

class _LeadsDataGridState extends ConsumerState<LeadsDataGrid> {
  late LeadDataSource _leadDataSource;
  late List<GridColumn> _columns;

  @override
  void initState() {
    super.initState();
    _columns = _getColumns();
    _leadDataSource = LeadDataSource(
      leads: widget.leads,
      onRowTap: (lead) {
        widget.onLeadTap?.call(lead);
      },
    );
  }

  @override
  void didUpdateWidget(covariant LeadsDataGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.leads != widget.leads) {
      _leadDataSource = LeadDataSource(
        leads: widget.leads,
        onRowTap: (lead) {
          widget.onLeadTap?.call(lead);
        },
      );
    }
  }

  List<GridColumn> _getColumns() {
    return <GridColumn>[
      GridColumn(
        columnName: 'title',
        label: Container(
          padding: const EdgeInsets.all(8.0),
          alignment: Alignment.centerLeft,
          child: Text(
            'Lead Title',
            style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
      ),
      GridColumn(
        columnName: 'client',
        label: Container(
          padding: const EdgeInsets.all(8.0),
          alignment: Alignment.centerLeft,
          child: Text(
            'Client Name',
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
        columnName: 'followUpDate',
        label: Container(
          padding: const EdgeInsets.all(8.0),
          alignment: Alignment.centerLeft,
          child: Text(
            'Follow Up',
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
            'Created At',
            style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
      ),
      GridColumn(
        columnName: 'updatedAt',
        label: Container(
          padding: const EdgeInsets.all(8.0),
          alignment: Alignment.centerLeft,
          child: Text(
            'Updated At',
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

    if (widget.leads.isEmpty) {
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
          source: _leadDataSource,
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
        ).animate().fadeIn(duration: 600.ms),
      ),
    );
  }
}

class LeadDataSource extends DataGridSource {
  List<LeadModel> leads = [];
  Function(LeadModel)? onRowTap;

  LeadDataSource({required this.leads, this.onRowTap}) {
    _buildDataGridRows();
  }

  List<DataGridRow> _leadDataGridRows = [];

  @override
  List<DataGridRow> get rows => _leadDataGridRows;

  void _buildDataGridRows() {
    _leadDataGridRows = leads.map<DataGridRow>((lead) {
      return DataGridRow(cells: [
        DataGridCell<String>(columnName: 'title', value: lead.leadTitle),
        DataGridCell<String>(columnName: 'client', value: lead.clientName),
        DataGridCell<String>(columnName: 'status', value: lead.status),
        DataGridCell<DateTime?>(columnName: 'followUpDate', value: lead.followUpDate),
        DataGridCell<DateTime>(columnName: 'createdAt', value: lead.createdAt),
        DataGridCell<DateTime>(columnName: 'updatedAt', value: lead.updatedAt),
        DataGridCell<LeadModel>(columnName: 'actions', value: lead),
      ]);
    }).toList();
  }

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    final LeadModel lead = row.get                   CellWithName('actions')!.value;

    return DataGridRowAdapter(
        cells: row.getCells().map<Widget>((e) {
          if (e.columnName == 'status') {
            return Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: StatusBadge(
                status: e.value.toString(),
                backgroundColor: AppColors.getStatusColor(e.value.toString()).withOpacity(0.1),
                textColor: AppColors.getStatusColor(e.value.toString()),
              ),
            );
          } else if (e.columnName == 'followUpDate') {
            final DateTime? date = e.value;
            return Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: date != null
                  ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppHelpers.formatDate(date),
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: date.isBefore(DateTime.now()) ? AppColors.error : AppColors.warning,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (date.isBefore(DateTime.now()))
                    Text(
                      'Overdue',
                      style: AppTextStyles.caption.copyWith(color: AppColors.error),
                    ),
                ],
              )
                  : Text(
                'N/A',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary),
              ),
            );
          } else if (e.columnName == 'createdAt' || e.columnName == 'updatedAt') {
            final DateTime date = e.value;
            return Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                AppHelpers.formatDate(date),
                style: AppTextStyles.bodyMedium,
              ),
            );
          } else if (e.columnName == 'actions') {
            return Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(8.0),
              child: IconButton(
                icon: const Icon(LucideIcons.eye, size: 20, color: AppColors.primary),
                onPressed: () {
                  onRowTap?.call(lead);
                },
              ),
            );
          }
          return Container(
            padding: const EdgeInsets.all(8.0),
            alignment: Alignment.centerLeft,
            child: Text(
              e.value.toString(),
              style: AppTextStyles.bodyMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList());
  }

  @override
  Future<void> onSortChange(SfDataGridSortDetails dataGridSortDetails) async {
    // Implement custom sorting if default is not sufficient
    // For basic sorting, SfDataGrid handles it automatically if allowSorting is true
  }
}