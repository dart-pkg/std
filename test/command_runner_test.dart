// ignore_for_file: prefer_single_quotes
import 'package:test/test.dart';
import 'package:output/output.dart';
import 'package:std/command_runner.dart';

main() async {
  group('Run', () {
    test('run1', () async {
      echo('run1');
      var runner = CommandRunner();
      String ls = await runner.run('ls', silent: true);
      echo(ls, 'ls');
    });
  });
}
