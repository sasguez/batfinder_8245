import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Widget displaying incident description with translation option
class IncidentDescriptionWidget extends StatefulWidget {
  final String description;

  const IncidentDescriptionWidget({super.key, required this.description});

  @override
  State<IncidentDescriptionWidget> createState() =>
      _IncidentDescriptionWidgetState();
}

class _IncidentDescriptionWidgetState extends State<IncidentDescriptionWidget> {
  bool _isTranslated = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Incident Description',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _isTranslated = !_isTranslated;
                  });
                },
                icon: CustomIconWidget(
                  iconName: 'translate',
                  color: theme.colorScheme.primary,
                  size: 18,
                ),
                label: Text(
                  _isTranslated ? 'Original' : 'Translate',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: theme.colorScheme.outline, width: 1),
            ),
            child: Text(
              _isTranslated
                  ? _translateText(widget.description)
                  : widget.description,
              style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  String _translateText(String text) {
    return text;
  }
}
