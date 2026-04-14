import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';
import '../providers/music_provider.dart';
import 'player_screen.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final music = context.watch<MusicProvider>();
    final song = music.currentSong;
    if (song == null) return const SizedBox.shrink();

    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const PlayerScreen()),
      ),
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Song row ────────────────────────────────────────────
            SizedBox(
              height: 68,
              child: Row(
                children: [
                  const SizedBox(width: 10),
                  // Artwork
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: QueryArtworkWidget(
                      id: song.albumId ?? song.id,
                      type: ArtworkType.ALBUM,
                      nullArtworkWidget: Container(
                        width: 48,
                        height: 48,
                        color: theme.colorScheme.primary.withOpacity(0.15),
                        child: Icon(Icons.music_note,
                            color: theme.colorScheme.primary, size: 24),
                      ),
                      artworkWidth: 48,
                      artworkHeight: 48,
                      artworkFit: BoxFit.cover,
                      keepOldArtwork: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Title + Artist
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          song.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontWeight: FontWeight.w500, fontSize: 14),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          song.artist,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: theme.colorScheme.primary, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  // Play / Pause
                  StreamBuilder<PlayerState>(
                    stream: music.playerStateStream,
                    builder: (_, snap) {
                      final playing = snap.data?.playing ?? false;
                      return IconButton(
                        icon: Icon(
                          playing
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          size: 28,
                          color: theme.colorScheme.onSurface,
                        ),
                        onPressed: music.playPause,
                      );
                    },
                  ),
                  // Next
                  IconButton(
                    icon: Icon(Icons.skip_next_rounded,
                        size: 28, color: theme.colorScheme.onSurface),
                    onPressed: music.next,
                  ),
                  const SizedBox(width: 4),
                ],
              ),
            ),

            // ── Thin progress bar ────────────────────────────────────
            _MiniProgressBar(),

            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}

/// Slim progress indicator that sits at the bottom of the mini-player card.
class _MiniProgressBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final music = context.watch<MusicProvider>();
    final theme = Theme.of(context);

    return StreamBuilder<Duration>(
      stream: music.positionStream,
      builder: (_, posSnap) {
        return StreamBuilder<Duration?>(
          stream: music.durationStream,
          builder: (_, durSnap) {
            final pos = posSnap.data ?? Duration.zero;
            final dur = durSnap.data ?? Duration.zero;
            final fraction = dur.inMilliseconds > 0
                ? (pos.inMilliseconds / dur.inMilliseconds).clamp(0.0, 1.0)
                : 0.0;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: fraction,
                  minHeight: 3,
                  backgroundColor:
                      theme.colorScheme.onSurface.withOpacity(0.12),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.primary,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}