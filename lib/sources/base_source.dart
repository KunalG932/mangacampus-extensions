import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart';
import '../models/models.dart';

abstract class BaseSource {
  abstract final String name;
  abstract final String baseUrl;
  abstract final String lang;

  Map<String, String> get headers => {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36',
        'Referer': baseUrl,
      };

  Future<List<Manga>> getPopular(int page);
  Future<List<Manga>> search(String query, int page);
  Future<MangaDetails> getDetails(String mangaUrl);
  Future<List<Chapter>> getChapters(String mangaUrl);
  Future<List<String>> getPages(String chapterUrl);

  String urljoin(String base, String path) {
    if (path.startsWith('http')) return path;
    if (path.startsWith('//')) return 'https:$path';
    final uri = Uri.parse(base);
    return uri.resolve(path).toString();
  }

  String? textOf(Element? element, String? selector) {
    if (element == null) return null;
    if (selector == null) return element.text.trim();
    return element.querySelector(selector)?.text.trim();
  }

  String? attrOf(Element? element, String? selector, String attr) {
    if (element == null) return null;
    if (selector == null) return element.attributes[attr];
    return element.querySelector(selector)?.attributes[attr];
  }

  Future<Document> fetchHtml(String url) async {
    try {
      final response = await http.get(Uri.parse(url), headers: headers);
      if (response.statusCode == 200) return parse(response.body);
      throw Exception('HTTP ${response.statusCode}');
    } catch (e) {
      throw Exception('Network Error: $e');
    }
  }
}
