import 'dart:io' as dart_io;
import 'dart:async' as dart_async;
import 'dart:convert' as dart_convert;
import 'dart:typed_data';
import 'package:std/misc.dart' as std_misc;

/// Process manager for executing command lines
class CommandRunner {
  bool useUnixShell;
  String unixShell;
  dart_convert.Encoding? encoding;

  CommandRunner({
    this.useUnixShell = false,
    this.unixShell = 'bash',
    this.encoding /* = null */,
  });

  ///
  Future<dynamic> script(
    String script, {
    List<String>? arguments,
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
    arguments ??= [];
    if (workingDirectory != null) {
      workingDirectory = std_misc.pathExpand(workingDirectory);
    }
    workingDirectory ??= dart_io.Directory.current.absolute.path;
    if (!noPrompt) {
      //print('[$workingDirectory]\n<script>\n$script</script>');
      dart_io.stderr.write('[$workingDirectory]\n<script>\n$script</script>\n');
    }
    String? tmpFile;
    String command;
    if (useUnixShell) {
      String b64 = dart_convert.base64.encode(dart_convert.utf8.encode(script));
      command = 'echo $b64 | base64 -d | bash /dev/stdin';
      for (int i = 0; i < arguments.length; i++) {
        command += ' "${arguments[i]}"';
      }
    } else {
      tmpFile = std_misc.installBinaryToTempDir(
        Uint8List.fromList(
          dart_io.SystemEncoding().encode(
            dart_io.Platform.isWindows
                ? script.replaceAll('\n', '\r\n')
                : script,
          ),
        ),
        suffix: '.cmd',
      );
      command = '"$tmpFile"';
      for (int i = 0; i < arguments.length; i++) {
        command += ' "${arguments[i]}"';
      }
    }
    //print(command);
    dynamic result;
    try {
      result = await run(
        command,
        encoding: encoding,
        workingDirectory: workingDirectory,
        environment: environment,
        includeParentEnvironment: includeParentEnvironment,
        silent: silent,
        noPrompt: true,
        returnCode: returnCode,
      );
    } finally {
      if (tmpFile != null) {
        dart_io.File(tmpFile).deleteSync();
      }
    }
    return result;
  }

  ///
  dynamic scriptSync(
    String script, {
    List<String>? arguments,
    dart_convert.Encoding? encoding,
    String? workingDirectory,
    Map<String, String>? environment,
    bool includeParentEnvironment = true,
    bool silent = false,
    bool noPrompt = false,
    bool returnCode = false,
  }) {
    if (!script.endsWith('\n')) {
      script += '\n';
    }
    arguments ??= [];
    if (workingDirectory != null) {
      workingDirectory = std_misc.pathExpand(workingDirectory);
    }
    workingDirectory ??= dart_io.Directory.current.absolute.path;
    if (!noPrompt) {
      //print('[$workingDirectory]\n<script>\n$script</script>');
      dart_io.stderr.write('[$workingDirectory]\n<script>\n$script</script>\n');
    }
    String? tmpFile;
    String command;
    if (useUnixShell) {
      String b64 = dart_convert.base64.encode(dart_convert.utf8.encode(script));
      command = 'echo $b64 | base64 -d | bash /dev/stdin';
      for (int i = 0; i < arguments.length; i++) {
        command += ' "${arguments[i]}"';
      }
    } else {
      tmpFile = std_misc.installBinaryToTempDir(
        Uint8List.fromList(
          dart_io.SystemEncoding().encode(
            dart_io.Platform.isWindows
                ? script.replaceAll('\n', '\r\n')
                : script,
          ),
        ),
        suffix: '.cmd',
      );
      command = '"$tmpFile"';
      for (int i = 0; i < arguments.length; i++) {
        command += ' "${arguments[i]}"';
      }
    }
    //print(command);
    dynamic result;
    try {
      result = runSync(
        command,
        encoding: encoding,
        workingDirectory: workingDirectory,
        environment: environment,
        includeParentEnvironment: includeParentEnvironment,
        silent: silent,
        noPrompt: true,
        returnCode: returnCode,
      );
    } finally {
      if (tmpFile != null) {
        dart_io.File(tmpFile).deleteSync();
      }
    }
    return result;
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

  /// Execute command and returns stdout
  dynamic runSync(
    String command, {
    dart_convert.Encoding? encoding,
    String? workingDirectory,
    Map<String, String>? environment,
    bool includeParentEnvironment = true,
    bool silent = false,
    bool noPrompt = false,
    bool returnCode = false,
  }) {
    List<String> split = std_misc.splitCommandLine(command);
    return runSync$(
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

  /// Execute command and returns stdout
  dynamic runSync$(
    List<String> command, {
    dart_convert.Encoding? encoding,
    String? workingDirectory,
    Map<String, String>? environment,
    bool includeParentEnvironment = true,
    bool silent = false,
    bool noPrompt = false,
    bool returnCode = false,
    bool autoQuote = true,
  }) {
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
    dart_io.ProcessResult result = dart_io.Process.runSync(
      executable,
      arguments,
      stdoutEncoding: encoding,
      stderrEncoding: encoding,
      workingDirectory: workingDirectory,
      environment: environment,
      includeParentEnvironment: includeParentEnvironment,
      runInShell: !useUnixShell,
    );
    String stdoutString = (result.stdout as String);
    stdoutString = stdoutString.trimRight();
    stdoutString = std_misc.adjustTextNewlines(stdoutString);
    if (!silent) {
      dart_io.stdout.write(stdoutString);
    }
    dart_io.stderr.write(result.stderr as String);
    if (returnCode) {
      return result.exitCode;
    } else {
      return stdoutString;
    }
  }
}
