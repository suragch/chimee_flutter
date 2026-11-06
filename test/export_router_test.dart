import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:chimee/features/sharing/export_router.dart';
import 'package:mongol_code/mongol_code.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ExportRouter payload formatting', () {
    test('prepareBainuPayload preserves raw Menksoft text', () {
      const menksoftSample = ' ᠨ';
      final payload = ExportRouter.instance.prepareBainuPayload(menksoftSample);
      expect(payload, equals(menksoftSample));
    });

    test('prepareUnicodePayload converts Menksoft text to Unicode', () {
      // Modern mongol_code converts Unicode to Menksoft and vice versa
      const sampleUnicode = 'ᠮᠣᠩᠭᠣᠯ';
      final menksoftText = convertUnicodeToMenksoft(sampleUnicode);
      expect(menksoftText, isNotEmpty);

      final unicodeResult = ExportRouter.instance.prepareUnicodePayload(menksoftText);
      expect(unicodeResult, isNotEmpty);
      // First character of Unicode Mongol should be in U+1800 block
      expect(unicodeResult.codeUnitAt(0), inInclusiveRange(0x1800, 0x18AF));
    });

    test('renderCardImage returns valid PNG image bytes', () async {
      const menksoftSample = ' ᠨ';
      final bytes = await ExportRouter.instance.renderCardImage(
        menksoftSample,
        options: const CardRenderOptions(
          cardHeight: 400.0,
          minWidth: 300.0,
        ),
      );

      expect(bytes, isA<Uint8List>());
      expect(bytes.length, greaterThan(100));

      // PNG file signature: 89 50 4E 47 0D 0A 1A 0A
      const pngHeader = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A];
      expect(bytes.sublist(0, 8), equals(pngHeader));
    });
  });
}
