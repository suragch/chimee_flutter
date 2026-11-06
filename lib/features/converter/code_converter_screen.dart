import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:mongol/mongol.dart';
import 'package:mongol_code/mongol_code.dart';

import '../../core/localization/mongol_strings.dart';

class CodeConverterScreen extends StatefulWidget {
  final String fontFamily;

  const CodeConverterScreen({
    super.key,
    this.fontFamily = 'Qagan',
  });

  @override
  State<CodeConverterScreen> createState() => _CodeConverterScreenState();
}

class _CodeConverterScreenState extends State<CodeConverterScreen> {
  final TextEditingController _inputController = TextEditingController();
  String _convertedOutput = '';
  bool _unicodeToMenksoft = true;

  @override
  void initState() {
    super.initState();
    _inputController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _inputController.removeListener(_onTextChanged);
    _inputController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final input = _inputController.text;
    if (input.isEmpty) {
      setState(() => _convertedOutput = '');
      return;
    }

    setState(() {
      if (_unicodeToMenksoft) {
        _convertedOutput = convertUnicodeToMenksoft(input);
      } else {
        _convertedOutput = convertMenksoftToUnicode(input);
      }
    });
  }

  void _toggleDirection() {
    setState(() {
      _unicodeToMenksoft = !_unicodeToMenksoft;
      _inputController.text = _convertedOutput;
    });
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null) {
      _inputController.text = data!.text!;
    }
  }

  Future<void> _copyOutput() async {
    if (_convertedOutput.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: _convertedOutput));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(MongolStrings.textCopied)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: MongolText(
          MongolStrings.codeConverter,
          style: TextStyle(fontFamily: widget.fontFamily, fontSize: 20.0),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Mode Banner
            Card(
              elevation: 0,
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        _unicodeToMenksoft
                            ? '${MongolStrings.converterUnicode}  ➔  ${MongolStrings.converterMenksoft}'
                            : '${MongolStrings.converterMenksoft}  ➔  ${MongolStrings.converterUnicode}',
                        style: TextStyle(
                          fontFamily: widget.fontFamily,
                          fontWeight: FontWeight.bold,
                          fontSize: 14.0,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.swap_horiz),
                      onPressed: _toggleDirection,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16.0),

            // Input section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _unicodeToMenksoft
                      ? MongolStrings.converterUnicode
                      : MongolStrings.converterMenksoft,
                  style: TextStyle(
                    fontFamily: widget.fontFamily,
                    fontWeight: FontWeight.w600,
                    fontSize: 14.0,
                  ),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.paste, size: 16),
                  label: Text(
                    MongolStrings.converterPaste,
                    style: TextStyle(fontFamily: widget.fontFamily, fontSize: 14.0),
                  ),
                  onPressed: _pasteFromClipboard,
                ),
              ],
            ),
            const SizedBox(height: 6.0),
            TextField(
              controller: _inputController,
              maxLines: 5,
              style: TextStyle(
                fontFamily: _unicodeToMenksoft ? null : widget.fontFamily,
                fontSize: 16.0,
              ),
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                suffixIcon: _inputController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => _inputController.clear(),
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 24.0),

            // Output section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _unicodeToMenksoft
                      ? MongolStrings.converterMenksoft
                      : MongolStrings.converterUnicode,
                  style: TextStyle(
                    fontFamily: widget.fontFamily,
                    fontWeight: FontWeight.w600,
                    fontSize: 14.0,
                  ),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.copy, size: 16),
                  label: Text(
                    MongolStrings.converterCopy,
                    style: TextStyle(fontFamily: widget.fontFamily, fontSize: 14.0),
                  ),
                  onPressed: _convertedOutput.isNotEmpty ? _copyOutput : null,
                ),
              ],
            ),
            const SizedBox(height: 6.0),
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).dividerColor),
                borderRadius: BorderRadius.circular(8.0),
                color: Theme.of(context).colorScheme.surfaceContainerLow,
              ),
              constraints: const BoxConstraints(minHeight: 120),
              child: SelectableText(
                _convertedOutput,
                style: TextStyle(
                  fontFamily: _unicodeToMenksoft ? widget.fontFamily : null,
                  fontSize: 16.0,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
