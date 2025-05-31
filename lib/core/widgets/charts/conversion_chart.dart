import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/custom_widgets.dart'; // For EmptyState and MinimalLoader
import '../../utils/helpers.dart'; // For AppHelpers

class ConversionChart extends ConsumerWidget {
  final String title;
  final String? subtitle;
  final List<Map<String, dynamic>> chartData;
  final bool isLoading;
  final String emptyStateTitle;
  final String emptyStateSubtitle;
  final IconData emptyStateIcon;

  const ConversionChart({
    super.key,
    required this.title,
    this.subtitle,
    required this.chartData,
    this.isLoading = false,
    this.emptyStateTitle = 'No Data Available',
    this.emptyStateSubtitle = 'Add leads or update their statuses to see this chart.',
    this.emptyStateIcon = LucideIcons.pieChart,
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
            child: SfCircularChart(
              legend: const Legend(
                isVisible: true,
                position: LegendPosition.right, // Moved to right for better readability
                overflowMode: LegendItemOverflowMode.wrap,
              ),
              series: <CircularSeries>[
                DoughnutSeries<Map<String, dynamic>, String>(
                  dataSource: chartData,
                  xValueMapper: (data, _) => data['status'] as String,
                  yValueMapper: (data, _) => (data['count'] as int).toDouble(),
                  pointColorMapper: (data, _) => AppHelpers.getStatusColor(data['status'] as String),
                  innerRadius: '60%',
                  dataLabelSettings: DataLabelSettings(
                    isVisible: true,
                    labelPosition: ChartDataLabelPosition.outside,
                    connectorLineSettings: const ConnectorLineSettings(type: ConnectorType.Curve),
                    builder: (data, point, series, pointIndex, _) {
                      final status = data['status'] as String;
                      final count = data['count'] as int;
                      final total = chartData.map((e) => e['count'] as int).fold(0, (prev, curr) => prev + curr);
                      final percentage = total > 0 ? (count / total * 100).toStringAsFixed(1) : '0.0';
                      return Text(
                        '$status\n($percentage%)',
                        style: AppTextStyles.labelSmall.copyWith(color: AppColors.textPrimary),
                        textAlign: TextAlign.center,
                      );
                    },
                  ),
                ),
              ],
              tooltipBehavior: TooltipBehavior(enable: true),
            ).animate().fadeIn(duration: 800.ms).scale(begin: 0.8, duration: 600.ms),
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