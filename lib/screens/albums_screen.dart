import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';

class AlbumsScreen extends StatefulWidget {
  const AlbumsScreen({super.key});

  @override
  State<AlbumsScreen> createState() => _AlbumsScreenState();
}

class _AlbumsScreenState extends State<AlbumsScreen> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final _query = OnAudioQuery();

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);

    return FutureBuilder<List<AlbumModel>>(
      future: _query.queryAlbums(sortType: AlbumSortType.ALBUM, orderType: OrderType.ASC_OR_SMALLER),
      builder: (_, snap) {
        if (!snap.hasData) {
          return Center(child: CircularProgressIndicator(color: theme.colorScheme.primary, strokeWidth: 2));
        }
        final albums = snap.data!;
        if (albums.isEmpty) {
          return Center(child: Text('No albums', style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.4))));
        }
        return GridView.builder(
          padding: const EdgeInsets.all(12),
          physics: const BouncingScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.82,
          ),
          itemCount: albums.length,
          itemBuilder: (_, i) => _AlbumCard(album: albums[i]),
        );
      },
    );
  }
}

class _AlbumCard extends StatelessWidget {
  final AlbumModel album;
  const _AlbumCard({required this.album});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: QueryArtworkWidget(
              id: album.id,
              type: ArtworkType.ALBUM,
              nullArtworkWidget: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.album_rounded, color: theme.colorScheme.primary.withOpacity(0.4), size: 48),
              ),
              artworkFit: BoxFit.cover,
              keepOldArtwork: true,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(album.album, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
        Text('${album.numOfSongs} songs', style: TextStyle(fontSize: 11, color: theme.colorScheme.primary)),
      ],
    );
  }
}
