import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';
import '../providers/music_provider.dart';
import '../models/song.dart';
import 'player_screen.dart';

class TracksScreen extends StatefulWidget {
  const TracksScreen({super.key});

  @override
  State<TracksScreen> createState() => _TracksScreenState();
}

class _TracksScreenState extends State<TracksScreen> with AutomaticKeepAliveClientMixin {
  bool _searching = false;
  final _searchCtrl = TextEditingController();

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _showSortMenu(BuildContext context, MusicProvider music) {
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

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final music = context.watch<MusicProvider>();
    final theme = Theme.of(context);
    final songs = music.songs;

    return Column(
      children: [
        // Toolbar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Row(
            children: [
              if (_searching)
                Expanded(
                  child: Container(
                    height: 42,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: _searchCtrl,
                      autofocus: true,
                      style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Search',
                        hintStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.4)),
                        prefixIcon: Icon(Icons.search, color: theme.colorScheme.primary, size: 20),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 11),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.close, color: theme.colorScheme.onSurface.withOpacity(0.5), size: 18),
                          onPressed: () {
                            setState(() { _searching = false; });
                            _searchCtrl.clear();
                            music.search('');
                          },
                        ),
                      ),
                      onChanged: music.search,
                    ),
                  ),
                )
              else ...[
                InkWell(
                  onTap: () => _showSortMenu(context, music),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Icon(Icons.sort_rounded, color: theme.colorScheme.primary, size: 22),
                  ),
                ),
                const Spacer(),
                Text(
                  '${songs.length} tracks',
                  style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.4), fontSize: 12),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () => setState(() => _searching = true),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Icon(Icons.search, color: theme.colorScheme.primary, size: 22),
                  ),
                ),
              ],
            ],
          ),
        ),
        Expanded(
          child: music.loading
              ? Center(
                  child: CircularProgressIndicator(
                    color: theme.colorScheme.primary,
                    strokeWidth: 2,
                  ),
                )
              : songs.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.music_off_rounded, size: 56, color: theme.colorScheme.primary.withOpacity(0.3)),
                          const SizedBox(height: 12),
                          Text('No tracks found', style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.4))),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: songs.length,
                      itemExtent: 70,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(bottom: 8),
                      itemBuilder: (ctx, i) => _SongTile(
                        song: songs[i],
                        isPlaying: music.currentIndex == i,
                        onTap: () {
                          music.play(i);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const PlayerScreen()),
                          );
                        },
                      ),
                    ),
        ),
      ],
    );
  }
}

class _SongTile extends StatelessWidget {
  final Song song;
  final bool isPlaying;
  final VoidCallback onTap;

  const _SongTile({required this.song, required this.isPlaying, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: QueryArtworkWidget(
          id: song.albumId ?? song.id,
          type: ArtworkType.ALBUM,
          nullArtworkWidget: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.music_note, color: theme.colorScheme.primary, size: 24),
          ),
          artworkWidth: 48,
          artworkHeight: 48,
          artworkFit: BoxFit.cover,
          keepOldArtwork: true,
        ),
      ),
      title: Text(
        song.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: isPlaying ? theme.colorScheme.primary : theme.colorScheme.onSurface,
          fontWeight: isPlaying ? FontWeight.w600 : FontWeight.w400,
          fontSize: 14,
        ),
      ),
      subtitle: Text(
        song.artist,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: isPlaying
              ? theme.colorScheme.primary.withOpacity(0.7)
              : theme.colorScheme.onSurface.withOpacity(0.5),
          fontSize: 12,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isPlaying)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Icon(Icons.equalizer_rounded, color: theme.colorScheme.primary, size: 18),
            ),
          IconButton(
            icon: Icon(Icons.more_vert, color: theme.colorScheme.onSurface.withOpacity(0.4), size: 18),
            onPressed: () => _showOptions(context),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }

  void _showOptions(BuildContext context) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.cardColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Container(width: 40, height: 4, decoration: BoxDecoration(color: theme.dividerColor, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: QueryArtworkWidget(
                    id: song.albumId ?? song.id,
                    type: ArtworkType.ALBUM,
                    nullArtworkWidget: Container(
                      width: 48,
                      height: 48,
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: Icon(Icons.music_note, color: theme.colorScheme.primary),
                    ),
                    artworkWidth: 48, artworkHeight: 48, artworkFit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(song.title, style: const TextStyle(fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                      Text(song.artist, style: TextStyle(color: theme.colorScheme.primary, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ListTile(leading: const Icon(Icons.playlist_add_rounded), title: const Text('Add to playlist')),
          ListTile(leading: const Icon(Icons.info_outline_rounded), title: const Text('Song info')),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _SortSheet extends StatefulWidget {
  final SortField currentField;
  final SortOrder currentOrder;
  final void Function(SortField, SortOrder) onChanged;

  const _SortSheet({required this.currentField, required this.currentOrder, required this.onChanged});

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
          Container(width: 40, height: 4, decoration: BoxDecoration(color: theme.dividerColor, borderRadius: BorderRadius.circular(2))),
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
                onTap: () { setState(() => _order = SortOrder.ascending); widget.onChanged(_field, _order); },
              ),
              const SizedBox(width: 12),
              _OrderButton(
                icon: Icons.arrow_downward_rounded,
                label: 'Desc',
                selected: _order == SortOrder.descending,
                onTap: () { setState(() => _order = SortOrder.descending); widget.onChanged(_field, _order); },
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

  const _OrderButton({required this.icon, required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? theme.colorScheme.primary.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? theme.colorScheme.primary : theme.dividerColor,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: selected ? theme.colorScheme.primary : theme.colorScheme.onSurface.withOpacity(0.5)),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(color: selected ? theme.colorScheme.primary : theme.colorScheme.onSurface.withOpacity(0.5))),
          ],
        ),
      ),
    );
  }
}
