# 🎵 Muse

A minimal, lightning-fast local music player for Android — inspired by Lotus.

## Features

- 🎵 **Local music playback** via `just_audio` (no internet needed)
- 🎨 **Deep green dark theme** with Material You dynamic colors
- 📂 **Tracks, Albums, Artists, Playlists** tabs
- 🔀 **Shuffle & repeat** (none / all / one)
- 🔍 **Search & sort** by title, artist, album, genre, year, track number, date
- ⚙️ **Settings**: Playback, Music scan, Theme, Lyrics, Tabs
- 🪶 **Tiny footprint** — only 5 dependencies, no bloat

## Tech Stack

| Package | Purpose |
|---|---|
| `just_audio` | Audio engine |
| `on_audio_query` | MediaStore scanning |
| `provider` | Lightweight state management |
| `audio_session` | Audio focus handling |
| `permission_handler` | Runtime permissions |

## Setup

### Prerequisites
- Flutter 3.x
- Android SDK (minSdk 21, targetSdk 34)

### Build

```bash
cd muse
flutter pub get
flutter run --release
```

### Build APK (smallest size)
```bash
flutter build apk --release --split-per-abi --obfuscate --split-debug-info=build/debug
```

This produces separate APKs per ABI (~8–12 MB each), much smaller than a fat APK.

## Project Structure

```
lib/
├── main.dart              # App entry, theme
├── models/
│   └── song.dart          # Song data model
├── providers/
│   ├── music_provider.dart    # Playback + library state
│   └── settings_provider.dart # User preferences
└── screens/
    ├── home_screen.dart       # Tab navigation
    ├── tracks_screen.dart     # Song list + search/sort
    ├── albums_screen.dart     # Album grid
    ├── artists_screen.dart    # Artist list
    ├── playlists_screen.dart  # Playlists
    ├── player_screen.dart     # Now playing
    ├── mini_player.dart       # Bottom mini player
    └── settings_screen.dart   # All settings
```

## Performance Tips

- `itemExtent` on `ListView.builder` for O(1) scroll performance
- `AutomaticKeepAliveClientMixin` on tabs to avoid rebuilds
- `keepOldArtwork: true` on artwork widgets to prevent flicker
- `BouncingScrollPhysics` for native-feel scroll
- Release builds use R8 tree-shaking automatically

## Permissions

| Permission | Why |
|---|---|
| `READ_MEDIA_AUDIO` | Android 13+ audio access |
| `READ_EXTERNAL_STORAGE` | Android ≤12 audio access |
| `FOREGROUND_SERVICE` | Background playback |
| `WAKE_LOCK` | Keep CPU awake while playing |
