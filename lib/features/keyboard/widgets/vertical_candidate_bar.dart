import 'package:material_ui/material_ui.dart';
import 'package:mongol/mongol.dart';
import '../../../core/database/app_database.dart';

/// Vertical candidate bar docked along the left edge of the keyboard container.
///
/// Dual-purpose layout matching legacy Android CustomImeContainer and ImeCandidatesView:
/// 1. When [candidates] is empty: Displays the 3 tool buttons vertically:
///    - Hide keyboard (down chevron)
///    - Cursor navigation toggle
///    - Emoji picker toggle
/// 2. When [candidates] is not empty: Displays predictive words top-to-bottom with MongolText.
class VerticalCandidateBar extends StatelessWidget {
  const VerticalCandidateBar({
    super.key,
    required this.candidates,
    required this.onCandidateSelected,
    this.onHideKeyboard,
    this.onToggleNavigation,
    this.onToggleEmoji,
    this.isNavMode = false,
    this.isEmojiMode = false,
    this.width = 52.0,
    this.fontFamily = 'Qagan',
  });

  final List<DictionaryWord> candidates;
  final ValueChanged<String> onCandidateSelected;
  final VoidCallback? onHideKeyboard;
  final VoidCallback? onToggleNavigation;
  final VoidCallback? onToggleEmoji;
  final bool isNavMode;
  final bool isEmojiMode;
  final double width;
  final String fontFamily;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        border: Border(
          right: BorderSide(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: candidates.isEmpty ? _buildToolButtons(context) : _buildCandidateList(context),
    );
  }

  Widget _buildToolButtons(BuildContext context) {
    return Column(
      children: [
        // 1. Hide Keyboard
        _buildToolIconButton(
          context: context,
          icon: Icons.keyboard_arrow_down,
          tooltip: 'Hide Keyboard',
          isActive: false,
          onTap: onHideKeyboard,
        ),
        const SizedBox(height: 4),

        // 2. Cursor Navigation Toggle
        _buildToolIconButton(
          context: context,
          icon: Icons.open_with,
          tooltip: 'Cursor Navigation',
          isActive: isNavMode,
          onTap: onToggleNavigation,
        ),
        const SizedBox(height: 4),

        // 3. Emoji Keyboard Toggle
        _buildToolIconButton(
          context: context,
          icon: Icons.sentiment_satisfied_alt,
          tooltip: 'Emoji',
          isActive: isEmojiMode,
          onTap: onToggleEmoji,
        ),

        const Spacer(),
      ],
    );
  }

  Widget _buildToolIconButton({
    required BuildContext context,
    required IconData icon,
    required String tooltip,
    required bool isActive,
    required VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    final activeBg = theme.colorScheme.primaryContainer;
    final activeFg = theme.colorScheme.onPrimaryContainer;
    final inactiveFg = theme.colorScheme.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
      child: Material(
        color: isActive ? activeBg : Colors.transparent,
        borderRadius: BorderRadius.circular(6.0),
        child: InkWell(
          borderRadius: BorderRadius.circular(6.0),
          onTap: onTap,
          child: SizedBox(
            width: width - 8.0,
            height: 44.0,
            child: Icon(
              icon,
              size: 24.0,
              color: isActive ? activeFg : inactiveFg,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCandidateList(BuildContext context) {
    return ListView.separated(
      scrollDirection: Axis.vertical,
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 6.0),
      itemCount: candidates.length,
      separatorBuilder: (context, index) => const Divider(
        height: 8,
        thickness: 1,
        indent: 6,
        endIndent: 6,
      ),
      itemBuilder: (context, index) {
        final word = candidates[index].word;
        return InkWell(
          borderRadius: BorderRadius.circular(6.0),
          onTap: () => onCandidateSelected(word),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 2.0),
            child: Center(
              child: MongolText(
                word,
                style: TextStyle(
                  fontFamily: fontFamily,
                  fontSize: 20.0,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
