import 'dart:math' as math;
import 'package:material_ui/material_ui.dart';

class ScaleGestureContainer extends StatefulWidget {
  final Widget child;
  final double currentFontSize;
  final double currentHeight;
  final ValueChanged<double> onFontSizeChanged;
  final ValueChanged<double> onHeightChanged;
  final double minFontSize;
  final double maxFontSize;
  final double minHeight;
  final double maxHeight;

  const ScaleGestureContainer({
    super.key,
    required this.child,
    required this.currentFontSize,
    required this.currentHeight,
    required this.onFontSizeChanged,
    required this.onHeightChanged,
    this.minFontSize = 14.0,
    this.maxFontSize = 64.0,
    this.minHeight = 150.0,
    this.maxHeight = 900.0,
  });

  @override
  State<ScaleGestureContainer> createState() => _ScaleGestureContainerState();
}

class _ScaleGestureContainerState extends State<ScaleGestureContainer> {
  int _pointerCount = 0;
  double _baseFontSize = 24.0;
  double _baseHeight = 300.0;
  Offset _initialFocalPoint = Offset.zero;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) {
        setState(() => _pointerCount++);
      },
      onPointerUp: (_) {
        setState(() => _pointerCount = math.max(0, _pointerCount - 1));
      },
      onPointerCancel: (_) {
        setState(() => _pointerCount = math.max(0, _pointerCount - 1));
      },
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onScaleStart: (details) {
          if (details.pointerCount >= 2) {
            _baseFontSize = widget.currentFontSize;
            _baseHeight = widget.currentHeight;
            _initialFocalPoint = details.localFocalPoint;
          }
        },
        onScaleUpdate: (details) {
          if (details.pointerCount >= 2) {
            final delta = details.localFocalPoint - _initialFocalPoint;
            // Determine whether scaling gesture is primarily vertical or horizontal
            final isVertical = delta.dy.abs() > delta.dx.abs();

            if (isVertical) {
              // Vertical scale adjusts container height
              final newHeight = (_baseHeight * details.scale)
                  .clamp(widget.minHeight, widget.maxHeight);
              widget.onHeightChanged(newHeight);
            } else {
              // Horizontal scale adjusts text font size
              final newFontSize = (_baseFontSize * details.scale)
                  .clamp(widget.minFontSize, widget.maxFontSize);
              widget.onFontSizeChanged(newFontSize);
            }
          }
        },
        child: widget.child,
      ),
    );
  }
}
