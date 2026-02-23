import 'dart:io';

void main() async {
  final extensionsDir = Directory('lib/extensions');
  final libDir = Directory('lib/sources');
  final registryFile = File('lib/sources/source_registry.dart');

  if (!await extensionsDir.exists()) {
    print('Extensions directory not found at ${extensionsDir.path}');
    return;
  }

  final List<Map<String, String>> extensions = [];
  final List<String> imports = [
    "import 'base_source.dart';",
  ];

  await for (var langDir in extensionsDir.list()) {
    if (langDir is Directory) {
      final lang = langDir.path.split(Platform.pathSeparator).last;
      await for (var extDir in langDir.list()) {
        if (extDir is Directory) {
          final extId = extDir.path.split(Platform.pathSeparator).last;
          final sourceFile = File('${extDir.path}/$extId.dart');
          
          if (await sourceFile.exists()) {
            final content = await sourceFile.readAsString();
            final classMatch = RegExp(r'class (\w+) extends BaseSource').firstMatch(content);
            if (classMatch != null) {
              final className = classMatch.group(1)!;
              // Use relative import within lib
              final relativePath = '../extensions/$lang/$extId/$extId.dart';
              imports.add("import '$relativePath';");
              extensions.add({
                'class': className,
                'name': extId,
              });
            }
          }
        }
      }
    }
  }

  // Also include built-in sources in lib/sources
  await for (var file in libDir.list()) {
    if (file is File && file.path.endsWith('.dart') && !file.path.contains('base_source') && !file.path.contains('source_registry')) {
      final content = await file.readAsString();
      final classMatch = RegExp(r'class (\w+) extends BaseSource').firstMatch(content);
      if (classMatch != null) {
        final className = classMatch.group(1)!;
        final fileName = file.path.split(Platform.pathSeparator).last;
        imports.add("import '$fileName';");
        extensions.add({
          'class': className,
          'name': fileName.replaceAll('.dart', ''),
        });
      }
    }
  }

  final sb = StringBuffer();
  sb.writeln("// GENERATED CODE - DO NOT MODIFY BY HAND");
  sb.writeln();
  for (var imp in imports.toSet()) {
    sb.writeln(imp);
  }
  sb.writeln();
  sb.writeln("List<BaseSource> getRegisteredSources() {");
  sb.writeln("  return [");
  for (var ext in extensions) {
    sb.writeln("    ${ext['class']}(),");
  }
  sb.writeln("  ];");
  sb.writeln("}");

  await registryFile.writeAsString(sb.toString());
  print('Registry updated with ${extensions.length} sources.');
}
