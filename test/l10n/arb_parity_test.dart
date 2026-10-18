import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Guards translation completeness so new strings cannot ship in only one
/// locale. Every `app_*.arb` catalog is compared against the English template:
/// it must define the exact same message keys (ignoring `@`-prefixed metadata),
/// leave no translation empty, and preserve every `{placeholder}` token.
void main() {
  const arbDir = 'lib/l10n';

  final template = jsonDecode(
    File('$arbDir/app_en.arb').readAsStringSync(),
  ) as Map<String, dynamic>;
  final templateKeys = _messageKeys(template);
  final templateTokens = {
    for (final key in templateKeys) key: _tokens(template[key] as String),
  };

  final localeFiles =
      Directory(arbDir)
          .listSync()
          .whereType<File>()
          .where(
            (file) =>
                file.path.endsWith('.arb') && !file.path.endsWith('app_en.arb'),
          )
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));

  test('translation catalogs exist beyond the English template', () {
    expect(localeFiles, isNotEmpty);
  });

  for (final file in localeFiles) {
    final name = file.uri.pathSegments.last;

    group(name, () {
      late Map<String, dynamic> arb;
      late Set<String> keys;

      setUpAll(() {
        arb = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
        keys = _messageKeys(arb);
      });

      test('has every English key', () {
        final missing = templateKeys.difference(keys);
        expect(
          missing,
          isEmpty,
          reason: 'Missing translations in $name for: ${missing.join(', ')}',
        );
      });

      test('has no keys absent from English', () {
        final extra = keys.difference(templateKeys);
        expect(
          extra,
          isEmpty,
          reason: '$name defines unknown keys: ${extra.join(', ')}',
        );
      });

      test('leaves no translation empty', () {
        for (final key in keys) {
          expect(
            (arb[key] as String).trim(),
            isNotEmpty,
            reason: 'Empty translation for "$key" in $name',
          );
        }
      });

      test('preserves placeholder tokens', () {
        for (final key in keys.intersection(templateKeys)) {
          expect(
            _tokens(arb[key] as String),
            templateTokens[key],
            reason: 'Placeholder mismatch for "$key" in $name',
          );
        }
      });
    });
  }
}

Set<String> _messageKeys(Map<String, dynamic> arb) {
  return arb.keys.where((key) => !key.startsWith('@')).toSet();
}

/// Extracts argument names, recursing into ICU select/plural branches while
/// treating branch contents as text. Sport labels such as `{Run}` are branch
/// messages, not placeholder arguments.
Set<String> _tokens(String message) {
  final result = <String>{};
  var position = 0;
  while (position < message.length) {
    if (message[position] != '{') {
      position++;
      continue;
    }
    final start = ++position;
    var depth = 1;
    while (position < message.length && depth > 0) {
      if (message[position] == '{') depth++;
      if (message[position] == '}') depth--;
      position++;
    }
    final body = message.substring(start, position - 1);
    final comma = body.indexOf(',');
    if (comma < 0) {
      result.add(body.trim());
      continue;
    }
    result.add(body.substring(0, comma).trim());
    final branchesStart = body.indexOf(',', comma + 1);
    if (branchesStart < 0) continue;
    var branchPosition = branchesStart + 1;
    while (branchPosition < body.length) {
      final open = body.indexOf('{', branchPosition);
      if (open < 0) break;
      branchPosition = open + 1;
      var branchDepth = 1;
      while (branchPosition < body.length && branchDepth > 0) {
        if (body[branchPosition] == '{') branchDepth++;
        if (body[branchPosition] == '}') branchDepth--;
        branchPosition++;
      }
      result.addAll(_tokens(body.substring(open + 1, branchPosition - 1)));
    }
  }
  return result;
}
