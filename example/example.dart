import 'dart:io';
import 'package:std/command_runner.dart';

Future<void> main() async {
  var shell = CommandRunner(useUnixShell: true);

  // Pipe results to string, easily.
  // Without `silent: true', stdout is echoed automatically although you get stdout as method result.
  String echo = await shell.run('echo hello world', silent: true);
  print(echo);

  // You can run a program, and expect a certain exit code.
  //
  // Use `returnCode: true' to get process exit code.
  //
  // Otherwise, a Error is thrown.
  int find = await shell.run$(
    ['find', '.', '-name', '"*.dart"'],
    autoQuote: false,
    returnCode: true,
  );
  print(find);
  if (find != 0) {
    exit(find);
  }

  // You can also run a process and immediately receive a string.
  String pwd = await shell.run('pwd');
  print('cwd: `$pwd`');

  Directory.current = './lib';
  pwd = await shell.run('pwd');
  print('cwd: `$pwd`');

  // You can use | within command line (when CommandRunner() was constructed with `useUnixShell: true'.
  String find2 = await shell.run('find . -name "*.dart" | wc -l');
  print(find2);

  // You can use | within command line (when CommandRunner() was constructed with `useUnixShell: true'.
  // run$() quotes all of the arguments; so in order to use pipe (|) you need to specify `autoQuote: false'.
  String find3 = await shell.run$([
    'find',
    '.',
    '-name',
    '"*.dart"',
    '|',
    'wc',
    '-l',
  ], autoQuote: false);
  print(find3);
}
