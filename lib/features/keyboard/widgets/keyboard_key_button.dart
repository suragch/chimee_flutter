import 'package:material_ui/material_ui.dart';
import '../keyboard_types.dart';

/// Virtual keycap widget rendering upright Mongolian letterforms via RotatedBox
/// and standard action icons.
class KeyboardKeyButton extends StatelessWidget {
  const KeyboardKeyButton({
    super.key,
    required this.keyDef,
    required this.onPressed,
    this.onLongPress,
    this.fontFamily = 'Qagan',
  });

  final KeyDefinition keyDef;
  final ValueChanged<KeyDefinition> onPressed;
  final ValueChanged<KeyDefinition>? onLongPress;
  final String fontFamily;

  bool _isMongolian(String str) {
    if (str.isEmpty) return false;
    for (int i = 0; i < str.length; i++) {
      final code = str.codeUnitAt(i);
      if (code >= 0x1800 && code <= 0x18AF) return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final isSpecialAction = keyDef.action != KeyAction.input && keyDef.action != KeyAction.space;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0),
      child: Material(
        color: isSpecialAction
            ? Theme.of(context).colorScheme.surfaceContainerHighest
            : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(6.0),
        elevation: 1.0,
        child: InkWell(
          borderRadius: BorderRadius.circular(6.0),
          onTap: () => onPressed(keyDef),
          onLongPress: onLongPress != null ? () => onLongPress!(keyDef) : null,
          child: Container(
            height: 48.0,
            alignment: Alignment.center,
            child: _buildKeyContent(context),
          ),
        ),
      ),
    );
  }

  Widget _buildKeyContent(BuildContext context) {
    if (keyDef.action == KeyAction.backspace) {
      return const Icon(Icons.backspace_outlined, size: 20.0);
    }
    if (keyDef.action == KeyAction.newline) {
      return const Icon(Icons.keyboard_return, size: 20.0);
    }
    if (keyDef.action == KeyAction.switchLayout) {
      return const Icon(Icons.language, size: 20.0);
    }
    if (keyDef.action == KeyAction.space) {
      final label = keyDef.label ?? 'Space';
      final isMongol = _isMongolian(label);
      return FittedBox(
        fit: BoxFit.scaleDown,
        child: isMongol
            ? RotatedBox(
                quarterTurns: 1,
                child: Text(
                  label,
                  style: TextStyle(
                    fontFamily: fontFamily,
                    fontSize: 16.0,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              )
            : Text(
                label,
                style: TextStyle(
                  fontSize: 12.0,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
      );
    }

    final displayText = keyDef.label ?? keyDef.text ?? '';
    final subText = keyDef.subLabel ?? '';
    final isMongol = _isMongolian(displayText);

    Widget mainLabelWidget = Text(
      displayText,
      style: TextStyle(
        fontFamily: isMongol ? fontFamily : null,
        fontSize: isMongol ? 20.0 : 18.0,
        fontWeight: FontWeight.w500,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );

    if (isMongol) {
      mainLabelWidget = RotatedBox(
        quarterTurns: 1,
        child: mainLabelWidget,
      );
    }

    if (subText.isNotEmpty) {
      final isSubMongol = _isMongolian(subText);
      Widget subLabelWidget = Text(
        subText,
        style: TextStyle(
          fontFamily: isSubMongol ? fontFamily : null,
          fontSize: 10.0,
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
        ),
      );

      if (isSubMongol) {
        subLabelWidget = RotatedBox(
          quarterTurns: 1,
          child: subLabelWidget,
        );
      }

      return Stack(
        children: [
          Positioned(
            right: 4,
            top: 2,
            child: subLabelWidget,
          ),
          Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: mainLabelWidget,
            ),
          ),
        ],
      );
    }

    return Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: mainLabelWidget,
      ),
    );
  }
}
