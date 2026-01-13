import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

/// Remember me toggle widget with secure storage
class RememberMeToggle extends StatefulWidget {
  final Function(bool) onChanged;

  const RememberMeToggle({super.key, required this.onChanged});

  @override
  State<RememberMeToggle> createState() => _RememberMeToggleState();
}

class _RememberMeToggleState extends State<RememberMeToggle> {
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _loadRememberMePreference();
  }

  Future<void> _loadRememberMePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final savedValue = prefs.getBool('remember_me') ?? false;

    if (mounted) {
      setState(() {
        _rememberMe = savedValue;
      });
      widget.onChanged(savedValue);
    }
  }

  Future<void> _saveRememberMePreference(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('remember_me', value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        SizedBox(
          width: 6.w,
          height: 6.w,
          child: Checkbox(
            value: _rememberMe,
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _rememberMe = value;
                });
                _saveRememberMePreference(value);
                widget.onChanged(value);
              }
            },
          ),
        ),
        SizedBox(width: 2.w),
        Expanded(
          child: Text(
            'Recordarme en este dispositivo',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}
