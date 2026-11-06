import 'package:material_ui/material_ui.dart';
import 'package:mongol/mongol.dart';
import 'core/database/legacy_migrator.dart';
import 'features/editor/editor_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Execute one-time legacy database migration or initial seeding
  try {
    final migrator = LegacyMigrator();
    await migrator.executeMigration();
  } catch (e) {
    debugPrint('Migration notice: $e');
  }

  runApp(const ChimeeApp());
}

class ChimeeApp extends StatelessWidget {
  const ChimeeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chimee (ᠴᠢᠮᠡᠭᠡ)',
      debugShowCheckedModeBanner: false,
      builder: (context, child) => MongolTextEditingShortcuts(child: child),
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFC49A45), // Warm Mongolian gold/amber
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.dark,
          seedColor: const Color(0xFFC49A45),
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
        ),
      ),
      themeMode: ThemeMode.system,
      home: const EditorScreen(),
    );
  }
}
