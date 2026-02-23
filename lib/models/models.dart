class Manga {
  final String title;
  final String url;
  final String thumbnailUrl;

  Manga({
    required this.title,
    required this.url,
    required this.thumbnailUrl,
  });

  @override
  String toString() => 'Manga(title: $title, url: $url)';
}

class Chapter {
  final String name;
  final String url;
  final String? dateUploaded;

  Chapter({
    required this.name,
    required this.url,
    this.dateUploaded,
  });

  @override
  String toString() => 'Chapter(name: $name, url: $url)';
}

class MangaDetails {
  final String title;
  final String description;
  final String? author;
  final String? artist;
  final List<String> genres;
  final String status;
  final String thumbnailUrl;

  MangaDetails({
    required this.title,
    required this.description,
    this.author,
    this.artist,
    required this.genres,
    required this.status,
    required this.thumbnailUrl,
  });
}

class ExtensionRepo {
  final String name;
  final String url; // Base URL of the repo (e.g. https://raw.githubusercontent.com/user/repo/main)
  
  ExtensionRepo({required this.name, required this.url});
}

class RemoteExtension {
  final String name;
  final String pkg;
  final String version;
  final String lang;
  final String downloadUrl;
  final String? iconUrl;

  RemoteExtension({
    required this.name,
    required this.pkg,
    required this.version,
    required this.lang,
    required this.downloadUrl,
    this.iconUrl,
  });

  factory RemoteExtension.fromJson(Map<String, dynamic> json, String repoBaseUrl) {
    final base = repoBaseUrl.endsWith('/') ? repoBaseUrl.substring(0, repoBaseUrl.length - 1) : repoBaseUrl;
    // Tachiyomi-style: apk at repo root (e.g. index has "apk": "tachiyomi-all.ahottie-v1.4.2.apk")
    final apk = json['apk'] as String?;
    final downloadUrl = apk != null && apk.toString().endsWith('.apk')
        ? '$base/$apk'
        : '$base/sources/${json['code'] ?? json['file'] ?? apk}';
    final pkg = json['pkg']?.toString() ?? '';
    final iconUrl = json['icon'] != null 
        ? '$base/${json['icon']}' 
        : (pkg.isNotEmpty ? '$base/icons/$pkg.png' : null);

    return RemoteExtension(
      name: json['name']?.toString() ?? 'Unknown',
      pkg: pkg,
      version: json['version']?.toString() ?? '0',
      lang: json['lang']?.toString() ?? 'all',
      downloadUrl: downloadUrl,
      iconUrl: iconUrl,
    );

  }
}
