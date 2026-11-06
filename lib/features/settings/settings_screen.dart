import 'package:material_ui/material_ui.dart';
import 'package:mongol/mongol.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/localization/mongol_strings.dart';
import '../about/about_screen.dart';
import '../converter/code_converter_screen.dart';
import '../editor/dialogs/font_chooser_dialog.dart';
import '../history/history_screen.dart';

class SettingsScreen extends StatefulWidget {
  final String currentFontFamily;
  final ValueChanged<String> onFontChanged;

  const SettingsScreen({
    super.key,
    required this.currentFontFamily,
    required this.onFontChanged,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late String _fontFamily;
  bool _showBainu = true;

  static const String _helpUrl = 'http://www.studymongolian.net/apps/chimee/zh/chimee-help/';

  @override
  void initState() {
    super.initState();
    _fontFamily = widget.currentFontFamily;
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _showBainu = prefs.getBool('show_bainu') ?? true;
    });
  }

  Future<void> _setShowBainu(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('show_bainu', value);
    setState(() => _showBainu = value);
  }

  Future<void> _launchHelp() async {
    final uri = Uri.parse(_helpUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: MongolText(
          MongolStrings.settings,
          style: TextStyle(fontFamily: _fontFamily, fontSize: 20.0),
        ),
      ),
      body: ListView(
        children: [
          // 1. Font Family
          ListTile(
            leading: const Icon(Icons.font_download_outlined),
            title: Text(
              MongolStrings.font,
              style: TextStyle(fontFamily: _fontFamily, fontSize: 18.0),
            ),
            subtitle: Text(_fontFamily),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              showDialog<void>(
                context: context,
                builder: (_) => FontChooserDialog(
                  currentFontFamily: _fontFamily,
                  uiFontFamily: _fontFamily,
                  onSelectFont: (font) async {
                    setState(() => _fontFamily = font);
                    widget.onFontChanged(font);
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setString('default_font_family', font);
                  },
                ),
              );
            },
          ),
          const Divider(height: 1),

          // 2. Show Bainu Share Toggle
          SwitchListTile(
            secondary: const Icon(Icons.chat_bubble_outline),
            title: Text(
              MongolStrings.shareBainu,
              style: TextStyle(fontFamily: _fontFamily, fontSize: 18.0),
            ),
            value: _showBainu,
            onChanged: _setShowBainu,
          ),
          const Divider(height: 1),

          // 3. Message History
          ListTile(
            leading: const Icon(Icons.history),
            title: Text(
              MongolStrings.history,
              style: TextStyle(fontFamily: _fontFamily, fontSize: 18.0),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => HistoryScreen(fontFamily: _fontFamily),
                ),
              );
            },
          ),
          const Divider(height: 1),

          // 4. Code Converter
          ListTile(
            leading: const Icon(Icons.sync_alt),
            title: Text(
              MongolStrings.codeConverter,
              style: TextStyle(fontFamily: _fontFamily, fontSize: 18.0),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CodeConverterScreen(fontFamily: _fontFamily),
                ),
              );
            },
          ),
          const Divider(height: 1),

          // 5. Help (Browser)
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: Text(
              MongolStrings.help,
              style: TextStyle(fontFamily: _fontFamily, fontSize: 18.0),
            ),
            trailing: const Icon(Icons.open_in_new),
            onTap: _launchHelp,
          ),
          const Divider(height: 1),

          // 6. About Screen
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(
              MongolStrings.about,
              style: TextStyle(fontFamily: _fontFamily, fontSize: 18.0),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AboutScreen(fontFamily: _fontFamily),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
