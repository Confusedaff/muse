class Song {
  final int id;
  final String title;
  final String artist;
  final String album;
  final String? genre;
  final int? year;
  final int duration; // ms
  final String uri;
  final int? albumId;
  final int? trackNumber;
  final int? dateModified;

  const Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.duration,
    required this.uri,
    this.genre,
    this.year,
    this.albumId,
    this.trackNumber,
    this.dateModified,
  });

  String get durationString {
    final d = Duration(milliseconds: duration);
    final min = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final sec = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '${d.inHours > 0 ? '${d.inHours}:' : ''}$min:$sec';
  }
}

enum SortField { title, artist, album, genre, year, trackNumber, dateModified }
enum SortOrder { ascending, descending }
