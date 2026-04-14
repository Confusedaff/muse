import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';
import '../providers/music_provider.dart';

class PlayerScreen extends StatelessWidget {
  const PlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final music = context.watch<MusicProvider>();
    final song = music.currentSong;
    final theme = Theme.of(context);

    if (song == null) return const SizedBox.shrink();

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top bar ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.keyboard_arrow_down_rounded,
                        size: 32, color: theme.colorScheme.primary),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(Icons.timer_outlined,
                        size: 22, color: theme.colorScheme.primary),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: Icon(Icons.queue_music_rounded,
                        size: 22, color: theme.colorScheme.primary),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: Icon(Icons.lyrics_outlined,
                        size: 22, color: theme.colorScheme.primary),
                    onPressed: () {},
                  ),
                  // Combined shuffle/repeat cycle button
                  _CycleButton(),
                  IconButton(
                    icon: Icon(Icons.more_vert,
                        size: 22, color: theme.colorScheme.primary),
                    onPressed: () {},
                  ),
                ],
              ),
            ),

            // ── Album art — nearly full width ────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: AspectRatio(
                aspectRatio: 1,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: QueryArtworkWidget(
                    id: song.albumId ?? song.id,
                    type: ArtworkType.ALBUM,
                    nullArtworkWidget: Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.music_note_rounded,
                        size: 80,
                        color: theme.colorScheme.primary.withOpacity(0.5),
                      ),
                    ),
                    artworkBorder: BorderRadius.circular(12),
                    artworkFit: BoxFit.cover,
                    artworkWidth: 800,
                    artworkHeight: 800,
                    keepOldArtwork: true,
                    quality: 100,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ── Song info ────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    song.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    song.artist,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── Progress bar ─────────────────────────────────────────
            _ProgressBar(),

            const SizedBox(height: 4),

            // ── Controls ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left placeholder to balance layout (shuffle removed from here)
                  const SizedBox(width: 40),
                  IconButton(
                    icon: Icon(Icons.skip_previous_rounded,
                        size: 40, color: theme.colorScheme.onSurface),
                    onPressed: music.previous,
                  ),
                  StreamBuilder<PlayerState>(
                    stream: music.playerStateStream,
                    builder: (_, snap) {
                      final playing = snap.data?.playing ?? false;
                      return GestureDetector(
                        onTap: music.playPause,
                        child: Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            playing
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            color: theme.colorScheme.onPrimary,
                            size: 40,
                          ),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.skip_next_rounded,
                        size: 40, color: theme.colorScheme.onSurface),
                    onPressed: music.next,
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
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

            return Column(
              children: [
                SliderTheme(
                  data: theme.sliderTheme.copyWith(
                    trackHeight: 4,
                    thumbShape:
                        const RoundSliderThumbShape(enabledThumbRadius: 8),
                  ),
                  child: Slider(
                    value: fraction,
                    onChanged: (v) => music.seek(Duration(
                        milliseconds: (v * dur.inMilliseconds).round())),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_fmt(pos),
                          style: TextStyle(
                              fontSize: 12,
                              color: theme.colorScheme.onSurface
                                  .withOpacity(0.55))),
                      Text(_fmt(dur),
                          style: TextStyle(
                              fontSize: 12,
                              color: theme.colorScheme.onSurface
                                  .withOpacity(0.55))),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '${d.inHours > 0 ? '${d.inHours}:' : ''}$m:$s';
  }
}

/// Cycles through: none → shuffle → repeat one → repeat all
/// - none       : repeat icon, dim (no highlight)
/// - shuffle    : shuffle icon, highlighted
/// - repeat one : repeat_one icon, highlighted
/// - repeat all : repeat icon, highlighted
class _CycleButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final music = context.watch<MusicProvider>();
    final theme = Theme.of(context);

    // Determine icon and active state based on current mode
    final IconData icon;
    final bool active;

    if (music.shuffle) {
      icon = Icons.shuffle_rounded;
      active = true;
    } else {
      switch (music.repeatMode) {
        case RepeatMode.none:
          icon = Icons.repeat_rounded;
          active = false;
        case RepeatMode.one:
          icon = Icons.repeat_one_rounded;
          active = true;
        case RepeatMode.all:
          icon = Icons.repeat_rounded;
          active = true;
      }
    }

    return IconButton(
      icon: Icon(
        icon,
        size: 22,
        color: active
            ? theme.colorScheme.primary
            : theme.colorScheme.primary.withOpacity(0.4),
      ),
      onPressed: music.cyclePlaybackMode,
    );
  }
}