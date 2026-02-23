import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart';

class RepoService {
  Future<List<RemoteExtension>> fetchExtensionsFromRepo(ExtensionRepo repo) async {
    final indexUrl = "${repo.url}/index.min.json";
    
    try {
      final response = await http.get(Uri.parse(indexUrl));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => RemoteExtension.fromJson(json, repo.url)).toList();
      } else {
        final fallbackResponse = await http.get(Uri.parse("${repo.url}/index.json"));
        if (fallbackResponse.statusCode == 200) {
          final List<dynamic> data = json.decode(fallbackResponse.body);
          return data.map((json) => RemoteExtension.fromJson(json, repo.url)).toList();
        }
        throw Exception("Status: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Repo Error: $e");
    }
  }

  static ExtensionRepo get keiyoushiRepo => ExtensionRepo(
    name: "Keiyoushi",
    url: "https://raw.githubusercontent.com/keiyoushi/extensions/repo"
  );
}
