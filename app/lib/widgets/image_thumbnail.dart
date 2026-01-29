import 'dart:io';
import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// A reusable widget for displaying image thumbnails with loading and error states
class ImageThumbnail extends StatefulWidget {
  final File? imageFile;
  final String? imagePath;
  final double size;
  final double? borderRadius;
  final Widget? placeholder;
  final BoxFit fit;
  final Map<String, bool>? imageExistsCache;

  const ImageThumbnail({
    super.key,
    this.imageFile,
    this.imagePath,
    this.size = AppSizes.imageThumbnail,
    this.borderRadius,
    this.placeholder,
    this.fit = BoxFit.cover,
    this.imageExistsCache,
  }) : assert(imageFile != null || imagePath != null,
            'Either imageFile or imagePath must be provided');

  @override
  State<ImageThumbnail> createState() => _ImageThumbnailState();
}

class _ImageThumbnailState extends State<ImageThumbnail> {
  bool? _cachedExists;
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    _checkImageExists();
  }

  Future<void> _checkImageExists() async {
    final file = widget.imageFile ??
        (widget.imagePath != null ? File(widget.imagePath!) : null);
    if (file == null) {
      _cachedExists = false;
      return;
    }

    // Check cache first
    if (widget.imageExistsCache != null && widget.imagePath != null) {
      if (widget.imageExistsCache!.containsKey(widget.imagePath)) {
        _cachedExists = widget.imageExistsCache![widget.imagePath];
        return;
      }
    }

    // If already checking, don't check again
    if (_isChecking) return;

    _isChecking = true;
    try {
      final exists = await file.exists();
      if (mounted) {
        setState(() {
          _cachedExists = exists;
          _isChecking = false;
        });
        // Update cache if provided
        if (widget.imageExistsCache != null && widget.imagePath != null) {
          widget.imageExistsCache![widget.imagePath!] = exists;
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _cachedExists = false;
          _isChecking = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final file = widget.imageFile ??
        (widget.imagePath != null ? File(widget.imagePath!) : null);
    if (file == null) {
      return _buildPlaceholder(context);
    }

    // Show loading placeholder while checking
    if (_cachedExists == null || _isChecking) {
      return _buildLoadingPlaceholder(context);
    }

    // Show placeholder if file doesn't exist
    if (!_cachedExists!) {
      return _buildPlaceholder(context);
    }

    // Show image
    return ClipRRect(
      borderRadius: BorderRadius.circular(
        widget.borderRadius ?? AppBorderRadius.md,
      ),
      child: Image.file(
        file,
        width: widget.size,
        height: widget.size,
        fit: widget.fit,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholder(context);
        },
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    if (widget.placeholder != null) {
      return SizedBox(
        width: widget.size,
        height: widget.size,
        child: widget.placeholder,
      );
    }

    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(
          widget.borderRadius ?? AppBorderRadius.md,
        ),
      ),
      child: Icon(
        Icons.image,
        size: widget.size * 0.5,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildLoadingPlaceholder(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Center(
        child: SizedBox(
          width: widget.size * 0.3,
          height: widget.size * 0.3,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }
}
