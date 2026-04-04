import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Widget displaying Colombian emergency service buttons
class EmergencyServicesWidget extends StatelessWidget {
  final Function(String, String) onCallService;

  const EmergencyServicesWidget({super.key, required this.onCallService});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final services = [
      {
        'name': 'Emergencia General',
        'number': '123',
        'icon': 'emergency',
        'color': theme.colorScheme.error,
      },
      {
        'name': 'Policía',
        'number': '112',
        'icon': 'local_police',
        'color': Color(0xFF1B365D),
      },
      {
        'name': 'Médica',
        'number': '125',
        'icon': 'local_hospital',
        'color': Colors.green,
      },
      {
        'name': 'Bomberos',
        'number': '119',
        'icon': 'local_fire_department',
        'color': Colors.orange,
      },
    ];

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
                  color: theme.colorScheme.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CustomIconWidget(
                  iconName: 'phone_in_talk',
                  color: theme.colorScheme.error,
                  size: 20,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Servicios de Emergencia',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      'Llamada directa a autoridades',
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
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 2.w,
              mainAxisSpacing: 1.h,
              childAspectRatio: 1.5,
            ),
            itemCount: services.length,
            itemBuilder: (context, index) {
              final service = services[index];
              return _buildServiceButton(context, service, theme);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildServiceButton(
    BuildContext context,
    Map<String, dynamic> service,
    ThemeData theme,
  ) {
    return ElevatedButton(
      onPressed: () {
        HapticFeedback.heavyImpact();
        onCallService(service['name'] as String, service['number'] as String);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: (service['color'] as Color).withValues(alpha: 0.1),
        foregroundColor: service['color'] as Color,
        padding: EdgeInsets.all(3.w),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: (service['color'] as Color).withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: service['icon'] as String,
            color: service['color'] as Color,
            size: 32,
          ),
          SizedBox(height: 1.h),
          Text(
            service['name'] as String,
            style: theme.textTheme.labelLarge?.copyWith(
              color: service['color'] as Color,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 0.5.h),
          Text(
            service['number'] as String,
            style: theme.textTheme.bodySmall?.copyWith(
              color: (service['color'] as Color).withValues(alpha: 0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
