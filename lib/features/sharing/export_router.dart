import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:material_ui/material_ui.dart';
import 'package:mongol/mongol.dart';
import 'package:mongol_code/mongol_code.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class CardRenderOptions {
  final Color backgroundColor;
  final Color textColor;
  final double fontSize;
  final String fontFamily;
  final double cardHeight;
  final double minWidth;
  final double padding;

  const CardRenderOptions({
    this.backgroundColor = const Color(0xFFFBF6EC), // Elegant paper/parchment tone
    this.textColor = const Color(0xFF222222),
    this.fontSize = 24.0,
    this.fontFamily = 'Qagan',
    this.cardHeight = 600.0,
    this.minWidth = 380.0,
    this.padding = 32.0,
  });
}

class ExportRouter {
  static final ExportRouter instance = ExportRouter();

  /// Prepares payload for Bainu: Bainu requires raw Menksoft PUA code.
  String prepareBainuPayload(String menksoftText) {
    return menksoftText;
  }

  /// Prepares payload for standard applications: Converts Menksoft PUA to standard Unicode.
  String prepareUnicodePayload(String menksoftText) {
    return convertMenksoftToUnicode(menksoftText);
  }

  /// Renders a vertical Mongolian card to PNG bytes off-screen.
  /// Automatically expands width to prevent horizontal clipping when multi-column text wraps.
  Future<Uint8List> renderCardImage(
    String menksoftText, {
    CardRenderOptions options = const CardRenderOptions(),
  }) async {
    final textSpan = TextSpan(
      text: menksoftText,
      style: TextStyle(
        fontFamily: options.fontFamily,
        fontSize: options.fontSize,
        color: options.textColor,
        height: 1.5,
      ),
    );

    final painter = MongolTextPainter(
      text: textSpan,
    );

    final maxContentHeight = options.cardHeight - (options.padding * 2);
    painter.layout(
      minHeight: 0,
      maxHeight: maxContentHeight > 0 ? maxContentHeight : double.infinity,
    );

    final contentWidth = painter.width;
    final contentHeight = painter.height;

    final totalWidth = math.max(options.minWidth, contentWidth + (options.padding * 2));
    final totalHeight = math.max(options.cardHeight, contentHeight + (options.padding * 2));

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(
      recorder,
      Rect.fromLTWH(0, 0, totalWidth, totalHeight),
    );

    // Draw background
    final bgPaint = Paint()..color = options.backgroundColor;
    canvas.drawRect(Rect.fromLTWH(0, 0, totalWidth, totalHeight), bgPaint);

    // Paint text offset by padding
    painter.paint(canvas, Offset(options.padding, options.padding));

    final picture = recorder.endRecording();
    final image = await picture.toImage(
      totalWidth.ceil(),
      totalHeight.ceil(),
    );
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    return byteData!.buffer.asUint8List();
  }

  /// Shares Menksoft text directly to Bainu or system share.
  Future<ShareResult> shareToBainu(
    String menksoftText, {
    Rect? sharePositionOrigin,
  }) async {
    final payload = prepareBainuPayload(menksoftText);
    return await SharePlus.instance.share(
      ShareParams(
        text: payload,
        subject: 'Chimee Bainu Message',
        sharePositionOrigin: sharePositionOrigin,
      ),
    );
  }

  /// Converts Menksoft text to standard Unicode and shares via system sheet.
  Future<ShareResult> shareAsUnicode(
    String menksoftText, {
    Rect? sharePositionOrigin,
  }) async {
    final payload = prepareUnicodePayload(menksoftText);
    return await SharePlus.instance.share(
      ShareParams(
        text: payload,
        subject: 'Chimee Message',
        sharePositionOrigin: sharePositionOrigin,
      ),
    );
  }

  /// Renders text to an image card and shares via system sheet (e.g. for WeChat, Photos, etc.).
  Future<ShareResult> shareAsCardImage(
    String menksoftText, {
    CardRenderOptions options = const CardRenderOptions(),
    Rect? sharePositionOrigin,
  }) async {
    final pngBytes = await renderCardImage(menksoftText, options: options);
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/chimee_card_${DateTime.now().millisecondsSinceEpoch}.png');
    await file.writeAsBytes(pngBytes);

    return await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'image/png')],
        text: 'Chimee Card',
        sharePositionOrigin: sharePositionOrigin,
      ),
    );
  }

  /// Shares to WeChat by generating the unconstrained vertical text card image.
  Future<ShareResult> shareToWeChat(
    String menksoftText, {
    CardRenderOptions options = const CardRenderOptions(),
    Rect? sharePositionOrigin,
  }) async {
    return await shareAsCardImage(
      menksoftText,
      options: options,
      sharePositionOrigin: sharePositionOrigin,
    );
  }
}
