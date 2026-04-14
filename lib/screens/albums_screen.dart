import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';
import '../providers/music_provider.dart';
import 'player_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Albums grid
// ─────────────────────────────────────────────────────────────────────────────

class AlbumsScreen extends StatefulWidget {
  const AlbumsScreen({super.key});

  @override
  State<AlbumsScreen> createState() => _AlbumsScreenState();
}

class _AlbumsScreenState extends State<AlbumsScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final _query = OnAudioQuery();

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);

    return FutureBuilder<List<AlbumModel>>(
      future: _query.queryAlbums(
        sortType: AlbumSortType.ALBUM,
        orderType: OrderType.ASC_OR_SMALLER,
      ),
      builder: (_, snap) {
        if (!snap.hasData) {
          return Center(
            child: CircularProgressIndicator(
                color: theme.colorScheme.primary, strokeWidth: 2),
          );
        }

        // Deduplicate by album name (case-insensitive), summing song counts
        final seen = <String, AlbumModel>{};
        final songCounts = <String, int>{};
        for (final a in snap.data!) {
          final key = a.album.toLowerCase().trim();
          if (!seen.containsKey(key)) {
            seen[key] = a;
            songCounts[key] = a.numOfSongs;
          } else {
            songCounts[key] = (songCounts[key] ?? 0) + a.numOfSongs;
          }
        }
        final albums = seen.values.toList();

        if (albums.isEmpty) {
          return Center(
            child: Text('No albums',
                style: TextStyle(
                    color: theme.colorScheme.onSurface.withOpacity(0.4))),
          );
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
          itemBuilder: (_, i) {
            final key = albums[i].album.toLowerCase().trim();
            return _AlbumCard(
              album: albums[i],
              songCount: songCounts[key] ?? albums[i].numOfSongs,
            );
          },
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Album card
// ─────────────────────────────────────────────────────────────────────────────

class _AlbumCard extends StatelessWidget {
  final AlbumModel album;
  final int songCount;

  const _AlbumCard({required this.album, required this.songCount});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => AlbumDetailScreen(album: album)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1,
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
                  child: Icon(Icons.album_rounded,
                      color: theme.colorScheme.primary.withOpacity(0.4),
                      size: 48),
                ),
                artworkWidth: 300,
                artworkHeight: 300,
                artworkFit: BoxFit.cover,
                keepOldArtwork: true,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            album.album,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
          ),
          Text(
            '$songCount songs',
            style: TextStyle(fontSize: 11, color: theme.colorScheme.primary),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Album detail screen
// ─────────────────────────────────────────────────────────────────────────────

class AlbumDetailScreen extends StatelessWidget {
  final AlbumModel album;

  const AlbumDetailScreen({super.key, required this.album});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final music = context.watch<MusicProvider>();
    final query = OnAudioQuery();

    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<List<SongModel>>(
          future: query.querySongs(
            sortType: SongSortType.TITLE,
            orderType: OrderType.ASC_OR_SMALLER,
            uriType: UriType.EXTERNAL,
          ).then((all) => all
              .where((s) =>
                  (s.album ?? '').toLowerCase().trim() ==
                  album.album.toLowerCase().trim())
              .toList()),
          builder: (_, snap) {
            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Header
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 4),
                        child: IconButton(
                          icon: Icon(Icons.keyboard_arrow_down_rounded,
                              size: 32, color: theme.colorScheme.primary),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 48),
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: QueryArtworkWidget(
                              id: album.id,
                              type: ArtworkType.ALBUM,
                              nullArtworkWidget: Container(
                                decoration: BoxDecoration(
                                  color: theme.colorScheme
                                      .surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Icon(Icons.album_rounded,
                                    size: 64,
                                    color: theme.colorScheme.primary
                                        .withOpacity(0.4)),
                              ),
                              artworkWidth: 600,
                              artworkHeight: 600,
                              artworkFit: BoxFit.cover,
                              keepOldArtwork: true,
                              quality: 100,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              album.album,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              snap.hasData
                                  ? '${snap.data!.length} songs'
                                  : '${album.numOfSongs} songs',
                              style: TextStyle(
                                  color: theme.colorScheme.primary,
                                  fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Divider(
                          height: 1,
                          color: theme.dividerColor,
                          indent: 20,
                          endIndent: 20),
                    ],
                  ),
                ),

                if (!snap.hasData)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: Center(
                        child: CircularProgressIndicator(
                            color: theme.colorScheme.primary, strokeWidth: 2),
                      ),
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) {
                        final s = snap.data![i];
                        final globalIdx =
                            music.songs.indexWhere((song) => song.id == s.id);
                        final isPlaying =
                            globalIdx >= 0 && music.currentIndex == globalIdx;

                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 4),
                          leading: SizedBox(
                            width: 28,
                            child: Center(
                              child: Text(
                                '${i + 1}',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: isPlaying
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.onSurface
                                          .withOpacity(0.4),
                                ),
                              ),
                            ),
                          ),
                          title: Text(
                            s.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: isPlaying
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onSurface,
                            ),
                          ),
                          subtitle: Text(
                            s.artist ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.colorScheme.onSurface
                                  .withOpacity(0.5),
                            ),
                          ),
                          trailing: isPlaying
                              ? Icon(Icons.equalizer_rounded,
                                  color: theme.colorScheme.primary, size: 18)
                              : null,
                          onTap: () {
                            if (globalIdx >= 0) {
                              music.play(globalIdx);
                            }
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const PlayerScreen()),
                            );
                          },
                        );
                      },
                      childCount: snap.data!.length,
                    ),
                  ),

                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            );
          },
        ),
      ),
    );
  }
}