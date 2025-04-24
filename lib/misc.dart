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
