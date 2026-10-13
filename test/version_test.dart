// Versión de la app (D-006): pubspec.yaml y android/app/build.gradle tienen
// que decir lo mismo, y nunca menos que lo último publicado en Play.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Última versión que Google Play ya tiene: 1.1.11 (17), en producción desde
/// el 2026-10-06 (D-035).
const _lastPublishedCode = 17;

void main() {
  final pubspec = File('pubspec.yaml').readAsStringSync();
  final gradle = File('android/app/build.gradle').readAsStringSync();

  final pubspecMatch = RegExp(
    r'^version:\s*(\d+\.\d+\.\d+)\+(\d+)\s*$',
    multiLine: true,
  ).firstMatch(pubspec);
  final gradleName = RegExp(r'versionName\s+"([^"]+)"').firstMatch(gradle);
  final gradleCode = RegExp(r'versionCode\s+(\d+)').firstMatch(gradle);

  test('pubspec.yaml y build.gradle dicen la misma versión', () {
    expect(
      pubspecMatch,
      isNotNull,
      reason: 'pubspec.yaml sin "version: X.Y.Z+N"',
    );
    expect(gradleName, isNotNull, reason: 'build.gradle sin versionName');
    expect(gradleCode, isNotNull, reason: 'build.gradle sin versionCode');

    expect(gradleName!.group(1), pubspecMatch!.group(1));
    expect(gradleCode!.group(1), pubspecMatch.group(2));
  });

  test('el versionCode es mayor que el último publicado en Play', () {
    expect(int.parse(pubspecMatch!.group(2)!), greaterThan(_lastPublishedCode));
  });
}
