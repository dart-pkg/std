// ignore_for_file: prefer_single_quotes
import 'dart:typed_data';
import 'dart:convert' as dart_convert;
import 'package:test/test.dart';
import 'package:std/misc.dart';
import 'package:output/output.dart';
import 'package:text_serializer/text_serializer.dart';

void main() {
  group('Misc', () {
    test('splitCommandLine()', () {
      var result = splitCommandLine(r'''ls -l''');
      echo(toJson(result));
      expect(toJson(result) == r'''["ls","-l"]''', isTrue);
    });
    test('timeBasedVersionString()', () {
      echo(timeBasedVersionString());
    });
    test('isBinary()', () {
      final Uint8List listA = Uint8List.fromList([1, 2, 3]);
      expect(isBinary(listA), isFalse);
      final Uint8List listB = Uint8List.fromList([1, 0, 3]);
      expect(isBinary(listB), isTrue);
      final List<int> listC = <int>[];
      for (int i = 0; i < 8000; i++) {
        listC.add(1);
      }
      listC.add(0);
      expect(isBinary(Uint8List.fromList(listC)), isFalse);
      final List<int> listD = <int>[];
      for (int i = 0; i < 7999; i++) {
        listD.add(1);
      }
      listD.add(0);
      expect(isBinary(Uint8List.fromList(listD)), isTrue);
      expect(isBinaryFile('test/favicon.png'), isTrue);
      expect(isBinaryFile('test/misc_test.dart'), isFalse);
      expect(isTextFile('test/favicon.png'), isFalse);
      expect(isTextFile('test/misc_test.dart'), isTrue);
    });
    test('pathExpand()', () {
      String result = pathExpand(r'$HOME/cmd/$XYZ');
      echo(result, r'result');
      expect(result == r'''D:/home11/cmd/$XYZ''', isTrue);
      result = pathExpand(r'${HOME}/cmd/${XYZ}');
      echo(result, r'result');
      expect(result == r'''D:/home11/cmd/${XYZ}''', isTrue);
      result = pathExpand(r'~/cmd/${XYZ}');
      echo(result, r'result');
      expect(result == r'''D:/home11/cmd/${XYZ}''', isTrue);
      result = pathExpand(r'%USERPROFILE%\%MSYSTEM%\${XYZ}');
      echo(result, r'result');
      expect(result == r'''C:/Users/user/CLANG64/${XYZ}''', isTrue);
    });
    test('readFileString()', () {
      String result = readFileString(r'$HOME/.bashrc');
      echoJson(result);
      expect(result.contains('\r\n'), isFalse);
    });
    test('pathOfTempDir', () {
      echo(pathOfTempDir, 'pathOfTempDir');
    });
    test('installBinaryToTempDir()', () {
      Uint8List bytes = dart_convert.utf8.encode('abcハロー©');
      echo(installBinaryToTempDir(bytes, prefix: 'test-', suffix: '.txt'));
    });
  });
}
