import '../../../models/models.dart';
import '../../../sources/base_source.dart';

class AsuraScans extends BaseSource {
  @override
  final String name = "Asura Scans";
  @override
  final String baseUrl = "https://asuracomic.net";
  @override
  final String lang = "en";

  @override
  Future<List<Manga>> getPopular(int page) async {
    final document = await fetchHtml("$baseUrl/series?page=$page&status=all&type=all&order=popular");
    final elements = document.querySelectorAll("a[href*='/series/']");
    return elements.where((e) => e.querySelector("img") != null).map((e) => Manga(
      title: textOf(e, "span.font-bold") ?? textOf(e, "div.text-white") ?? "Unknown",
      url: urljoin(baseUrl, e.attributes['href'] ?? ""),
      thumbnailUrl: attrOf(e, "img", "src") ?? "",
    )).toList();
  }

  @override
  Future<List<Manga>> search(String query, int page) async {
    final document = await fetchHtml("$baseUrl/series?search=$query&page=$page");
    final elements = document.querySelectorAll("a[href*='/series/']");
    return elements.where((e) => e.querySelector("img") != null).map((e) => Manga(
      title: textOf(e, "span.font-bold") ?? textOf(e, "div.text-white") ?? "Unknown",
      url: urljoin(baseUrl, e.attributes['href'] ?? ""),
      thumbnailUrl: attrOf(e, "img", "src") ?? "",
    )).toList();
  }

  @override
  Future<MangaDetails> getDetails(String mangaUrl) async {
    final doc = await fetchHtml(mangaUrl);
    return MangaDetails(
      title: textOf(doc.body, "h1") ?? "",
      description: textOf(doc.body, "span.font-medium.text-sm") ?? "",
      genres: doc.querySelectorAll("button.bg-\\[\\#343434\\], a.bg-\\[\\#343434\\]").map((e) => e.text.trim()).toList(),
      status: "Unknown",
      thumbnailUrl: attrOf(doc.body, "img[alt='poster']", "src") ?? attrOf(doc.body, "img.w-full.h-full", "src") ?? "",
    );
  }

  @override
  Future<List<Chapter>> getChapters(String mangaUrl) async {
    final doc = await fetchHtml(mangaUrl);
    final elements = doc.querySelectorAll("div.group.flex.justify-between, a.group.flex.justify-between");
    return elements.map((e) => Chapter(
      name: textOf(e, "h3") ?? textOf(e, "span.font-medium") ?? "Chapter",
      url: urljoin(baseUrl, (e.localName == 'a' ? e.attributes['href'] : attrOf(e, "a", "href")) ?? ""),
      dateUploaded: textOf(e, "span.text-\\[\\#A2A2A2\\]") ?? textOf(e, "span.text-gray-400"),
    )).toList();
  }

  @override
  Future<List<String>> getPages(String chapterUrl) async {
    final doc = await fetchHtml(chapterUrl);
    return doc.querySelectorAll("img.mx-auto, div.flex.flex-col img").map((e) => e.attributes['src'] ?? "").where((s) => s.isNotEmpty).toList();
  }
}
