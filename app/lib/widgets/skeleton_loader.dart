import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// Skeleton loader widget for loading states
class SkeletonLoader extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final Color? color;

  const SkeletonLoader({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color ?? Colors.grey[300],
        borderRadius: borderRadius ?? AppBorderRadius.circularMd,
      ),
    );
  }
}

/// Skeleton card for session cards
class SessionCardSkeleton extends StatelessWidget {
  const SessionCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Card(
      margin: AppPadding.allMd,
      child: Padding(
        padding: AppPadding.allMd,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image skeleton
            SkeletonLoader(
              width: AppSizes.imageThumbnail,
              height: AppSizes.imageThumbnail,
              borderRadius: AppBorderRadius.circularMd,
            ),
            AppSpacing.widthMd,
            // Content skeleton
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonLoader(
                    height: 16,
                    width: 100,
                    borderRadius: AppBorderRadius.circularSm,
                  ),
                  AppSpacing.heightSm,
                  SkeletonLoader(
                    height: 14,
                    width: double.infinity,
                    borderRadius: AppBorderRadius.circularSm,
                  ),
                  AppSpacing.heightXs,
                  SkeletonLoader(
                    height: 14,
                    width: 200,
                    borderRadius: AppBorderRadius.circularSm,
                  ),
                  AppSpacing.heightSm,
                  SkeletonLoader(
                    height: 12,
                    width: 150,
                    borderRadius: AppBorderRadius.circularSm,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// List of skeleton cards
class SkeletonList extends StatelessWidget {
  final int count;
  final Widget Function(BuildContext, int) itemBuilder;

  const SkeletonList({
    super.key,
    this.count = 3,
    Widget Function(BuildContext, int)? itemBuilder,
  }) : itemBuilder = itemBuilder ?? _defaultItemBuilder;

  static Widget _defaultItemBuilder(BuildContext context, int index) {
    return const SessionCardSkeleton();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: AppPadding.allMd,
      itemCount: count,
      itemBuilder: itemBuilder,
    );
  }
}
