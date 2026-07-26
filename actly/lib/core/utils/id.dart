import 'dart:math';

final Random _random = Random.secure();

String newId(String prefix) {
  final micros = DateTime.now().microsecondsSinceEpoch;
  final salt = _random.nextInt(1 << 32).toRadixString(16).padLeft(8, '0');
  return '${prefix}_${micros}_$salt';
}
