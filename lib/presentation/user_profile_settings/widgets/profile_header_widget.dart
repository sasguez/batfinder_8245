import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

/// Profile Header Widget
/// Displays user avatar, name, role badge, and reputation score
class ProfileHeaderWidget extends StatelessWidget {
  final Map<String, dynamic> userData;

  const ProfileHeaderWidget({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(bottom: BorderSide(color: theme.dividerColor, width: 1)),
      ),
      child: Column(
        children: [
          // Avatar with edit button
          Stack(
            children: [
              Container(
                width: 25.w,
                height: 25.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.colorScheme.primary,
                    width: 3,
                  ),
                ),
                child: ClipOval(
                  child: CustomImageWidget(
                    imageUrl: userData["avatar"] as String,
                    width: 25.w,
                    height: 25.w,
                    fit: BoxFit.cover,
                    semanticLabel: userData["semanticLabel"] as String,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () {
                    // Edit avatar functionality
                  },
                  child: Container(
                    width: 8.w,
                    height: 8.w,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.colorScheme.surface,
                        width: 2,
                      ),
                    ),
                    child: CustomIconWidget(
                      iconName: 'edit',
                      color: theme.colorScheme.onPrimary,
                      size: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 2.h),

          // Name
          Text(
            userData["name"] as String,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),

          SizedBox(height: 1.h),

          // Role Badge
          Container(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomIconWidget(
                  iconName: 'verified_user',
                  color: theme.colorScheme.secondary,
                  size: 16,
                ),
                SizedBox(width: 1.w),
                Text(
                  userData["role"] as String,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.secondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 2.h),

          // Reputation Score
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomIconWidget(
                  iconName: 'star',
                  color: Colors.amber,
                  size: 24,
                ),
                SizedBox(width: 2.w),
                Text(
                  '${userData["reputationScore"]}',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.primary,
                  ),
                ),
                SizedBox(width: 1.w),
                Text(
                  'Puntuación de Reputación',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 1.h),

          // Total Reports
          Text(
            '${userData["totalReports"]} reportes enviados',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
