import '../keyboard_types.dart';

class QwertyLayout {
  static const List<List<KeyDefinition>> rows = [
    // Row 1
    [
      KeyDefinition(text: '\u1834', swipeUpText: '\u1842', label: 'ᠴ', subLabel: 'ᠼ'),
      KeyDefinition(text: '\u1838', label: 'ᠸ'),
      KeyDefinition(text: '\u1821', swipeUpText: '\u1827', label: 'ᠡ', subLabel: 'ᠡᠡ'),
      KeyDefinition(text: '\u1837', swipeUpText: '\u183F', label: 'ᠷ', subLabel: 'ᠿ'),
      KeyDefinition(text: '\u1832', label: 'ᠲ'),
      KeyDefinition(text: '\u1836', label: 'ᠶ'),
      KeyDefinition(text: '\u1826', label: 'ᠦ'),
      KeyDefinition(text: '\u1822', label: 'ᠢ'),
      KeyDefinition(text: '\u1825', label: 'ᠥ'),
      KeyDefinition(text: '\u182B', label: 'ᠫ'),
    ],
    // Row 2
    [
      KeyDefinition(text: '\u1820', label: 'ᠠ'),
      KeyDefinition(text: '\u1830', label: 'ᠰ'),
      KeyDefinition(text: '\u1833', label: 'ᠳ'),
      KeyDefinition(text: '\u1839', label: 'ᠹ'),
      KeyDefinition(text: '\u182D', label: 'ᠭ'),
      KeyDefinition(text: '\u182C', swipeUpText: '\u183E', label: 'ᠬ', subLabel: 'ᠾ'),
      KeyDefinition(text: '\u1835', swipeUpText: '\u1841', label: 'ᠵ', subLabel: 'ᠵᠢ'),
      KeyDefinition(text: '\u183A', label: 'ᠺ'),
      KeyDefinition(text: '\u182F', swipeUpText: '\u1840', label: 'ᠯ', subLabel: 'ᡀ'),
      KeyDefinition(text: '\u1829', label: 'ᠩ'),
    ],
    // Row 3
    [
      KeyDefinition(text: '\u200D', swipeUpText: '\u180A', label: '|', subLabel: '᠊', flex: 1.2),
      KeyDefinition(text: '\u183D', swipeUpText: '\u183C', label: 'ᠽ', subLabel: 'ᠼ'),
      KeyDefinition(text: '\u1831', label: 'ᠱ'),
      KeyDefinition(text: '\u1823', label: 'ᠣ'),
      KeyDefinition(text: '\u1824', label: 'ᠤ'),
      KeyDefinition(text: '\u182A', label: 'ᠪ'),
      KeyDefinition(text: '\u1828', label: 'ᠨ'),
      KeyDefinition(text: '\u182E', label: 'ᠮ'),
      KeyDefinition.action(
        action: KeyAction.backspace,
        label: '⌫',
        flex: 1.4,
      ),
    ],
    // Row 4
    [
      KeyDefinition.action(
        action: KeyAction.switchLayout,
        label: '🌐',
        flex: 1.3,
      ),
      KeyDefinition(text: '!', label: '!', flex: 0.9),
      KeyDefinition(text: '\u1802', label: '᠂', flex: 0.9),
      KeyDefinition(
        text: ' ',
        label: 'ᠶ᠋ᠢ ᠳᠤ ᠤᠨ',
        action: KeyAction.space,
        flex: 3.5,
      ),
      KeyDefinition(text: '\u1804', label: '᠄', flex: 0.9),
      KeyDefinition(text: '\uFE16', label: '︖', flex: 0.9),
      KeyDefinition.action(
        action: KeyAction.newline,
        label: '↵',
        flex: 1.3,
      ),
    ],
  ];
}
