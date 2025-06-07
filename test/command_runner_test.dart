// ignore_for_file: prefer_single_quotes
import 'dart:convert';

import 'package:test/test.dart';
import 'package:debug_output/debug_output.dart';
import 'package:std/command_runner.dart';

Future<void> main() async {
  group('Run', () {
    test('run1', () async {
      echo('run1');
      var runner = CommandRunner(useUnixShell: false);
      await runner.script(
        '''
echo on
ls -ltr
echo aaa
echo %1
echo %2''',
        encoding: utf8,
        arguments: ['a b', 'c d'],
      );
    });
    test('run1Syc', () {
      echo('run1Syc');
      var runner = CommandRunner(useUnixShell: false);
      runner.scriptSync(
        '''
echo on
ls -ltr
echo aaa
echo %1
echo %2''',
        encoding: utf8,
        arguments: ['a b', 'c d'],
      );
    });
    test('run2', () async {
      echo('run2');
      var runner = CommandRunner(useUnixShell: true);
      await runner.script(
        '''
set -uvx
set -e
ls -ltr
echo あああ
echo \$1
echo \$2''',
        encoding: utf8,
        arguments: ['a b', 'c d'],
      );
      String ls = await runner.run$(
        ['ls', '-l'],
        encoding: utf8,
        silent: true,
        //noPrompt: true,
        workingDirectory: '~/',
      );
      echo(ls, title: 'ls -l');
    });
    test('run2Sync', () {
      echo('run2Sync');
      var runner = CommandRunner(useUnixShell: true);
      runner.scriptSync(
        '''
set -uvx
set -e
ls -ltr
echo あああ
echo \$1
echo \$2''',
        encoding: utf8,
        arguments: ['a b', 'c d'],
      );
      String ls = runner.runSync$(
        ['ls', '-l'],
        encoding: utf8,
        silent: true,
        //noPrompt: true,
        workingDirectory: '~/',
      );
      echo(ls, title: 'ls -l');
    });
  });
}
