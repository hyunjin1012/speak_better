import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/session.dart';
import '../models/topic.dart';
import '../state/topics_provider.dart';
import '../utils/constants.dart';
import 'image_thumbnail.dart';

/// A reusable card widget for displaying practice sessions in lists
class SessionCard extends ConsumerWidget {
  final PracticeSession session;
  final Topic? topic;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final Map<String, bool>? imageExistsCache;

  const SessionCard({
    super.key,
    required this.session,
    this.topic,
    this.onTap,
    this.onDelete,
    this.imageExistsCache,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final topics = ref.watch(topicsProvider);
    final displayTopic = topic ??
        topics.firstWhere(
          (t) => t.id == session.topicId,
          orElse: () => Topic(
            id: '',
            title: '',
            prompt: '',
            language: session.language,
            isBuiltIn: false,
          ),
        );

    return Card(
      elevation: AppElevation.low,
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      shape: const RoundedRectangleBorder(
        borderRadius: AppBorderRadius.circularLg,
      ),
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap?.call();
        },
        borderRadius: AppBorderRadius.circularLg,
        child: Padding(
          padding: AppPadding.allMd,
          child: Row(
            children: [
              // Image thumbnail or icon
              _buildThumbnail(context, displayTopic, colorScheme),
              AppSpacing.widthMd,
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (displayTopic.title.isNotEmpty) ...[
                      _buildTopicBadge(context, displayTopic, colorScheme),
                      AppSpacing.heightSm,
                    ],
                    _buildTranscript(context),
                    AppSpacing.heightXs,
                    _buildTimestamp(context, colorScheme),
                  ],
                ),
              ),
              // Delete button
              if (onDelete != null)
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  color: Colors.red,
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    onDelete?.call();
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail(
    BuildContext context,
    Topic topic,
    ColorScheme colorScheme,
  ) {
    if (session.imagePath != null) {
      return ImageThumbnail(
        imagePath: session.imagePath,
        size: AppSizes.imageThumbnail,
        borderRadius: AppBorderRadius.md,
        placeholder: Container(
          padding: AppPadding.allSm,
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: AppBorderRadius.circularMd,
          ),
          child: Icon(
            topic.isBuiltIn ? Icons.star : Icons.mic,
            color: colorScheme.primary,
            size: AppSizes.iconMd,
          ),
        ),
      );
    }

    return Container(
      padding: AppPadding.allSm,
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: AppBorderRadius.circularMd,
      ),
      child: Icon(
        topic.isBuiltIn ? Icons.star : Icons.mic,
        color: colorScheme.primary,
        size: AppSizes.iconMd,
      ),
    );
  }

  Widget _buildTopicBadge(
    BuildContext context,
    Topic topic,
    ColorScheme colorScheme,
  ) {
    return Container(
      padding: AppPadding.symmetricSm,
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer,
        borderRadius: AppBorderRadius.circularSm,
      ),
      child: Text(
        topic.title,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: colorScheme.onSecondaryContainer,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildTranscript(BuildContext context) {
    final transcript = session.transcript;
    final displayText = transcript.length > 50
        ? '${transcript.substring(0, 50)}...'
        : transcript;

    return Text(
      displayText,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
    );
  }

  Widget _buildTimestamp(BuildContext context, ColorScheme colorScheme) {
    final date = session.createdAt;
    final dateStr =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

    return Text(
      dateStr,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurface.withOpacity(AppOpacity.medium),
          ),
    );
  }
}
