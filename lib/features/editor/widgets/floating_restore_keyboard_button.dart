import 'package:material_ui/material_ui.dart';

/// Floating circular restore button displayed in the bottom-right corner of the canvas
/// when the virtual keyboard is collapsed.
class FloatingRestoreKeyboardButton extends StatelessWidget {
  const FloatingRestoreKeyboardButton({
    super.key,
    required this.onPressed,
  });

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.5,
      child: Material(
        color: Colors.white,
        shape: const CircleBorder(),
        elevation: 4.0,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: const SizedBox(
            width: 48.0,
            height: 48.0,
            child: Icon(
              Icons.keyboard_outlined,
              color: Colors.black87,
              size: 28.0,
            ),
          ),
        ),
      ),
    );
  }
}
