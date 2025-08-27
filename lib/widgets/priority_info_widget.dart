// lib/widgets/priority_info_widget.dart
import 'package:flutter/material.dart';
import '../config/category_config.dart';
import '../utils/theme.dart';

class PriorityInfoWidget extends StatelessWidget {
  final String? selectedPriority;
  final ValueChanged<String>? onPriorityChanged;
  final bool showDescription;
  final bool isReadOnly;

  const PriorityInfoWidget({
    super.key,
    this.selectedPriority,
    this.onPriorityChanged,
    this.showDescription = true,
    this.isReadOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tingkat Prioritas',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppTheme.spacing12),
        
        if (isReadOnly && selectedPriority != null) ...[
          _buildPriorityDisplay(context, selectedPriority!),
        ] else ...[
          // Priority selection cards
          ...PriorityConfig.priorities.entries.map((entry) {
            final priorityKey = entry.key;
            final priorityData = entry.value;
            final isSelected = selectedPriority == priorityKey;
            
            return Container(
              margin: const EdgeInsets.only(bottom: AppTheme.spacing12),
              decoration: BoxDecoration(
                color: isSelected 
                    ? priorityData.color.withValues(alpha: 0.1) 
                    : AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(AppTheme.radius12),
                border: Border.all(
                  color: isSelected 
                      ? priorityData.color 
                      : AppTheme.borderColor,
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: isSelected ? AppTheme.shadowSm : null,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: isReadOnly ? null : () => onPriorityChanged?.call(priorityKey),
                  borderRadius: BorderRadius.circular(AppTheme.radius12),
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.spacing16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppTheme.spacing8),
                          decoration: BoxDecoration(
                            color: priorityData.color.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(AppTheme.radius8),
                          ),
                          child: Icon(
                            priorityData.icon,
                            color: priorityData.color,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: AppTheme.spacing16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                priorityData.name,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: isSelected ? priorityData.color : AppTheme.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (showDescription) ...[
                                const SizedBox(height: AppTheme.spacing4),
                                Text(
                                  priorityData.description,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (isSelected) ...[
                          Container(
                            padding: const EdgeInsets.all(AppTheme.spacing4),
                            decoration: BoxDecoration(
                              color: priorityData.color,
                              borderRadius: BorderRadius.circular(AppTheme.radius8),
                            ),
                            child: const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ],
        
        if (showDescription && selectedPriority != null) ...[
          const SizedBox(height: AppTheme.spacing16),
          Container(
            padding: const EdgeInsets.all(AppTheme.spacing16),
            decoration: BoxDecoration(
                              color: AppTheme.infoColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppTheme.radius12),
                              border: Border.all(color: AppTheme.infoColor.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppTheme.infoColor,
                  size: 20,
                ),
                const SizedBox(width: AppTheme.spacing12),
                Expanded(
                  child: Text(
                    'Prioritas yang dipilih akan menentukan urutan penanganan temuan',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.infoColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPriorityDisplay(BuildContext context, String priorityKey) {
    final priorityData = PriorityConfig.getPriorityData(priorityKey);
    if (priorityData == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing16),
      decoration: BoxDecoration(
                        color: priorityData.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radius12),
                  border: Border.all(color: priorityData.color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.spacing8),
            decoration: BoxDecoration(
                              color: priorityData.color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppTheme.radius8),
            ),
            child: Icon(
              priorityData.icon,
              color: priorityData.color,
              size: 24,
            ),
          ),
          const SizedBox(width: AppTheme.spacing16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  priorityData.name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: priorityData.color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (showDescription) ...[
                  const SizedBox(height: AppTheme.spacing4),
                  Text(
                    priorityData.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Widget untuk menampilkan kategori dengan informasi lengkap
class CategoryInfoWidget extends StatelessWidget {
  final String? selectedCategory;
  final ValueChanged<String>? onCategoryChanged;
  final bool showDescription;
  final bool isReadOnly;

  const CategoryInfoWidget({
    super.key,
    this.selectedCategory,
    this.onCategoryChanged,
    this.showDescription = true,
    this.isReadOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kategori Temuan',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppTheme.spacing12),
        
        if (isReadOnly && selectedCategory != null) ...[
          _buildCategoryDisplay(context, selectedCategory!),
        ] else ...[
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: AppTheme.spacing12,
              mainAxisSpacing: AppTheme.spacing12,
              childAspectRatio: 1.1,
            ),
            itemCount: AppCategoryConfigs.configs.length,
            itemBuilder: (context, index) {
              final categoryKey = AppCategoryConfigs.configs.keys.elementAt(index);
              final config = AppCategoryConfigs.configs[categoryKey]!;
              final isSelected = selectedCategory == categoryKey;
              
              return Container(
                decoration: BoxDecoration(
                  color: isSelected ? config.color.withValues(alpha: 0.1) : AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(AppTheme.radius12),
                  border: Border.all(
                    color: isSelected ? config.color : AppTheme.borderColor,
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: isSelected ? AppTheme.shadowSm : null,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: isReadOnly ? null : () => onCategoryChanged?.call(categoryKey),
                    borderRadius: BorderRadius.circular(AppTheme.radius12),
                    child: Padding(
                      padding: const EdgeInsets.all(AppTheme.spacing12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(AppTheme.spacing8),
                            decoration: BoxDecoration(
                              color: config.color.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(AppTheme.radius8),
                            ),
                            child: Icon(
                              config.icon,
                              size: 24,
                              color: config.color,
                            ),
                          ),
                          const SizedBox(height: AppTheme.spacing8),
                          Text(
                            config.name,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: isSelected ? config.color : AppTheme.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: AppTheme.spacing4),
                          Text(
                            '${config.subcategories.length} jenis',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          if (isSelected) ...[
                            const SizedBox(height: AppTheme.spacing4),
                            Container(
                              padding: const EdgeInsets.all(AppTheme.spacing2),
                              decoration: BoxDecoration(
                                color: config.color,
                                borderRadius: BorderRadius.circular(AppTheme.radius4),
                              ),
                              child: const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 12,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ],
    );
  }

  Widget _buildCategoryDisplay(BuildContext context, String categoryKey) {
    final config = AppCategoryConfigs.getConfig(categoryKey);
    if (config == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing16),
      decoration: BoxDecoration(
        color: config.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radius12),
        border: Border.all(color: config.color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.spacing12),
            decoration: BoxDecoration(
              color: config.color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppTheme.radius12),
            ),
            child: Icon(
              config.icon,
              color: config.color,
              size: 32,
            ),
          ),
          const SizedBox(width: AppTheme.spacing16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  config.name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: config.color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (showDescription) ...[
                  const SizedBox(height: AppTheme.spacing4),
                  Text(
                    config.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
                const SizedBox(height: AppTheme.spacing8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacing8,
                    vertical: AppTheme.spacing4,
                  ),
                  decoration: BoxDecoration(
                    color: config.color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppTheme.radius8),
                  ),
                  child: Text(
                    '${config.subcategories.length} sub-kategori tersedia',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: config.color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Widget untuk progress indicator yang lebih informatif
class ProgressInfoWidget extends StatelessWidget {
  final double progress;
  final String status;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool showTimeRemaining;

  const ProgressInfoWidget({
    super.key,
    required this.progress,
    required this.status,
    this.startDate,
    this.endDate,
    this.showTimeRemaining = true,
  });

  @override
  Widget build(BuildContext context) {
    final isOverdue = endDate != null && 
        DateTime.now().isAfter(endDate!) && 
        status != 'selesai' && 
        status != 'completed';

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing16),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(AppTheme.radius12),
        border: Border.all(
          color: isOverdue ? AppTheme.errorColor.withValues(alpha: 0.3) : AppTheme.borderColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress Pekerjaan',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${progress.toInt()}%',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: isOverdue ? AppTheme.errorColor : AppTheme.primaryColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacing12),
          
          // Progress bar
          LinearProgressIndicator(
            value: progress / 100,
            backgroundColor: AppTheme.borderColor,
            valueColor: AlwaysStoppedAnimation<Color>(
              isOverdue ? AppTheme.errorColor : AppTheme.primaryColor,
            ),
            borderRadius: BorderRadius.circular(AppTheme.radius4),
          ),
          
          const SizedBox(height: AppTheme.spacing12),
          
          // Progress text
          Text(
            _getProgressText(progress),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          
          if (showTimeRemaining && endDate != null) ...[
            const SizedBox(height: AppTheme.spacing8),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacing8,
                vertical: AppTheme.spacing4,
              ),
              decoration: BoxDecoration(
                color: isOverdue 
                            ? AppTheme.errorColor.withValues(alpha: 0.1)
        : AppTheme.infoColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.radius8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isOverdue ? Icons.warning : Icons.schedule,
                    size: 14,
                    color: isOverdue ? AppTheme.errorColor : AppTheme.infoColor,
                  ),
                  const SizedBox(width: AppTheme.spacing4),
                  Text(
                    _getTimeRemainingText(endDate!),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: isOverdue ? AppTheme.errorColor : AppTheme.infoColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getProgressText(double progress) {
    if (progress == 0) return 'Belum dimulai';
    if (progress < 25) return 'Tahap awal';
    if (progress < 50) return 'Dalam progress';
    if (progress < 75) return 'Setengah jalan';
    if (progress < 100) return 'Hampir selesai';
    return 'Selesai';
  }

  String _getTimeRemainingText(DateTime endDate) {
    final now = DateTime.now();
    final difference = endDate.difference(now);
    
    if (difference.isNegative) {
      final overdueDays = now.difference(endDate).inDays;
      return 'Terlambat ${overdueDays} hari';
    }
    
    if (difference.inDays > 0) {
      return 'Sisa ${difference.inDays} hari';
    } else if (difference.inHours > 0) {
      return 'Sisa ${difference.inHours} jam';
    } else {
      return 'Deadline hari ini';
    }
  }
}