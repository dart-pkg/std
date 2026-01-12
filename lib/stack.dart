// https://stackoverflow.com/questions/64060944/how-to-implement-a-stack-with-push-and-pop-in-dart
import 'dart:collection' show Queue;

class Stack<T> {
  final Queue<T> _underlyingQueue;

  Stack() : _underlyingQueue = Queue<T>();

  int get length => _underlyingQueue.length;

  bool get isEmpty => _underlyingQueue.isEmpty;

  bool get isNotEmpty => _underlyingQueue.isNotEmpty;

  void clear() => _underlyingQueue.clear();

  T peek() {
    if (isEmpty) {
      throw StateError('Cannot peek() on empty stack.');
    }
    return _underlyingQueue.last;
  }

  T pop() {
    if (isEmpty) {
      throw StateError('Cannot pop() on empty stack.');
    }
    return _underlyingQueue.removeLast();
  }

  void push(final T element) => _underlyingQueue.addLast(element);
}
