import '../keyboard_types.dart';

class CyrillicLayout {
  static const List<List<KeyDefinition>> rows = [
    // Row 1
    [
      KeyDefinition(text: 'ф', label: 'ф'),
      KeyDefinition(text: 'ц', label: 'ц'),
      KeyDefinition(text: 'у', label: 'у'),
      KeyDefinition(text: 'ж', label: 'ж'),
      KeyDefinition(text: 'э', label: 'э'),
      KeyDefinition(text: 'н', label: 'н'),
      KeyDefinition(text: 'г', label: 'г'),
      KeyDefinition(text: 'ш', label: 'ш'),
      KeyDefinition(text: 'ү', label: 'ү'),
      KeyDefinition(text: 'з', label: 'з'),
      KeyDefinition(text: 'к', label: 'к'),
      KeyDefinition(text: 'ъ', label: 'ъ'),
    ],
    // Row 2
    [
      KeyDefinition(text: 'й', label: 'й'),
      KeyDefinition(text: 'ы', label: 'ы'),
      KeyDefinition(text: 'б', label: 'б'),
      KeyDefinition(text: 'ө', label: 'ө'),
      KeyDefinition(text: 'а', label: 'а'),
      KeyDefinition(text: 'х', label: 'х'),
      KeyDefinition(text: 'р', label: 'р'),
      KeyDefinition(text: 'о', label: 'о'),
      KeyDefinition(text: 'л', label: 'л'),
      KeyDefinition(text: 'д', label: 'д'),
      KeyDefinition(text: 'п', label: 'п'),
      KeyDefinition(text: 'е', label: 'е'),
    ],
    // Row 3
    [
      KeyDefinition(text: 'я', label: 'я'),
      KeyDefinition(text: 'ч', label: 'ч'),
      KeyDefinition(text: 'ё', label: 'ё'),
      KeyDefinition(text: 'с', label: 'с'),
      KeyDefinition(text: 'м', label: 'м'),
      KeyDefinition(text: 'и', label: 'и'),
      KeyDefinition(text: 'т', label: 'т'),
      KeyDefinition(text: 'ь', label: 'ь'),
      KeyDefinition(text: 'в', label: 'в'),
      KeyDefinition(text: 'ю', label: 'ю'),
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
