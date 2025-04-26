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
