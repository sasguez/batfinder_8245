import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Widget displaying emergency contacts with call buttons
class EmergencyContactsWidget extends StatelessWidget {
  final List<Map<String, dynamic>> contacts;
  final Function(String) onCallContact;

  const EmergencyContactsWidget({
    super.key,
    required this.contacts,
    required this.onCallContact,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CustomIconWidget(
                  iconName: 'contacts',
                  color: theme.colorScheme.secondary,
                  size: 20,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Contactos de Emergencia',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      'Notificados automáticamente',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: contacts.length,
            separatorBuilder: (context, index) => SizedBox(height: 1.h),
            itemBuilder: (context, index) {
              final contact = contacts[index];
              return _buildContactCard(context, contact, theme);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard(
    BuildContext context,
    Map<String, dynamic> contact,
    ThemeData theme,
  ) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
            child: Text(
              (contact['name'] as String).substring(0, 1).toUpperCase(),
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contact['name'] as String,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 0.5.h),
                Row(
                  children: [
                    CustomIconWidget(
                      iconName: contact['notified'] == true
                          ? 'check_circle'
                          : 'schedule',
                      color: contact['notified'] == true
                          ? Colors.green
                          : theme.colorScheme.onSurfaceVariant,
                      size: 14,
                    ),
                    SizedBox(width: 1.w),
                    Expanded(
                      child: Text(
                        contact['notified'] == true
                            ? 'Notificado'
                            : 'Notificando...',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 2.w),
          ElevatedButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
              onCallContact(contact['phone'] as String);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
              minimumSize: Size(0, 0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomIconWidget(
                  iconName: 'call',
                  color: theme.colorScheme.onPrimary,
                  size: 16,
                ),
                SizedBox(width: 1.w),
                Text(
                  'Llamar',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onPrimary,
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
