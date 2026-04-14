import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:audio_session/audio_session.dart';
import '../models/song.dart';

// Playback cycle order (tapping the top-bar button):
//   none  → shuffle → one  → all  → none …
// none    = no repeat, no shuffle
// shuffle = shuffle on, no repeat
// one     = repeat this song (shuffle off)
// all     = repeat playlist (shuffle off)
enum RepeatMode { none, all, one }

class MusicProvider extends ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();
  final OnAudioQuery _query = OnAudioQuery();

  List<Song> _songs = [];
  List<Song> _filtered = [];
  int _currentIndex = -1;
  bool _loading = true;
  bool _hasPermission = false;
  String _searchQuery = '';
  RepeatMode _repeatMode = RepeatMode.none;
  bool _shuffle = false;
  SortField _sortField = SortField.title;
  SortOrder _sortOrder = SortOrder.ascending;

  List<Song> get songs =>
      _filtered.isEmpty && _searchQuery.isEmpty ? _songs : _filtered;
  Song? get currentSong =>
      _currentIndex >= 0 && _currentIndex < songs.length
          ? songs[_currentIndex]
          : null;
  bool get loading => _loading;
  bool get hasPermission => _hasPermission;
  AudioPlayer get player => _player;
  RepeatMode get repeatMode => _repeatMode;
  bool get shuffle => _shuffle;
  int get currentIndex => _currentIndex;
  SortField get sortField => _sortField;
  SortOrder get sortOrder => _sortOrder;

  Stream<PlayerState> get playerStateStream => _player.playerStateStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<Duration> get positionStream => _player.positionStream;

  MusicProvider() {
    _init();
  }

  Future<void> _init() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());

    _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        _onTrackComplete();
      }
    });

    await requestPermission();
  }

  Future<void> requestPermission() async {
    final status = await Permission.audio.request();
    if (status.isGranted) {
      _hasPermission = true;
      await loadSongs();
    } else {
      _hasPermission = false;
      _loading = false;
    }
    notifyListeners();
  }

  Future<void> loadSongs() async {
    _loading = true;
    notifyListeners();

    try {
      final result = await _query.querySongs(
        sortType: SongSortType.TITLE,
        orderType: OrderType.ASC_OR_SMALLER,
        uriType: UriType.EXTERNAL,
        ignoreCase: true,
      );

      _songs = result
          .where((s) => s.duration != null && s.duration! > 30000)
          .map((s) => Song(
                id: s.id,
                title: s.title,
                artist: s.artist ?? '<unknown>',
                album: s.album ?? '<unknown>',
                duration: s.duration ?? 0,
                uri: s.uri ?? '',
                genre: s.genre,
                year: null,
                albumId: s.albumId,
                trackNumber: s.track,
                dateModified: s.dateModified,
              ))
          .toList();

      _sortSongs();
    } catch (e) {
      debugPrint('Error loading songs: $e');
    }

    _loading = false;
    notifyListeners();
  }

  void _sortSongs() {
    int Function(Song, Song) compare;
    switch (_sortField) {
      case SortField.title:
        compare = (a, b) =>
            a.title.toLowerCase().compareTo(b.title.toLowerCase());
      case SortField.artist:
        compare = (a, b) =>
            a.artist.toLowerCase().compareTo(b.artist.toLowerCase());
      case SortField.album:
        compare = (a, b) =>
            a.album.toLowerCase().compareTo(b.album.toLowerCase());
      case SortField.genre:
        compare = (a, b) => (a.genre ?? '').compareTo(b.genre ?? '');
      case SortField.year:
        compare = (a, b) => (a.year ?? 0).compareTo(b.year ?? 0);
      case SortField.trackNumber:
        compare =
            (a, b) => (a.trackNumber ?? 0).compareTo(b.trackNumber ?? 0);
      case SortField.dateModified:
        compare =
            (a, b) => (a.dateModified ?? 0).compareTo(b.dateModified ?? 0);
    }
    _songs.sort(compare);
    if (_sortOrder == SortOrder.descending) _songs = _songs.reversed.toList();
    if (_searchQuery.isNotEmpty) _applyFilter();
  }

  void setSort(SortField field, SortOrder order) {
    _sortField = field;
    _sortOrder = order;
    _sortSongs();
    notifyListeners();
  }

  void search(String query) {
    _searchQuery = query;
    _applyFilter();
    notifyListeners();
  }

  void _applyFilter() {
    if (_searchQuery.isEmpty) {
      _filtered = [];
    } else {
      final q = _searchQuery.toLowerCase();
      _filtered = _songs
          .where((s) =>
              s.title.toLowerCase().contains(q) ||
              s.artist.toLowerCase().contains(q) ||
              s.album.toLowerCase().contains(q))
          .toList();
    }
  }

  Future<void> play(int index) async {
    final list = songs;
    if (index < 0 || index >= list.length) return;
    _currentIndex = index;
    final song = list[index];
    try {
      await _player.setAudioSource(AudioSource.uri(Uri.parse(song.uri)));
      await _player.play();
    } catch (e) {
      debugPrint('Play error: $e');
    }
    notifyListeners();
  }

  Future<void> playPause() async {
    if (_player.playing) {
      await _player.pause();
    } else {
      await _player.play();
    }
  }

  Future<void> next() async {
    final list = songs;
    if (list.isEmpty) return;
    if (_shuffle) {
      final indices =
          List.generate(list.length, (i) => i)..remove(_currentIndex);
      if (indices.isEmpty) return;
      indices.shuffle();
      await play(indices.first);
    } else {
      await play((_currentIndex + 1) % list.length);
    }
  }

  Future<void> previous() async {
    if (_player.position.inSeconds > 3) {
      await _player.seek(Duration.zero);
      return;
    }
    final list = songs;
    if (list.isEmpty) return;
    await play((_currentIndex - 1 + list.length) % list.length);
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  void _onTrackComplete() {
    if (_shuffle) {
      next();
      return;
    }
    switch (_repeatMode) {
      case RepeatMode.one:
        _player.seek(Duration.zero);
        _player.play();
      case RepeatMode.all:
        next();
      case RepeatMode.none:
        final list = songs;
        if (_currentIndex < list.length - 1) {
          next();
        }
        // else: last song, just stop
    }
  }

  /// Cycles playback mode in this order:
  ///   none (no repeat, no shuffle)
  ///   → shuffle (shuffle on)
  ///   → repeat one (shuffle off, repeat this song)
  ///   → repeat all (shuffle off, repeat playlist)
  ///   → none …
  void cyclePlaybackMode() {
    if (!_shuffle && _repeatMode == RepeatMode.none) {
      // none → shuffle
      _shuffle = true;
      _repeatMode = RepeatMode.none;
    } else if (_shuffle) {
      // shuffle → repeat one
      _shuffle = false;
      _repeatMode = RepeatMode.one;
    } else if (_repeatMode == RepeatMode.one) {
      // repeat one → repeat all
      _repeatMode = RepeatMode.all;
    } else {
      // repeat all → none
      _repeatMode = RepeatMode.none;
    }
    notifyListeners();
  }

  /// Legacy individual toggles (kept for compatibility if used elsewhere)
  void cycleRepeat() {
    switch (_repeatMode) {
      case RepeatMode.none:
        _repeatMode = RepeatMode.all;
      case RepeatMode.all:
        _repeatMode = RepeatMode.one;
      case RepeatMode.one:
        _repeatMode = RepeatMode.none;
    }
    notifyListeners();
  }

  void toggleShuffle() {
    _shuffle = !_shuffle;
    notifyListeners();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}

extension ListExt<T> on List<T> {
  int get size => length;
}