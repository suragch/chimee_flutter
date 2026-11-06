import 'package:material_ui/material_ui.dart';
import 'package:mongol/mongol.dart';

import '../../core/database/app_database.dart';
import '../../core/localization/mongol_strings.dart';

class FavoritesScreen extends StatefulWidget {
  final String fontFamily;

  const FavoritesScreen({
    super.key,
    this.fontFamily = 'Qagan',
  });

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<FavoriteItem> _favorites = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() => _isLoading = true);
    final items = await AppDatabase.instance.getAllFavorites();
    if (mounted) {
      setState(() {
        _favorites = items;
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteFavorite(int id) async {
    await AppDatabase.instance.deleteFavorite(id);
    await _loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: MongolText(
          MongolStrings.save,
          style: TextStyle(fontFamily: widget.fontFamily, fontSize: 20.0),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _favorites.isEmpty
              ? Center(
                  child: MongolText(
                    MongolStrings.directoryEmpty,
                    style: TextStyle(
                      fontFamily: widget.fontFamily,
                      fontSize: 22.0,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(12.0),
                  itemCount: _favorites.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12.0),
                  itemBuilder: (context, index) {
                    final item = _favorites[index];
                    final date = DateTime.fromMillisecondsSinceEpoch(item.timestamp);
                    final dateStr =
                        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

                    return Card(
                      elevation: 1.5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12.0),
                        onTap: () {
                          // Return selected favorite to editor
                          Navigator.pop(context, item.message);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              // Vertical Mongolian message preview
                              Container(
                                height: 120,
                                constraints: const BoxConstraints(minWidth: 80, maxWidth: 240),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .surfaceContainerHighest
                                      .withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                  vertical: 4.0,
                                ),
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: MongolText(
                                    item.message,
                                    style: TextStyle(
                                      fontFamily: widget.fontFamily,
                                      fontSize: 18.0,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16.0),
                              Expanded(
                                child: Text(
                                  dateStr,
                                  style: TextStyle(
                                    fontSize: 12.0,
                                    color: Theme.of(context).colorScheme.outline,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline),
                                color: Theme.of(context).colorScheme.error,
                                tooltip: MongolStrings.delete,
                                onPressed: () async {
                                  final confirmed = await showDialog<bool>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: MongolText(
                                        MongolStrings.delete,
                                        style: TextStyle(fontFamily: widget.fontFamily, fontSize: 18.0),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(ctx, false),
                                          child: Text(
                                            MongolStrings.cancel,
                                            style: TextStyle(fontFamily: widget.fontFamily, fontSize: 16.0),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () => Navigator.pop(ctx, true),
                                          child: Text(
                                            MongolStrings.deleteYes,
                                            style: TextStyle(fontFamily: widget.fontFamily, fontSize: 16.0),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirmed == true && item.id != null) {
                                    await _deleteFavorite(item.id!);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
