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
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 32),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  IconButton(icon: const Icon(Icons.timer_outlined, size: 22), onPressed: () {}),
                  IconButton(icon: const Icon(Icons.queue_music_rounded, size: 22), onPressed: () {}),
                  IconButton(icon: const Icon(Icons.lyrics_outlined, size: 22), onPressed: () {}),
                  // Repeat
                  _RepeatButton(),
                  IconButton(icon: const Icon(Icons.more_vert, size: 22), onPressed: () {}),
                ],
              ),
            ),
            const Spacer(flex: 2),
            // Album art
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: AspectRatio(
                aspectRatio: 1,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: QueryArtworkWidget(
                    id: song.albumId ?? song.id,
                    type: ArtworkType.ALBUM,
                    nullArtworkWidget: Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.music_note_rounded,
                        size: 80,
                        color: theme.colorScheme.primary.withOpacity(0.5),
                      ),
                    ),
                    artworkBorder: BorderRadius.circular(16),
                    artworkFit: BoxFit.cover,
                    keepOldArtwork: true,
                  ),
                ),
              ),
            ),
            const Spacer(flex: 2),
            // Song info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  Text(
                    song.title,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleLarge?.copyWith(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    song.artist,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: theme.colorScheme.primary, fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Progress
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _ProgressBar(),
            ),
            const SizedBox(height: 8),
            // Controls
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Shuffle
                  IconButton(
                    icon: Icon(
                      Icons.shuffle_rounded,
                      color: music.shuffle ? theme.colorScheme.primary : theme.colorScheme.onSurface.withOpacity(0.4),
                    ),
                    onPressed: music.toggleShuffle,
                  ),
                  // Previous
                  IconButton(
                    icon: Icon(Icons.skip_previous_rounded, size: 36, color: theme.colorScheme.onSurface),
                    onPressed: music.previous,
                  ),
                  // Play/Pause
                  StreamBuilder<PlayerState>(
                    stream: music.playerStateStream,
                    builder: (_, snap) {
                      final playing = snap.data?.playing ?? false;
                      return GestureDetector(
                        onTap: music.playPause,
                        child: Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                            color: theme.colorScheme.onPrimary,
                            size: 36,
                          ),
                        ),
                      );
                    },
                  ),
                  // Next
                  IconButton(
                    icon: Icon(Icons.skip_next_rounded, size: 36, color: theme.colorScheme.onSurface),
                    onPressed: music.next,
                  ),
                  // Repeat placeholder - empty space
                  const SizedBox(width: 48),
                ],
              ),
            ),
            const Spacer(flex: 1),
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
            final fraction = dur.inMilliseconds > 0 ? pos.inMilliseconds / dur.inMilliseconds : 0.0;

            return Column(
              children: [
                SliderTheme(
                  data: Theme.of(context).sliderTheme.copyWith(
                    trackHeight: 3,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                  ),
                  child: Slider(
                    value: fraction.clamp(0.0, 1.0),
                    onChanged: (v) => music.seek(Duration(milliseconds: (v * dur.inMilliseconds).round())),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_fmt(pos), style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.5))),
                      Text(_fmt(dur), style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.5))),
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
    return '$m:$s';
  }
}

class _RepeatButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final music = context.watch<MusicProvider>();
    final theme = Theme.of(context);
    final color = music.repeatMode != RepeatMode.none
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurface.withOpacity(0.4);

    return IconButton(
      icon: Icon(
        music.repeatMode == RepeatMode.one ? Icons.repeat_one_rounded : Icons.repeat_rounded,
        color: color,
        size: 22,
      ),
      onPressed: music.cycleRepeat,
    );
  }
}
