import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

/// Widget displaying attached photos and videos with full-screen viewing capability
class MediaGalleryWidget extends StatelessWidget {
  final List<Map<String, dynamic>> mediaItems;

  const MediaGalleryWidget({super.key, required this.mediaItems});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (mediaItems.isEmpty) {
      return SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Media Evidence',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          SizedBox(
            height: 15.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: mediaItems.length,
              separatorBuilder: (context, index) => SizedBox(width: 2.w),
              itemBuilder: (context, index) {
                final media = mediaItems[index];
                final bool isVideo = media['type'] == 'video';

                return GestureDetector(
                  onTap: () => _showFullScreen(context, media),
                  child: Container(
                    width: 25.w,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: theme.colorScheme.outline,
                        width: 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          CustomImageWidget(
                            imageUrl: media['url'] ?? '',
                            width: 25.w,
                            height: 15.h,
                            fit: BoxFit.cover,
                            semanticLabel:
                                media['semanticLabel'] ??
                                'Incident evidence photo',
                          ),
                          if (isVideo)
                            Container(
                              color: Colors.black.withValues(alpha: 0.4),
                              child: Center(
                                child: CustomIconWidget(
                                  iconName: 'play_circle_filled',
                                  color: Colors.white,
                                  size: 32,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showFullScreen(BuildContext context, Map<String, dynamic> media) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            Center(
              child: CustomImageWidget(
                imageUrl: media['url'] ?? '',
                width: 100.w,
                height: 100.h,
                fit: BoxFit.contain,
                semanticLabel:
                    media['semanticLabel'] ?? 'Full screen incident evidence',
              ),
            ),
            Positioned(
              top: 4.h,
              right: 4.w,
              child: IconButton(
                icon: Icon(Icons.close, color: Colors.white, size: 32),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
