# CHANGELOG.md

## 2025.424.1835

- Initial release

## 2025.424.1957

- Added: lastChars() and timeBasedVersionString()

## 2025.425.2018

- Added: String adjustTextNewlines(String s),  bool isBinary(Uint8List bytes), bool isText(Uint8List bytes), bool isBinaryFile(String file), and bool isTextFile(String file)

## 2025.426.1519

- Added: List<String> textToLines(String s) /// Splits string with newlines to list of lines

## 2025.426.1626

- Added: bool get isInDebugMode, String\? getenv(String name), Uint8List readFileBytes(String path), String readFileString(String path), List<String> readFileLines(String path), void writeFileBytes(String path, Uint8List data), void writeFileString(String path, String data), bool fileExists(String path), and bool directoryExists(String path)

## 2025.426.1633

- Fixed bug in adjustTextNewlines()

## 2025.426.1637

- Modified within CommandRunner.run$(): buffer = buffer.trimRight()

## 2025.426.2245

- Changed signature of CommandRunner.run$()

## 2025.426.2248

- Added: lib/std.dart

```
--- a/pubspec.yaml
+++ b/pubspec.yaml
-version: 2025.426.2245
+version: 2025.426.2248
```

## 2025.427.52

- Added: example/example.dart

```
--- a/pubspec.yaml
+++ b/pubspec.yaml
-version: 2025.426.2248
+version: 2025.427.52
+platforms:
+  android:
+  ios:
+  linux:
+  macos:
+  #web:
+  windows:
+topics:
+  - cli
+  - process
-#executables:
-#  std: main
```

## 2025.428.1703

- Changed CommandRunner's default encoding from utf8 to SystemEncoding()

```
--- a/pubspec.yaml
+++ b/pubspec.yaml
-version: 2025.427.52
+version: 2025.428.1703
```

## 2025.430.1833

- Added: pathExpand()

```
--- a/pubspec.yaml
+++ b/pubspec.yaml
-version: 2025.428.1703
+version: 2025.430.1833
```

## 2025.430.2012

- Modified pathExpand()

```
--- a/pubspec.yaml
+++ b/pubspec.yaml
-version: 2025.430.1833
+version: 2025.430.2012
```

## 2025.430.2132

- Ported functions depending on path package from sys package

```
--- a/pubspec.yaml
+++ b/pubspec.yaml
-version: 2025.430.2012
+version: 2025.430.2132
+dependencies:
+  path: ^1.9.1
```

## 2025.430.2138

- Added descriptions to some functions

```
--- a/pubspec.yaml
+++ b/pubspec.yaml
-version: 2025.430.2132
+version: 2025.430.2138
```

## 2025.501.843

- Modified readFileString()

```
--- a/pubspec.yaml
+++ b/pubspec.yaml
-version: 2025.430.2138
+version: 2025.501.843
```

## 2025.502.2031

- Added pathOfTempDir

```
--- a/pubspec.yaml
+++ b/pubspec.yaml
-version: 2025.501.843
+version: 2025.502.2031
-  output: ^2025.430.1731
+  output: ^2025.502.1958
-  text_serializer: ^2025.430.1719
+  text_serializer: ^2025.502.1757
```

## 2025.502.2210

- Added: uuidTimeBased(), uuidRandom(), uuidForNamespace(String ns), md5(Uint8List bytes), sha1(Uint8List bytes), sha224(Uint8List bytes), sha256(Uint8List bytes), sha512(Uint8List bytes), identicalBinaries(Uint8List bytes1, Uint8List bytes2), installBinaryToTempDir(Uint8List bytes, {String prefix = '', suffix = '', int trial = 0})

```
--- a/pubspec.yaml
+++ b/pubspec.yaml
-version: 2025.502.2031
+version: 2025.502.2210
+  crypto: ^3.0.6
+  uuid: ^4.5.1
```

## 2025.502.2312

- Added: pathRename(String oldPath, String newPath)

```
--- a/pubspec.yaml
+++ b/pubspec.yaml
-version: 2025.502.2210
+version: 2025.502.2312
```

## 2025.502.2329

- Modified CommandRunner class

```
--- a/pubspec.yaml
+++ b/pubspec.yaml
-version: 2025.502.2312
+version: 2025.502.2329
```

## 2025.502.2358

- Added adjustPackageName(String name)

```
--- a/pubspec.yaml
+++ b/pubspec.yaml
-version: 2025.502.2329
+version: 2025.502.2358
```

## 2025.504.612

- Fixed a bug of pathExpand()

```
--- a/pubspec.yaml
+++ b/pubspec.yaml
-version: 2025.502.2358
+version: 2025.504.612
+  debug_output: ^2025.502.2007
```

## 2025.504.1143

- Added 'String get pathOfUserDir'

```
--- a/pubspec.yaml
+++ b/pubspec.yaml
-version: 2025.504.612
+version: 2025.504.1143
-  output: ^2025.502.1958
+  system_info2: ^4.0.0
```

## 2025.504.1244

- Added pathJoin(List<String> parts)

```
--- a/pubspec.yaml
+++ b/pubspec.yaml
-version: 2025.504.1143
+version: 2025.504.1244
```

## 2025.513.452

- Modified timeBasedVersionString()

```
--- a/pubspec.yaml
+++ b/pubspec.yaml
-version: 2025.504.1244
+version: 2025.513.452
-  test: ^1.25.15
-  text_serializer: ^2025.502.1757
+  test: ^1.26.0
+  intl: ^0.20.2
```

## 2025.523.1949

- Modified command_runner.dart

```
--- a/pubspec.yaml
+++ b/pubspec.yaml
-version: 2025.513.452
+version: 2025.523.1949
-  lints: ^5.1.1
-  test: ^1.26.0
+  lints: ^6.0.0
+  test: ^1.26.2
```

## 2025.523.1954

- Modified command_runner.dart

```
--- a/pubspec.yaml
+++ b/pubspec.yaml
-version: 2025.523.1949
+version: 2025.523.1954
```

## 2025.525.1954

- Modified std/command_runner.dart

```
--- a/pubspec.yaml
+++ b/pubspec.yaml
-version: 2025.523.1954
+version: 2025.525.1954
```

## 2025.526.1746

- Modified std/command_runner.dart

```
--- a/pubspec.yaml
+++ b/pubspec.yaml
-version: 2025.525.1954
+version: 2025.526.1746
```

## 2025.526.1751

- Modified std/command_runner.dart

```
--- a/pubspec.yaml
+++ b/pubspec.yaml
-version: 2025.526.1746
+version: 2025.526.1751
```

## 2025.526.2025

- Modified pathFullName()

```
--- a/pubspec.yaml
+++ b/pubspec.yaml
-version: 2025.526.1751
+version: 2025.526.2025
```

## 2025.526.2028

- std/misc.dart

```
--- a/pubspec.yaml
+++ b/pubspec.yaml
-version: 2025.526.2025
+version: 2025.526.2028
```

## 2025.526.2046

- Modified pathExpand()

```
--- a/pubspec.yaml
+++ b/pubspec.yaml
-version: 2025.526.2028
+version: 2025.526.2046
```

## 2025.526.2206

- Added pathRelative()

```
--- a/pubspec.yaml
+++ b/pubspec.yaml
-version: 2025.526.2046
+version: 2025.526.2206
```

## 2025.526.2313

- Added: Stack<E>, pushd(), popd()

```
--- a/pubspec.yaml
+++ b/pubspec.yaml
-version: 2025.526.2206
+version: 2025.526.2313
```

## 2025.526.2333

- Backport from sys package

```
--- a/pubspec.yaml
+++ b/pubspec.yaml
-version: 2025.526.2313
+version: 2025.526.2333
+  archive: ^4.0.7
+  http: ^1.4.0
```

## 2025.527.154

- Add: CommandRunner.script()

```
--- a/pubspec.yaml
+++ b/pubspec.yaml
-version: 2025.526.2333
+version: 2025.527.154
```

## 2025.527.1952

- Modified CommandRunner.script()

```
--- a/pubspec.yaml
+++ b/pubspec.yaml
-version: 2025.527.154
+version: 2025.527.1952
```

## 2025.606.242

- Added: installZipToTempDir()

```
--- a/pubspec.yaml
+++ b/pubspec.yaml
-version: 2025.527.1952
+version: 2025.606.242
```

## 2025.606.2308

- Added: encryptText(), decryptText(), encryptBytes(), and decryptBytes()

```
--- a/pubspec.yaml
+++ b/pubspec.yaml
-version: 2025.606.242
+version: 2025.606.2308
```

## 2025.607.333

- Modified CommandRunner.script()

```
--- a/pubspec.yaml
+++ b/pubspec.yaml
-version: 2025.606.2308
+version: 2025.607.333
```

## 2025.608.657

- Added: CommandRunner.runSync(), CommandRunner.runSync$(), and CommandRunner.scriptSync()

```
--- a/pubspec.yaml
+++ b/pubspec.yaml
-version: 2025.607.333
+version: 2025.608.657
```

## 2025.609.122

- Modified pathExpand()

```
--- a/pubspec.yaml
+++ b/pubspec.yaml
-version: 2025.608.657
+version: 2025.609.122
```

## 2025.609.455

- Modified CommandRunner.runSync$()

```
--- a/pubspec.yaml
+++ b/pubspec.yaml
-version: 2025.609.122
+version: 2025.609.455
```
