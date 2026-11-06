import 'dart:io';
import 'dart:ui' as ui;
import 'package:material_ui/material_ui.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mongol/mongol.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/localization/mongol_strings.dart';

class PhotoOverlayScreen extends StatefulWidget {
  final String initialText;
  final String fontFamily;

  const PhotoOverlayScreen({
    super.key,
    required this.initialText,
    this.fontFamily = 'Qagan',
  });

  @override
  State<PhotoOverlayScreen> createState() => _PhotoOverlayScreenState();
}

class _PhotoOverlayScreenState extends State<PhotoOverlayScreen> {
  final GlobalKey _boundaryKey = GlobalKey();
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  Offset _textOffset = const Offset(100, 100);
  double _scale = 1.0;
  double _rotation = 0.0;
  Color _textColor = Colors.white;
  Color _textBgColor = Colors.black45;

  @override
  void initState() {
    super.initState();
    _pickImage();
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _imageFile = File(picked.path));
    }
  }

  Future<void> _exportAndShare() async {
    try {
      final boundary =
          _boundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;

      final bytes = byteData.buffer.asUint8List();
      final tempDir = await getTemporaryDirectory();
      final filePath =
          '${tempDir.path}/chimee_photo_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File(filePath);
      await file.writeAsBytes(bytes);

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: 'image/png')],
          text: MongolStrings.appName,
        ),
      );
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
          'ᠵᠢᠷᠤᠭ ᠲᠡᠭᠡᠷ᠎ᠡ',
          style: TextStyle(fontFamily: widget.fontFamily, fontSize: 20.0),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.photo_library_outlined),
            onPressed: _pickImage,
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: _imageFile == null ? null : _exportAndShare,
          ),
        ],
      ),
      body: _imageFile == null
          ? Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.image),
                label: Text(
                  'ᠵᠢᠷᠤᠭ ᠰᠣᠩᠭᠣᠬᠤ',
                  style: TextStyle(fontFamily: widget.fontFamily, fontSize: 18.0),
                ),
                onPressed: _pickImage,
              ),
            )
          : Stack(
              children: [
                Center(
                  child: RepaintBoundary(
                    key: _boundaryKey,
                    child: Stack(
                      children: [
                        Image.file(
                          _imageFile!,
                          fit: BoxFit.contain,
                        ),
                        Positioned(
                          left: _textOffset.dx,
                          top: _textOffset.dy,
                          child: GestureDetector(
                            onScaleUpdate: (details) {
                              setState(() {
                                _textOffset += details.focalPointDelta;
                                if (details.scale != 1.0) {
                                  _scale = (_scale * details.scale).clamp(0.5, 3.0);
                                }
                                if (details.rotation != 0.0) {
                                  _rotation += details.rotation;
                                }
                              });
                            },
                            child: Transform(
                              alignment: Alignment.center,
                              transform: Matrix4.identity()
                                ..scaleByDouble(_scale, _scale, 1.0, 1.0)
                                ..rotateZ(_rotation),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10.0,
                                  vertical: 6.0,
                                ),
                                decoration: BoxDecoration(
                                  color: _textBgColor,
                                  borderRadius: BorderRadius.circular(6.0),
                                ),
                                child: MongolText(
                                  widget.initialText.isNotEmpty
                                      ? widget.initialText
                                      : 'ᠮᠣᠩᠭᠣᠯ',
                                  style: TextStyle(
                                    fontFamily: widget.fontFamily,
                                    fontSize: 22.0,
                                    color: _textColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 24,
                  left: 16,
                  right: 16,
                  child: Card(
                    color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          TextButton.icon(
                            icon: const Icon(Icons.format_color_text),
                            label: Text(
                              MongolStrings.textColor,
                              style: TextStyle(fontFamily: widget.fontFamily, fontSize: 16.0),
                            ),
                            onPressed: () {
                              setState(() {
                                _textColor = _textColor == Colors.white
                                    ? Colors.black
                                    : _textColor == Colors.black
                                        ? Colors.amber
                                        : Colors.white;
                              });
                            },
                          ),
                          TextButton.icon(
                            icon: const Icon(Icons.format_paint_outlined),
                            label: Text(
                              MongolStrings.background,
                              style: TextStyle(fontFamily: widget.fontFamily, fontSize: 16.0),
                            ),
                            onPressed: () {
                              setState(() {
                                _textBgColor = _textBgColor == Colors.black45
                                    ? Colors.white70
                                    : _textBgColor == Colors.white70
                                        ? Colors.transparent
                                        : Colors.black45;
                              });
                            },
                          ),
                          TextButton.icon(
                            icon: const Icon(Icons.refresh),
                            label: Text(
                              MongolStrings.clearAll,
                              style: TextStyle(fontFamily: widget.fontFamily, fontSize: 16.0),
                            ),
                            onPressed: () {
                              setState(() {
                                _scale = 1.0;
                                _rotation = 0.0;
                                _textOffset = const Offset(100, 100);
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
