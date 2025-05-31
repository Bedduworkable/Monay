import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/custom_widgets.dart'; // For EmptyState and MinimalLoader
import '../../utils/helpers.dart'; // For AppHelpers

class LeadsOverviewChart extends ConsumerWidget {
  final String title;
  final String? subtitle;
  final List<Map<String, dynamic>> chartData; // Expects [{ 'label': 'Month', 'value': 100 }]
  final bool isLoading;
  final String emptyStateTitle;
  final String emptyStateSubtitle;
  final IconData emptyStateIcon;

  const LeadsOverviewChart({
    super.key,
    required this.title,
    this.subtitle,
    required this.chartData,
    this.isLoading = false,
    this.emptyStateTitle = 'No Leads Data',
    this.emptyStateSubtitle = 'Lead creation trends will appear here once you add leads.',
    this.emptyStateIcon = LucideIcons.lineChart,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (isLoading) {
      return _buildChartContainer(
        const Center(child: MinimalLoader()),
      );
    }

    if (chartData.isEmpty) {
      return _buildChartContainer(
        EmptyState(
          icon: emptyStateIcon,
          title: emptyStateTitle,
          subtitle: emptyStateSubtitle,
          actionText: 'Add Lead', // Example action
          onAction: () {
            // Implement navigation to add lead screen or similar
            AppHelpers.showInfoSnackbar(context, 'Navigating to Add Lead Screen');
          },
        ),
      );
    }

    return _buildChartContainer(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          Expanded(
            child: SfCartesianChart(
              primaryXAxis: const CategoryAxis(
                majorGridLines: MajorGridLines(width: 0),
                axisLine: AxisLine(width: 0),
              ),
              primaryYAxis: const NumericAxis(
                majorGridLines: MajorGridLines(width: 0.5, dashArray: <double>[5, 5]),
                axisLine: AxisLine(width: 0),
                labelFormat: '{value}',
                minimum: 0,
              ),
              series: <CartesianSeries>[
                SplineSeries<Map<String, dynamic>, String>(
                  dataSource: chartData,
                  xValueMapper: (data, _) => data['label'] as String,
                  yValueMapper: (data, _) => (data['value'] as int).toDouble(),
                  name: 'Leads Created',
                  color: AppColors.primary,
                  width: 3,
                  markerSettings: const MarkerSettings(
                    isVisible: true,
                    shape: DataMarkerType.circle,
                    borderWidth: 2,
                    color: AppColors.primary,
                    borderColor: AppColors.textOnPrimary,
                  ),
                  dataLabelSettings: DataLabelSettings(
                    isVisible: true,
                    labelAlignment: ChartDataLabelAlignment.top,
                    textStyle: AppTextStyles.labelSmall.copyWith(color: AppColors.textPrimary),
                  ),
                ),
              ],
              tooltipBehavior: TooltipBehavior(enable: true),
            ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.2, duration: 600.ms),
          ),
        ],
      ),
    );
  }

  Widget _buildChartContainer(Widget content) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: content,
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.titleLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ],
    );
  }
}