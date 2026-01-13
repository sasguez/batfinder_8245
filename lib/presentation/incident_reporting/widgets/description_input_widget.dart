import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Widget for incident description with voice-to-text support
class DescriptionInputWidget extends StatefulWidget {
  final TextEditingController controller;
  final String? errorText;

  const DescriptionInputWidget({
    super.key,
    required this.controller,
    this.errorText,
  });

  @override
  State<DescriptionInputWidget> createState() => _DescriptionInputWidgetState();
}

class _DescriptionInputWidgetState extends State<DescriptionInputWidget> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  bool _speechAvailable = false;

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    try {
      _speechAvailable = await _speech.initialize(
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') {
            setState(() => _isListening = false);
          }
        },
        onError: (error) {
          setState(() => _isListening = false);
        },
      );
      if (mounted) setState(() {});
    } catch (e) {
      _speechAvailable = false;
    }
  }

  Future<void> _toggleListening() async {
    if (!_speechAvailable) return;

    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
    } else {
      setState(() => _isListening = true);
      await _speech.listen(
        onResult: (result) {
          setState(() {
            widget.controller.text = result.recognizedWords;
          });
        },
        localeId: 'es_CO',
      );
    }
  }

  @override
  void dispose() {
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Descripción',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            if (_speechAvailable)
              InkWell(
                onTap: _toggleListening,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 3.w,
                    vertical: 0.8.h,
                  ),
                  decoration: BoxDecoration(
                    color: _isListening
                        ? theme.colorScheme.primary.withValues(alpha: 0.15)
                        : theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _isListening
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outline,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomIconWidget(
                        iconName: _isListening ? 'mic' : 'mic_none',
                        color: _isListening
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurfaceVariant,
                        size: 18,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        _isListening ? 'Escuchando...' : 'Voz',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: _isListening
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: 1.5.h),
        TextField(
          controller: widget.controller,
          maxLines: 5,
          maxLength: 500,
          decoration: InputDecoration(
            hintText: 'Describe el incidente en detalle...',
            errorText: widget.errorText,
            counterStyle: theme.textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}
