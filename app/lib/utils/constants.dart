import 'package:flutter/material.dart';

/// App-wide constants for spacing, sizing, and design tokens
class AppSpacing {
  AppSpacing._();

  // Spacing values
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  // Common SizedBox shortcuts
  static const heightXs = SizedBox(height: xs);
  static const heightSm = SizedBox(height: sm);
  static const heightMd = SizedBox(height: md);
  static const heightLg = SizedBox(height: lg);
  static const heightXl = SizedBox(height: xl);
  static const heightXxl = SizedBox(height: xxl);

  static const widthXs = SizedBox(width: xs);
  static const widthSm = SizedBox(width: sm);
  static const widthMd = SizedBox(width: md);
  static const widthLg = SizedBox(width: lg);
  static const widthXl = SizedBox(width: xl);
}

class AppPadding {
  AppPadding._();

  // Standard padding values
  static const allXs = EdgeInsets.all(AppSpacing.xs);
  static const allSm = EdgeInsets.all(AppSpacing.sm);
  static const allMd = EdgeInsets.all(AppSpacing.md);
  static const allLg = EdgeInsets.all(AppSpacing.lg);
  static const allXl = EdgeInsets.all(AppSpacing.xl);

  // Horizontal padding
  static const horizontalSm = EdgeInsets.symmetric(horizontal: AppSpacing.sm);
  static const horizontalMd = EdgeInsets.symmetric(horizontal: AppSpacing.md);
  static const horizontalLg = EdgeInsets.symmetric(horizontal: AppSpacing.lg);

  // Vertical padding
  static const verticalSm = EdgeInsets.symmetric(vertical: AppSpacing.sm);
  static const verticalMd = EdgeInsets.symmetric(vertical: AppSpacing.md);
  static const verticalLg = EdgeInsets.symmetric(vertical: AppSpacing.lg);

  // Symmetric padding
  static const symmetricSm = EdgeInsets.symmetric(
    horizontal: AppSpacing.sm,
    vertical: AppSpacing.sm,
  );
  static const symmetricMd = EdgeInsets.symmetric(
    horizontal: AppSpacing.md,
    vertical: AppSpacing.md,
  );
  static const symmetricLg = EdgeInsets.symmetric(
    horizontal: AppSpacing.lg,
    vertical: AppSpacing.lg,
  );
}

class AppBorderRadius {
  AppBorderRadius._();

  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;

  static const circularSm = BorderRadius.all(Radius.circular(sm));
  static const circularMd = BorderRadius.all(Radius.circular(md));
  static const circularLg = BorderRadius.all(Radius.circular(lg));
  static const circularXl = BorderRadius.all(Radius.circular(xl));
  static const circularXxl = BorderRadius.all(Radius.circular(xxl));
}

class AppSizes {
  AppSizes._();

  // Icon sizes
  static const double iconXs = 16.0;
  static const double iconSm = 24.0;
  static const double iconMd = 32.0;
  static const double iconLg = 48.0;
  static const double iconXl = 56.0;
  static const double iconXxl = 64.0;
  static const double iconXxxl = 80.0;

  // Image sizes
  static const double imageThumbnail = 56.0;
  static const double imageSmall = 120.0;
  static const double imageMedium = 180.0;
  static const double imageLarge = 250.0;
  static const double imageDisplay = 200.0;

  // Button sizes
  static const double buttonHeight = 48.0;
  static const double buttonHeightSmall = 40.0;
  static const double buttonHeightLarge = 56.0;
}

class AppDurations {
  AppDurations._();

  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);

  // Animation durations
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);

  // Timer intervals
  static const Duration timerInterval = Duration(seconds: 1);
  static const Duration positionUpdateInterval = Duration(milliseconds: 100);
  static const Duration refreshDelay = Duration(milliseconds: 300);
}

class AppElevation {
  AppElevation._();

  static const double none = 0.0;
  static const double low = 2.0;
  static const double medium = 4.0;
  static const double high = 8.0;
}

class AppOpacity {
  AppOpacity._();

  static const double disabled = 0.38;
  static const double medium = 0.6;
  static const double high = 0.87;
  static const double overlay = 0.1;
}
