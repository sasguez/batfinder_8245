import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Custom app bar variants for Colombian Safety App
/// Implements Civic Minimalism with clean, purposeful interfaces
enum CustomAppBarVariant { standard, withActions, withSearch, transparent }

/// Custom app bar for Colombian Safety App
/// Provides consistent navigation and branding across screens
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final CustomAppBarVariant variant;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final VoidCallback? onSearchTap;
  final PreferredSizeWidget? bottom;
  final bool showBackButton;

  const CustomAppBar({
    super.key,
    required this.title,
    this.variant = CustomAppBarVariant.standard,
    this.actions,
    this.leading,
    this.centerTitle = false,
    this.onSearchTap,
    this.bottom,
    this.showBackButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Determine background color based on variant
    Color? backgroundColor;
    double elevation = 0;

    switch (variant) {
      case CustomAppBarVariant.transparent:
        backgroundColor = Colors.transparent;
        elevation = 0;
        break;
      case CustomAppBarVariant.standard:
      case CustomAppBarVariant.withActions:
      case CustomAppBarVariant.withSearch:
        backgroundColor = theme.appBarTheme.backgroundColor;
        elevation = 0;
        break;
    }

    // Build actions based on variant
    List<Widget>? appBarActions;

    if (variant == CustomAppBarVariant.withSearch) {
      appBarActions = [
        IconButton(
          icon: Icon(Icons.search, size: 24),
          onPressed: () {
            HapticFeedback.lightImpact();
            if (onSearchTap != null) {
              onSearchTap!();
            }
          },
          tooltip: 'Search',
        ),
        if (actions != null) ...actions!,
      ];
    } else if (variant == CustomAppBarVariant.withActions && actions != null) {
      appBarActions = actions;
    }

    return AppBar(
      title: Text(title, style: theme.appBarTheme.titleTextStyle),
      centerTitle: centerTitle,
      backgroundColor: backgroundColor,
      elevation: elevation,
      leading:
          leading ??
          (showBackButton && Navigator.canPop(context)
              ? IconButton(
                  icon: Icon(Icons.arrow_back, size: 24),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(context);
                  },
                  tooltip: 'Back',
                )
              : null),
      actions: appBarActions,
      bottom: bottom,
      systemOverlayStyle: isDark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0.0));
}

/// Custom app bar with emergency alert indicator
/// Shows active emergency status in the app bar
class CustomAppBarWithEmergency extends StatelessWidget
    implements PreferredSizeWidget {
  final String title;
  final bool hasActiveEmergency;
  final VoidCallback? onEmergencyTap;
  final List<Widget>? actions;
  final bool centerTitle;

  const CustomAppBarWithEmergency({
    super.key,
    required this.title,
    this.hasActiveEmergency = false,
    this.onEmergencyTap,
    this.actions,
    this.centerTitle = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppBar(
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasActiveEmergency) ...[
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: theme.colorScheme.error,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 8),
          ],
          Flexible(
            child: Text(
              title,
              style: theme.appBarTheme.titleTextStyle,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      centerTitle: centerTitle,
      backgroundColor: theme.appBarTheme.backgroundColor,
      elevation: 0,
      actions: [
        if (hasActiveEmergency)
          TextButton.icon(
            onPressed: () {
              HapticFeedback.mediumImpact();
              if (onEmergencyTap != null) {
                onEmergencyTap!();
              }
            },
            icon: Icon(
              Icons.warning_amber_rounded,
              color: theme.colorScheme.error,
              size: 20,
            ),
            label: Text(
              'ACTIVE',
              style: TextStyle(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
        if (actions != null) ...actions!,
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
