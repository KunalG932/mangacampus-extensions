import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';

void main() async {
  final extensionsDir = Directory('extensions');
  final repoDir = Directory('repo');
  final List<Map<String, dynamic>> repoIndex = [];

  print('MangaCampus Build System');

  if (!await extensionsDir.exists()) {
    print('Extensions directory not found');
    return;
  }

  if (await repoDir.exists()) await repoDir.delete(recursive: true);
  await repoDir.create();
  
  final sourcesDir = Directory('repo/sources')..createSync();
  final iconsDir = Directory('repo/icons')..createSync();

  await for (var langDir in extensionsDir.list()) {
    if (langDir is Directory) {
      final lang = langDir.path.split(Platform.pathSeparator).last;
      
      await for (var extDir in langDir.list()) {
        if (extDir is Directory) {
          final extId = extDir.path.split(Platform.pathSeparator).last;
          final metadataFile = File('${extDir.path}/extension.json');
          
          if (await metadataFile.exists()) {
            final metadata = json.decode(await metadataFile.readAsString());
            final sourceFile = File('${extDir.path}/$extId.dart');
            final iconFile = File('${extDir.path}/icon.png');

            if (!await sourceFile.exists()) continue;

            final outFileName = '${lang}_$extId.dart';
            final outIconName = '${lang}_$extId.png';

            final bytes = await sourceFile.readAsBytes();
            final hash = sha256.convert(bytes).toString();

            await sourceFile.copy('${sourcesDir.path}/$outFileName');
            if (await iconFile.exists()) {
              await iconFile.copy('${iconsDir.path}/$outIconName');
            }

            repoIndex.add({
              "name": metadata['name'],
              "pkg": "com.mangacampus.extension.$lang.$extId",
              "version": metadata['version'],
              "versionCode": metadata['versionCode'] ?? 1,
              "lang": lang,
              "code": outFileName,
              "hash": hash,
              "icon": await iconFile.exists() ? "icons/$outIconName" : null,
              "nsfw": metadata['nsfw'] ?? 0,
            });

            print('Built: ${metadata['name']}');
          }
        }
      }
    }
  }

  await File('repo/index.min.json').writeAsString(json.encode(repoIndex));
  print('Done: ${repoIndex.length} extensions');

  print('Updating source registry...');
  final result = await Process.run('dart', ['scripts/update_registry.dart']);
  if (result.exitCode == 0) {
    print(result.stdout);
  } else {
    print('Failed to update registry: ${result.stderr}');
  }
}
