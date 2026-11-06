import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:chimee/features/editor/card_auto_sizer.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const TextStyle testStyle = TextStyle(fontSize: 24.0, fontFamily: 'Qagan');
  const double maxViewportHeight = 600.0;
  const double maxViewportWidth = 400.0;

  group('CardAutoSizer Base Constraints', () {
    test('Empty text produces base dimensions (75.0 x 150.0)', () {
      final size = CardAutoSizer.computeSize(
        text: '',
        textStyle: testStyle,
        maxViewportHeight: maxViewportHeight,
        maxViewportWidth: maxViewportWidth,
        currentHeight: 150.0,
        isManualScaling: false,
      );

      expect(size.height, equals(150.0));
      expect(size.width, equals(75.0));
    });

    test('Short single-column text stays at minimum height 150.0', () {
      final size = CardAutoSizer.computeSize(
        text: 'ᠰᠠᠢᠨ',
        textStyle: testStyle,
        maxViewportHeight: maxViewportHeight,
        maxViewportWidth: maxViewportWidth,
        currentHeight: 150.0,
        isManualScaling: false,
      );

      expect(size.height, equals(150.0));
      expect(size.width, greaterThanOrEqualTo(75.0));
    });
  });

  group('CardAutoSizer Stepping Dynamics', () {
    test('Height increments by 50.0 dp steps when text columns expand', () {
      // Long vertical text with multiple columns
      final buffer = StringBuffer();
      for (int i = 0; i < 20; i++) {
        buffer.writeln('ᠰᠠᠢᠨ ᠪᠠᠢᠨ᠎ᠠ ᠤᠤ ᠴᠢᠮᠡᠭᠡ ᠠᠪᠤᠷᠠᠭᠴᠢ');
      }
      final multiColumnText = buffer.toString();

      final size = CardAutoSizer.computeSize(
        text: multiColumnText,
        textStyle: testStyle,
        maxViewportHeight: maxViewportHeight,
        maxViewportWidth: maxViewportWidth,
        currentHeight: 150.0,
        isManualScaling: false,
      );

      // Height should step up from 150.0 in increments of 50.0
      expect(size.height, greaterThan(150.0));
      expect((size.height - 150.0) % 50.0, equals(0.0));
      expect(size.height, lessThanOrEqualTo(maxViewportHeight));
    });

    test('Height decrements in 50.0 dp steps when text shrinks', () {
      // If previous height was 400.0, but current text only needs 1 column
      final size = CardAutoSizer.computeSize(
        text: 'ᠴᠢᠮᠡᠭᠡ',
        textStyle: testStyle,
        maxViewportHeight: maxViewportHeight,
        maxViewportWidth: maxViewportWidth,
        currentHeight: 400.0,
        isManualScaling: false,
      );

      // Height should decrement down towards 150.0
      expect(size.height, lessThan(400.0));
      expect((size.height - 150.0) % 50.0, equals(0.0));
      expect(size.height, equals(150.0));
    });
  });

  group('CardAutoSizer Viewport Clamping & Edge Cases', () {
    test('Width never exceeds maxViewportWidth - 32.0', () {
      final hugeBuffer = StringBuffer();
      for (int i = 0; i < 200; i++) {
        hugeBuffer.writeln('ᠮᠣᠩᠭᠣᠯ ᠪᠢᠴᠢᠭ ᠤᠷᠲᠤ ᠦᠭᠡ ᠲᠠᠰᠤᠷᠠᠯᠲᠠ ᠦᠭᠡᠢ');
      }

      final size = CardAutoSizer.computeSize(
        text: hugeBuffer.toString(),
        textStyle: testStyle,
        maxViewportHeight: 300.0,
        maxViewportWidth: 200.0, // Narrow viewport
        currentHeight: 150.0,
        isManualScaling: false,
      );

      expect(size.width, lessThanOrEqualTo(200.0 - 32.0));
      expect(size.height, lessThanOrEqualTo(300.0));
    });

    test('Compact screen does not throw ArgumentError on clamping bounds', () {
      // Extremely compact viewport where maxViewportWidth - 32.0 < 75.0
      expect(
        () => CardAutoSizer.computeSize(
          text: 'ᠮᠣᠩᠭᠣᠯ',
          textStyle: testStyle,
          maxViewportHeight: 120.0,
          maxViewportWidth: 80.0, // 80 - 32 = 48 < 75
          currentHeight: 100.0,
          isManualScaling: false,
        ),
        returnsNormally,
      );
    });

    test('Manual scaling clamps to min/max heights and enforces proportion', () {
      final manualSize = CardAutoSizer.computeSize(
        text: 'ᠰᠠᠢᠨ',
        textStyle: testStyle,
        maxViewportHeight: 500.0,
        maxViewportWidth: 400.0,
        currentHeight: 150.0,
        isManualScaling: true,
        manualDesiredHeight: 320.0,
      );

      expect(manualSize.height, equals(320.0));
      expect(manualSize.width, greaterThanOrEqualTo(320.0 / 2.0));
    });
  });

  group('CardAutoSizer Scroll Threshold', () {
    test('canScroll is false while dimensions have not maxed out', () {
      // 1. Short text at min height
      final result1 = CardAutoSizer.computeResult(
        text: 'ᠰᠠᠢᠨ ᠪᠠᠢᠨ᠎ᠠ ᠤᠤ',
        textStyle: testStyle,
        maxViewportHeight: maxViewportHeight,
        maxViewportWidth: maxViewportWidth,
        currentHeight: 150.0,
        isManualScaling: false,
      );
      expect(result1.canScroll, isFalse);

      // 2. Growing text when height is still less than maxViewportHeight
      final buffer = StringBuffer();
      for (int i = 0; i < 5; i++) {
        buffer.writeln('ᠰᠠᠢᠨ ᠪᠠᠢᠨ᠎ᠠ ᠤᠤ ᠴᠢᠮᠡᠭᠡ');
      }
      final result2 = CardAutoSizer.computeResult(
        text: buffer.toString(),
        textStyle: testStyle,
        maxViewportHeight: maxViewportHeight,
        maxViewportWidth: maxViewportWidth,
        currentHeight: 150.0,
        isManualScaling: false,
      );
      expect(result2.cardSize.height, lessThan(maxViewportHeight));
      expect(result2.canScroll, isFalse);
    });

    test('canScroll is true strictly when both vertical and horizontal limits are maxed out', () {
      final hugeBuffer = StringBuffer();
      for (int i = 0; i < 100; i++) {
        hugeBuffer.writeln('ᠮᠣᠩᠭᠣᠯ ᠪᠢᠴᠢᠭ ᠤᠷᠲᠤ ᠦᠭᠡ ᠲᠠᠰᠤᠷᠠᠯᠲᠠ ᠦᠭᠡᠢ');
      }

      final result = CardAutoSizer.computeResult(
        text: hugeBuffer.toString(),
        textStyle: testStyle,
        maxViewportHeight: 300.0,
        maxViewportWidth: 200.0, // 200 - 32 = 168 maxCardWidth
        currentHeight: 150.0,
        isManualScaling: false,
      );

      expect(result.cardSize.height, equals(300.0));
      expect(result.cardSize.width, equals(200.0 - 32.0));
      expect(result.contentWidth, greaterThan(200.0 - 32.0));
      expect(result.canScroll, isTrue);
    });
  });
}
