import 'package:material_ui/material_ui.dart';
import 'package:mongol/mongol.dart';
import '../../../core/localization/mongol_strings.dart';

class ColorChooserDialog extends StatefulWidget {
  final Color currentBgColor;
  final Color currentTextColor;
  final String fontFamily;
  final void Function(Color bgColor, Color textColor) onColorsSelected;

  const ColorChooserDialog({
    super.key,
    required this.currentBgColor,
    required this.currentTextColor,
    required this.onColorsSelected,
    this.fontFamily = 'Qagan',
  });

  @override
  State<ColorChooserDialog> createState() => _ColorChooserDialogState();
}

class _ColorChooserDialogState extends State<ColorChooserDialog> {
  late Color _bgColor;
  late Color _textColor;
  bool _isSelectingBg = true;

  static const List<Color> colorPalette = [
    Color(0xFFFFFFFF), // White
    Color(0xFFFBF6EC), // Parchment
    Color(0xFFEEEEEE), // Light Grey
    Color(0xFF9E9E9E), // Grey
    Color(0xFF424242), // Dark Grey
    Color(0xFF000000), // Black
    Color(0xFFCFD8DC), // Blue Grey Light
    Color(0xFF607D8B), // Blue Grey
    Color(0xFF37474F), // Blue Grey Dark
    Color(0xFFC8E6C9), // Pale Green
    Color(0xFF81C784), // Light Green
    Color(0xFF2E7D32), // Dark Green
    Color(0xFFFFF9C4), // Pale Yellow
    Color(0xFFFFEE58), // Amber Light
    Color(0xFFF57F17), // Deep Amber
    Color(0xFFFFCDD2), // Pale Red
    Color(0xFFE57373), // Light Red
    Color(0xFFC62828), // Deep Crimson
    Color(0xFFE1BEE7), // Pale Purple
    Color(0xFF9C27B0), // Purple
    Color(0xFF4A148C), // Deep Purple
    Color(0xFFBBDEFB), // Pale Blue
    Color(0xFF2196F3), // Primary Blue
    Color(0xFF0D47A1), // Deep Navy
  ];

  @override
  void initState() {
    super.initState();
    _bgColor = widget.currentBgColor;
    _textColor = widget.currentTextColor;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440, maxHeight: 520),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    MongolStrings.color,
                    style: TextStyle(
                      fontFamily: widget.fontFamily,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 8.0),
              // Live Preview Banner
              Container(
                height: 100,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: _bgColor,
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                ),
                alignment: Alignment.center,
                child: MongolText(
                  MongolStrings.colorPreviewText,
                  style: TextStyle(
                    fontFamily: widget.fontFamily,
                    color: _textColor,
                    fontSize: 48.0,
                  ),
                ),
              ),
              const SizedBox(height: 12.0),
              // Segmented toggle: Background vs Text
              SegmentedButton<bool>(
                segments: [
                  ButtonSegment(
                    value: true,
                    label: Text(
                      MongolStrings.background,
                      style: TextStyle(fontFamily: widget.fontFamily, fontSize: 16.0),
                    ),
                    icon: const Icon(Icons.format_paint_outlined),
                  ),
                  ButtonSegment(
                    value: false,
                    label: Text(
                      MongolStrings.textColor,
                      style: TextStyle(fontFamily: widget.fontFamily, fontSize: 16.0),
                    ),
                    icon: const Icon(Icons.format_color_text),
                  ),
                ],
                selected: {_isSelectingBg},
                onSelectionChanged: (selected) {
                  setState(() => _isSelectingBg = selected.first);
                },
              ),
              const SizedBox(height: 12.0),
              // Color palette grid
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 6,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                  ),
                  itemCount: colorPalette.length,
                  itemBuilder: (context, index) {
                    final color = colorPalette[index];
                    final isSelected = _isSelectingBg
                        ? _bgColor.toARGB32() == color.toARGB32()
                        : _textColor.toARGB32() == color.toARGB32();

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (_isSelectingBg) {
                            _bgColor = color;
                          } else {
                            _textColor = color;
                          }
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Colors.grey.shade400,
                            width: isSelected ? 3.0 : 1.0,
                          ),
                        ),
                        child: isSelected
                            ? Icon(
                                Icons.check,
                                size: 18,
                                color: color.computeLuminance() > 0.5
                                    ? Colors.black
                                    : Colors.white,
                              )
                            : null,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      MongolStrings.cancel,
                      style: TextStyle(fontFamily: widget.fontFamily, fontSize: 16.0),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  ElevatedButton(
                    onPressed: () {
                      widget.onColorsSelected(_bgColor, _textColor);
                      Navigator.pop(context);
                    },
                    child: Text(
                      MongolStrings.ok,
                      style: TextStyle(fontFamily: widget.fontFamily, fontSize: 16.0),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
