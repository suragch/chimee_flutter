import 'dart:math' as math;
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:mongol/mongol.dart';
import 'package:mongol_code/mongol_code.dart';

import '../../core/database/app_database.dart';
import '../../core/localization/mongol_strings.dart';
import '../favorites/favorites_screen.dart';
import '../keyboard/in_app_keyboard.dart';
import '../open/open_screen.dart';
import '../photo_overlay/photo_overlay_screen.dart';
import '../save/save_screen.dart';
import '../settings/settings_screen.dart';
import '../sharing/export_router.dart';
import 'card_auto_sizer.dart';
import 'dialogs/color_chooser_dialog.dart';
import 'dialogs/font_chooser_dialog.dart';
import 'scale_gesture_container.dart';
import 'widgets/floating_editor_card.dart';
import 'widgets/floating_restore_keyboard_button.dart';

class EditorScreen extends StatefulWidget {
  const EditorScreen({super.key});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  Color _bgColor = const Color(0xFFFFFFFF);
  Color _textColor = const Color(0xFF222222);
  double _fontSize = 24.0;
  double _editorHeight = 150.0;
  String _fontFamily = 'Qagan';
  bool _isKeyboardVisible = true;
  String _lastSavedContent = '';
  String _lastSavedHistory = '';

  bool _isManualScaling = false;
  double? _manualDesiredHeight;

  @override
  void initState() {
    super.initState();
    // Default placeholder in Menksoft code
    final initialText = convertUnicodeToMenksoft('ᠰᠠᠢᠨ ᠪᠠᠢᠨ᠎ᠠ ᠤᠤ');
    _controller.text = initialText;
    _lastSavedContent = initialText;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final shortestSide = MediaQuery.sizeOf(context).shortestSide;
    if (shortestSide < 600) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  bool get _hasUnsavedContent {
    return _controller.text.isNotEmpty && _controller.text != _lastSavedContent;
  }

  // --- Persistence & History ---

  Future<void> _saveToHistory(String message) async {
    if (message.isEmpty || message == _lastSavedHistory) return;
    await AppDatabase.instance.insertHistory(
      HistoryItem(
        timestamp: DateTime.now().millisecondsSinceEpoch,
        message: message,
      ),
    );
    _lastSavedHistory = message;
  }

  // --- Formatting Dialogs ---

  void _openColorChooserDialog() {
    showDialog<void>(
      context: context,
      builder: (_) => ColorChooserDialog(
        currentBgColor: _bgColor,
        currentTextColor: _textColor,
        fontFamily: _fontFamily,
        onColorsSelected: (bg, fg) {
          setState(() {
            _bgColor = bg;
            _textColor = fg;
          });
        },
      ),
    );
  }

  void _openFontChooserDialog() {
    showDialog<void>(
      context: context,
      builder: (_) => FontChooserDialog(
        currentFontFamily: _fontFamily,
        onSelectFont: (font) {
          setState(() => _fontFamily = font);
        },
      ),
    );
  }

  // --- Export Actions ---

  Future<void> _shareToWeChat() async {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      _showEmptyToast();
      return;
    }
    await _saveToHistory(text);
    ExportRouter.instance.shareToWeChat(
      text,
      options: CardRenderOptions(
        backgroundColor: _bgColor,
        textColor: _textColor,
        fontSize: _fontSize,
        fontFamily: _fontFamily,
        cardHeight: _editorHeight,
      ),
    );
  }

  Future<void> _shareToBainu() async {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      _showEmptyToast();
      return;
    }
    await _saveToHistory(text);
    ExportRouter.instance.shareToBainu(text);
  }

  Future<void> _shareToOther() async {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      _showEmptyToast();
      return;
    }
    await _saveToHistory(text);
    ExportRouter.instance.shareAsUnicode(text);
  }

  void _showEmptyToast() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text(MongolStrings.inputWindowEmpty)),
    );
  }

  // --- Context Menu Builder ---

  Widget _buildContextMenu(BuildContext context, MongolEditableTextState editableTextState) {
    final buttonItems = editableTextState.contextMenuButtonItems;

    buttonItems.add(
      ContextMenuButtonItem(
        type: ContextMenuButtonType.custom,
        label: MongolStrings.color,
        onPressed: () {
          ContextMenuController.removeAny();
          _openColorChooserDialog();
        },
      ),
    );

    buttonItems.add(
      ContextMenuButtonItem(
        type: ContextMenuButtonType.custom,
        label: MongolStrings.font,
        onPressed: () {
          ContextMenuController.removeAny();
          _openFontChooserDialog();
        },
      ),
    );

    return MongolAdaptiveTextSelectionToolbar.buttonItems(
      buttonItems: buttonItems,
      anchors: editableTextState.contextMenuAnchors,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Chimee',
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          // 1. Share Action Menu
          MongolPopupMenuButton<String>(
            icon: const Icon(Icons.share),
            tooltip: MongolStrings.shareOther,
            onSelected: (value) {
              switch (value) {
                case 'wechat':
                  _shareToWeChat();
                  break;
                case 'bainu':
                  _shareToBainu();
                  break;
                case 'other':
                  _shareToOther();
                  break;
              }
            },
            itemBuilder: (context) => [
              MongolPopupMenuItem(
                value: 'wechat',
                child: MongolText(
                  MongolStrings.shareWeChat,
                  style: TextStyle(fontFamily: _fontFamily, fontSize: 16.0),
                ),
              ),
              MongolPopupMenuItem(
                value: 'bainu',
                child: MongolText(
                  MongolStrings.shareBainu,
                  style: TextStyle(fontFamily: _fontFamily, fontSize: 16.0),
                ),
              ),
              MongolPopupMenuItem(
                value: 'other',
                child: MongolText(
                  MongolStrings.shareOther,
                  style: TextStyle(fontFamily: _fontFamily, fontSize: 16.0),
                ),
              ),
            ],
          ),

          // 2. Photo Overlay Action
          IconButton(
            icon: const Icon(Icons.insert_photo_outlined),
            tooltip: 'Photo',
            onPressed: () {
              if (_controller.text.trim().isEmpty) {
                _showEmptyToast();
                return;
              }
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PhotoOverlayScreen(
                    initialText: _controller.text,
                    fontFamily: _fontFamily,
                  ),
                ),
              );
            },
          ),

          // 3. Favorites Action
          IconButton(
            icon: const Icon(Icons.star_outline),
            tooltip: 'Favorites',
            onPressed: () async {
              final selectedText = await Navigator.push<String>(
                context,
                MaterialPageRoute(
                  builder: (_) => FavoritesScreen(fontFamily: _fontFamily),
                ),
              );
              if (selectedText != null) {
                setState(() {
                  _controller.text = selectedText;
                  _lastSavedContent = selectedText;
                });
              }
            },
          ),

          // 4. Overflow Menu (Open/Save and Settings)
          MongolPopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            tooltip: MongolStrings.settings,
            onSelected: (value) async {
              switch (value) {
                case 'open':
                  await Navigator.push<void>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OpenScreen(
                        fontFamily: _fontFamily,
                        onFileLoaded: (content) {
                          setState(() {
                            _controller.text = content;
                            _lastSavedContent = content;
                          });
                        },
                      ),
                    ),
                  );
                  break;
                case 'save':
                  await Navigator.push<void>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SaveScreen(
                        fontFamily: _fontFamily,
                        textToSave: _controller.text,
                        onSaveSuccess: (_) {
                          setState(() {
                            _lastSavedContent = _controller.text;
                          });
                        },
                      ),
                    ),
                  );
                  break;
                case 'settings':
                  await Navigator.push<void>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SettingsScreen(
                        currentFontFamily: _fontFamily,
                        onFontChanged: (font) {
                          setState(() => _fontFamily = font);
                        },
                      ),
                    ),
                  );
                  break;
              }
            },
            itemBuilder: (context) => [
              if (_hasUnsavedContent)
                MongolPopupMenuItem(
                  value: 'save',
                  child: MongolText(
                    MongolStrings.save,
                    style: TextStyle(fontFamily: _fontFamily, fontSize: 16.0),
                  ),
                )
              else
                MongolPopupMenuItem(
                  value: 'open',
                  child: MongolText(
                    MongolStrings.open,
                    style: TextStyle(fontFamily: _fontFamily, fontSize: 16.0),
                  ),
                ),
              MongolPopupMenuItem(
                value: 'settings',
                child: MongolText(
                  MongolStrings.settings,
                  style: TextStyle(fontFamily: _fontFamily, fontSize: 16.0),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Upper Stage: Editor Canvas Stage (#E4E4E4 Background)
          Expanded(
            child: Container(
              color: const Color(0xFFE4E4E4),
              child: Stack(
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final sizingResult = CardAutoSizer.computeResult(
                        text: _controller.text,
                        textStyle: TextStyle(
                          fontFamily: _fontFamily,
                          fontSize: _fontSize,
                        ),
                        maxViewportHeight: math.max(150.0, constraints.maxHeight - 32.0),
                        maxViewportWidth: constraints.maxWidth,
                        currentHeight: _editorHeight,
                        isManualScaling: _isManualScaling,
                        manualDesiredHeight: _manualDesiredHeight,
                      );
                      _editorHeight = sizingResult.cardSize.height;

                      return Center(
                        child: ScaleGestureContainer(
                          currentFontSize: _fontSize,
                          currentHeight: _editorHeight,
                          onFontSizeChanged: (newSize) => setState(() => _fontSize = newSize),
                          onHeightChanged: (newHeight) {
                            setState(() {
                              _isManualScaling = true;
                              _manualDesiredHeight = newHeight;
                              _editorHeight = newHeight;
                            });
                          },
                          child: FloatingEditorCard(
                            cardSize: sizingResult.cardSize,
                            backgroundColor: _bgColor,
                            canScroll: sizingResult.canScroll,
                            contentWidth: sizingResult.contentWidth,
                            child: MongolTextField(
                              controller: _controller,
                              focusNode: _focusNode,
                              maxLines: null,
                              expands: true,
                              keyboardType: TextInputType.none,
                              showCursor: true,
                              decoration: null,
                              scrollPhysics: sizingResult.canScroll
                                  ? const ClampingScrollPhysics()
                                  : const NeverScrollableScrollPhysics(),
                              style: TextStyle(
                                fontFamily: _fontFamily,
                                fontSize: _fontSize,
                                color: _textColor,
                                height: 1.5,
                              ),
                              contextMenuBuilder: _buildContextMenu,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  if (!_isKeyboardVisible)
                    Positioned(
                      right: 16.0,
                      bottom: 16.0,
                      child: FloatingRestoreKeyboardButton(
                        onPressed: () {
                          setState(() => _isKeyboardVisible = true);
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Lower Stage: Keyboard Host Stage (#DEDEDE Background)
          if (_isKeyboardVisible)
            Container(
              color: const Color(0xFFDEDEDE),
              alignment: Alignment.center,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800.0),
                child: InAppKeyboard(
                  controller: _controller,
                  fontFamily: _fontFamily,
                  onSubmitted: () => _saveToHistory(_controller.text),
                  onHideKeyboard: () {
                    setState(() => _isKeyboardVisible = false);
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}
