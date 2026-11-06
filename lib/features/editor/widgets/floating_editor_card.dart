import 'dart:math' as math;
import 'package:material_ui/material_ui.dart';
import 'package:chimee/features/editor/card_auto_sizer.dart';

/// Animated floating card hosting the vertical text editor.
/// Sizes dynamically based on [cardSize] with smooth transitions, 2 dp drop shadow,
/// and horizontal column scrolling strictly enabled only when both boundaries are maxed out.
class FloatingEditorCard extends StatelessWidget {
  const FloatingEditorCard({
    super.key,
    required this.cardSize,
    required this.backgroundColor,
    required this.child,
    this.canScroll = false,
    this.contentWidth,
  });

  final Size cardSize;
  final Color backgroundColor;
  final Widget child;
  final bool canScroll;
  final double? contentWidth;

  @override
  Widget build(BuildContext context) {
    final double innerWidth = math.max(0.0, cardSize.width - CardAutoSizer.cardPadding.horizontal);
    final double innerHeight = math.max(0.0, cardSize.height - CardAutoSizer.cardPadding.vertical);
    final double effectiveContentWidth = canScroll && contentWidth != null
        ? math.max(contentWidth! - CardAutoSizer.cardPadding.horizontal, innerWidth)
        : innerWidth;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOutCubic,
      width: cardSize.width,
      height: cardSize.height,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4.0),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4.0),
        child: Padding(
          padding: CardAutoSizer.cardPadding,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: canScroll
                ? const ClampingScrollPhysics()
                : const NeverScrollableScrollPhysics(),
            child: SizedBox(
              width: effectiveContentWidth,
              height: innerHeight,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
