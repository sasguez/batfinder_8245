import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

/// Widget displaying comments section with community discussion
class CommentsSectionWidget extends StatefulWidget {
  final List<Map<String, dynamic>> comments;

  const CommentsSectionWidget({super.key, required this.comments});

  @override
  State<CommentsSectionWidget> createState() => _CommentsSectionWidgetState();
}

class _CommentsSectionWidgetState extends State<CommentsSectionWidget> {
  final TextEditingController _commentController = TextEditingController();
  bool _postAnonymously = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Community Discussion (${widget.comments.length})',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: theme.colorScheme.outline, width: 1),
            ),
            child: Column(
              children: [
                TextField(
                  controller: _commentController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText:
                        'Share your thoughts or additional information...',
                    border: InputBorder.none,
                    hintStyle: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                SizedBox(height: 1.h),
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Checkbox(
                            value: _postAnonymously,
                            onChanged: (value) {
                              setState(() {
                                _postAnonymously = value ?? false;
                              });
                            },
                          ),
                          Text(
                            'Post anonymously',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => _postComment(),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: 4.w,
                          vertical: 1.h,
                        ),
                      ),
                      child: Text('Post'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 2.h),
          ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: widget.comments.length,
            separatorBuilder: (context, index) => SizedBox(height: 2.h),
            itemBuilder: (context, index) {
              final comment = widget.comments[index];
              return _buildCommentCard(context, comment, theme);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCommentCard(
    BuildContext context,
    Map<String, dynamic> comment,
    ThemeData theme,
  ) {
    final bool isAnonymous = comment['isAnonymous'] ?? false;
    final String authorName = isAnonymous
        ? 'Anonymous User'
        : (comment['authorName'] ?? 'Unknown');
    final String content = comment['content'] ?? '';
    final DateTime timestamp = comment['timestamp'] ?? DateTime.now();

    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.outline, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8.w,
                height: 8.w,
                decoration: BoxDecoration(
                  color: isAnonymous
                      ? theme.colorScheme.secondary.withValues(alpha: 0.2)
                      : theme.colorScheme.primary.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: isAnonymous
                      ? CustomIconWidget(
                          iconName: 'person_outline',
                          color: theme.colorScheme.secondary,
                          size: 16,
                        )
                      : CustomImageWidget(
                          imageUrl: comment['authorAvatar'] ?? '',
                          width: 8.w,
                          height: 8.w,
                          fit: BoxFit.cover,
                          semanticLabel:
                              comment['authorAvatarSemanticLabel'] ??
                              'Commenter profile photo',
                        ),
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      authorName,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      _formatTimestamp(timestamp),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Text(content, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }

  void _postComment() {
    if (_commentController.text.trim().isEmpty) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Comment posted successfully'),
        duration: Duration(seconds: 2),
      ),
    );

    _commentController.clear();
    setState(() {
      _postAnonymously = false;
    });
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}
