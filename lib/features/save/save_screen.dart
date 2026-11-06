import 'dart:io';
import 'package:material_ui/material_ui.dart';
import 'package:mongol/mongol.dart';
import 'package:path_provider/path_provider.dart';
import '../../core/localization/mongol_strings.dart';

/// Text file save screen prompting for file name, handling overwrite confirmation,
/// and saving editor text as UTF-8 .txt to the app documents directory.
class SaveScreen extends StatefulWidget {
  const SaveScreen({
    super.key,
    required this.textToSave,
    required this.onSaveSuccess,
    this.fontFamily = 'Qagan',
  });

  final String textToSave;
  final ValueChanged<String> onSaveSuccess;
  final String fontFamily;

  @override
  State<SaveScreen> createState() => _SaveScreenState();
}

class _SaveScreenState extends State<SaveScreen> {
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final rawName = _nameController.text.trim();
    if (rawName.isEmpty) return;

    final sanitizedName = rawName.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
    final dir = await getApplicationDocumentsDirectory();
    final filePath = '${dir.path}/$sanitizedName.txt';
    final targetFile = File(filePath);

    if (await targetFile.exists()) {
      if (!mounted) return;
      final shouldOverwrite = await showDialog<bool>(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: MongolText(
              MongolStrings.overwriteAlert,
              style: TextStyle(fontFamily: widget.fontFamily, fontSize: 18.0),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(
                  MongolStrings.cancel,
                  style: TextStyle(fontFamily: widget.fontFamily, fontSize: 16.0),
                ),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(
                  MongolStrings.overwriteYes,
                  style: TextStyle(fontFamily: widget.fontFamily, fontSize: 16.0),
                ),
              ),
            ],
          );
        },
      );

      if (shouldOverwrite != true) return;
    }

    try {
      await targetFile.writeAsString(widget.textToSave);
      widget.onSaveSuccess(sanitizedName);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(MongolStrings.saved)),
        );
        Navigator.pop(context);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(MongolStrings.couldntBeSaved)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: MongolText(
          MongolStrings.save,
          style: TextStyle(fontFamily: widget.fontFamily, fontSize: 20.0),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              autofocus: true,
              decoration: InputDecoration(
                labelText: MongolStrings.fileName,
                labelStyle: TextStyle(fontFamily: widget.fontFamily, fontSize: 18.0),
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.edit_document),
              ),
              style: TextStyle(fontFamily: widget.fontFamily, fontSize: 18.0),
              onSubmitted: (_) => _handleSave(),
            ),
            const SizedBox(height: 24.0),
            FilledButton.icon(
              icon: const Icon(Icons.save),
              label: Text(
                MongolStrings.save,
                style: TextStyle(fontFamily: widget.fontFamily, fontSize: 18.0),
              ),
              onPressed: _handleSave,
            ),
          ],
        ),
      ),
    );
  }
}
