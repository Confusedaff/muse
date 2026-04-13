import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';

class ArtistsScreen extends StatefulWidget {
  const ArtistsScreen({super.key});

  @override
  State<ArtistsScreen> createState() => _ArtistsScreenState();
}

class _ArtistsScreenState extends State<ArtistsScreen> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final _query = OnAudioQuery();

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);

    return FutureBuilder<List<ArtistModel>>(
      future: _query.queryArtists(sortType: ArtistSortType.ARTIST, orderType: OrderType.ASC_OR_SMALLER),
      builder: (_, snap) {
        if (!snap.hasData) {
          return Center(child: CircularProgressIndicator(color: theme.colorScheme.primary, strokeWidth: 2));
        }
        final artists = snap.data!;
        if (artists.isEmpty) {
          return Center(child: Text('No artists', style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.4))));
        }
        return ListView.builder(
          physics: const BouncingScrollPhysics(),
          itemCount: artists.length,
          itemExtent: 64,
          itemBuilder: (_, i) {
            final a = artists[i];
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                child: Text(
                  a.artist.isNotEmpty ? a.artist[0].toUpperCase() : '?',
                  style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w600),
                ),
              ),
              title: Text(a.artist, maxLines: 1, overflow: TextOverflow.ellipsis),
              subtitle: Text('${a.numberOfAlbums ?? 0} albums · ${a.numberOfTracks ?? 0} tracks'),
              trailing: Icon(Icons.chevron_right, color: theme.colorScheme.onSurface.withOpacity(0.3)),
            );
          },
        );
      },
    );
  }
}
