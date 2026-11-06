import 'package:material_ui/material_ui.dart';
import '../../core/database/app_database.dart';

/// Horizontal candidate bar docked along the top edge of Qwerty keyboard layout.
///
/// Dual-purpose layout matching legacy Android CustomImeContainer and ImeCandidatesView:
/// 1. When [candidates] is empty: Displays the 3 tool buttons horizontally on the left:
///    - Hide keyboard (down chevron)
///    - Cursor navigation toggle
///    - Emoji picker toggle
/// 2. When [candidates] is not empty: Displays predictive words horizontally.
class CandidateBar extends StatelessWidget {
  final List<DictionaryWord> candidates;
  final ValueChanged<String> onSelectWord;
  final VoidCallback? onHideKeyboard;
  final VoidCallback? onToggleNavigation;
  final VoidCallback? onToggleEmoji;
  final bool isNavMode;
  final bool isEmojiMode;
  final String fontFamily;

  const CandidateBar({
    super.key,
    required this.candidates,
    required this.onSelectWord,
    this.onHideKeyboard,
    this.onToggleNavigation,
    this.onToggleEmoji,
    this.isNavMode = false,
    this.isEmojiMode = false,
    this.fontFamily = 'Qagan',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44.0,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: candidates.isEmpty ? _buildToolButtons(context) : _buildCandidateList(context),
    );
  }

  Widget _buildToolButtons(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 4),
        _buildToolIconButton(
          context: context,
          icon: Icons.keyboard_arrow_down,
          tooltip: 'Hide Keyboard',
          isActive: false,
          onTap: onHideKeyboard,
        ),
        const SizedBox(width: 4),
        _buildToolIconButton(
          context: context,
          icon: Icons.open_with,
          tooltip: 'Cursor Navigation',
          isActive: isNavMode,
          onTap: onToggleNavigation,
        ),
        const SizedBox(width: 4),
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

    return Material(
      color: isActive ? activeBg : Colors.transparent,
      borderRadius: BorderRadius.circular(6.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(6.0),
        onTap: onTap,
        child: SizedBox(
          width: 44.0,
          height: 36.0,
          child: Icon(
            icon,
            size: 22.0,
            color: isActive ? activeFg : inactiveFg,
          ),
        ),
      ),
    );
  }

  Widget _buildCandidateList(BuildContext context) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      itemCount: candidates.length,
      separatorBuilder: (context, index) => const VerticalDivider(
        width: 8,
        thickness: 1,
        indent: 8,
        endIndent: 8,
      ),
      itemBuilder: (context, index) {
        final word = candidates[index].word;
        return InkWell(
          borderRadius: BorderRadius.circular(6.0),
          onTap: () => onSelectWord(word),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Center(
              child: Text(
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
