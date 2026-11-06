import '../keyboard_types.dart';

class PunctuationLayout {
  static const List<List<KeyDefinition>> rows = [
    // Row 1 (Numbers)
    [
      KeyDefinition(text: '1', label: '1'),
      KeyDefinition(text: '2', label: '2'),
      KeyDefinition(text: '3', label: '3'),
      KeyDefinition(text: '4', label: '4'),
      KeyDefinition(text: '5', label: '5'),
      KeyDefinition(text: '6', label: '6'),
      KeyDefinition(text: '7', label: '7'),
      KeyDefinition(text: '8', label: '8'),
      KeyDefinition(text: '9', label: '9'),
      KeyDefinition(text: '0', label: '0'),
    ],
    // Row 2 (Mongolian Digits)
    [
      KeyDefinition(text: '\u1810', label: '᠐'),
      KeyDefinition(text: '\u1811', label: '᠑'),
      KeyDefinition(text: '\u1812', label: '᠒'),
      KeyDefinition(text: '\u1813', label: '᠓'),
      KeyDefinition(text: '\u1814', label: '᠔'),
      KeyDefinition(text: '\u1815', label: '᠕'),
      KeyDefinition(text: '\u1816', label: '᠖'),
      KeyDefinition(text: '\u1817', label: '᠗'),
      KeyDefinition(text: '\u1818', label: '᠘'),
      KeyDefinition(text: '\u1819', label: '᠙'),
    ],
    // Row 3 (Punctuation and brackets)
    [
      KeyDefinition(text: '\u1800', label: '᠀'),
      KeyDefinition(text: '\u1801', label: '᠁'),
      KeyDefinition(text: '\u1802', label: '᠂'),
      KeyDefinition(text: '\u1803', label: '᠃'),
      KeyDefinition(text: '\u1804', label: '᠄'),
      KeyDefinition(text: '\u1805', label: '᠅'),
      KeyDefinition(text: '\u300A', label: '《'),
      KeyDefinition(text: '\u300B', label: '》'),
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
      KeyDefinition(text: '\uFE16', label: '︖', flex: 1.0),
      KeyDefinition(
        text: ' ',
        label: 'space',
        action: KeyAction.space,
        flex: 3.5,
      ),
      KeyDefinition(text: '\uFE15', label: '︕', flex: 1.0),
      KeyDefinition.action(
        action: KeyAction.newline,
        label: '↵',
        flex: 1.5,
      ),
    ],
  ];
}
