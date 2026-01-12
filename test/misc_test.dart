import 'dart:typed_data';
import 'dart:convert' as dart_convert;
import 'package:test/test.dart';
import 'package:std/misc.dart';
import 'package:debug_output/debug_output.dart';

void main() {
  group('Misc', () {
    test('encryptText(1)', () {
      String result;
      String enc = encryptText('this is a text', 'passwd', 'iv');
      result = echo(enc, title: 'enc');
      expect(result, equals(r'''enc ==> `osFC4ZrmBNMEUDkrbi0olg==`'''));
      String dec = decryptText(enc, 'passwd', 'iv');
      result = echo(dec, title: 'dec');
      expect(result, equals(r'''dec ==> `this is a text`'''));
    });
    test('encryptText(2)', () {
      for (int i = 0; i < 10; i++) {
        String text = uuidRandom();
        echo(text, title: 'text');
        String pass = uuidRandom();
        String iv = uuidRandom();
        String enc = encryptText(text, pass, iv);
        echo(enc, title: 'enc');
        String dec = decryptText(enc, pass, iv);
        echo(dec, title: 'dec');
        expect(dec, equals(text));
      }
    });
    test('encryptBytes(1)', () {
      String result;
      String enc = encryptBytes(
        dart_convert.utf8.encode('this is a text'),
        'passwd',
        'iv',
      );
      result = echo(enc, title: 'enc');
      expect(result, equals(r'''enc ==> `osFC4ZrmBNMEUDkrbi0olg==`'''));
      String dec = dart_convert.utf8.decode(decryptBytes(enc, 'passwd', 'iv'));
      result = echo(dec, title: 'dec');
      expect(result, equals(r'''dec ==> `this is a text`'''));
    });
    test('encryptBytes(2)', () {
      for (int i = 0; i < 10; i++) {
        String text = uuidRandom();
        echo(text, title: 'text');
        String pass = uuidRandom();
        String iv = uuidRandom();
        String enc = encryptBytes(dart_convert.utf8.encode(text), pass, iv);
        echo(enc, title: 'enc');
        String dec = dart_convert.utf8.decode(decryptBytes(enc, pass, iv));
        echo(dec, title: 'dec');
        expect(dec, equals(text));
      }
    });
    // test('installZipToTempDir()', () {
    //   setCwd('~/pub/std');
    //   String result;
    //   var bytes = readFileBytes('test.zip');
    //   String path = installZipToTempDir(bytes, prefix: 'test-', suffix: '.zip');
    //   result = echo(path, type: 'json');
    //   expect(
    //     result,
    //     equals(
    //       r'''"C:/msys64/tmp/test-63f1da43316014a2b8e02d32f39ae7d6.zip"''',
    //     ),
    //   );
    // });
    test('expand url', () {
      String result;
      String exp = pathExpand('https://www.youtube.com/xyz/../abc');
      result = echo(exp, type: 'json');
      expect(result, equals(r'''"https://www.youtube.com/xyz/../abc"'''));
    });
    // test('pathExpand()', () {
    //   String result;
    //   String exp = pathExpand('/xyz');
    //   result = echo(exp, type: 'json');
    //   print('pathExpand() before expect');
    //   expect(result, equals(r'''"C:/msys64/xyz"'''));
    //   print('pathExpand() ok');
    // });
    test('pathRelative()', () {
      String result;
      String rel;
      rel = pathRelative(
        'https://www.youtube.com/xyz/',
        from: 'https://www.youtube.com/abc/',
      );
      result = echo(rel, type: 'json');
      expect(result, equals(r'''"../xyz"'''));
      setCwd('~/pub/std');
      rel = pathRelative(r'D:\home12\cmd');
      result = echo(rel, type: 'json');
      expect(result, equals(r'''"../../cmd"'''));
      echo(getCwd(), title: 'getCwd()');
      rel = pathRelative(r'~\cmd', from: '.');
      result = echo(rel, type: 'json');
      expect(result, equals(r'''"../../cmd"'''));
    });
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
]'''),
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
      expect(isBinaryFile('~/pub/std/test/favicon.png'), isTrue);
      expect(isBinaryFile('~/pub/std/test/misc_test.dart'), isFalse);
      expect(isTextFile('~/pub/std/test/favicon.png'), isFalse);
      expect(isTextFile('~/pub/std/test/misc_test.dart'), isTrue);
    });
    //     test('pathExpand()', () {
    //       String result;
    //       result = echo(pathExpand(r'$HOME/cmd/$XYZ'));
    //       expect(
    //         result,
    //         equals(r'''
    // `D:/home12/cmd/$XYZ`'''),
    //       );
    //       result = echo(pathExpand(r'${HOME}/cmd/${XYZ}'));
    //       expect(
    //         result,
    //         equals(r'''
    // `D:/home12/cmd/${XYZ}`'''),
    //       );
    //       result = echo(pathExpand(r'~/cmd/${XYZ}'));
    //       expect(
    //         result,
    //         equals(r'''
    // `D:/home12/cmd/${XYZ}`'''),
    //       );
    //       result = echo(pathExpand(r'~'));
    //       expect(
    //         result,
    //         equals(r'''
    // `D:/home12`'''),
    //       );
    //       result = echo(pathExpand(r'%USERPROFILE%\%MSYSTEM%\${XYZ}'));
    //       expect(
    //         result,
    //         equals(r'''
    // `C:/Users/user/CLANG64/${XYZ}`'''),
    //       );
    //     });
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
        result,
        equals(r'''
`D:/home12/cmd`'''),
      );
      result = echo(pathJoin([r'$HOME', 'cmd']));
      expect(
        result,
        equals(r'''
`D:/home12/cmd`'''),
      );
      result = echo(pathJoin([r'$HOME', 'pub', 'dart_scan', 'lib']));
      expect(
        result,
        equals(r'''
`D:/home12/pub/dart_scan/lib`'''),
      );
      result = echo(pathJoin([r'$HOME']));
      expect(
        result,
        equals(r'''
`D:/home12`'''),
      );
      result = echo(pathJoin([]));
      expect(
        result,
        equals(r'''
``'''),
      );
    });
  });
  test('findExePath()', () {
    echo(findExePath('cs-gen.exe'));
  });
}
