import 'package:mangacampus_repo/models/models.dart';
import 'package:mangacampus_repo/sources/base_source.dart';

class MangaBuddy extends BaseSource {
  @override
  final String name = "MangaBuddy";
  @override
  final String baseUrl = "https://mangabuddy.com";
  @override
  final String lang = "en";

  @override
  Future<List<Manga>> getPopular(int page) async {
    final doc = await fetchHtml("$baseUrl/latest?page=$page");
    return doc.querySelectorAll(".manga-item, .item").map((e) => Manga(
      title: textOf(e, ".title, a.name") ?? "Unknown",
      url: urljoin(baseUrl, attrOf(e, "a", "href") ?? ""),
      thumbnailUrl: attrOf(e, "img", "data-src") ?? attrOf(e, "img", "src") ?? "",
    )).toList();
  }

  @override
  Future<List<Manga>> search(String query, int page) async {
    final doc = await fetchHtml("$baseUrl/search?q=$query&page=$page");
    return doc.querySelectorAll(".manga-item, .item").map((e) => Manga(
      title: textOf(e, ".title, a.name") ?? "Unknown",
      url: urljoin(baseUrl, attrOf(e, "a", "href") ?? ""),
      thumbnailUrl: attrOf(e, "img", "data-src") ?? attrOf(e, "img", "src") ?? "",
    )).toList();
  }

  @override
  Future<MangaDetails> getDetails(String mangaUrl) async {
    final doc = await fetchHtml(mangaUrl);
    return MangaDetails(
      title: textOf(doc.body, "h1") ?? "",
      description: textOf(doc.body, ".summary-content") ?? "",
      genres: doc.querySelectorAll(".genres a").map((e) => e.text.trim()).toList(),
      status: textOf(doc.body, ".status-info") ?? "Unknown",
      thumbnailUrl: attrOf(doc.body, "meta[property='og:image']", "content") ?? "",
    );
  }

  @override
  Future<List<Chapter>> getChapters(String mangaUrl) async {
    final doc = await fetchHtml(mangaUrl);
    return doc.querySelectorAll("#chapter-list li").map((e) => Chapter(
      name: textOf(e, ".chapter-name") ?? "Chapter",
      url: urljoin(baseUrl, attrOf(e, "a", "href") ?? ""),
    )).toList();
  }

  @override
  Future<List<String>> getPages(String chapterUrl) async {
    final doc = await fetchHtml(chapterUrl);
    return doc.querySelectorAll(".reader-area img").map((e) => attrOf(e, null, "data-src") ?? e.attributes['src'] ?? "").toList();
  }
}
