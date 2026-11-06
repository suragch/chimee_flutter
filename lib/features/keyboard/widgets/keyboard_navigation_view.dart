import 'package:material_ui/material_ui.dart';

enum NavDirection { up, down, left, right, lineStart, lineEnd }

/// Keypad view for vertical cursor navigation in Traditional Mongolian text.
class KeyboardNavigationView extends StatelessWidget {
  const KeyboardNavigationView({
    super.key,
    required this.onDirectionalNav,
    required this.onClose,
  });

  final void Function(NavDirection direction) onDirectionalNav;
  final VoidCallback onClose;

  Widget _buildNavButton({
    required BuildContext context,
    required IconData icon,
    required VoidCallback onTap,
    String? tooltip,
  }) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(8.0),
      elevation: 1.0,
      child: InkWell(
        borderRadius: BorderRadius.circular(8.0),
        onTap: onTap,
        child: SizedBox(
          width: 56.0,
          height: 48.0,
          child: Icon(icon, size: 28.0, color: Theme.of(context).colorScheme.onSurface),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.keyboard),
                tooltip: 'Keyboard',
                onPressed: onClose,
              ),
              Row(
                children: [
                  _buildNavButton(
                    context: context,
                    icon: Icons.first_page,
                    tooltip: 'Start',
                    onTap: () => onDirectionalNav(NavDirection.lineStart),
                  ),
                  const SizedBox(width: 8),
                  _buildNavButton(
                    context: context,
                    icon: Icons.last_page,
                    tooltip: 'End',
                    onTap: () => onDirectionalNav(NavDirection.lineEnd),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildNavButton(
                context: context,
                icon: Icons.arrow_upward,
                tooltip: 'Up',
                onTap: () => onDirectionalNav(NavDirection.up),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildNavButton(
                context: context,
                icon: Icons.arrow_back,
                tooltip: 'Left Column',
                onTap: () => onDirectionalNav(NavDirection.left),
              ),
              const SizedBox(width: 48),
              _buildNavButton(
                context: context,
                icon: Icons.arrow_forward,
                tooltip: 'Right Column',
                onTap: () => onDirectionalNav(NavDirection.right),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildNavButton(
                context: context,
                icon: Icons.arrow_downward,
                tooltip: 'Down',
                onTap: () => onDirectionalNav(NavDirection.down),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
