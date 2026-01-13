import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Widget for community verification with voting system
class VerificationSectionWidget extends StatefulWidget {
  final int initialConfirms;
  final int initialDisputes;

  const VerificationSectionWidget({
    super.key,
    required this.initialConfirms,
    required this.initialDisputes,
  });

  @override
  State<VerificationSectionWidget> createState() =>
      _VerificationSectionWidgetState();
}

class _VerificationSectionWidgetState extends State<VerificationSectionWidget> {
  late int _confirms;
  late int _disputes;
  String? _userVote;

  @override
  void initState() {
    super.initState();
    _confirms = widget.initialConfirms;
    _disputes = widget.initialDisputes;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final int totalVotes = _confirms + _disputes;
    final double confirmPercentage = totalVotes > 0
        ? (_confirms / totalVotes) * 100
        : 0;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.outline, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Community Verification',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text(
                      '${confirmPercentage.toStringAsFixed(0)}%',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: Color(0xFF2E7D32),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Confirmed',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 6.h,
                color: theme.colorScheme.outline,
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      '$totalVotes',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Total Votes',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _userVote == 'confirm'
                      ? null
                      : () => _handleVote('confirm'),
                  icon: CustomIconWidget(
                    iconName: 'thumb_up',
                    color: _userVote == 'confirm'
                        ? Colors.white
                        : theme.colorScheme.onPrimary,
                    size: 18,
                  ),
                  label: Text('Confirm ($_confirms)'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _userVote == 'confirm'
                        ? Color(0xFF2E7D32)
                        : theme.colorScheme.primary,
                    padding: EdgeInsets.symmetric(vertical: 1.5.h),
                  ),
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _userVote == 'dispute'
                      ? null
                      : () => _handleVote('dispute'),
                  icon: CustomIconWidget(
                    iconName: 'thumb_down',
                    color: _userVote == 'dispute'
                        ? theme.colorScheme.error
                        : theme.colorScheme.primary,
                    size: 18,
                  ),
                  label: Text('Dispute ($_disputes)'),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: _userVote == 'dispute'
                          ? theme.colorScheme.error
                          : theme.colorScheme.primary,
                      width: 1,
                    ),
                    padding: EdgeInsets.symmetric(vertical: 1.5.h),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _handleVote(String voteType) {
    setState(() {
      if (_userVote != null) {
        if (_userVote == 'confirm') {
          _confirms--;
        } else {
          _disputes--;
        }
      }

      if (voteType == 'confirm') {
        _confirms++;
      } else {
        _disputes++;
      }

      _userVote = voteType;
    });
  }
}
