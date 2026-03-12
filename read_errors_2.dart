import 'dart:io';
void main() {
  final file = File('r8.txt');
  final lines = file.readAsLinesSync();
  for (var l in lines) {
    if (l.contains('error - ')) print(l.trim());
  }
}
