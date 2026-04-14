import 'package:flutter/material.dart';
import 'package:muse/widgets/songs_indicator.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';
import '../providers/music_provider.dart';
import '../models/song.dart';
import 'player_screen.dart';

class TracksScreen extends StatefulWidget {
  const TracksScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  TracksScreenState createState() => TracksScreenState();
}

class TracksScreenState extends State<TracksScreen>
    with AutomaticKeepAliveClientMixin {
  bool _searching = false;
  final _searchCtrl = TextEditingController();

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void openSortMenu() {
    final music = context.read<MusicProvider>();
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _SortSheet(
        currentField: music.sortField,
        currentOrder: music.sortOrder,
        onChanged: music.setSort,
      ),
    );
  }

  void startSearch() => setState(() => _searching = true);

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final music = context.watch<MusicProvider>();
    final theme = Theme.of(context);
    final songs = music.songs;

    return Column(
      children: [
        if (_searching)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Container(
              height: 42,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _searchCtrl,
                autofocus: true,
                style: TextStyle(
                    color: theme.colorScheme.onSurface, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Search',
                  hintStyle: TextStyle(
                      color: theme.colorScheme.onSurface.withOpacity(0.4)),
                  prefixIcon: Icon(Icons.search,
                      color: theme.colorScheme.primary, size: 20),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 11),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.close,
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                        size: 18),
                    onPressed: () {
                      setState(() => _searching = false);
                      _searchCtrl.clear();
                      music.search('');
                    },
                  ),
                ),
                onChanged: music.search,
              ),
            ),
          ),

        Expanded(
          child: music.loading
              ? Center(
                  child: CircularProgressIndicator(
                      color: theme.colorScheme.primary, strokeWidth: 2))
              : songs.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.music_off_rounded,
                              size: 56,
                              color:
                                  theme.colorScheme.primary.withOpacity(0.3)),
                          const SizedBox(height: 12),
                          Text('No tracks found',
                              style: TextStyle(
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.4))),
                        ],
                      ),
                    )
                  : ListView.builder(
                      // No itemExtent — let each tile size itself naturally
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(bottom: 8),
                      itemCount: songs.length,
                      itemBuilder: (ctx, i) => _SongTile(
                        // Key ensures Flutter keeps the State alive per song
                        key: ValueKey(songs[i].id),
                        song: songs[i],
                        isPlaying: music.currentIndex == i,
                        onTap: () {
                          music.play(i);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const PlayerScreen()),
                          );
                        },
                      ),
                    ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Song tile — StatefulWidget so SongIndicator's AnimationControllers survive
// ─────────────────────────────────────────────────────────────────────────────
class _SongTile extends StatefulWidget {
  final Song song;
  final bool isPlaying;
  final VoidCallback onTap;

  const _SongTile({
    super.key,
    required this.song,
    required this.isPlaying,
    required this.onTap,
  });

  @override
  State<_SongTile> createState() => _SongTileState();
}

class _SongTileState extends State<_SongTile> {
  static const double _artSize = 64.0;
  static const double _radius = 12.0;
  static const double _tileHeight = 88.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final song = widget.song;
    final isPlaying = widget.isPlaying;

    return SizedBox(
      height: _tileHeight,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                // ── Artwork ──────────────────────────────────────────
                _RoundedArtwork(
                  id: song.albumId ?? song.id,
                  size: _artSize,
                  radius: _radius,
                  primaryColor: theme.colorScheme.primary,
                  surfaceColor: theme.colorScheme.surfaceContainerHighest,
                ),
                const SizedBox(width: 14),

                // ── Title + Artist ────────────────────────────────────
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        song.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isPlaying
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface,
                          fontWeight:
                              isPlaying ? FontWeight.w600 : FontWeight.w400,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        song.artist,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isPlaying
                              ? theme.colorScheme.primary.withOpacity(0.7)
                              : theme.colorScheme.onSurface.withOpacity(0.5),
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Trailing: indicator + more button ────────────────
                if (isPlaying)
                  Padding(
                    padding: const EdgeInsets.only(right: 2),
                    child: SongIndicator(
                      color: theme.colorScheme.primary,
                      size: 22,
                    ),
                  ),
                IconButton(
                  icon: Icon(Icons.more_vert,
                      color: theme.colorScheme.onSurface.withOpacity(0.4),
                      size: 20),
                  onPressed: () => _showOptions(context),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showOptions(BuildContext context) {
    final theme = Theme.of(context);
    final song = widget.song;
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.cardColor,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: theme.dividerColor,
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                _RoundedArtwork(
                  id: song.albumId ?? song.id,
                  size: 52,
                  radius: 12,
                  primaryColor: theme.colorScheme.primary,
                  surfaceColor: theme.colorScheme.surfaceContainerHighest,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(song.title,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      Text(song.artist,
                          style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ListTile(
              leading: const Icon(Icons.playlist_add_rounded),
              title: const Text('Add to playlist')),
          ListTile(
              leading: const Icon(Icons.info_outline_rounded),
              title: const Text('Song info')),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Double-clipped rounded artwork — fixes QueryArtworkWidget's internal circle
// ─────────────────────────────────────────────────────────────────────────────
class _RoundedArtwork extends StatelessWidget {
  final int id;
  final double size;
  final double radius;
  final Color primaryColor;
  final Color surfaceColor;

  const _RoundedArtwork({
    required this.id,
    required this.size,
    required this.radius,
    required this.primaryColor,
    required this.surfaceColor,
  });

  @override
  Widget build(BuildContext context) {
    final border = BorderRadius.circular(radius);
    return SizedBox(
      width: size,
      height: size,
      child: ClipRRect(
        borderRadius: border,
        child: QueryArtworkWidget(
          id: id,
          type: ArtworkType.ALBUM,
          artworkBorder: border,
          artworkWidth: size,
          artworkHeight: size,
          artworkFit: BoxFit.cover,
          keepOldArtwork: true,
          nullArtworkWidget: Container(
            width: size,
            height: size,
            color: surfaceColor,
            child: Icon(Icons.music_note,
                color: primaryColor, size: size * 0.48),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sort bottom sheet
// ─────────────────────────────────────────────────────────────────────────────
class _SortSheet extends StatefulWidget {
  final SortField currentField;
  final SortOrder currentOrder;
  final void Function(SortField, SortOrder) onChanged;

  const _SortSheet({
      required this.currentField,
      required this.currentOrder,
      required this.onChanged});

  @override
  State<_SortSheet> createState() => _SortSheetState();
}

class _SortSheetState extends State<_SortSheet> {
  late SortField _field;
  late SortOrder _order;

  @override
  void initState() {
    super.initState();
    _field = widget.currentField;
    _order = widget.currentOrder;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fields = [
      (SortField.title, 'Title'),
      (SortField.album, 'Album'),
      (SortField.artist, 'Artist'),
      (SortField.genre, 'Genre'),
      (SortField.year, 'Year'),
      (SortField.trackNumber, 'Track Number'),
      (SortField.dateModified, 'Date Modified'),
    ];

    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: theme.dividerColor,
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 8),
          ...fields.map((f) => RadioListTile<SortField>(
                value: f.$1,
                groupValue: _field,
                title: Text(f.$2),
                dense: true,
                onChanged: (v) {
                  setState(() => _field = v!);
                  widget.onChanged(_field, _order);
                },
              )),
          const Divider(),
          Row(
            children: [
              const SizedBox(width: 16),
              _OrderButton(
                icon: Icons.arrow_upward_rounded,
                label: 'Asc',
                selected: _order == SortOrder.ascending,
                onTap: () {
                  setState(() => _order = SortOrder.ascending);
                  widget.onChanged(_field, _order);
                },
              ),
              const SizedBox(width: 12),
              _OrderButton(
                icon: Icons.arrow_downward_rounded,
                label: 'Desc',
                selected: _order == SortOrder.descending,
                onTap: () {
                  setState(() => _order = SortOrder.descending);
                  widget.onChanged(_field, _order);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OrderButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _OrderButton({
      required this.icon,
      required this.label,
      required this.selected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? theme.colorScheme.primary.withOpacity(0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: selected
                  ? theme.colorScheme.primary
                  : theme.dividerColor),
        ),
        child: Row(
          children: [
            Icon(icon,
                size: 16,
                color: selected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withOpacity(0.5)),
            const SizedBox(width: 4),
            Text(label,
                style: TextStyle(
                    color: selected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface.withOpacity(0.5))),
          ],
        ),
      ),
    );
  }
}