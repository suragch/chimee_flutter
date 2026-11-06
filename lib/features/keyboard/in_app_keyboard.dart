import 'dart:math' as math;
import 'package:material_ui/material_ui.dart';
import 'package:mongol_code/mongol_code.dart';

import '../../core/database/app_database.dart';
import 'candidate_bar.dart';
import 'keyboard_types.dart';
import 'layouts/aeiou_layout.dart';
import 'layouts/cyrillic_layout.dart';
import 'layouts/english_layout.dart';
import 'layouts/punctuation_layout.dart';
import 'layouts/qwerty_layout.dart';
import 'widgets/keyboard_key_button.dart';
import 'widgets/keyboard_navigation_view.dart';
import 'widgets/keyboard_emoji_view.dart';
import 'widgets/vertical_candidate_bar.dart';

class InAppKeyboard extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback? onSubmitted;
  final VoidCallback? onHideKeyboard;
  final String fontFamily;

  const InAppKeyboard({
    super.key,
    required this.controller,
    this.onSubmitted,
    this.onHideKeyboard,
    this.fontFamily = 'Qagan',
  });

  @override
  State<InAppKeyboard> createState() => _InAppKeyboardState();
}

class _InAppKeyboardState extends State<InAppKeyboard> {
  KeyboardLayoutType _currentLayout = KeyboardLayoutType.aeiou;
  bool _isNavMode = false;
  bool _isEmojiMode = false;
  String _composingUnicode = '';
  int _composingMenksoftLength = 0;
  List<DictionaryWord> _candidates = [];

  // Common Mongolian suffixes preceded by NNBS (\u202F)
  static const List<String> commonSuffixes = [
    '\u202F\u1836\u1822\u1828', //  ᠶᠢᠨ
    '\u202F\u1824\u1828',       //  ᠤᠨ
    '\u202F\u1826\u1828',       //  ᠦᠨ
    '\u202F\u1836\u1822',       //  ᠶᠢ
    '\u202F\u1833\u1824',       //  ᠳᠤ
    '\u202F\u1833\u1826',       //  ᠳᠦ
    '\u202F\u1832\u1824',       //  ᠲᠤ
    '\u202F\u1832\u1826',       //  ᠲᠦ
    '\u202F\u182A\u1820\u1837', //  ᠪᠠᠷ
    '\u202F\u182A\u1821\u1837', //  ᠪᠡᠷ
    '\u202F\u1822\u1836\u1820\u1837', //  ᠢᠶᠠᠷ
    '\u202F\u1822\u1836\u1821\u1837', //  ᠢᠶᠡᠷ
    '\u202F\u1832\u1820\u1822', //  ᠲᠠᠢ
    '\u202F\u1832\u1821\u1822', //  ᠲᠡᠢ
    '\u202F\u182A\u1820\u1828', //  ᠪᠠᠨ
    '\u202F\u182A\u1821\u1828', //  ᠪᠡᠨ
  ];

  void _toggleNavMode() {
    setState(() {
      _isNavMode = !_isNavMode;
      if (_isNavMode) _isEmojiMode = false;
    });
  }

  void _toggleEmojiMode() {
    setState(() {
      _isEmojiMode = !_isEmojiMode;
      if (_isEmojiMode) _isNavMode = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: _buildKeyboardLayout(),
    );
  }

  Widget _buildKeyboardLayout() {
    final List<List<KeyDefinition>> rows;
    switch (_currentLayout) {
      case KeyboardLayoutType.aeiou:
        rows = AeiouLayout.rows;
        break;
      case KeyboardLayoutType.qwerty:
        rows = QwertyLayout.rows;
        break;
      case KeyboardLayoutType.cyrillic:
        rows = CyrillicLayout.rows;
        break;
      case KeyboardLayoutType.english:
        rows = EnglishLayout.rows;
        break;
      case KeyboardLayoutType.punctuation:
        rows = PunctuationLayout.rows;
        break;
    }

    final keyRowsColumn = Column(
      mainAxisSize: MainAxisSize.min,
      children: rows.map((row) => _buildRow(row)).toList(),
    );

    final Widget activeRightContent;
    if (_isNavMode) {
      activeRightContent = KeyboardNavigationView(
        onDirectionalNav: _handleDirectionalNav,
        onClose: _toggleNavMode,
      );
    } else if (_isEmojiMode) {
      activeRightContent = KeyboardEmojiView(
        onEmojiSelected: _handleInputCharacter,
        onBackspace: _handleBackspace,
        onSpace: () => _handleInputCharacter(' '),
        onDone: _toggleEmojiMode,
      );
    } else {
      activeRightContent = keyRowsColumn;
    }

    if (_currentLayout == KeyboardLayoutType.aeiou) {
      return Container(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              VerticalCandidateBar(
                candidates: (_isNavMode || _isEmojiMode) ? const [] : _candidates,
                onCandidateSelected: _onCandidateSelected,
                onHideKeyboard: widget.onHideKeyboard,
                onToggleNavigation: _toggleNavMode,
                onToggleEmoji: _toggleEmojiMode,
                isNavMode: _isNavMode,
                isEmojiMode: _isEmojiMode,
                fontFamily: widget.fontFamily,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 4.0),
                  child: activeRightContent,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_currentLayout == KeyboardLayoutType.qwerty) {
      return Container(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CandidateBar(
              candidates: (_isNavMode || _isEmojiMode) ? const [] : _candidates,
              onSelectWord: _onCandidateSelected,
              onHideKeyboard: widget.onHideKeyboard,
              onToggleNavigation: _toggleNavMode,
              onToggleEmoji: _toggleEmojiMode,
              isNavMode: _isNavMode,
              isEmojiMode: _isEmojiMode,
              fontFamily: widget.fontFamily,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
              child: activeRightContent,
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 6.0),
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: activeRightContent,
    );
  }

  Widget _buildRow(List<KeyDefinition> row) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        children: row.map((keyDef) {
          return Expanded(
            flex: (keyDef.flex * 10).round(),
            child: KeyboardKeyButton(
              keyDef: keyDef,
              onPressed: _handleKeyTap,
              onLongPress: _handleKeyLongPress,
              fontFamily: widget.fontFamily,
            ),
          );
        }).toList(),
      ),
    );
  }

  void _handleKeyTap(KeyDefinition keyDef) {
    switch (keyDef.action) {
      case KeyAction.input:
        if (keyDef.text != null) {
          _handleInputCharacter(keyDef.text!);
        }
        break;
      case KeyAction.backspace:
        _handleBackspace();
        break;
      case KeyAction.space:
        _commitComposingWord(appendSpace: true);
        break;
      case KeyAction.newline:
        _commitComposingWord(appendSpace: false);
        _insertTextAtCursor('\n');
        widget.onSubmitted?.call();
        break;
      case KeyAction.switchLayout:
        _showLayoutPicker();
        break;
      case KeyAction.openSuffixChooser:
        _showSuffixPicker();
        break;
    }
  }

  void _handleKeyLongPress(KeyDefinition keyDef) {
    if (keyDef.action == KeyAction.space) {
      _showSuffixPicker();
      return;
    }
    if (keyDef.swipeUpText != null) {
      _handleInputCharacter(keyDef.swipeUpText!);
    }
  }

  void _handleDirectionalNav(NavDirection direction) {
    final text = widget.controller.text;
    final selection = widget.controller.selection;
    int offset = selection.baseOffset >= 0 ? selection.baseOffset : text.length;

    switch (direction) {
      case NavDirection.up:
        offset = math.max(0, offset - 1);
        break;
      case NavDirection.down:
        offset = math.min(text.length, offset + 1);
        break;
      case NavDirection.left:
        final prevNewline = text.lastIndexOf('\n', math.max(0, offset - 1));
        if (prevNewline >= 0) {
          final beforePrev = text.lastIndexOf('\n', math.max(0, prevNewline - 1));
          final lineLength = offset - (prevNewline + 1);
          final startOfPrevLine = beforePrev >= 0 ? beforePrev + 1 : 0;
          final prevLineLength = prevNewline - startOfPrevLine;
          offset = startOfPrevLine + math.min(lineLength, prevLineLength);
        } else {
          offset = 0;
        }
        break;
      case NavDirection.right:
        final currentLineStart = text.lastIndexOf('\n', math.max(0, offset - 1));
        final startOfCurrent = currentLineStart >= 0 ? currentLineStart + 1 : 0;
        final colOffset = offset - startOfCurrent;
        final nextNewline = text.indexOf('\n', offset);
        if (nextNewline >= 0) {
          final afterNextNewline = nextNewline + 1;
          final endOfNextLine = text.indexOf('\n', afterNextNewline);
          final nextLineLength = (endOfNextLine >= 0 ? endOfNextLine : text.length) - afterNextNewline;
          offset = afterNextNewline + math.min(colOffset, nextLineLength);
        } else {
          offset = text.length;
        }
        break;
      case NavDirection.lineStart:
        final lastNl = text.lastIndexOf('\n', math.max(0, offset - 1));
        offset = lastNl >= 0 ? lastNl + 1 : 0;
        break;
      case NavDirection.lineEnd:
        final nextNl = text.indexOf('\n', offset);
        offset = nextNl >= 0 ? nextNl : text.length;
        break;
    }

    widget.controller.selection = TextSelection.collapsed(offset: offset);
  }

  void _handleInputCharacter(String char) {
    final isMongolLetter = _isMongolianLetter(char.codeUnitAt(0));

    if (isMongolLetter) {
      _composingUnicode += char;
      final shapedMenksoft = convertUnicodeToMenksoft(_composingUnicode);
      _replaceComposingText(shapedMenksoft);
      _updateCandidates(shapedMenksoft);
    } else {
      _commitComposingWord(appendSpace: false);
      _insertTextAtCursor(char);
    }
  }

  void _replaceComposingText(String newText) {
    final text = widget.controller.text;
    final selection = widget.controller.selection;

    final cursor = selection.baseOffset >= 0 ? selection.baseOffset : text.length;
    final replaceStart = cursor - _composingMenksoftLength;

    if (replaceStart >= 0 && replaceStart <= text.length) {
      final prefix = text.substring(0, replaceStart);
      final suffix = text.substring(cursor);
      widget.controller.text = prefix + newText + suffix;
      _composingMenksoftLength = newText.length;
      widget.controller.selection = TextSelection.collapsed(
        offset: replaceStart + newText.length,
      );
    } else {
      _insertTextAtCursor(newText);
      _composingMenksoftLength = newText.length;
    }
  }

  void _insertTextAtCursor(String text) {
    final currentText = widget.controller.text;
    final selection = widget.controller.selection;

    if (selection.baseOffset >= 0 && selection.extentOffset >= 0) {
      final start = selection.start;
      final end = selection.end;
      final newText = currentText.replaceRange(start, end, text);
      widget.controller.text = newText;
      widget.controller.selection = TextSelection.collapsed(offset: start + text.length);
    } else {
      widget.controller.text = currentText + text;
      widget.controller.selection = TextSelection.collapsed(offset: widget.controller.text.length);
    }
  }

  void _handleBackspace() {
    if (_composingUnicode.isNotEmpty) {
      _composingUnicode = _composingUnicode.substring(0, _composingUnicode.length - 1);
      if (_composingUnicode.isEmpty) {
        _replaceComposingText('');
        _composingMenksoftLength = 0;
        setState(() => _candidates = []);
      } else {
        final shapedMenksoft = convertUnicodeToMenksoft(_composingUnicode);
        _replaceComposingText(shapedMenksoft);
        _updateCandidates(shapedMenksoft);
      }
    } else {
      final text = widget.controller.text;
      final selection = widget.controller.selection;
      if (text.isEmpty) return;

      if (!selection.isCollapsed && selection.start >= 0) {
        final start = selection.start;
        final end = selection.end;
        widget.controller.text = text.replaceRange(start, end, '');
        widget.controller.selection = TextSelection.collapsed(offset: start);
      } else {
        final cursor = selection.baseOffset >= 0 ? selection.baseOffset : text.length;
        if (cursor > 0) {
          widget.controller.text = text.replaceRange(cursor - 1, cursor, '');
          widget.controller.selection = TextSelection.collapsed(offset: cursor - 1);
        }
      }
    }
  }

  void _commitComposingWord({bool appendSpace = false}) {
    if (_composingUnicode.isNotEmpty) {
      final shapedMenksoft = convertUnicodeToMenksoft(_composingUnicode);
      AppDatabase.instance.insertOrIncrementWord(shapedMenksoft);
      _composingUnicode = '';
      _composingMenksoftLength = 0;
      setState(() => _candidates = []);
    }
    if (appendSpace) {
      _insertTextAtCursor(' ');
    }
  }

  void _onCandidateSelected(String menksoftWord) {
    _replaceComposingText(menksoftWord);
    AppDatabase.instance.insertOrIncrementWord(menksoftWord);
    _insertTextAtCursor(' ');
    _composingUnicode = '';
    _composingMenksoftLength = 0;
    setState(() => _candidates = []);
  }

  Future<void> _updateCandidates(String menksoftPrefix) async {
    final words = await AppDatabase.instance.getDictionaryWords(
      prefix: menksoftPrefix,
      limit: 15,
    );
    if (mounted) {
      setState(() => _candidates = words);
    }
  }

  bool _isMongolianLetter(int codeUnit) {
    return (codeUnit >= 0x1820 && codeUnit <= 0x1842) ||
        codeUnit == 0x200D || // ZWJ
        codeUnit == 0x200C || // ZWNJ
        codeUnit == 0x180A;   // NIRUGU
  }

  void _showLayoutPicker() {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.keyboard),
                title: const Text('ᠴᠠᠭᠠᠨ ᠲᠣᠯᠤᠭᠠᠢ (AEIOU)'),
                selected: _currentLayout == KeyboardLayoutType.aeiou,
                onTap: () {
                  setState(() => _currentLayout = KeyboardLayoutType.aeiou);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.keyboard_alt_outlined),
                title: const Text('ᠮᠣᠩᠭᠣᠯ QWERTY'),
                selected: _currentLayout == KeyboardLayoutType.qwerty,
                onTap: () {
                  setState(() => _currentLayout = KeyboardLayoutType.qwerty);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.language),
                title: const Text('Монгол Кирилл'),
                selected: _currentLayout == KeyboardLayoutType.cyrillic,
                onTap: () {
                  setState(() => _currentLayout = KeyboardLayoutType.cyrillic);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.abc),
                title: const Text('English (Latin)'),
                selected: _currentLayout == KeyboardLayoutType.english,
                onTap: () {
                  setState(() => _currentLayout = KeyboardLayoutType.english);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.tag),
                title: const Text('ᠲᠡᠮᠳᠡᠭ (Punctuation)'),
                selected: _currentLayout == KeyboardLayoutType.punctuation,
                onTap: () {
                  setState(() => _currentLayout = KeyboardLayoutType.punctuation);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSuffixPicker() {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Text(
                    'ᠳᠠᠭᠠᠪᠤᠷᠢ (Suffixes)',
                    style: TextStyle(
                      fontFamily: widget.fontFamily,
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: commonSuffixes.map((suffixUnicode) {
                    final menksoftSuffix = convertUnicodeToMenksoft(suffixUnicode);
                    return ActionChip(
                      label: Text(
                        menksoftSuffix,
                        style: TextStyle(
                          fontFamily: widget.fontFamily,
                          fontSize: 18.0,
                        ),
                      ),
                      onPressed: () {
                        _commitComposingWord(appendSpace: false);
                        _insertTextAtCursor(menksoftSuffix);
                        Navigator.pop(context);
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
