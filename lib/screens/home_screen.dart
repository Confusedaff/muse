import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/music_provider.dart';
import 'tracks_screen.dart';
import 'mini_player.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final music = context.watch<MusicProvider>();

    if (!music.hasPermission && !music.loading) {
      return _PermissionScreen();
    }

    return const Scaffold(body: _TracksPage());
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Main page: big title + toolbar + tracks list + mini player
// ─────────────────────────────────────────────────────────────────────────────
class _TracksPage extends StatefulWidget {
  const _TracksPage();

  @override
  State<_TracksPage> createState() => _TracksPageState();
}

class _TracksPageState extends State<_TracksPage> {
  final GlobalKey<TracksScreenState> _tracksKey =
      GlobalKey<TracksScreenState>();

  @override
  Widget build(BuildContext context) {
    final music = context.watch<MusicProvider>();
    final theme = Theme.of(context);

    return Column(
      children: [
        // ── Big title header ─────────────────────────────────────
        SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 28, 8, 4),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Center(
                      child: Text(
                        'Tracks',
                        style: theme.textTheme.displayLarge?.copyWith(
                          fontSize: 40,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      child: IconButton(
                        icon: Icon(Icons.settings_outlined,
                            color: theme.colorScheme.primary, size: 22),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const SettingsScreen()),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Accent underline
              Container(
                width: 56,
                height: 2.5,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 4),
            ],
          ),
        ),

        // ── Toolbar: sort | track count | search ────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
          child: Row(
            children: [
              InkWell(
                onTap: () => _tracksKey.currentState?.openSortMenu(),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Icon(Icons.sort_rounded,
                      color: theme.colorScheme.primary, size: 22),
                ),
              ),
              const Spacer(),
              Consumer<MusicProvider>(
                builder: (_, m, __) => Text(
                  '${m.songs.length} tracks',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withOpacity(0.4),
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () => _tracksKey.currentState?.startSearch(),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Icon(Icons.search,
                      color: theme.colorScheme.primary, size: 22),
                ),
              ),
            ],
          ),
        ),

        // ── Tracks list ──────────────────────────────────────────
        Expanded(child: TracksScreen(key: _tracksKey)),

        // ── Mini player ──────────────────────────────────────────
        if (music.currentSong != null) const MiniPlayer(),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Permission screen
// ─────────────────────────────────────────────────────────────────────────────
class _PermissionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.music_note_rounded,
                      size: 50, color: theme.colorScheme.primary),
                ),
                const SizedBox(height: 32),
                Text('muse',
                    style:
                        theme.textTheme.displayLarge?.copyWith(fontSize: 42)),
                const SizedBox(height: 16),
                Text(
                  'Grant audio permission to play your music',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 40),
                FilledButton(
                  onPressed: () =>
                      context.read<MusicProvider>().requestPermission(),
                  style: FilledButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24)),
                  ),
                  child: const Text('Grant Permission',
                      style: TextStyle(fontSize: 15)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}