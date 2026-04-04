import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Role Selection Section Widget
/// Allows users to select their role: Citizen, Authority, or NGO Representative
class RoleSelectionSectionWidget extends StatelessWidget {
  final String selectedRole;
  final Function(String) onRoleChanged;

  const RoleSelectionSectionWidget({
    super.key,
    required this.selectedRole,
    required this.onRoleChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Your Role',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          'Choose the role that best describes you',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        SizedBox(height: 2.h),

        // Role Cards
        _buildRoleCard(
          context: context,
          role: 'Citizen',
          icon: 'person',
          description:
              'Report incidents and stay informed about safety in your community',
          permissions: [
            'Create and view safety alerts',
            'Access community safety chat',
            'View safety maps and analytics',
          ],
        ),
        SizedBox(height: 2.h),

        _buildRoleCard(
          context: context,
          role: 'Authority',
          icon: 'shield',
          description:
              'Manage incidents, coordinate responses, and access advanced analytics',
          permissions: [
            'Verify and manage all alerts',
            'Access administrative dashboard',
            'Coordinate emergency responses',
            'View detailed analytics and reports',
          ],
        ),
        SizedBox(height: 2.h),

        _buildRoleCard(
          context: context,
          role: 'NGO Representative',
          icon: 'volunteer_activism',
          description:
              'Support community safety initiatives and access field work tools',
          permissions: [
            'Create community safety campaigns',
            'Access field data collection tools',
            'View community engagement metrics',
            'Coordinate with authorities',
          ],
        ),
      ],
    );
  }

  Widget _buildRoleCard({
    required BuildContext context,
    required String role,
    required String icon,
    required String description,
    required List<String> permissions,
  }) {
    final theme = Theme.of(context);
    final isSelected = selectedRole == role;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onRoleChanged(role);
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withValues(alpha: 0.1)
              : theme.colorScheme.surface,
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.1,
                          ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: CustomIconWidget(
                    iconName: icon,
                    color: isSelected
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.onSurfaceVariant,
                    size: 24,
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Text(
                    role,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                if (isSelected)
                  CustomIconWidget(
                    iconName: 'check_circle',
                    color: theme.colorScheme.primary,
                    size: 24,
                  ),
              ],
            ),
            SizedBox(height: 1.5.h),
            Text(
              description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 1.5.h),
            Text(
              'Permissions:',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 0.5.h),
            ...permissions.map(
              (permission) => Padding(
                padding: EdgeInsets.only(bottom: 0.5.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomIconWidget(
                      iconName: 'check',
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant,
                      size: 16,
                    ),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: Text(
                        permission,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
