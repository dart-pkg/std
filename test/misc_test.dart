import 'dart:typed_data';
import 'dart:convert' as dart_convert;
import 'package:test/test.dart';
import 'package:std/misc.dart';
import 'package:debug_output/debug_output.dart';
import 'package:text_serializer/text_serializer.dart';

void main() {
  group('Misc', () {
    test('splitCommandLine()', () {
      String result;
      var line = splitCommandLine(r'''ls -l''');
      result = echo(line, type: 'json');
      expect(
        result,
        equals(r'''
[
  "ls",
  "-l"
]
'''),
      );
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
      String result;
      result = echo(pathExpand(r'$HOME/cmd/$XYZ'));
      expect(
        result,
        equals(r'''
`D:/home11/cmd/$XYZ`
'''),
      );
      result = echo(pathExpand(r'${HOME}/cmd/${XYZ}'));
      expect(
        result,
        equals(r'''
`D:/home11/cmd/${XYZ}`
'''),
      );
      result = echo(pathExpand(r'~/cmd/${XYZ}'));
      expect(
        result,
        equals(r'''
`D:/home11/cmd/${XYZ}`
'''),
      );
      result = echo(pathExpand(r'~'));
      expect(
        result,
        equals(r'''
`D:/home11`
'''),
      );
      result = echo(pathExpand(r'%USERPROFILE%\%MSYSTEM%\${XYZ}'));
      expect(
        result,
        equals(r'''
`C:/Users/user/CLANG64/${XYZ}`
'''),
      );
    });
    test('readFileString()', () {
      String result = readFileString(r'$HOME/.bashrc');
      echo(result, type: 'json');
      expect(result.contains('\r\n'), isFalse);
    });
    test('pathOfTempDir', () {
      echo(pathOfTempDir, title: 'pathOfTempDir');
    });
    test('pathOfUserDir', () {
      String result;
      result = echo(pathOfUserDir, title: 'pathOfUserDir').trimRight();
      expect(result, equals(r'''pathOfUserDir ==> `C:/Users/user`'''));
    });
    test('installBinaryToTempDir()', () {
      Uint8List bytes = dart_convert.utf8.encode('abcハロー©');
      echo(installBinaryToTempDir(bytes, prefix: 'test-', suffix: '.txt'));
    });
    test('pathJoin', () {
      String result;
      result = echo(pathJoin(['~', 'cmd']));
      expect(
        result, equals(
            r'''
`D:/home11/cmd`
''')
      );
      result = echo(pathJoin([r'$HOME', 'cmd']));
      expect(
        result, equals(
            r'''
`D:/home11/cmd`
''')
      );
      result = echo(pathJoin([r'$HOME', 'pub', 'dart_scan', 'lib']));
      expect(
        result, equals(
            r'''
`D:/home11/pub/dart_scan/lib`
''')
      );
      result = echo(pathJoin([r'$HOME']));
      expect(
        result, equals(
            r'''
`D:/home11`
''')
      );
      result = echo(pathJoin([]));
      expect(
        result, equals(
            r'''
``
''')
      );
    });
  });
}
