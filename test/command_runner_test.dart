// ignore_for_file: prefer_single_quotes
import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';
import 'package:debug_output/debug_output.dart';
import 'package:std/command_runner.dart';

main() async {
  group('Run', () {
    test('run1', () async {
      echo('run1');
      var runner = CommandRunner();
      String ls = await runner.run$(['ls', '-l'], silent: true);
      echo(ls, title: 'ls');
      await runner.run('ping -n 2 www.youtube.com');
      runner = CommandRunner(encoding: SystemEncoding());
      await runner.run('ping -n 2 www.youtube.com');
      runner = CommandRunner(encoding: utf8);
      //await runner.run('ping -n 2 www.youtube.com'); // error
      await runner.run(
        'ping -n 2 www.youtube.com',
        encoding: SystemEncoding(),
      ); // ok
    });
  });
}
