import 'dart:io' as io__;
import 'dart:async' as async__;
import 'dart:convert' as convert__;
import 'package:std/misc.dart' as misc__;

/// Process manager for executing command lines
class CommandRunner {
  bool useUnixShell;
  String unixShell;
  convert__.Encoding? encoding;

  CommandRunner({
    this.useUnixShell = false,
    this.unixShell = 'bash',
    this.encoding /* = null */, //convert__.utf8,
  });

  /// Execute command and returns stdout
  Future<dynamic> run(
    String command, {
    String? workingDirectory,
    Map<String, String>? environment,
    bool includeParentEnvironment = true,
    bool silent = false,
    bool returnCode = false,
  }) async {
    List<String> split = misc__.splitCommandLine(command);
    return run$(
      split,
      workingDirectory: workingDirectory,
      environment: environment,
      silent: silent,
      returnCode: returnCode,
      autoQuote: false,
    );
  }

  String _quote(String arg) {
    if (arg.startsWith('"') || arg.startsWith("'") || arg.startsWith('`')) {
      return arg;
    } else {
      return '"$arg"';
    }
  }

  String _unquote(String arg) {
    if (arg.startsWith('"') || arg.startsWith("'")) {
      arg = arg.substring(1);
    }
    if (arg.endsWith('"') || arg.endsWith("'")) {
      arg = arg.substring(0, arg.length - 1);
    }
    return arg;
  }

  /// Execute command and returns stdout
  Future<dynamic> run$(
    List<String> command, {
    String? workingDirectory,
    Map<String, String>? environment,
    bool includeParentEnvironment = true,
    bool silent = false,
    bool returnCode = false,
    bool autoQuote = true,
  }) async {
    String executable = command[0];
    List<String> arguments = command.sublist(1).toList();
    workingDirectory ??= io__.Directory.current.absolute.path;
    if (autoQuote) {
      executable = _quote(executable);
      arguments = arguments.map((x) => _quote(x)).toList();
    }
    String display = misc__.joinCommandLine([executable, ...arguments]);
    if (useUnixShell) {
      String command = misc__.joinCommandLine([executable, ...arguments]);
      executable = unixShell;
      arguments = ['-c', command];
    } else {
      executable = _unquote(executable);
      arguments = arguments.map((x) => _unquote(x)).toList();
    }
    print('[$workingDirectory] \$ $display');
    var completer = async__.Completer<dynamic>();
    String buffer = '';
    io__.Process.start(
      executable,
      arguments,
      workingDirectory: workingDirectory,
      environment: environment,
      includeParentEnvironment: includeParentEnvironment,
      runInShell: !useUnixShell,
    ).then((process) {
      process.stdout
          .transform((encoding ?? io__.SystemEncoding()).decoder)
          .listen((data) {
            if (!silent) {
              io__.stdout.write(data);
            }
            buffer += data;
          });
      process.stderr
          .transform((encoding ?? io__.SystemEncoding()).decoder)
          .listen((data) {
            io__.stderr.write(data);
          });
      process.exitCode.then((code) {
        if (returnCode) {
          completer.complete(code);
          return;
        }
        if (code != 0) {
          throw Exception(
            '$display, exitCode $code, workingDirectory: $workingDirectory',
          );
        }
        // if (buffer.endsWith('\r\n')) {
        //   buffer = buffer.substring(0, buffer.length - 2);
        // } else if (buffer.endsWith('\n')) {
        //   buffer = buffer.substring(0, buffer.length - 1);
        // } else if (buffer.endsWith('\r')) {
        //   buffer = buffer.substring(0, buffer.length - 1);
        // }
        buffer = buffer.trimRight();
        buffer = misc__.adjustTextNewlines(buffer);
        completer.complete(buffer);
      });
    });
    return completer.future;
  }
}
