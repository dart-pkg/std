import 'dart:io' as dart_io;
import 'dart:async' as dart_async;
import 'dart:convert' as dart_convert;
import 'package:std/misc.dart' as std_misc;

// String _padBase64(String rawBase64) {
//   return (rawBase64.length % 4 > 0)
//       ? rawBase64 += List.filled(4 - (rawBase64.length % 4), '=').join('')
//       : rawBase64;
// }

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

  Future<dynamic> script(
    String script, {
    dart_convert.Encoding? encoding,
    String? workingDirectory,
    Map<String, String>? environment,
    bool includeParentEnvironment = true,
    bool silent = false,
    bool noPrompt = false,
    bool returnCode = false,
  }) async {
    if (!script.endsWith('\n')) {
      script += '\n';
    }
    if (workingDirectory != null) {
      workingDirectory = std_misc.pathExpand(workingDirectory);
    }
    workingDirectory ??= dart_io.Directory.current.absolute.path;
    if (!noPrompt) {
      //print('[$workingDirectory]\n<script>\n$script</script>');
      dart_io.stderr.write('[$workingDirectory]\n<script>\n$script</script>\n');
    }
    //String b64 = _padBase64(dart_convert.base64.encode(dart_convert.utf8.encode(script)));
    String b64 = dart_convert.base64.encode(dart_convert.utf8.encode(script));
    //print('b64: $b64');
    String command = 'echo $b64 | base64 -di | bash';
    //print(command);
    return run(
      command,
      encoding: encoding,
      workingDirectory: workingDirectory,
      environment: environment,
      includeParentEnvironment: includeParentEnvironment,
      silent: silent,
      noPrompt: true,
      returnCode: returnCode,
    );
  }

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
    if (workingDirectory != null) {
      workingDirectory = std_misc.pathExpand(workingDirectory);
    }
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
    if (!noPrompt) {
      //print('[$workingDirectory] \$ $display');
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
