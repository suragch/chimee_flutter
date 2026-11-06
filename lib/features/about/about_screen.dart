import 'package:material_ui/material_ui.dart';
import 'package:mongol/mongol.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/localization/mongol_strings.dart';

class AboutScreen extends StatelessWidget {
  final String fontFamily;

  const AboutScreen({
    super.key,
    this.fontFamily = 'Qagan',
  });

  static const String _siteUrl = 'http://www.studymongolian.net/apps/chimee/zh/';
  static const String _contactUrl = 'http://www.studymongolian.net/contact-zh/';

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _shareApp() {
    SharePlus.instance.share(
      ShareParams(
        text: 'Chimee 1.0.0\n$_siteUrl',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: MongolText(
          MongolStrings.about,
          style: TextStyle(fontFamily: fontFamily, fontSize: 20.0),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // App icon or branding
            const Icon(Icons.edit_note, size: 72.0, color: Colors.blueGrey),
            const SizedBox(height: 16.0),

            // App Name & Version in Traditional Mongolian
            Center(
              child: Text(
                'Chimee 1.0.0',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            const SizedBox(height: 8.0),
            Center(
              child: Text(
                MongolStrings.siteName,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
              ),
            ),
            const SizedBox(height: 40.0),

            // Three Main Action Buttons matching legacy Android
            FilledButton.icon(
              icon: const Icon(Icons.email_outlined),
              label: Text(
                MongolStrings.contact,
                style: TextStyle(fontFamily: fontFamily, fontSize: 18.0),
              ),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(50.0),
              ),
              onPressed: () => _launchUrl(_contactUrl),
            ),
            const SizedBox(height: 16.0),

            FilledButton.tonalIcon(
              icon: const Icon(Icons.update),
              label: Text(
                MongolStrings.updates,
                style: TextStyle(fontFamily: fontFamily, fontSize: 18.0),
              ),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(50.0),
              ),
              onPressed: () => _launchUrl(_siteUrl),
            ),
            const SizedBox(height: 16.0),

            OutlinedButton.icon(
              icon: const Icon(Icons.share_outlined),
              label: Text(
                MongolStrings.shareApp,
                style: TextStyle(fontFamily: fontFamily, fontSize: 18.0),
              ),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(50.0),
              ),
              onPressed: _shareApp,
            ),
          ],
        ),
      ),
    );
  }
}
