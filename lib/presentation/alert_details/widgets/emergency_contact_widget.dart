import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../widgets/custom_icon_widget.dart';

class EmergencyContactWidget extends StatelessWidget {
  const EmergencyContactWidget({super.key});

  static const _contacts = [
    _EmergencyContact(
      label: 'Emergencia General',
      number: '123',
      icon: Icons.emergency_rounded,
      isHighlighted: true,
    ),
    _EmergencyContact(
      label: 'Policía Nacional',
      number: '112',
      icon: Icons.local_police_rounded,
      isHighlighted: false,
    ),
    _EmergencyContact(
      label: 'Ambulancia',
      number: '125',
      icon: Icons.local_hospital_rounded,
      isHighlighted: false,
    ),
  ];

  Future<void> _call(BuildContext context, String number) async {
    final uri = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se puede llamar al $number en este dispositivo')),
        );
      }
    }
  }

  void _showConfirmDialog(BuildContext context, String label, String number) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.phone_rounded, color: theme.colorScheme.error, size: 24),
            SizedBox(width: 2.w),
            const Text('Llamar a Emergencias'),
          ],
        ),
        content: Text('¿Deseas llamar a $label al número $number?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              _call(context, number);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: theme.colorScheme.onError,
            ),
            icon: const Icon(Icons.phone_rounded, size: 18),
            label: Text('Llamar al $number'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.error.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.error.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(4.w, 2.h, 4.w, 1.h),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'emergency',
                  color: theme.colorScheme.error,
                  size: 22,
                ),
                SizedBox(width: 2.w),
                Text(
                  'Servicios de Emergencia',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.error,
                  ),
                ),
              ],
            ),
          ),
          Divider(
            color: theme.colorScheme.error.withValues(alpha: 0.2),
            height: 1,
          ),
          ...List.generate(_contacts.length, (i) {
            final contact = _contacts[i];
            final isLast = i == _contacts.length - 1;
            return Column(
              children: [
                InkWell(
                  onTap: () => _showConfirmDialog(context, contact.label, contact.number),
                  borderRadius: BorderRadius.vertical(
                    bottom: isLast ? const Radius.circular(12) : Radius.zero,
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: contact.isHighlighted
                                ? theme.colorScheme.error
                                : theme.colorScheme.error.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            contact.icon,
                            color: contact.isHighlighted
                                ? theme.colorScheme.onError
                                : theme.colorScheme.error,
                            size: 22,
                          ),
                        ),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                contact.label,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                contact.number,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.error,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.error.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.phone_rounded,
                            color: theme.colorScheme.error,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (!isLast)
                  Divider(
                    color: theme.colorScheme.error.withValues(alpha: 0.12),
                    height: 1,
                    indent: 4.w + 44 + 3.w,
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _EmergencyContact {
  final String label;
  final String number;
  final IconData icon;
  final bool isHighlighted;

  const _EmergencyContact({
    required this.label,
    required this.number,
    required this.icon,
    required this.isHighlighted,
  });
}
