import 'package:material_ui/material_ui.dart';
import 'package:mongol/mongol.dart';
import '../../../core/fonts/font_catalog.dart';
import '../../../core/localization/mongol_strings.dart';

class FontChooserDialog extends StatelessWidget {
  final String currentFontFamily;
  final ValueChanged<String> onSelectFont;
  final String uiFontFamily;

  const FontChooserDialog({
    super.key,
    required this.currentFontFamily,
    required this.onSelectFont,
    this.uiFontFamily = 'Qagan',
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 520),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    MongolStrings.font,
                    style: TextStyle(
                      fontFamily: uiFontFamily,
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: ListView.separated(
                  itemCount: FontCatalog.fonts.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = FontCatalog.fonts[index];
                    final isSelected = item.family == currentFontFamily;

                    return ListTile(
                      selected: isSelected,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      leading: SizedBox(
                        width: 48.0,
                        height: 56.0,
                        child: Center(
                          child: MongolText(
                            item.nameMenksoft,
                            style: TextStyle(
                              fontFamily: item.family,
                              fontSize: 22.0,
                            ),
                          ),
                        ),
                      ),
                      trailing: isSelected
                          ? Icon(
                              Icons.check_circle,
                              color: Theme.of(context).colorScheme.primary,
                            )
                          : null,
                      onTap: () {
                        onSelectFont(item.family);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
