import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class SafetyScoreWidget extends StatelessWidget {
  final int score;
  final String location;
  final VoidCallback onTap;

  const SafetyScoreWidget({
    super.key,
    required this.score,
    required this.location,
    required this.onTap,
  });

  Color _getScoreColor(int score, ThemeData theme) {
    if (score >= 70) {
      return Color(0xFF2E7D32); // Green - Safe
    } else if (score >= 40) {
      return Color(0xFFF57C00); // Orange - Moderate
    } else {
      return theme.colorScheme.error; // Red - Unsafe
    }
  }

  String _getScoreLabel(int score) {
    if (score >= 70) {
      return 'Safe';
    } else if (score >= 40) {
      return 'Moderate';
    } else {
      return 'Unsafe';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final scoreColor = _getScoreColor(score, theme);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.all(5.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                scoreColor.withValues(alpha: 0.1),
                scoreColor.withValues(alpha: 0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: scoreColor.withValues(alpha: 0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.3)
                    : Colors.black.withValues(alpha: 0.05),
                blurRadius: 8.0,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Safety Score',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          location,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  CustomIconWidget(
                    iconName: 'info_outline',
                    color: theme.colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                ],
              ),
              SizedBox(height: 3.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Score display
                  Text(
                    score.toString(),
                    style: theme.textTheme.displayLarge?.copyWith(
                      color: scoreColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 48,
                      height: 1,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 1.h, left: 2.w),
                    child: Text(
                      '/100',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Spacer(),
                  // Score label
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 4.w,
                      vertical: 1.h,
                    ),
                    decoration: BoxDecoration(
                      color: scoreColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: scoreColor.withValues(alpha: 0.3),
                          blurRadius: 8.0,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      _getScoreLabel(score),
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 3.h),
              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: score / 100,
                  backgroundColor: theme.colorScheme.surface,
                  valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
                  minHeight: 8,
                ),
              ),
              SizedBox(height: 2.h),
              // Statistics
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(
                    context,
                    icon: 'trending_down',
                    label: 'Incidents',
                    value: '12',
                    color: theme.colorScheme.error,
                  ),
                  Container(
                    width: 1,
                    height: 4.h,
                    color: theme.colorScheme.outline,
                  ),
                  _buildStatItem(
                    context,
                    icon: 'people',
                    label: 'Active Users',
                    value: '847',
                    color: theme.colorScheme.primary,
                  ),
                  Container(
                    width: 1,
                    height: 4.h,
                    color: theme.colorScheme.outline,
                  ),
                  _buildStatItem(
                    context,
                    icon: 'verified_user',
                    label: 'Safe Zones',
                    value: '5',
                    color: Color(0xFF2E7D32),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required String icon,
    required String label,
    required String value,
    required Color color,
  }) {
    final theme = Theme.of(context);

    return Column(
      children: [
        CustomIconWidget(iconName: icon, color: color, size: 20),
        SizedBox(height: 0.5.h),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}
