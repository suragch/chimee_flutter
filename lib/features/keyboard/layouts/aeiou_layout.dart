import '../keyboard_types.dart';

class AeiouLayout {
  static const List<List<KeyDefinition>> rows = [
    // Row 1
    [
      KeyDefinition(text: '\u1820', label: 'ᠠ', subLabel: '᠎ᠠ'),
      KeyDefinition(text: '\u1821', swipeUpText: '\u1827', label: 'ᠡ', subLabel: 'ᠡᠡ'),
      KeyDefinition(text: '\u1822', label: 'ᠢ'),
      KeyDefinition(text: '\u1823', label: 'ᠣ'),
      KeyDefinition(text: '\u1824', label: 'ᠤ'),
    ],
    // Row 2
    [
      KeyDefinition(text: '\u1828', swipeUpText: '\u1829', label: 'ᠨ', subLabel: 'ᠩ'),
      KeyDefinition(text: '\u182A', swipeUpText: '\u182B', label: 'ᠪ', subLabel: 'ᠫ'),
      KeyDefinition(text: '\u182C', swipeUpText: '\u183E', label: 'ᠬ', subLabel: 'ᠾ'),
      KeyDefinition(text: '\u182D', swipeUpText: '\u183A', label: 'ᠭ', subLabel: 'ᠺ'),
      KeyDefinition(text: '\u182E', label: 'ᠮ'),
      KeyDefinition(text: '\u182F', swipeUpText: '\u1840', label: 'ᠯ', subLabel: 'ᡀ'),
    ],
    // Row 3
    [
      KeyDefinition(text: '\u1830', swipeUpText: '\u1831', label: 'ᠰ', subLabel: 'ᠱ'),
      KeyDefinition(text: '\u1833', swipeUpText: '\u1832', label: 'ᠳ', subLabel: 'ᠲ'),
      KeyDefinition(text: '\u1834', swipeUpText: '\u183D', label: 'ᠴ', subLabel: 'ᠽ'),
      KeyDefinition(text: '\u1835', swipeUpText: '\u1841', label: 'ᠵ', subLabel: 'ᠵᠢ'),
      KeyDefinition(text: '\u1836', swipeUpText: '\u1838', label: 'ᠶ', subLabel: 'ᠸ'),
      KeyDefinition(text: '\u1837', swipeUpText: '\u183F', label: 'ᠷ', subLabel: 'ᠿ'),
    ],
    // Row 4
    [
      KeyDefinition.action(
        action: KeyAction.switchLayout,
        label: '🌐',
        flex: 1.2,
      ),
      KeyDefinition(text: '\u1802', label: '᠂', flex: 1.0),
      KeyDefinition(
        text: ' ',
        label: 'ᠶ᠋ᠢ ᠳᠤ ᠤᠨ',
        action: KeyAction.space,
        flex: 3.0,
      ),
      KeyDefinition.action(
        action: KeyAction.newline,
        label: '↵',
        flex: 1.2,
      ),
      KeyDefinition.action(
        action: KeyAction.backspace,
        label: '⌫',
        flex: 1.2,
      ),
    ],
  ];
}
