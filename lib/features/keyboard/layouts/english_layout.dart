import '../keyboard_types.dart';

class EnglishLayout {
  static const List<List<KeyDefinition>> rows = [
    // Row 1
    [
      KeyDefinition(text: 'q', label: 'q'),
      KeyDefinition(text: 'w', label: 'w'),
      KeyDefinition(text: 'e', label: 'e'),
      KeyDefinition(text: 'r', label: 'r'),
      KeyDefinition(text: 't', label: 't'),
      KeyDefinition(text: 'y', label: 'y'),
      KeyDefinition(text: 'u', label: 'u'),
      KeyDefinition(text: 'i', label: 'i'),
      KeyDefinition(text: 'o', label: 'o'),
      KeyDefinition(text: 'p', label: 'p'),
    ],
    // Row 2
    [
      KeyDefinition(text: 'a', label: 'a'),
      KeyDefinition(text: 's', label: 's'),
      KeyDefinition(text: 'd', label: 'd'),
      KeyDefinition(text: 'f', label: 'f'),
      KeyDefinition(text: 'g', label: 'g'),
      KeyDefinition(text: 'h', label: 'h'),
      KeyDefinition(text: 'j', label: 'j'),
      KeyDefinition(text: 'k', label: 'k'),
      KeyDefinition(text: 'l', label: 'l'),
    ],
    // Row 3
    [
      KeyDefinition(text: 'z', label: 'z'),
      KeyDefinition(text: 'x', label: 'x'),
      KeyDefinition(text: 'c', label: 'c'),
      KeyDefinition(text: 'v', label: 'v'),
      KeyDefinition(text: 'b', label: 'b'),
      KeyDefinition(text: 'n', label: 'n'),
      KeyDefinition(text: 'm', label: 'm'),
      KeyDefinition.action(
        action: KeyAction.backspace,
        label: '⌫',
        flex: 1.5,
      ),
    ],
    // Row 4
    [
      KeyDefinition.action(
        action: KeyAction.switchLayout,
        label: '🌐',
        flex: 1.5,
      ),
      KeyDefinition(text: ',', label: ',', flex: 1.0),
      KeyDefinition(
        text: ' ',
        label: 'space',
        action: KeyAction.space,
        flex: 3.5,
      ),
      KeyDefinition(text: '.', label: '.', flex: 1.0),
      KeyDefinition.action(
        action: KeyAction.newline,
        label: '↵',
        flex: 1.5,
      ),
    ],
  ];
}
