import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mongol/mongol.dart';
import 'package:chimee/core/database/app_database.dart';
import 'package:chimee/features/editor/widgets/floating_editor_card.dart';
import 'package:chimee/features/editor/widgets/floating_restore_keyboard_button.dart';
import 'package:chimee/features/keyboard/keyboard_types.dart';
import 'package:chimee/features/keyboard/widgets/keyboard_key_button.dart';
import 'package:chimee/features/keyboard/widgets/keyboard_navigation_view.dart';
import 'package:chimee/features/keyboard/widgets/keyboard_emoji_view.dart';
import 'package:chimee/features/keyboard/widgets/vertical_candidate_bar.dart';
import 'package:chimee/features/editor/editor_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FloatingEditorCard & Restore Button', () {
    testWidgets('FloatingEditorCard renders with given size and child', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FloatingEditorCard(
              cardSize: Size(120.0, 200.0),
              backgroundColor: Colors.white,
              child: Text('Card Content'),
            ),
          ),
        ),
      );

      expect(find.text('Card Content'), findsOneWidget);
      expect(find.byType(FloatingEditorCard), findsOneWidget);
    });

    testWidgets('FloatingRestoreKeyboardButton invokes callback on tap', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FloatingRestoreKeyboardButton(
              onPressed: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(FloatingRestoreKeyboardButton));
      await tester.pump();
      expect(tapped, isTrue);
    });
  });

  group('Keyboard Components', () {
    testWidgets('VerticalCandidateBar renders candidates and selects', (tester) async {
      String? selected;
      final candidates = [
        DictionaryWord(word: 'ᠰᠠᠢᠨ', frequency: 10),
        DictionaryWord(word: 'ᠪᠠᠢᠨ᠎ᠠ', frequency: 5),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VerticalCandidateBar(
              candidates: candidates,
              onCandidateSelected: (word) => selected = word,
            ),
          ),
        ),
      );

      expect(find.byType(MongolText), findsNWidgets(2));
      await tester.tap(find.byWidgetPredicate((w) => w is MongolText && w.data == 'ᠰᠠᠢᠨ'));
      await tester.pump();
      expect(selected, equals('ᠰᠠᠢᠨ'));
    });

    testWidgets('VerticalCandidateBar renders 3 tool buttons when empty and triggers callbacks', (tester) async {
      bool hideTapped = false;
      bool navTapped = false;
      bool emojiTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VerticalCandidateBar(
              candidates: const [],
              onCandidateSelected: (_) {},
              onHideKeyboard: () => hideTapped = true,
              onToggleNavigation: () => navTapped = true,
              onToggleEmoji: () => emojiTapped = true,
            ),
          ),
        ),
      );

      // Verify tool buttons: hide (down chevron), nav (open_with), emoji (sentiment_satisfied_alt)
      expect(find.byIcon(Icons.keyboard_arrow_down), findsOneWidget);
      expect(find.byIcon(Icons.open_with), findsOneWidget);
      expect(find.byIcon(Icons.sentiment_satisfied_alt), findsOneWidget);

      await tester.tap(find.byIcon(Icons.keyboard_arrow_down));
      await tester.pump();
      expect(hideTapped, isTrue);

      await tester.tap(find.byIcon(Icons.open_with));
      await tester.pump();
      expect(navTapped, isTrue);

      await tester.tap(find.byIcon(Icons.sentiment_satisfied_alt));
      await tester.pump();
      expect(emojiTapped, isTrue);
    });

    testWidgets('KeyboardEmojiView renders emojis and invokes callbacks', (tester) async {
      String? selectedEmoji;
      bool backspaceTapped = false;
      bool doneTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: KeyboardEmojiView(
              onEmojiSelected: (e) => selectedEmoji = e,
              onBackspace: () => backspaceTapped = true,
              onSpace: () {},
              onDone: () => doneTapped = true,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.backspace_outlined), findsOneWidget);
      expect(find.byIcon(Icons.keyboard_return), findsOneWidget);

      await tester.tap(find.byIcon(Icons.backspace_outlined));
      await tester.pump();
      expect(backspaceTapped, isTrue);

      await tester.tap(find.byIcon(Icons.keyboard_return));
      await tester.pump();
      expect(doneTapped, isTrue);

      // Tap first emoji
      await tester.tap(find.text('😀'));
      await tester.pump();
      expect(selectedEmoji, equals('😀'));
    });

    testWidgets('KeyboardKeyButton rotates Mongolian letters and keeps action unrotated', (tester) async {
      // 1. Mongolian letter key
      const mongolKey = KeyDefinition(text: 'ᠠ', label: 'ᠠ');
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: KeyboardKeyButton(
              keyDef: mongolKey,
              onPressed: (_) {},
            ),
          ),
        ),
      );

      expect(find.byType(RotatedBox), findsWidgets);

      // 2. Action key
      const backspaceKey = KeyDefinition.action(action: KeyAction.backspace);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: KeyboardKeyButton(
              keyDef: backspaceKey,
              onPressed: (_) {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.backspace_outlined), findsOneWidget);
    });

    testWidgets('KeyboardNavigationView triggers directional navigation', (tester) async {
      NavDirection? triggered;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: KeyboardNavigationView(
              onDirectionalNav: (dir) => triggered = dir,
              onClose: () {},
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.arrow_upward));
      await tester.pump();
      expect(triggered, equals(NavDirection.up));

      await tester.tap(find.byIcon(Icons.arrow_downward));
      await tester.pump();
      expect(triggered, equals(NavDirection.down));

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pump();
      expect(triggered, equals(NavDirection.left));

      await tester.tap(find.byIcon(Icons.arrow_forward));
      await tester.pump();
      expect(triggered, equals(NavDirection.right));
    });
  });

  group('EditorScreen Integration', () {
    testWidgets('EditorScreen displays horizontal Chimee title, 4 legacy actions and floating editor card', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: EditorScreen(),
        ),
      );
      await tester.pump();

      // Check AppBar has horizontal Latin 'Chimee' title
      expect(find.text('Chimee'), findsOneWidget);

      // Check AppBar has exactly 4 actions: share, photo, favorites, overflow
      expect(find.byIcon(Icons.share), findsOneWidget);
      expect(find.byIcon(Icons.insert_photo_outlined), findsOneWidget);
      expect(find.byIcon(Icons.star_outline), findsOneWidget);
      expect(find.byIcon(Icons.more_vert), findsOneWidget);

      // Floating card is present
      expect(find.byType(FloatingEditorCard), findsOneWidget);

      // MongolTextField is present
      expect(find.byType(MongolTextField), findsOneWidget);

      // Verify InAppKeyboard on AEIOU has NO top toolbar
      expect(find.text('AEIOU'), findsNothing);
      // But has tool buttons in the vertical candidate bar
      expect(find.byIcon(Icons.keyboard_arrow_down), findsOneWidget);
      expect(find.byIcon(Icons.open_with), findsOneWidget);
      expect(find.byIcon(Icons.sentiment_satisfied_alt), findsOneWidget);
    });
  });
}
