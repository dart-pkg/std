import 'dart:convert' as dart_convert;
import 'dart:io' as dart_io;
import 'dart:typed_data';
import 'package:archive/archive.dart' as archive_archive;
import 'package:encrypt/encrypt.dart' as encrypt_encrypt;
import 'package:http/http.dart' as http_http;
import 'package:path/path.dart' as path_path;
import 'package:crypto/crypto.dart' as crypto_crypto;
import 'package:uuid/uuid.dart' as uuid_uuid;
import 'package:system_info2/system_info2.dart' as sys_info;
import 'package:intl/intl.dart' as intl_intl;
import 'package:std/stack.dart' as std_stack;
import 'package:std/command_runner.dart';

final _cwdStack = std_stack.Stack<String>();

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

String _adjustVersionString(String s) {
  List<String> split = s.split('.');
  List<String> result = <String>[];
  for (int i = 0; i < split.length; i++) {
    String part = split[i];
    String part2 = '';
    bool isBeginning = true;
    for (int j = 0; j < part.length; j++) {
      if (!isBeginning || (j == part.length - 1)) {
        part2 += part[j];
      } else {
        if (part[j] != '0') {
          part2 += part[j];
          isBeginning = false;
        }
      }
    }
    result.add(part2);
  }
  return result.join('.');
}

/// Returns local time based version string
String timeBasedVersionString() {
  // final now = DateTime.now();
  // String year = '${now.year}';
  // String month = lastChars('0${now.month}', 2);
  // String day = lastChars('0${now.day}', 2);
  // String hour = lastChars('0${now.hour}', 2);
  // String minute = lastChars('0${now.minute}', 2);
  // String version = '$year.$month$day.$hour$minute';
  // version = _adjustVersionString(version);
  // return version;
  final now = DateTime.now();
  final formatter1 = intl_intl.DateFormat('yyyy.MMdd.HHmm');
  String version = formatter1.format(now);
  version = _adjustVersionString(version);
  return version;
}

/// Replace non-unix new lines in a string to unix newlines
String adjustTextNewlines(String s) {
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
bool isBinaryFile(String path) {
  path = pathExpand(path);
  final f = dart_io.File(path);
  Uint8List bytes = f.readAsBytesSync();
  return isBinary(bytes);
}

/// Returns false if file's content is binary else true
bool isTextFile(String path) {
  path = pathExpand(path);
  final f = dart_io.File(path);
  Uint8List bytes = f.readAsBytesSync();
  return !isBinary(bytes);
}

/// Splits string with newlines to list of lines
List<String> textToLines(String s) {
  const splitter = dart_convert.LineSplitter();
  final lines = splitter.convert(s);
  return lines;
}

/// Returns true if dart was run with `--enable-asserts' flag else false
bool get isInDebugMode {
  bool inDebugMode = false;
  assert(inDebugMode = true);
  return inDebugMode;
}

/// Returns environment variable with name or null if not exists
String? getenv(String name) {
  return dart_io.Platform.environment[name];
}

/// Expands path with environment variables
String pathExpand(String path) {
  if (path.contains('://')) {
    return path;
  }
  if (path.startsWith('~')) {
    String? home = getenv('HOME');
    if (home != null) {
      path = '$home${path.substring(1)}';
    } else {
      path = '$pathOfUserDir${path.substring(1)}';
    }
  }
  path = path.replaceAllMapped(RegExp(r'[$]([_0-9a-zA-Z]+)'), (match) {
    String varName = match.group(1)!;
    String? varValue = getenv(varName);
    return varValue ?? match.group(0)!;
  });
  path = path.replaceAllMapped(RegExp(r'[$]{([_0-9a-zA-Z]+)}'), (match) {
    String varName = match.group(1)!;
    String? varValue = getenv(varName);
    return varValue ?? match.group(0)!;
  });
  path = path.replaceAllMapped(RegExp(r'%([_0-9a-zA-Z]+)%'), (match) {
    String varName = match.group(1)!;
    String? varValue = getenv(varName);
    return varValue ?? match.group(0)!;
  });
  if (dart_io.Platform.isWindows && path.startsWith('/')) {
    final cr = CommandRunner(useUnixShell: false, encoding: dart_convert.utf8);
    try {
      //print(path);
      path = cr.runSync('cygpath -wm "$path"', noPrompt: true);
      //print(path);
    } catch (_) {}
  }
  return path_path.normalize(path_path.absolute(path)).replaceAll(r'\', '/');
}

String pathRelative(String path, {String? from}) {
  path = pathExpand(path);
  if (from != null) {
    from = pathExpand(from);
  }
  return path_path.relative(path, from: from).replaceAll('\\', '/');
}

/// Joins the given path parts into a single path
String pathJoin(List<String> parts) {
  if (parts.isEmpty) {
    return '';
  }
  String path = parts[0];
  for (int i = 1; i < parts.length; i++) {
    path = path_path.join(path, parts[i]);
  }
  return pathExpand(path);
}

/// Sets current directory
void setCwd(String path) {
  path = pathExpand(path);
  dart_io.Directory.current = path; //pathFullName(path);
}

/// Gets current directory
String getCwd() {
  return pathFullName(dart_io.Directory.current.absolute.path);
}

/// pushd
void pushd(String path) {
  _cwdStack.push(getCwd());
  setCwd(path);
}

/// popd
void popd() {
  setCwd(_cwdStack.pop());
}

/// Returns full path of a path
String pathFullName(String path) {
  return pathExpand(path);
  //return path_path.normalize(path_path.absolute(path)).replaceAll(r'\', '/');
}

/// Returns directory part of a path
String pathDirectoryName(String path) {
  path = pathExpand(path);
  //return pathFullName(path_path.dirname(path));
  return path_path.dirname(path);
}

/// Returns file name part of a path
String pathFileName(String path) {
  path = pathExpand(path);
  return path_path.basename(path);
}

/// Returns directory part (without extension) of a path
String pathBaseName(String path) {
  path = pathExpand(path);
  return path_path.basenameWithoutExtension(path);
}

/// Returns extension of a path
String pathExtension(String path) {
  path = pathExpand(path);
  return path_path.extension(path);
}

List<String> _getFilesFromDirRecursive(String path) {
  List<String> result = [];
  dart_io.Directory dir = dart_io.Directory(path);
  List<dart_io.FileSystemEntity> entities = dir.listSync().toList();
  for (var entity in entities) {
    if (entity is dart_io.File) {
      result.add(pathFullName(entity.path));
    } else if (entity is dart_io.Directory) {
      result.addAll(_getFilesFromDirRecursive(pathFullName(entity.path)));
    }
  }
  return result;
}

/// Returns all files under a path
List<String> pathFiles(String path, [bool? recursive]) {
  path = pathExpand(path);
  try {
    recursive ??= false;
    if (recursive) {
      return _getFilesFromDirRecursive(
        path,
      ).map(($x) => $x.replaceAll(r'\', r'/')).toList();
    }
    final $dir = dart_io.Directory(path_path.join(path));
    final List<dart_io.FileSystemEntity> $entities = $dir.listSync().toList();
    final Iterable<dart_io.File> $files = $entities.whereType<dart_io.File>();
    List<String> result = [];
    $files.toList().forEach((x) {
      result.add(pathFullName(x.path));
    });
    return result.map(($x) => $x.replaceAll(r'\', r'/')).toList();
  } catch ($e) {
    return <String>[];
  }
}

/// Returns all directories under a path
List<String> pathDirectories(String path) {
  path = pathExpand(path);
  try {
    final $dir = dart_io.Directory(path_path.join(path));
    final List<dart_io.FileSystemEntity> $entities = $dir.listSync().toList();
    final Iterable<dart_io.Directory> $dirs =
        $entities.whereType<dart_io.Directory>();
    List<String> result = [];
    $dirs.toList().forEach((x) {
      result.add(pathFullName(x.path));
    });
    return result.map(($x) => $x.replaceAll(r'\', r'/')).toList();
  } catch ($e) {
    return <String>[];
  }
}

/// Renames a file or a directory
void pathRename(String oldPath, String newPath) {
  if (directoryExists(oldPath)) {
    dart_io.Directory(oldPath).renameSync(newPath);
  } else if (fileExists(oldPath)) {
    dart_io.File(oldPath).renameSync(newPath);
  } else {
    throw Exception('$oldPath does not exist');
  }
}

/// Returns system temporary directory path
String get pathOfTempDir {
  return pathFullName(dart_io.Directory.systemTemp.path);
}

/// Returns system temporary directory path
String get pathOfUserDir {
  return pathFullName(sys_info.SysInfo.userDirectory);
}

/// Reads file content as bytes
Uint8List readFileBytes(String path) {
  path = pathExpand(path);
  final file = dart_io.File(path);
  return file.readAsBytesSync();
}

/// Reads file content as string
String readFileString(String path) {
  path = pathExpand(path);
  final file = dart_io.File(path);
  return adjustTextNewlines(file.readAsStringSync());
}

/// Reads file content as lines
List<String> readFileLines(String path) {
  path = pathExpand(path);
  final file = dart_io.File(path);
  return file.readAsLinesSync();
}

/// Writes bytes data to file
void writeFileBytes(String path, Uint8List data) {
  path = pathExpand(path);
  dart_io.File(path)
    ..createSync(recursive: true)
    ..writeAsBytesSync(data.toList());
}

/// Writes string data to file
void writeFileString(String path, String data) {
  path = pathExpand(path);
  data = adjustTextNewlines(data);
  writeFileBytes(path, dart_convert.utf8.encode(data));
}

/// Returns true if file exists or false if not
bool fileExists(String path) {
  path = pathExpand(path);
  return dart_io.File(path).existsSync();
}

/// Returns true if directory exists or false if not
bool directoryExists(String path) {
  path = pathExpand(path);
  return dart_io.Directory(path).existsSync();
}

/// Generates a time-based version 1 UUID
String uuidTimeBased() {
  var uuid = uuid_uuid.Uuid();
  return uuid.v1();
}

/// Generates a RNG version 4 UUID (a random UUID)
String uuidRandom() {
  var uuid = uuid_uuid.Uuid();
  return uuid.v4();
}

/// Generate a v5 (namespace-name-sha1-based) id
String uuidForNamespace(String ns) {
  var uuid = uuid_uuid.Uuid();
  return uuid.v5(uuid_uuid.Namespace.url.value, ns);
}

/// Returns MD5 hash
String md5(Uint8List bytes) {
  var digest = crypto_crypto.md5.convert(bytes);
  return digest.toString();
}

/// Returns SHA-1 hash
String sha1(Uint8List bytes) {
  var digest = crypto_crypto.sha1.convert(bytes);
  return digest.toString();
}

/// Returns SHA-224 hash
String sha224(Uint8List bytes) {
  var digest = crypto_crypto.sha224.convert(bytes);
  return digest.toString();
}

/// Returns SHA-256 hash
String sha256(Uint8List bytes) {
  var digest = crypto_crypto.sha256.convert(bytes);
  return digest.toString();
}

/// Returns SHA-512 hash
String sha512(Uint8List bytes) {
  var digest = crypto_crypto.sha512.convert(bytes);
  return digest.toString();
}

/// Returns true if byte1 and bytes2 are identical, false if not
bool identicalBinaries(Uint8List bytes1, Uint8List bytes2) {
  if (bytes1.length != bytes2.length) return false;
  for (int i = 0; i < bytes1.length; i++) {
    if (bytes1[i] != bytes2[i]) {
      return false;
    }
  }
  return true;
}

/// Installs bytes to temp dir and returns the full path of that file
String installBinaryToTempDir(
  Uint8List bytes, {
  String prefix = '',
  suffix = '',
  int trial = 0,
}) {
  var sha = md5(bytes);
  String fileName = prefix + sha + (trial == 0 ? '' : '_$trial') + suffix;
  String path = path_path.join(pathOfTempDir, fileName).replaceAll(r'\', '/');
  if (!fileExists(path)) {
    String uuid = uuidTimeBased();
    writeFileBytes('$path.$uuid', bytes);
    try {
      //dart_io.File('$path.$uuid').renameSync(path);
      pathRename('$path.$uuid', path);
    } catch (_) {}
  }
  Uint8List bytes2 = readFileBytes(path);
  if (identicalBinaries(bytes, bytes2)) {
    return path;
  }
  return installBinaryToTempDir(
    bytes,
    prefix: prefix,
    suffix: suffix,
    trial: trial + 1,
  );
}

/// Converts illegal characters for dart package name to underscore (_)
String adjustPackageName(String name) {
  name = name.replaceAllMapped(RegExp(r'[^_0-9a-zA-Z]+'), (match) {
    return '_';
  });
  while (name.contains('__')) {
    name = name.replaceAll('__', '_');
  }
  return name;
}

///
String reformatUglyYaml(String yaml) {
  List<String> lines1 = textToLines(yaml);
  List<String> lines2 = <String>[];
  for (int i = 0; i < lines1.length; i++) {
    if (i > 0) {
      if (lines1[i] == '' && lines1[i - 1] == '') {
        continue;
      }
    }
    lines2.add(lines1[i]);
  }
  yaml = lines2.join('\n');
  if (yaml.endsWith('\n\n')) {
    yaml = yaml.substring(0, yaml.length - 1);
  } else if (!yaml.endsWith('\n')) {
    yaml += '\n';
  }
  return yaml;
}

///
void reformatUglyYamlFile(String yamlPath) {
  String yaml = readFileString(yamlPath);
  writeFileString(yamlPath, reformatUglyYaml(yaml));
}

///
Future<String?> httpGetBodyAsync(String $urlString) async {
  try {
    var url = Uri.parse($urlString);
    var response = await http_http.get(url);
    if (response.statusCode != 200) {
      return null;
    }
    return response.body;
  } catch ($e) {
    return null;
  }
}

///
void unzipToDirectory(dynamic pathOrBytes, String destDir) {
  Uint8List bytes;
  if (pathOrBytes is String) {
    String zipPath = pathOrBytes;
    zipPath = pathFullName(pathExpand(zipPath));
    destDir = pathFullName(pathExpand(destDir));
    bytes = dart_io.File(zipPath).readAsBytesSync();
  } else if (pathOrBytes is Uint8List) {
    bytes = pathOrBytes;
  } else {
    throw ArgumentError();
  }
  final archive = archive_archive.ZipDecoder().decodeBytes(bytes);
  for (final entry in archive) {
    if (entry.isFile) {
      var fileBytes = entry.readBytes();
      fileBytes = fileBytes!;
      if (isText(fileBytes)) {
        String text = dart_convert.utf8.decode(fileBytes);
        text = adjustTextNewlines(text);
        fileBytes = dart_convert.utf8.encode(text);
      }
      writeFileBytes('$destDir/${entry.name}', fileBytes);
    }
  }
}

///
void untarToDirectory(dynamic pathOrBytes, String destDir) {
  Uint8List bytes;
  if (pathOrBytes is String) {
    String zipPath = pathOrBytes;
    zipPath = pathFullName(pathExpand(zipPath));
    destDir = pathFullName(pathExpand(destDir));
    bytes = dart_io.File(zipPath).readAsBytesSync();
  } else if (pathOrBytes is Uint8List) {
    bytes = pathOrBytes;
  } else {
    throw ArgumentError();
  }
  final archive = archive_archive.TarDecoder().decodeBytes(bytes);
  for (final entry in archive) {
    if (entry.isFile) {
      var fileBytes = entry.readBytes();
      fileBytes = fileBytes!;
      if (isText(fileBytes)) {
        String text = dart_convert.utf8.decode(fileBytes);
        text = adjustTextNewlines(text);
        fileBytes = dart_convert.utf8.encode(text);
      }
      writeFileBytes('$destDir/${entry.name}', fileBytes);
    }
  }
}

///
bool unzipCheck(dynamic pathOrBytes, String destDir) {
  Uint8List bytes;
  if (pathOrBytes is String) {
    String zipPath = pathOrBytes;
    zipPath = pathFullName(pathExpand(zipPath));
    destDir = pathFullName(pathExpand(destDir));
    bytes = dart_io.File(zipPath).readAsBytesSync();
  } else if (pathOrBytes is Uint8List) {
    bytes = pathOrBytes;
  } else {
    throw ArgumentError();
  }
  final archive = archive_archive.ZipDecoder().decodeBytes(bytes);
  for (final entry in archive) {
    if (entry.isFile) {
      var fileBytes = entry.readBytes();
      fileBytes = fileBytes!;
      if (isText(fileBytes)) {
        String text = dart_convert.utf8.decode(fileBytes);
        text = adjustTextNewlines(text);
        fileBytes = dart_convert.utf8.encode(text);
      }
      //writeFileBytes('$destDir/${entry.name}', fileBytes);
      if (!fileExists('$destDir/${entry.name}')) return false;
      var destBytes = readFileBytes('$destDir/${entry.name}');
      if (!identicalBinaries(fileBytes, destBytes)) return false;
    }
  }
  return true;
}

/// Installs zip bytes to temp dir and returns the full path of that directory
String installZipToTempDir(
  Uint8List bytes, {
  String prefix = '',
  suffix = '',
  int trial = 0,
}) {
  var sha = md5(bytes);
  String fileName = prefix + sha + (trial == 0 ? '' : '_$trial') + suffix;
  String path = path_path.join(pathOfTempDir, fileName).replaceAll(r'\', '/');
  if (!directoryExists(path)) {
    String uuid = uuidTimeBased();
    unzipToDirectory(bytes, '$path.$uuid');
    try {
      pathRename('$path.$uuid', path);
    } catch (_) {}
  }
  if (unzipCheck(bytes, path)) {
    return path;
  }
  return installZipToTempDir(
    bytes,
    prefix: prefix,
    suffix: suffix,
    trial: trial + 1,
  );
}

///
String encryptText(String plainText, String keyText, String ivText) {
  keyText = sha512(dart_convert.utf8.encode(keyText)).substring(0, 32);
  ivText = sha512(dart_convert.utf8.encode(ivText)).substring(0, 16);
  final key = encrypt_encrypt.Key.fromUtf8(keyText);
  final iv = encrypt_encrypt.IV.fromUtf8(ivText);
  final encrypter = encrypt_encrypt.Encrypter(encrypt_encrypt.AES(key));
  final encrypted = encrypter.encrypt(plainText, iv: iv);
  return encrypted.base64;
}

///
String decryptText(String base64Text, String keyText, String ivText) {
  keyText = sha512(dart_convert.utf8.encode(keyText)).substring(0, 32);
  ivText = sha512(dart_convert.utf8.encode(ivText)).substring(0, 16);
  final key = encrypt_encrypt.Key.fromUtf8(keyText);
  final iv = encrypt_encrypt.IV.fromUtf8(ivText);
  final encrypter = encrypt_encrypt.Encrypter(encrypt_encrypt.AES(key));
  return encrypter.decrypt64(base64Text, iv: iv);
}

///
String encryptBytes(Uint8List bytes, String keyText, String ivText) {
  keyText = sha512(dart_convert.utf8.encode(keyText)).substring(0, 32);
  ivText = sha512(dart_convert.utf8.encode(ivText)).substring(0, 16);
  final key = encrypt_encrypt.Key.fromUtf8(keyText);
  final iv = encrypt_encrypt.IV.fromUtf8(ivText);
  final encrypter = encrypt_encrypt.Encrypter(encrypt_encrypt.AES(key));
  final encrypted = encrypter.encryptBytes(bytes, iv: iv);
  return encrypted.base64;
}

///
Uint8List decryptBytes(String base64Text, String keyText, String ivText) {
  keyText = sha512(dart_convert.utf8.encode(keyText)).substring(0, 32);
  ivText = sha512(dart_convert.utf8.encode(ivText)).substring(0, 16);
  final key = encrypt_encrypt.Key.fromUtf8(keyText);
  final iv = encrypt_encrypt.IV.fromUtf8(ivText);
  final encrypter = encrypt_encrypt.Encrypter(encrypt_encrypt.AES(key));
  return Uint8List.fromList(
    encrypter.decryptBytes(
      encrypt_encrypt.Encrypted.fromBase64(base64Text),
      iv: iv,
    ),
  );
}
