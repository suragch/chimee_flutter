enum KeyboardLayoutType {
  aeiou,
  qwerty,
  cyrillic,
  english,
  punctuation,
}

enum KeyAction {
  input,
  backspace,
  space,
  newline,
  switchLayout,
  openSuffixChooser,
}

class KeyDefinition {
  final String? text;
  final String? swipeUpText;
  final String? label;
  final String? subLabel;
  final KeyAction action;
  final double flex;
  final KeyboardLayoutType? targetLayout;
  final bool isRotated;

  const KeyDefinition({
    this.text,
    this.swipeUpText,
    this.label,
    this.subLabel,
    this.action = KeyAction.input,
    this.flex = 1.0,
    this.targetLayout,
    this.isRotated = false,
  });

  const KeyDefinition.action({
    required this.action,
    this.label,
    this.flex = 1.0,
    this.targetLayout,
  })  : text = null,
        swipeUpText = null,
        subLabel = null,
        isRotated = false;
}
