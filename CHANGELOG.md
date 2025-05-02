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
