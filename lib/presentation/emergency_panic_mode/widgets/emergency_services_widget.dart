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
        'colorA': const Color(0xFFEF4444),
        'colorB': const Color(0xFFB91C1C),
      },
      {
        'name': 'Policía',
        'number': '112',
        'icon': 'local_police',
        'colorA': const Color(0xFF1E40AF),
        'colorB': const Color(0xFF1B365D),
      },
      {
        'name': 'Médica',
        'number': '125',
        'icon': 'local_hospital',
        'colorA': const Color(0xFF16A34A),
        'colorB': const Color(0xFF166534),
      },
      {
        'name': 'Bomberos',
        'number': '119',
        'icon': 'local_fire_department',
        'colorA': const Color(0xFFF97316),
        'colorB': const Color(0xFFC2410C),
      },
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
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
                  borderRadius: BorderRadius.circular(10),
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
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Llamada directa a autoridades',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 2.5.h),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 3.w,
              mainAxisSpacing: 2.h,
              childAspectRatio: 1.4,
            ),
            itemCount: services.length,
            itemBuilder: (context, index) =>
                _ServiceButton(service: services[index], onCall: onCallService),
          ),
        ],
      ),
    );
  }
}

class _ServiceButton extends StatelessWidget {
  final Map<String, dynamic> service;
  final Function(String, String) onCall;

  const _ServiceButton({required this.service, required this.onCall});

  @override
  Widget build(BuildContext context) {
    final colorA = service['colorA'] as Color;
    final colorB = service['colorB'] as Color;
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () {
          HapticFeedback.heavyImpact();
          onCall(service['name'] as String, service['number'] as String);
        },
        borderRadius: BorderRadius.circular(16),
        splashColor: Colors.white.withValues(alpha: 0.2),
        highlightColor: Colors.white.withValues(alpha: 0.1),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [colorA, colorB],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: colorA.withValues(alpha: 0.4),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.5.h),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomIconWidget(
                  iconName: service['icon'] as String,
                  color: Colors.white,
                  size: 30,
                ),
                SizedBox(height: 0.8.h),
                Text(
                  service['name'] as String,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 0.5.h),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 2.5.w,
                    vertical: 0.3.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    service['number'] as String,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
