import 'dart:math' as math;
import 'package:material_ui/material_ui.dart';
import 'package:mongol/mongol.dart';

/// Result of a card auto-sizing calculation, including the clamped card size,
/// measured unclamped content width, and whether internal scrolling should be enabled.
class CardSizingResult {
  const CardSizingResult({
    required this.cardSize,
    required this.contentWidth,
    required this.canScroll,
  });

  /// The dimensions of the card container, clamped to viewport limits.
  final Size cardSize;

  /// The unclamped width needed to display all vertical text columns plus padding.
  final double contentWidth;

  /// Whether internal horizontal scrolling should be enabled.
  /// True only when the card has maxed out both horizontal and vertical bounds
  /// (or when manual scaling has maxed out width).
  final bool canScroll;
}

/// Calculation engine for the floating editor card's discrete 50 dp stepping algorithm.
/// Decoupled from live widget tree layout passes to avoid recursive layout cycles.
class CardAutoSizer {
  CardAutoSizer._();

  static const double minHeight = 150.0;
  static const double heightStep = 50.0;
  static const double minHeightToWidthProportion = 2.0; // 2:1 height-to-width ratio
  static const EdgeInsets cardPadding = EdgeInsets.all(16.0);

  /// Computes the comprehensive sizing result including dimensions and scrolling threshold.
  static CardSizingResult computeResult({
    required String text,
    required TextStyle textStyle,
    required double maxViewportHeight,
    required double maxViewportWidth,
    required double currentHeight,
    required bool isManualScaling,
    double? manualDesiredHeight,
  }) {
    final double maxCardHeight = math.max(minHeight, maxViewportHeight);
    final double absoluteMinWidth = minHeight / minHeightToWidthProportion; // 75.0 dp
    final double maxCardWidth = math.max(absoluteMinWidth, maxViewportWidth - 32.0); // 16 dp margin each side

    // 1. Manual pinch-to-scale sizing path
    if (isManualScaling && manualDesiredHeight != null) {
      final double clampedH = manualDesiredHeight.clamp(minHeight, maxCardHeight);
      final double measuredW = _measureWidth(text, textStyle, clampedH) + cardPadding.horizontal;
      double targetW = math.max(measuredW, absoluteMinWidth);
      if (minHeightToWidthProportion * targetW < clampedH) {
        targetW = clampedH / minHeightToWidthProportion;
      }
      final double effectiveMinW = math.min(absoluteMinWidth, maxCardWidth);
      final double clampedW = targetW.clamp(effectiveMinW, maxCardWidth);
      final bool canScroll = measuredW > maxCardWidth;
      return CardSizingResult(
        cardSize: Size(clampedW, clampedH),
        contentWidth: measuredW,
        canScroll: canScroll,
      );
    }

    // 2. Auto-sizing path: Start from current height bounded to [minHeight, maxCardHeight]
    double h = math.max(currentHeight, minHeight).clamp(minHeight, maxCardHeight);
    double w = _measureWidth(text, textStyle, h) + cardPadding.horizontal;
    final double minW = absoluteMinWidth; // 75.0 dp base width

    if (w < minW) {
      w = minW;
    }

    // Increment height in 50 dp steps if width exceeds height
    if (h < w && h < maxCardHeight) {
      while (h < maxCardHeight) {
        h += heightStep;
        if (h >= maxCardHeight) {
          h = maxCardHeight;
          w = _measureWidth(text, textStyle, h) + cardPadding.horizontal;
          break;
        }
        w = _measureWidth(text, textStyle, h) + cardPadding.horizontal;
        if (h >= w) {
          break;
        }
      }
    }
    // Decrement height in 50 dp steps if height is disproportionately tall (h > 2.0 * w)
    else if (h > minHeightToWidthProportion * w && h > minHeight) {
      while (h > minHeight) {
        h -= heightStep;
        if (h <= minHeight) {
          h = minHeight;
          w = _measureWidth(text, textStyle, h) + cardPadding.horizontal;
          break;
        }
        w = _measureWidth(text, textStyle, h) + cardPadding.horizontal;
        if (h <= minHeightToWidthProportion * w) {
          break;
        }
      }
    }

    final double contentWidth = w;
    if (w < minW) {
      w = minW;
    }

    final double effectiveMinW = math.min(minW, maxCardWidth);
    final double finalW = w.clamp(effectiveMinW, maxCardWidth);
    // The input window shouldn't scroll internally until it has maxed out BOTH horizontal and vertical bounds!
    final bool canScroll = (h >= maxCardHeight) && (contentWidth > maxCardWidth);

    return CardSizingResult(
      cardSize: Size(finalW, h),
      contentWidth: contentWidth,
      canScroll: canScroll,
    );
  }

  /// Backward-compatible convenience wrapper returning just the target [Size].
  static Size computeSize({
    required String text,
    required TextStyle textStyle,
    required double maxViewportHeight,
    required double maxViewportWidth,
    required double currentHeight,
    required bool isManualScaling,
    double? manualDesiredHeight,
  }) {
    return computeResult(
      text: text,
      textStyle: textStyle,
      maxViewportHeight: maxViewportHeight,
      maxViewportWidth: maxViewportWidth,
      currentHeight: currentHeight,
      isManualScaling: isManualScaling,
      manualDesiredHeight: manualDesiredHeight,
    ).cardSize;
  }

  static double _measureWidth(String text, TextStyle style, double availableHeight) {
    if (text.isEmpty) return 0.0;
    final textSpan = TextSpan(text: text, style: style);
    final painter = MongolTextPainter(text: textSpan);
    final double contentHeight = math.max(10.0, availableHeight - cardPadding.vertical);
    painter.layout(minHeight: 0.0, maxHeight: contentHeight);
    return painter.width;
  }
}
