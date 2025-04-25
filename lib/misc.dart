import 'dart:io' as io__;
import 'dart:typed_data';

/// Makes a command line string from List of String (arg list).
String joinCommandLine(List<String> command) {
  return command.join(' ');
}

/// Split a command line string into List of String (arg list).
List<String> splitCommandLine(String command) {
  final ret = <String>[];
  command = command.trim();
  while (command.isNotEmpty) {
    var regexp = RegExp(r"""[^'"-\s]+""");
    if (command[0] == '-') {
      regexp = RegExp(r"""--?[^'"\s]+""");
    } else if (command[0] == "'") {
      regexp = RegExp(r"""'[^']+'""");
    } else if (command[0] == '"') {
      regexp = RegExp(r'''"[^"]+"''');
    } else if (command[0] == '`') {
      regexp = RegExp(r'''`[^`]+`''');
    }
    final match = regexp.matchAsPrefix(command);
    if (match != null) {
      var part = command.substring(match.start, match.end);
      ret.add(part);
      command = command.substring(match.end).trim();
    } else {
      throw Exception('Cannot parse $command');
    }
  }
  return ret;
}

/// Returns last n characters of a string
String lastChars(String s, int len) {
  return s.substring(s.length - len);
}

String _adjustVersionString(String $s) {
  List<String> $split = $s.split('.');
  List<String> $result = <String>[];
  for (int i = 0; i < $split.length; i++) {
    String $part = $split[i];
    String $part2 = '';
    bool isBeggining = true;
    for (int j = 0; j < $part.length; j++) {
      if (!isBeggining || (j == $part.length - 1)) {
        $part2 += $part[j];
      } else {
        if ($part[j] != '0') {
          $part2 += $part[j];
          isBeggining = false;
        }
      }
    }
    $result.add($part2);
  }
  return $result.join('.');
}

/// Returns local time based version string
String timeBasedVersionString() {
  final now = DateTime.now();
  String year = '${now.year}';
  String month = lastChars('0${now.month}', 2);
  String day = lastChars('0${now.day}', 2);
  String hour = lastChars('0${now.hour}', 2);
  String minute = lastChars('0${now.minute}', 2);
  String version = '$year.$month$day.$hour$minute';
  version = _adjustVersionString(version);
  return version;
}

/// Replace non-unix new lines in a string to unix newlines
String adjustTextNewlines(String s) {
  if (s.endsWith('\r\n')) {
    s = s.substring(0, s.length - 2);
  } else if (s.endsWith('\n')) {
    s = s.substring(0, s.length - 1);
  } else if (s.endsWith('\r')) {
    s = s.substring(0, s.length - 1);
  }
  s = s.replaceAll('\r\n', '\n');
  s = s.replaceAll('\r', '\n');
  return s;
}

/// Returns true if bytes is binary else false
bool isBinary(Uint8List bytes) {
  for (int i = 0; i < bytes.length; i++) {
    if (bytes[i] == 0) {
      return true;
    }
    if (i >= (8000 - 1)) {
      break;
    }
  }
  return false;
}

/// Returns false if bytes is binary else true
bool isText(Uint8List bytes) {
  return !isBinary(bytes);
}

/// Returns true if file's content is binary else false
bool isBinaryFile(String file) {
  final f = io__.File(file);
  Uint8List bytes = f.readAsBytesSync();
  return isBinary(bytes);
}

/// Returns false if file's content is binary else true
bool isTextFile(String file) {
  final f = io__.File(file);
  Uint8List bytes = f.readAsBytesSync();
  return !isBinary(bytes);
}
