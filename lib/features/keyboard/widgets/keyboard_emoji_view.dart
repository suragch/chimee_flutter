import 'package:material_ui/material_ui.dart';

/// Emoji grid keyboard matching legacy Android KeyboardEmoji.java.
class KeyboardEmojiView extends StatelessWidget {
  const KeyboardEmojiView({
    super.key,
    required this.onEmojiSelected,
    required this.onBackspace,
    required this.onSpace,
    required this.onDone,
  });

  final ValueChanged<String> onEmojiSelected;
  final VoidCallback onBackspace;
  final VoidCallback onSpace;
  final VoidCallback onDone;

  static const List<String> emojis = [
    '😀', '😙', '😚', '😑', '😮', '😯', '😴', '😛', '😕', '😟',
    '😦', '😧', '😬', '🙂', '🙁', '😁', '😂', '😃', '😄', '😅',
    '😆', '😉', '😊', '😋', '😎', '😍', '😘', '😗', '😐', '😶',
    '😏', '😒', '😥', '😪', '😫', '😌', '😜', '😝', '😒', '😓',
    '😔', '😲', '🤐', '😷', '🤒', '🤕', '🤑', '🤠', '🤢', '🤮',
    '🤧', '😇', '🤠', '🤡', '🤥', '🤫', '🤭', '🧐', '🤓', '😈',
    '👿', '👹', '👺', '💀', '👻', '👽', '👾', '💩', '😺', '😸',
    '😹', '😻', '😼', '😽', '🙀', '😿', '😾', '🙈', '🙉', '🙊',
    '👶', '👦', '👧', '👨', '👩', '👴', '👵', '👮', '💂', '👷',
    '👸', '👳', '👲', '👰', '👼', '🎅', '🙍', '🙎', '🙅', '🙆',
    '💁', '🙋', '🙇', '💆', '💇', '🚶', '🏃', '💃', '👯', '🛀',
    '👤', '👥', '🏇', '🏂', '🏄', '🚣', '🏊', '🚴', '🚵', '🧗',
    '⚽', '⚾', '💪', '👈', '👉', '☝', '👆', '👇', '✌', '✋',
    '👌', '👍', '👎', '✊', '👊', '👋', '👏', '👐', '🙌', '🙏',
    '👂', '👃', '👣', '👀', '👅', '👄', '💋', '💘', '💝', '💖',
    '💗', '💓', '💞', '💕', '💌', '💔', '💛', '💚', '💙', '💜',
    '💟', '💣', '💥', '💦', '💨', '💫', '👓', '👔', '👕', '👖',
    '👗', '👘', '👙', '👚', '👛', '👜', '👝', '🎒', '👞', '👟',
    '👠', '👡', '👢', '👑', '👒', '🎩', '🎓', '💄', '💍', '💎',
    '🐵', '🐒', '🐶', '🐕', '🐩', '🐺', '🐱', '🐈', '🐯', '🐅',
    '🐆', '🐴', '🐎', '🐮', '🐂', '🐃', '🐄', '🐷', '🐖', '🐗',
    '🐽', '🐏', '🐑', '🐐', '🐪', '🐫', '🐘', '🐭', '🐁', '🐀',
    '🐹', '🐰', '🐇', '🐻', '🐨', '🐼', '🐾', '🐔', '🐓', '🐣',
    '🐤', '🐥', '🐦', '🐧', '🐸', '🐊', '🐢', '🐍', '🐲', '🐉',
    '🐳', '🐋', '🐬', '🐟', '🐠', '🐡', '🐙', '🐚', '🐌', '🐛',
    '🐜', '🐝', '🐞', '💐', '🌸', '💮', '🌹', '🌺', '🌻', '🌼',
    '🌷', '🌱', '🌲', '🌳', '🌴', '🌵', '🌾', '🌿', '🍀', '🍁',
    '🍂', '🍃', '🍇', '🍈', '🍉', '🍊', '🍋', '🍌', '🍍', '🍎',
    '🍏', '🍐', '🍑', '🍒', '🍓', '🍅', '🍆', '🌽', '🍄', '🌰',
    '🍞', '🍖', '🍗', '🍔', '🍟', '🍕', '🍳', '🍲', '🍱', '🍘',
    '🍙', '🍚', '🍛', '🍜', '🍝', '🍠', '🍢', '🍣', '🍤', '🍥',
    '🍡', '🍦', '🍧', '🍨', '🍩', '🍪', '🎂', '🍰', '🍫', '🍬',
    '🍭', '🍮', '🍯', '🍼', '🍵', '🍶', '🍷', '🍸', '🍹', '🍺',
    '🍻', '🍴', '🔪', '🌍', '🌎', '🌏', '🌐', '🌋', '🗻', '🏠',
    '🏡', '🏢', '🏣', '🏥', '🏦', '🏨', '🏩', '🏪', '🏫', '🏬',
    '🏭', '🏯', '🏰', '💒', '🗼', '🗽', '⛪', '⛲', '⛺', '🌁',
    '🌃', '🌄', '🌅', '🌆', '🌇', '🌉', '♨', '🎠', '🎡', '🎢',
    '💈', '🎪', '🚂', '🚃', '🚄', '🚅', '🚆', '🚇', '🚈', '🚉',
    '🚊', '🚝', '🚞', '🚋', '🚌', '🚍', '🚎', '🚏', '🚐', '🚑',
    '🚒', '🚓', '🚔', '🚕', '🚖', '🚗', '🚘', '🚙', '🚚', '🚛',
    '🚜', '🚲', '🚨', '🚥', '🚦', '🚧', '⚓', '⛵', '🚤', '🚢',
    '✈', '💺', '🚁', '🚟', '🚠', '🚡', '🚀', '⏳', '⏰', '⏱',
    '⏲', '🌑', '🌒', '🌓', '🌔', '🌕', '🌖', '🌗', '🌘', '🌙',
    '🌚', '🌛', '🌜', '🌝', '🌞', '🌟', '🌠', '🌀', '🌈', '🌂',
    '🔥', '💧', '🌊', '🎃', '🎄', '🎆', '🎇', '✨', '🎈', '🎉',
    '🎊', '🎋', '🎌', '🎍', '🎎', '🎏', '🎐', '🎑', '🎀', '🎁',
    '🎫', '🏆', '🏀', '🏈', '🏉', '🎾', '🎳', '🎣', '🎽', '🎿',
    '🎯', '🎱', '🔮', '🎮', '🎰', '🎲', '🎭', '🎨', '📢', '📣',
    '📯', '🔔', '🔕', '🎼', '🎵', '🎶', '🎤', '🎧', '📻', '🎷',
    '🎸', '🎹', '🎺', '🎻', '📱', '📲', '☎', '📞', '📟', '📠',
    '🔋', '🔌', '💻', '💽', '💾', '💿', '📀', '🎥', '🎬', '📺',
    '📷', '📹', '📼', '🔍', '🔎', '💡', '🔦', '🏮', '📔', '📕',
    '📖', '📗', '📘', '📙', '📚', '📓', '📒', '📃', '📜', '📄',
    '📰', '📑', '🔖', '💰', '💴', '💵', '💶', '💷', '💸', '💳',
    '📦', '📧', '📥', '📤', '✉', '📩', '📨', '📫', '📪', '📬',
    '📭', '📮', '📝', '💼', '📁', '📂', '📅', '📆', '📇', '📈',
    '📉', '📊', '📋', '📌', '📍', '📎', '📏', '📐', '🔒', '🔓',
    '🔏', '🔐', '🔑', '🔨', '🔫', '🔧', '🔩', '🔗', '🔬', '🔭',
    '📡', '💉', '💊', '🚪', '🚽', '🚿', '🛁', '🚬', '🗿', '🏧',
    '🚮', '🚰', '♿', '🚹', '🚺', '🚻', '🚼', '🚾', '🛂', '🛃',
    '🛄', '🛅', '⚠', '🚸', '⛔', '🚫', '🚳', '🚭', '🚯', '🚱',
    '🚷', '📵', '🔞', '🔄', '💯', '🏁',
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220.0,
      child: Row(
        children: [
          // Action column (del, space, done) matching Android KeyboardEmoji
          Container(
            width: 48.0,
            padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 2.0),
            child: Column(
              children: [
                Expanded(
                  child: _buildSideButton(
                    context: context,
                    icon: Icons.backspace_outlined,
                    onTap: onBackspace,
                  ),
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: _buildSideButton(
                    context: context,
                    icon: Icons.space_bar,
                    onTap: onSpace,
                  ),
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: _buildSideButton(
                    context: context,
                    icon: Icons.keyboard_return,
                    onTap: onDone,
                  ),
                ),
              ],
            ),
          ),
          // Emoji grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(4.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6,
                crossAxisSpacing: 4.0,
                mainAxisSpacing: 4.0,
              ),
              itemCount: emojis.length,
              itemBuilder: (context, index) {
                final emoji = emojis[index];
                return Material(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(6.0),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(6.0),
                    onTap: () => onEmojiSelected(emoji),
                    child: Center(
                      child: Text(
                        emoji,
                        style: const TextStyle(fontSize: 22.0),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSideButton({
    required BuildContext context,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(6.0),
      elevation: 1.0,
      child: InkWell(
        borderRadius: BorderRadius.circular(6.0),
        onTap: onTap,
        child: Center(
          child: Icon(icon, size: 20.0, color: Theme.of(context).colorScheme.onSurface),
        ),
      ),
    );
  }
}
