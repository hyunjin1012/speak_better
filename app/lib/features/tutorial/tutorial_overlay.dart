import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils/constants.dart';

/// Tutorial overlay that shows tips and guides
class TutorialOverlay extends StatefulWidget {
  final List<TutorialStep> steps;
  final VoidCallback? onComplete;
  final String language; // 'ko' or 'en'

  const TutorialOverlay({
    super.key,
    required this.steps,
    this.onComplete,
    this.language = 'en',
  });

  @override
  State<TutorialOverlay> createState() => _TutorialOverlayState();
}

class _TutorialOverlayState extends State<TutorialOverlay> {
  int _currentStep = 0;

  @override
  Widget build(BuildContext context) {
    if (_currentStep >= widget.steps.length) {
      widget.onComplete?.call();
      return const SizedBox.shrink();
    }

    final step = widget.steps[_currentStep];

    return Stack(
      children: [
        // Dark overlay
        Positioned.fill(
          child: GestureDetector(
            onTap: _nextStep,
            child: Container(
              color: Colors.black.withOpacity(0.7),
            ),
          ),
        ),
        // Highlighted area (if target key provided)
        if (step.targetKey != null) _buildHighlight(context, step.targetKey!),
        // Tutorial content
        Positioned(
          bottom: 100,
          left: AppPadding.allMd.left,
          right: AppPadding.allMd.right,
          child: Card(
            elevation: 8,
            child: Padding(
              padding: AppPadding.allLg,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  AppSpacing.heightMd,
                  Text(
                    step.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  AppSpacing.heightLg,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (_currentStep > 0)
                        TextButton(
                          onPressed: _previousStep,
                          child:
                              Text(widget.language == 'ko' ? '이전' : 'Previous'),
                        )
                      else
                        const SizedBox.shrink(),
                      Row(
                        children: [
                          // Step indicator
                          ...List.generate(
                            widget.steps.length,
                            (index) => Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: index == _currentStep
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.grey[300],
                              ),
                            ),
                          ),
                          AppSpacing.widthMd,
                          ElevatedButton(
                            onPressed: _nextStep,
                            child: Text(
                              _currentStep == widget.steps.length - 1
                                  ? (widget.language == 'ko' ? '완료' : 'Done')
                                  : (widget.language == 'ko' ? '다음' : 'Next'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHighlight(BuildContext context, GlobalKey targetKey) {
    final RenderBox? renderBox =
        targetKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return const SizedBox.shrink();

    final size = renderBox.size;
    final position = renderBox.localToGlobal(Offset.zero);

    return Positioned(
      left: position.dx,
      top: position.dy,
      width: size.width,
      height: size.height,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: 3),
          borderRadius: AppBorderRadius.circularMd,
          boxShadow: [
            BoxShadow(
              color: Colors.white.withOpacity(0.5),
              blurRadius: 10,
              spreadRadius: 5,
            ),
          ],
        ),
      ),
    );
  }

  void _nextStep() {
    HapticFeedback.lightImpact();
    if (_currentStep < widget.steps.length - 1) {
      setState(() {
        _currentStep++;
      });
    } else {
      widget.onComplete?.call();
    }
  }

  void _previousStep() {
    HapticFeedback.lightImpact();
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }
}

/// Tutorial step data
class TutorialStep {
  final String title;
  final String description;
  final GlobalKey? targetKey; // Optional key to highlight a widget

  TutorialStep({
    required this.title,
    required this.description,
    this.targetKey,
  });
}

/// Helper to show tutorial overlay
void showTutorialOverlay(
  BuildContext context, {
  required List<TutorialStep> steps,
  VoidCallback? onComplete,
  String language = 'en',
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => TutorialOverlay(
      steps: steps,
      onComplete: () {
        Navigator.of(context).pop();
        onComplete?.call();
      },
      language: language,
    ),
  );
}
