import 'dart:convert';
import 'dart:io';

final _cjkPattern = RegExp(r'[\u3400-\u9fff]');

void main(List<String> args) {
  final root = Directory.current;
  final libDir = Directory('${root.path}/lib');
  if (!libDir.existsSync()) {
    stderr.writeln('Run this from the campus_tour package root.');
    exitCode = 1;
    return;
  }

  final entriesByText = <String, _StringEntry>{};
  final dartFiles =
      libDir
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => file.path.endsWith('.dart'))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));

  for (final file in dartFiles) {
    final relativePath = _relativePath(root, file);
    final source = file.readAsStringSync();
    final literals = _extractStringLiterals(source);
    var sequence = 0;

    for (final literal in literals) {
      final text = literal.value.trim();
      if (text.isEmpty || !_cjkPattern.hasMatch(text)) continue;

      sequence++;
      final key = _keyFor(relativePath, sequence);
      final entry = entriesByText.putIfAbsent(
        text,
        () => _StringEntry(key: key, zh: text),
      );
      entry.occurrences.add(
        _Occurrence(file: relativePath, line: _lineFor(source, literal.start)),
      );
    }
  }

  final entries = entriesByText.values.toList()
    ..sort((a, b) => a.key.compareTo(b.key));
  final outputDir = Directory('${root.path}/tool');
  outputDir.createSync(recursive: true);

  final jsonFile = File('${outputDir.path}/i18n_chinese_strings.json');
  jsonFile.writeAsStringSync(
    const JsonEncoder.withIndent('  ').convert({
      'generatedBy': 'tool/extract_chinese_strings.dart',
      'totalUniqueStrings': entries.length,
      'entries': entries.map((entry) => entry.toJson()).toList(),
    }),
  );

  final markdownFile = File('${outputDir.path}/i18n_chinese_strings.md');
  markdownFile.writeAsStringSync(_markdownFor(entries));

  stdout.writeln('Found ${entries.length} unique Chinese strings.');
  stdout.writeln('Wrote ${_relativePath(root, jsonFile)}');
  stdout.writeln('Wrote ${_relativePath(root, markdownFile)}');
}

List<_StringLiteral> _extractStringLiterals(String source) {
  final literals = <_StringLiteral>[];
  var i = 0;

  while (i < source.length) {
    final char = source[i];
    final next = i + 1 < source.length ? source[i + 1] : '';

    if (char == '/' && next == '/') {
      i = _skipLineComment(source, i + 2);
      continue;
    }

    if (char == '/' && next == '*') {
      i = _skipBlockComment(source, i + 2);
      continue;
    }

    final isRawPrefix =
        (char == 'r' || char == 'R') &&
        i + 1 < source.length &&
        (source[i + 1] == '\'' || source[i + 1] == '"');
    final quoteIndex = isRawPrefix ? i + 1 : i;
    if (quoteIndex < source.length &&
        (source[quoteIndex] == '\'' || source[quoteIndex] == '"')) {
      final literal = _readString(source, quoteIndex, isRaw: isRawPrefix);
      if (literal != null) {
        literals.add(literal);
        i = literal.end;
        continue;
      }
    }

    i++;
  }

  return literals;
}

int _skipLineComment(String source, int start) {
  var i = start;
  while (i < source.length && source[i] != '\n') {
    i++;
  }
  return i;
}

int _skipBlockComment(String source, int start) {
  var i = start;
  while (i + 1 < source.length) {
    if (source[i] == '*' && source[i + 1] == '/') return i + 2;
    i++;
  }
  return source.length;
}

_StringLiteral? _readString(
  String source,
  int quoteIndex, {
  required bool isRaw,
}) {
  final quote = source[quoteIndex];
  final isTriple =
      quoteIndex + 2 < source.length &&
      source[quoteIndex + 1] == quote &&
      source[quoteIndex + 2] == quote;
  final start = quoteIndex;
  final contentStart = quoteIndex + (isTriple ? 3 : 1);
  final buffer = StringBuffer();
  var i = contentStart;

  while (i < source.length) {
    if (isTriple) {
      if (i + 2 < source.length &&
          source[i] == quote &&
          source[i + 1] == quote &&
          source[i + 2] == quote) {
        return _StringLiteral(buffer.toString(), start, i + 3);
      }

      buffer.write(source[i]);
      i++;
      continue;
    }

    if (!isRaw && source[i] == r'\') {
      if (i + 1 < source.length) {
        buffer.write(source.substring(i, i + 2));
        i += 2;
        continue;
      }
    }

    if (source[i] == quote) {
      return _StringLiteral(buffer.toString(), start, i + 1);
    }

    if (source[i] == '\n') return null;

    buffer.write(source[i]);
    i++;
  }

  return null;
}

int _lineFor(String source, int offset) {
  var line = 1;
  for (var i = 0; i < offset && i < source.length; i++) {
    if (source[i] == '\n') line++;
  }
  return line;
}

String _keyFor(String path, int sequence) {
  final withoutPrefix = path
      .replaceFirst(RegExp(r'^lib/'), '')
      .replaceFirst(RegExp(r'\.dart$'), '');
  final normalized = withoutPrefix
      .replaceAll(RegExp(r'[^A-Za-z0-9]+'), '.')
      .replaceAll(RegExp(r'\.+'), '.')
      .replaceAll(RegExp(r'^\.|\.$'), '')
      .toLowerCase();
  return '$normalized.s${sequence.toString().padLeft(3, '0')}';
}

String _relativePath(Directory root, File file) {
  final rootPath = root.path.endsWith('/') ? root.path : '${root.path}/';
  return file.path.startsWith(rootPath)
      ? file.path.substring(rootPath.length)
      : file.path;
}

String _markdownFor(List<_StringEntry> entries) {
  final buffer = StringBuffer()
    ..writeln('# Chinese UI String Inventory')
    ..writeln()
    ..writeln('Generated by `dart run tool/extract_chinese_strings.dart`.')
    ..writeln()
    ..writeln('Total unique strings: ${entries.length}')
    ..writeln()
    ..writeln('| Key | Chinese | English draft | Occurrences |')
    ..writeln('| --- | --- | --- | --- |');

  for (final entry in entries) {
    final occurrences = entry.occurrences
        .map((occurrence) => '${occurrence.file}:${occurrence.line}')
        .join('<br>');
    buffer.writeln(
      '| `${entry.key}` | ${_escapeMarkdownTable(entry.zh)} |  | $occurrences |',
    );
  }

  return buffer.toString();
}

String _escapeMarkdownTable(String value) {
  return value
      .replaceAll('\n', '<br>')
      .replaceAll('|', r'\|')
      .replaceAll('\r', '');
}

class _StringLiteral {
  const _StringLiteral(this.value, this.start, this.end);

  final String value;
  final int start;
  final int end;
}

class _StringEntry {
  _StringEntry({required this.key, required this.zh});

  final String key;
  final String zh;
  final occurrences = <_Occurrence>[];

  Map<String, Object?> toJson() {
    return {
      'key': key,
      'zh': zh,
      'en': '',
      'occurrences': occurrences
          .map(
            (occurrence) => {'file': occurrence.file, 'line': occurrence.line},
          )
          .toList(),
    };
  }
}

class _Occurrence {
  const _Occurrence({required this.file, required this.line});

  final String file;
  final int line;
}
