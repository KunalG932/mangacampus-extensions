import '../models/models.dart';
import 'base_source.dart';

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
    final elements = document.querySelectorAll("div.grid > div.relative.group");
    return elements.map((e) => Manga(
      title: textOf(e, "span.block.text-\\[13\\.3px\\].font-bold") ?? "Unknown",
      url: attrOf(e, "a", "href") ?? "",
      thumbnailUrl: attrOf(e, "img", "src") ?? "",
    )).toList();
  }

  @override
  Future<List<Manga>> search(String query, int page) async {
    final document = await fetchHtml("$baseUrl/series?search=$query&page=$page");
    final elements = document.querySelectorAll("div.grid > div.relative.group");
    return elements.map((e) => Manga(
      title: textOf(e, "span.block.text-\\[13\\.3px\\].font-bold") ?? "Unknown",
      url: attrOf(e, "a", "href") ?? "",
      thumbnailUrl: attrOf(e, "img", "src") ?? "",
    )).toList();
  }

  @override
  Future<MangaDetails> getDetails(String mangaUrl) async {
    final doc = await fetchHtml(mangaUrl);
    return MangaDetails(
      title: textOf(doc.body, "h1") ?? "",
      description: textOf(doc.body, "span.font-medium.text-sm.text-\\[\\#A2A2A2\\]") ?? "",
      genres: doc.querySelectorAll("button.bg-\\[\\#343434\\]").map((e) => e.text.trim()).toList(),
      status: "Unknown",
      thumbnailUrl: attrOf(doc.body, "img.w-full.h-full.object-cover", "src") ?? "",
    );
  }

  @override
  Future<List<Chapter>> getChapters(String mangaUrl) async {
    final doc = await fetchHtml(mangaUrl);
    final elements = doc.querySelectorAll("div.overflow-y-auto div.group.flex.justify-between");
    return elements.map((e) => Chapter(
      name: textOf(e, "h3") ?? "Chapter",
      url: attrOf(e, "a", "href") ?? "",
      dateUploaded: textOf(e, "span.text-\\[\\#A2A2A2\\]"),
    )).toList();
  }

  @override
  Future<List<String>> getPages(String chapterUrl) async {
    final doc = await fetchHtml(chapterUrl);
    return doc.querySelectorAll("img.mx-auto").map((e) => e.attributes['src'] ?? "").where((s) => s.isNotEmpty).toList();
  }
}
