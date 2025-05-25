import 'dart:io' as dart_io;
import 'dart:async' as dart_async;
import 'dart:convert' as dart_convert;
import 'package:std/misc.dart' as std_misc;

/// Process manager for executing command lines
class CommandRunner {
  bool useUnixShell;
  String unixShell;
  dart_convert.Encoding? encoding;

  CommandRunner({
    this.useUnixShell = false,
    this.unixShell = 'bash',
    this.encoding /* = null */, //convert__.utf8,
  });

  /// Execute command and returns stdout
  Future<dynamic> run(
    String command, {
    dart_convert.Encoding? encoding,
    String? workingDirectory,
    Map<String, String>? environment,
    bool includeParentEnvironment = true,
    bool silent = false,
    bool noPrompt = false,
    bool returnCode = false,
  }) async {
    List<String> split = std_misc.splitCommandLine(command);
    return run$(
      split,
      encoding: encoding,
      workingDirectory: workingDirectory,
      environment: environment,
      silent: silent,
      noPrompt: noPrompt,
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
    dart_convert.Encoding? encoding,
    String? workingDirectory,
    Map<String, String>? environment,
    bool includeParentEnvironment = true,
    bool silent = false,
    bool noPrompt = false,
    bool returnCode = false,
    bool autoQuote = true,
  }) async {
    String executable = command[0];
    List<String> arguments = command.sublist(1).toList();
    encoding ??= this.encoding;
    workingDirectory ??= dart_io.Directory.current.absolute.path;
    if (autoQuote) {
      executable = _quote(executable);
      arguments = arguments.map((x) => _quote(x)).toList();
    }
    String display = std_misc.joinCommandLine([executable, ...arguments]);
    if (useUnixShell) {
      String command = std_misc.joinCommandLine([executable, ...arguments]);
      executable = unixShell;
      arguments = ['-c', command];
    } else {
      executable = _unquote(executable);
      arguments = arguments.map((x) => _unquote(x)).toList();
    }
    //print('[$workingDirectory] \$ $display');
    if (!noPrompt) {
      dart_io.stderr.write('[$workingDirectory] \$ $display\n');
    }
    var completer = dart_async.Completer<dynamic>();
    String buffer = '';
    dart_io.Process.start(
      executable,
      arguments,
      workingDirectory: workingDirectory,
      environment: environment,
      includeParentEnvironment: includeParentEnvironment,
      runInShell: !useUnixShell,
    ).then((process) {
      process.stdout
          .transform((encoding ?? dart_io.SystemEncoding()).decoder)
          .listen((data) {
            if (!silent) {
              dart_io.stdout.write(data);
            }
            buffer += data;
          });
      process.stderr
          .transform((encoding ?? dart_io.SystemEncoding()).decoder)
          .listen((data) {
            dart_io.stderr.write(data);
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
        buffer = buffer.trimRight();
        buffer = std_misc.adjustTextNewlines(buffer);
        completer.complete(buffer);
      });
    });
    return completer.future;
  }
}
