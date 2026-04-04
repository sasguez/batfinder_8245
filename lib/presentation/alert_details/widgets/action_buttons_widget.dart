import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Widget displaying action buttons for alert interaction
class ActionButtonsWidget extends StatelessWidget {
  final Map<String, dynamic> alertData;
  final bool isAuthority;

  const ActionButtonsWidget({
    super.key,
    required this.alertData,
    this.isAuthority = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Column(
        children: [
          ElevatedButton.icon(
            onPressed: () => _getDirections(context),
            icon: CustomIconWidget(
              iconName: 'directions',
              color: theme.colorScheme.onPrimary,
              size: 20,
            ),
            label: Text('Get Directions to Avoid Area'),
            style: ElevatedButton.styleFrom(
              minimumSize: Size(double.infinity, 6.h),
              padding: EdgeInsets.symmetric(horizontal: 4.w),
            ),
          ),
          SizedBox(height: 1.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _shareAlert(context),
                  icon: CustomIconWidget(
                    iconName: 'share',
                    color: theme.colorScheme.primary,
                    size: 18,
                  ),
                  label: Text('Share'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: Size(double.infinity, 6.h),
                  ),
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _addUpdate(context),
                  icon: CustomIconWidget(
                    iconName: 'add_comment',
                    color: theme.colorScheme.primary,
                    size: 18,
                  ),
                  label: Text('Add Update'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: Size(double.infinity, 6.h),
                  ),
                ),
              ),
            ],
          ),
          if (isAuthority) ...[
            SizedBox(height: 1.h),
            ElevatedButton.icon(
              onPressed: () => _markResolved(context),
              icon: CustomIconWidget(
                iconName: 'check_circle',
                color: theme.colorScheme.onPrimary,
                size: 20,
              ),
              label: Text('Mark as Resolved'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF2E7D32),
                minimumSize: Size(double.infinity, 6.h),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _getDirections(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening safe route navigation...'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _shareAlert(BuildContext context) {
    final String location = alertData['location'] ?? 'Unknown Location';
    final String type = alertData['type'] ?? 'Unknown';
    Share.share(
      'Security Alert: $type reported at $location. Stay safe! - BatFinder',
      subject: 'Security Alert from BatFinder',
    );
  }

  void _addUpdate(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: EdgeInsets.all(4.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Add Update', style: Theme.of(context).textTheme.titleLarge),
              SizedBox(height: 2.h),
              TextField(
                maxLines: 4,
                decoration: InputDecoration(
                  hintText:
                      'Share additional information about this incident...',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 2.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancel'),
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Update posted successfully')),
                        );
                      },
                      child: Text('Post Update'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _markResolved(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Mark as Resolved'),
        content: Text(
          'Are you sure you want to mark this incident as resolved?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Incident marked as resolved')),
              );
            },
            child: Text('Confirm'),
          ),
        ],
      ),
    );
  }
}
