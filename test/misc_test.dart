// ignore_for_file: prefer_single_quotes
import 'package:test/test.dart';
import 'package:std/misc.dart';
import 'package:output/output.dart';
import 'package:text_serializer/text_serializer.dart';

void main() {
  group('Misc', () {
    test('splitCommandLine', () {
      var result = splitCommandLine(r'''ls -l''');
      echo(toJson(result));
      expect(toJson(result) == r'''["ls","-l"]''', isTrue);
    });
  });
}
