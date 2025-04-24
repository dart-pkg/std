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
