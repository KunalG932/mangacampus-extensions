import '../models/models.dart';
import 'base_source.dart';

class MangaKakalot extends BaseSource {
  @override
  final String name = "MangaKakalot";
  @override
  final String baseUrl = "https://www.mangakakalot.gg";
  @override
  final String lang = "en";

  @override
  Future<List<Manga>> getPopular(int page) async {
    final doc = await fetchHtml("$baseUrl/manga_list?type=topview&page=$page");
    return doc.querySelectorAll("div.list-truyen-item-wrap").map((e) => Manga(
      title: textOf(e, "h3 a") ?? "Unknown",
      url: attrOf(e, "h3 a", "href") ?? "",
      thumbnailUrl: attrOf(e, "img", "src") ?? "",
    )).toList();
  }

  @override
  Future<List<Manga>> search(String query, int page) async {
    final q = query.replaceAll(' ', '_').toLowerCase();
    final doc = await fetchHtml("$baseUrl/search/story/$q?page=$page");
    return doc.querySelectorAll("div.story_item").map((e) => Manga(
      title: textOf(e, "h3.story_name a") ?? "Unknown",
      url: attrOf(e, "h3.story_name a", "href") ?? "",
      thumbnailUrl: attrOf(e, "img", "src") ?? "",
    )).toList();
  }

  @override
  Future<MangaDetails> getDetails(String mangaUrl) async {
    final doc = await fetchHtml(mangaUrl);
    final info = doc.querySelector("ul.manga-info-text");
    return MangaDetails(
      title: textOf(doc.body, "h1") ?? "",
      description: textOf(doc.body, "div#noidungm") ?? "",
      genres: info?.querySelectorAll("li").where((e) => e.text.contains("Genres")).first.querySelectorAll("a").map((e) => e.text.trim()).toList() ?? [],
      status: "Ongoing",
      thumbnailUrl: attrOf(doc.body, "div.manga-info-pic img", "src") ?? "",
    );
  }

  @override
  Future<List<Chapter>> getChapters(String mangaUrl) async {
    final doc = await fetchHtml(mangaUrl);
    return doc.querySelectorAll("div.chapter-list div.row").map((e) => Chapter(
      name: textOf(e, "a") ?? "Chapter",
      url: attrOf(e, "a", "href") ?? "",
      dateUploaded: textOf(e, "span:last-child"),
    )).toList();
  }

  @override
  Future<List<String>> getPages(String chapterUrl) async {
    final doc = await fetchHtml(chapterUrl);
    return doc.querySelectorAll("div.container-chapter-reader img").map((e) => e.attributes['src'] ?? "").toList();
  }
}
