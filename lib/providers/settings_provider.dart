import 'package:flutter/material.dart';
import '../models/song.dart';

class SettingsProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;
  bool _darkLyrics = true;
  double _lyricsFontSize = 28;
  FontWeight _lyricsFontWeight = FontWeight.w600;
  double _lyricsLineHeight = 32;
  double _lyricsLetterSpacing = 0;
  TextAlign _lyricsAlignment = TextAlign.start;
  bool _audioFocus = true;
  bool _jumpToBeginning = true;
  bool _ignoreShortTracks = true;
  bool _refreshOnLaunch = true;
  bool _filterInstead = false;
  SortField _sortField = SortField.title;
  SortOrder _sortOrder = SortOrder.ascending;
  int _defaultTab = 1; // tracks

  ThemeMode get themeMode => _themeMode;
  bool get darkLyrics => _darkLyrics;
  double get lyricsFontSize => _lyricsFontSize;
  FontWeight get lyricsFontWeight => _lyricsFontWeight;
  double get lyricsLineHeight => _lyricsLineHeight;
  double get lyricsLetterSpacing => _lyricsLetterSpacing;
  TextAlign get lyricsAlignment => _lyricsAlignment;
  bool get audioFocus => _audioFocus;
  bool get jumpToBeginning => _jumpToBeginning;
  bool get ignoreShortTracks => _ignoreShortTracks;
  bool get refreshOnLaunch => _refreshOnLaunch;
  bool get filterInstead => _filterInstead;
  SortField get sortField => _sortField;
  SortOrder get sortOrder => _sortOrder;
  int get defaultTab => _defaultTab;

  void setThemeMode(ThemeMode m) { _themeMode = m; notifyListeners(); }
  void setDarkLyrics(bool v) { _darkLyrics = v; notifyListeners(); }
  void setLyricsFontSize(double v) { _lyricsFontSize = v; notifyListeners(); }
  void setLyricsFontWeight(FontWeight v) { _lyricsFontWeight = v; notifyListeners(); }
  void setLyricsLineHeight(double v) { _lyricsLineHeight = v; notifyListeners(); }
  void setLyricsLetterSpacing(double v) { _lyricsLetterSpacing = v; notifyListeners(); }
  void setLyricsAlignment(TextAlign v) { _lyricsAlignment = v; notifyListeners(); }
  void setAudioFocus(bool v) { _audioFocus = v; notifyListeners(); }
  void setJumpToBeginning(bool v) { _jumpToBeginning = v; notifyListeners(); }
  void setIgnoreShortTracks(bool v) { _ignoreShortTracks = v; notifyListeners(); }
  void setRefreshOnLaunch(bool v) { _refreshOnLaunch = v; notifyListeners(); }
  void setFilterInstead(bool v) { _filterInstead = v; notifyListeners(); }
  void setSortField(SortField f) { _sortField = f; notifyListeners(); }
  void setSortOrder(SortOrder o) { _sortOrder = o; notifyListeners(); }
  void setDefaultTab(int t) { _defaultTab = t; notifyListeners(); }
}
