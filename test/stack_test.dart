//import 'dart:typed_data';
//import 'dart:convert' as dart_convert;
import 'package:test/test.dart';
import 'package:std/std.dart';
//import 'package:debug_output/debug_output.dart';

void main() {
  group('Stack', () {
    test('stack(1)', () {
      final st = Stack<String>();
      st.push('abc');
      st.push('def');
      st.push('xyz');
      expect(st.pop(), equals('xyz'));
      expect(st.peek(), equals('def'));
      expect(st.pop(), equals('def'));
      expect(st.pop(), equals('abc'));
      expect(() => st.peek(), throwsStateError);
      expect(() => st.pop(), throwsA(TypeMatcher<StateError>()));
    });
    test('pushd/popd', () {
      setCwd('C:/');
      expect(getCwd(), equals('''C:/'''));
      pushd('C:/Windows');
      expect(getCwd(), equals('''C:/Windows'''));
      pushd('~/cmd');
      expect(getCwd(), equals('''D:/home12/cmd'''));
      popd();
      expect(getCwd(), equals('''C:/Windows'''));
      popd();
      expect(getCwd(), equals('''C:/'''));
      expect(() => popd(), throwsA(TypeMatcher<StateError>()));
    });
  });
}
