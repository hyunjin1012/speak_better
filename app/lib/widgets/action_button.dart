import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// A reusable action button widget with consistent styling
class ActionButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool isPrimary;
  final bool isDestructive;
  final double? height;
  final EdgeInsets? padding;
  final bool isLoading;

  const ActionButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.isPrimary = false,
    this.isDestructive = false,
    this.height,
    this.padding,
    this.isLoading = false,
  });

  const ActionButton.primary({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.height,
    this.padding,
    this.isLoading = false,
  })  : isPrimary = true,
        isDestructive = false;

  const ActionButton.destructive({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.height,
    this.padding,
    this.isLoading = false,
  })  : isPrimary = false,
        isDestructive = true;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (isPrimary) {
      return ElevatedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? SizedBox(
                width: AppSizes.iconSm,
                height: AppSizes.iconSm,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: colorScheme.onPrimary,
                ),
              )
            : icon != null
                ? Icon(icon)
                : const SizedBox.shrink(),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          minimumSize: Size(0, height ?? AppSizes.buttonHeight),
          padding: padding ?? AppPadding.symmetricMd,
        ),
      );
    }

    if (isDestructive) {
      return OutlinedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? const SizedBox(
                width: AppSizes.iconSm,
                height: AppSizes.iconSm,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.red,
                ),
              )
            : icon != null
                ? Icon(icon)
                : const SizedBox.shrink(),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red,
          side: const BorderSide(color: Colors.red),
          minimumSize: Size(0, height ?? AppSizes.buttonHeight),
          padding: padding ?? AppPadding.symmetricMd,
        ),
      );
    }

    return OutlinedButton.icon(
      onPressed: isLoading ? null : onPressed,
      icon: isLoading
          ? const SizedBox(
              width: AppSizes.iconSm,
              height: AppSizes.iconSm,
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            )
          : icon != null
              ? Icon(icon)
              : const SizedBox.shrink(),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        minimumSize: Size(0, height ?? AppSizes.buttonHeight),
        padding: padding ?? AppPadding.symmetricMd,
      ),
    );
  }
}
