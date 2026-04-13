import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          _SettingsCard(children: [
            _NavTile(icon: Icons.music_note_rounded, title: 'Playback', subtitle: 'Audio focus, equalizer',
              onTap: () => _push(context, const _PlaybackSettings())),
            _NavTile(icon: Icons.radar_rounded, title: 'Music scan', subtitle: 'Filter mode, folder management',
              onTap: () => _push(context, const _MusicScanSettings())),
            _NavTile(icon: Icons.tab_rounded, title: 'Tabs', subtitle: 'Default tab and order',
              onTap: () => _push(context, const _TabsSettings())),
            _NavTile(icon: Icons.playlist_play_rounded, title: 'Playlists', subtitle: 'Search field, import',
              onTap: () => _push(context, const _PlaylistSettings())),
          ]),
          _SettingsCard(children: [
            _NavTile(icon: Icons.palette_rounded, title: 'Theme', subtitle: 'Appearance, palette',
              onTap: () => _push(context, const _ThemeSettings())),
            _NavTile(icon: Icons.lyrics_rounded, title: 'Lyrics', subtitle: 'Font settings, alignment',
              onTap: () => _push(context, const _LyricsSettings())),
          ]),
          _SettingsCard(children: [
            _NavTile(icon: Icons.info_outline_rounded, title: 'About app', subtitle: 'Version, feedback',
              onTap: () => _push(context, const _AboutScreen())),
          ]),
        ],
      ),
    );
  }

  void _push(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Sub-screens
// ──────────────────────────────────────────────────────────────────────────────

class _PlaybackSettings extends StatelessWidget {
  const _PlaybackSettings();

  @override
  Widget build(BuildContext context) {
    final s = context.watch<SettingsProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Playback')),
      body: _SettingsCard(children: [
        SwitchListTile(
          secondary: const Icon(Icons.center_focus_strong_rounded),
          title: const Text('Audio focus'),
          subtitle: const Text('Pause playback when another app needs audio'),
          value: s.audioFocus,
          onChanged: s.setAudioFocus,
        ),
        SwitchListTile(
          secondary: const Icon(Icons.skip_previous_rounded),
          title: const Text('Jump to beginning'),
          subtitle: const Text('Restart current track on first press of previous button'),
          value: s.jumpToBeginning,
          onChanged: s.setJumpToBeginning,
        ),
        SwitchListTile(
          secondary: const Icon(Icons.equalizer_rounded),
          title: const Text('Equalizer'),
          subtitle: const Text('Manually adjust sound'),
          value: false,
          onChanged: null, // system EQ integration
        ),
      ]),
    );
  }
}

class _MusicScanSettings extends StatelessWidget {
  const _MusicScanSettings();

  @override
  Widget build(BuildContext context) {
    final s = context.watch<SettingsProvider>();
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Music scan')),
      body: ListView(
        children: [
          _SettingsCard(children: [
            SwitchListTile(
              secondary: const Icon(Icons.filter_alt_outlined),
              title: const Text('Ignore short tracks'),
              subtitle: const Text('Do not show tracks shorter than 30 seconds'),
              value: s.ignoreShortTracks,
              onChanged: s.setIgnoreShortTracks,
            ),
          ]),
          _SettingsCard(children: [
            SwitchListTile(
              secondary: const Icon(Icons.refresh_rounded),
              title: const Text('Refresh on app launch'),
              subtitle: const Text('Refresh data in MediaStore on launch'),
              value: s.refreshOnLaunch,
              onChanged: s.setRefreshOnLaunch,
            ),
          ]),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Refresh MediaStore'),
              style: FilledButton.styleFrom(
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                foregroundColor: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabsSettings extends StatelessWidget {
  const _TabsSettings();

  static const _tabs = ['Playlists', 'Tracks', 'Albums', 'Artists'];

  @override
  Widget build(BuildContext context) {
    final s = context.watch<SettingsProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Tabs')),
      body: _SettingsCard(
        children: List.generate(_tabs.length, (i) => RadioListTile<int>(
          value: i,
          groupValue: s.defaultTab,
          title: Text(_tabs[i]),
          onChanged: (v) => s.setDefaultTab(v!),
        )),
      ),
    );
  }
}

class _PlaylistSettings extends StatelessWidget {
  const _PlaylistSettings();

  @override
  Widget build(BuildContext context) {
    final s = context.watch<SettingsProvider>();
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Playlists')),
      body: _SettingsCard(children: [
        SwitchListTile(
          secondary: const Icon(Icons.filter_list_rounded),
          title: const Text('Filter instead of search'),
          subtitle: const Text('Replace playlist search with filter'),
          value: s.filterInstead,
          onChanged: s.setFilterInstead,
        ),
        ListTile(
          leading: const Icon(Icons.playlist_add_rounded),
          title: const Text('Import playlist'),
          subtitle: const Text('Add playlist from M3U file'),
          trailing: IconButton(
            icon: Icon(Icons.folder_open_rounded, color: theme.colorScheme.primary),
            onPressed: () {},
          ),
        ),
      ]),
    );
  }
}

class _ThemeSettings extends StatelessWidget {
  const _ThemeSettings();

  @override
  Widget build(BuildContext context) {
    final s = context.watch<SettingsProvider>();
    // final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Theme')),
      body: ListView(
        children: [
          _SettingsCard(
            label: 'Appearance',
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    _ThemeModeButton(label: 'System', icon: Icons.settings_suggest_rounded, mode: ThemeMode.system, current: s.themeMode, onTap: () => s.setThemeMode(ThemeMode.system)),
                    const SizedBox(width: 12),
                    _ThemeModeButton(label: 'Light', icon: Icons.light_mode_rounded, mode: ThemeMode.light, current: s.themeMode, onTap: () => s.setThemeMode(ThemeMode.light)),
                    const SizedBox(width: 12),
                    _ThemeModeButton(label: 'Dark', icon: Icons.dark_mode_rounded, mode: ThemeMode.dark, current: s.themeMode, onTap: () => s.setThemeMode(ThemeMode.dark)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ThemeModeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final ThemeMode mode;
  final ThemeMode current;
  final VoidCallback onTap;

  const _ThemeModeButton({required this.label, required this.icon, required this.mode, required this.current, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selected = mode == current;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? theme.colorScheme.primary.withOpacity(0.15) : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? theme.colorScheme.primary : Colors.transparent, width: 2),
        ),
        child: Column(
          children: [
            Icon(icon, color: selected ? theme.colorScheme.primary : theme.colorScheme.onSurface.withOpacity(0.6), size: 28),
            const SizedBox(height: 6),
            Text(label, style: TextStyle(fontSize: 12, color: selected ? theme.colorScheme.primary : theme.colorScheme.onSurface.withOpacity(0.6))),
          ],
        ),
      ),
    );
  }
}

class _LyricsSettings extends StatelessWidget {
  const _LyricsSettings();

  @override
  Widget build(BuildContext context) {
    final s = context.watch<SettingsProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Lyrics')),
      body: ListView(
        children: [
          _SettingsCard(children: [
            SwitchListTile(
              secondary: const Icon(Icons.dark_mode_rounded),
              title: const Text('Dark theme for lyrics'),
              subtitle: const Text('Apply dark theme even if light mode is active'),
              value: s.darkLyrics,
              onChanged: s.setDarkLyrics,
            ),
          ]),
          // Preview
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF2D5A2D),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'This shows how lyrics will look with these settings',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: s.lyricsFontSize * 0.6,
                  fontWeight: s.lyricsFontWeight,
                  height: s.lyricsLineHeight / s.lyricsFontSize,
                  letterSpacing: s.lyricsLetterSpacing,
                ),
              ),
            ),
          ),
          _SettingsCard(children: [
            _SliderTile(label: 'Font size', value: s.lyricsFontSize, min: 12, max: 48, divisions: 36,
              onChanged: s.setLyricsFontSize),
            _SliderTile(label: 'Font weight', value: s.lyricsFontWeight.value.toDouble(), min: 100, max: 900, divisions: 8,
              onChanged: (v) => s.setLyricsFontWeight(FontWeight.values.firstWhere(
                (fw) => fw.value == v.round(), orElse: () => FontWeight.w400))),
            _SliderTile(label: 'Line height', value: s.lyricsLineHeight, min: 16, max: 64, divisions: 48,
              onChanged: s.setLyricsLineHeight),
            _SliderTile(label: 'Letter spacing', value: s.lyricsLetterSpacing, min: -4, max: 8, divisions: 24,
              onChanged: s.setLyricsLetterSpacing),
          ]),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: OutlinedButton(
                onPressed: () {
                  s.setLyricsFontSize(28);
                  s.setLyricsFontWeight(FontWeight.w600);
                  s.setLyricsLineHeight(32);
                  s.setLyricsLetterSpacing(0);
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.colorScheme.onSurface,
                  side: BorderSide(color: theme.colorScheme.onSurface.withOpacity(0.2)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                child: const Text('Reset'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SliderTile extends StatelessWidget {
  final String label;
  final double value;
  final double min, max;
  final int divisions;
  final ValueChanged<double> onChanged;

  const _SliderTile({required this.label, required this.value, required this.min, required this.max, required this.divisions, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Row(
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
              const Spacer(),
              Text(value.round().toString(), style: TextStyle(color: Theme.of(context).colorScheme.primary)),
            ],
          ),
          Slider(value: value.clamp(min, max), min: min, max: max, divisions: divisions, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _AboutScreen extends StatelessWidget {
  const _AboutScreen();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('About app')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96, height: 96,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.music_note_rounded, size: 56, color: theme.colorScheme.primary),
            ),
            const SizedBox(height: 24),
            Text('muse', style: theme.textTheme.displayLarge?.copyWith(fontSize: 40)),
            const SizedBox(height: 8),
            Text('Version 1.0.0', style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.5))),
            const SizedBox(height: 4),
            Text('A minimal local music player', style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.5))),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Shared widgets
// ──────────────────────────────────────────────────────────────────────────────

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  final String? label;

  const _SettingsCard({required this.children, this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8, left: 4),
              child: Text(label!, style: TextStyle(color: theme.colorScheme.primary, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 1)),
            ),
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: children.asMap().entries.map((e) {
                final isLast = e.key == children.length - 1;
                return Column(
                  children: [
                    e.value,
                    if (!isLast) Divider(height: 1, color: theme.dividerColor, indent: 56),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _NavTile({required this.icon, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.primary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle),
      trailing: Icon(Icons.chevron_right, color: theme.colorScheme.onSurface.withOpacity(0.3)),
      onTap: onTap,
    );
  }
}
