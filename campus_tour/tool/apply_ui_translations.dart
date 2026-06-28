import 'dart:convert';
import 'dart:io';

final _targetPathPattern = RegExp(r'^lib/(view|widgets|styles)/');
final _interpolationPattern = RegExp(r'\$|\$\{');

void main(List<String> args) {
  final root = Directory.current;
  final inputFile = File('${root.path}/tool/i18n_chinese_strings.json');
  if (!inputFile.existsSync()) {
    stderr.writeln('Run this from the campus_tour package root.');
    exitCode = 1;
    return;
  }

  final decoded = jsonDecode(inputFile.readAsStringSync());
  final entries = decoded is Map<String, dynamic> ? decoded['entries'] : null;
  if (entries is! List) {
    stderr.writeln('tool/i18n_chinese_strings.json must contain entries.');
    exitCode = 1;
    return;
  }

  final keyByText = <String, String>{};
  final targetFiles = <String>{};
  for (final entry in entries.whereType<Map<String, dynamic>>()) {
    final key = entry['key'];
    final zh = entry['zh'];
    final occurrences = entry['occurrences'];
    if (key is! String ||
        zh is! String ||
        zh.isEmpty ||
        _interpolationPattern.hasMatch(zh) ||
        occurrences is! List) {
      continue;
    }

    final hasTargetOccurrence = occurrences
        .whereType<Map<String, dynamic>>()
        .map((occurrence) => occurrence['file'])
        .whereType<String>()
        .any(_targetPathPattern.hasMatch);
    if (!hasTargetOccurrence) continue;

    keyByText[zh] = key;
    for (final occurrence in occurrences.whereType<Map<String, dynamic>>()) {
      final file = occurrence['file'];
      if (file is String && _targetPathPattern.hasMatch(file)) {
        targetFiles.add(file);
      }
    }
  }

  var changedFiles = 0;
  var replacements = 0;
  for (final relativePath in targetFiles.toList()..sort()) {
    final file = File('${root.path}/$relativePath');
    if (!file.existsSync()) continue;

    final source = file.readAsStringSync();
    final result = _replaceLiterals(source, keyByText);
    if (result.replacements == 0) continue;

    var updated = result.source;
    updated = _ensureGetImport(updated);
    updated = _relaxConstForRuntimeTranslations(updated);
    file.writeAsStringSync(updated);
    changedFiles++;
    replacements += result.replacements;
  }

  stdout.writeln(
    'Applied $replacements UI translation replacements in $changedFiles files.',
  );
}

_ReplaceResult _replaceLiterals(String source, Map<String, String> keyByText) {
  final literals = _extractStringLiterals(source);
  if (literals.isEmpty) return _ReplaceResult(source, 0);

  final buffer = StringBuffer();
  var cursor = 0;
  var replacements = 0;
  for (final literal in literals) {
    final key = keyByText[literal.value.trim()];
    if (key == null || _isAlreadyTranslated(source, literal.end)) {
      continue;
    }

    buffer
      ..write(source.substring(cursor, literal.start))
      ..write("'$key'.tr");
    cursor = literal.end;
    replacements++;
  }

  if (replacements == 0) return _ReplaceResult(source, 0);
  buffer.write(source.substring(cursor));
  return _ReplaceResult(buffer.toString(), replacements);
}

bool _isAlreadyTranslated(String source, int literalEnd) {
  final after = source.substring(literalEnd).trimLeft();
  return after.startsWith('.tr');
}

String _ensureGetImport(String source) {
  if (source.contains("package:get/get.dart")) return source;

  final importPattern = RegExp(
    r'''^import\s+['"][^'"]+['"];\s*$''',
    multiLine: true,
  );
  final matches = importPattern.allMatches(source).toList();
  if (matches.isEmpty) {
    return "import 'package:get/get.dart';\n\n$source";
  }

  final lastImport = matches.last;
  return source.replaceRange(
    lastImport.end,
    lastImport.end,
    "\nimport 'package:get/get.dart';",
  );
}

String _relaxConstForRuntimeTranslations(String source) {
  var updated = source.replaceAllMapped(
    RegExp(r"static const ([A-Za-z_][A-Za-z0-9_]*) = ('[^']+\.tr);"),
    (match) => 'static String get ${match[1]} => ${match[2]};',
  );

  updated = updated.replaceAllMapped(
    RegExp(r'\bconst\s+([A-Z][A-Za-z0-9_]*(?:<[^>\n]+>)?\s*\()'),
    (match) => match[1]!,
  );
  updated = updated.replaceAll(RegExp(r'\bconst\s+\['), '[');
  updated = updated.replaceAll(RegExp(r'\bconst\s+\{'), '{');
  return updated;
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

class _ReplaceResult {
  const _ReplaceResult(this.source, this.replacements);

  final String source;
  final int replacements;
}

class _StringLiteral {
  const _StringLiteral(this.value, this.start, this.end);

  final String value;
  final int start;
  final int end;
}
