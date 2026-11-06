import 'dart:io';
import 'package:material_ui/material_ui.dart';
import 'package:mongol/mongol.dart';
import 'package:path_provider/path_provider.dart';
import '../../core/localization/mongol_strings.dart';

/// Text file open manager screen listing saved .txt documents from the app documents directory.
class OpenScreen extends StatefulWidget {
  const OpenScreen({
    super.key,
    required this.onFileLoaded,
    this.fontFamily = 'Qagan',
  });

  final ValueChanged<String> onFileLoaded;
  final String fontFamily;

  @override
  State<OpenScreen> createState() => _OpenScreenState();
}

class _OpenScreenState extends State<OpenScreen> {
  List<FileSystemEntity> _files = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFiles();
  }

  Future<void> _loadFiles() async {
    setState(() => _isLoading = true);
    try {
      final dir = await getApplicationDocumentsDirectory();
      final entities = dir.listSync().where((e) {
        return e is File && e.path.endsWith('.txt');
      }).toList();
      // Sort newest first
      entities.sort((a, b) {
        return b.statSync().modified.compareTo(a.statSync().modified);
      });
      if (mounted) {
        setState(() {
          _files = entities;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _openFile(File file) async {
    try {
      final content = await file.readAsString();
      widget.onFileLoaded(content);
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(MongolStrings.couldNotOpenFile)),
        );
      }
    }
  }

  Future<void> _deleteFile(File file) async {
    try {
      await file.delete();
      _loadFiles();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: MongolText(
          MongolStrings.open,
          style: TextStyle(fontFamily: widget.fontFamily, fontSize: 20.0),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _files.isEmpty
              ? Center(
                  child: MongolText(
                    MongolStrings.directoryEmpty,
                    style: TextStyle(
                      fontFamily: widget.fontFamily,
                      fontSize: 22.0,
                      color: Colors.grey,
                    ),
                  ),
                )
              : ListView.separated(
                  itemCount: _files.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final file = _files[index] as File;
                    final fileName = file.uri.pathSegments.last.replaceAll('.txt', '');
                    final modified = file.statSync().modified;
                    final dateStr =
                        '${modified.year}-${modified.month.toString().padLeft(2, '0')}-${modified.day.toString().padLeft(2, '0')}';

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      title: Text(
                        fileName,
                        style: TextStyle(
                          fontFamily: widget.fontFamily,
                          fontSize: 18.0,
                        ),
                      ),
                      subtitle: Text(
                        dateStr,
                        style: const TextStyle(fontSize: 12.0, color: Colors.grey),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                        onPressed: () => _deleteFile(file),
                      ),
                      onTap: () => _openFile(file),
                    );
                  },
                ),
    );
  }
}
