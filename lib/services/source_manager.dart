import '../sources/base_source.dart';
import '../sources/mangakakalot.dart';
import '../sources/asura_scans.dart';
import '../sources/mangabuddy.dart';

class SourceManager {
  static final SourceManager _instance = SourceManager._internal();
  factory SourceManager() => _instance;
  SourceManager._internal() {
    registerSource(MangaKakalot());
    registerSource(AsuraScans());
    registerSource(MangaBuddy());
  }

  final List<BaseSource> _sources = [];

  List<BaseSource> get sources => List.unmodifiable(_sources);

  void registerSource(BaseSource source) {
    if (!_sources.any((s) => s.name == source.name)) {
      _sources.add(source);
    }
  }

  BaseSource? getSourceByName(String name) {
    try {
      return _sources.firstWhere((s) => s.name == name);
    } catch (_) {
      return null;
    }
  }
}
