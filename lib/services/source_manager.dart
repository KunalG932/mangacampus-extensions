import '../sources/base_source.dart';
import '../sources/source_registry.dart';

class SourceManager {
  static final SourceManager _instance = SourceManager._internal();
  factory SourceManager() => _instance;
  SourceManager._internal() {
    for (final source in getRegisteredSources()) {
      registerSource(source);
    }
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
