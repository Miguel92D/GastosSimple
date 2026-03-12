import 'dart:io';

void main() {
  final res = Process.runSync('flutter', ['analyze', '--no-fatal-infos', '--no-fatal-warnings'], stdoutEncoding: systemEncoding, stderrEncoding: systemEncoding);
  final lines = res.stdout.toString().split('\n');
  for (var line in lines) {
    if (line.contains('error ')) {
      print(line.trim());
    }
  }
}
