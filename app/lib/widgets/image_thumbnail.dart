import 'dart:io';
import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// A reusable widget for displaying image thumbnails with loading and error states
class ImageThumbnail extends StatelessWidget {
  final File? imageFile;
  final String? imagePath;
  final double size;
  final double? borderRadius;
  final Widget? placeholder;
  final BoxFit fit;

  const ImageThumbnail({
    super.key,
    this.imageFile,
    this.imagePath,
    this.size = AppSizes.imageThumbnail,
    this.borderRadius,
    this.placeholder,
    this.fit = BoxFit.cover,
  }) : assert(imageFile != null || imagePath != null,
            'Either imageFile or imagePath must be provided');

  @override
  Widget build(BuildContext context) {
    final file = imageFile ?? (imagePath != null ? File(imagePath!) : null);
    if (file == null) {
      return _buildPlaceholder(context);
    }

    return FutureBuilder<bool>(
      future: file.exists(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingPlaceholder(context);
        }

        if (!snapshot.hasData || !snapshot.data!) {
          return _buildPlaceholder(context);
        }

        return ClipRRect(
          borderRadius: BorderRadius.circular(
            borderRadius ?? AppBorderRadius.md,
          ),
          child: Image.file(
            file,
            width: size,
            height: size,
            fit: fit,
            errorBuilder: (context, error, stackTrace) {
              return _buildPlaceholder(context);
            },
          ),
        );
      },
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    if (placeholder != null) {
      return SizedBox(
        width: size,
        height: size,
        child: placeholder,
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(
          borderRadius ?? AppBorderRadius.md,
        ),
      ),
      child: Icon(
        Icons.image,
        size: size * 0.5,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildLoadingPlaceholder(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Center(
        child: SizedBox(
          width: size * 0.3,
          height: size * 0.3,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }
}
