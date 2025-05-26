// https://stackoverflow.com/questions/64060944/how-to-implement-a-stack-with-push-and-pop-in-dart
import 'dart:collection' show Queue;

class Stack<T> {
  final Queue<T> _underlyingQueue;

  Stack() : _underlyingQueue = Queue<T>();

  int get length => this._underlyingQueue.length;

  bool get isEmpty => this._underlyingQueue.isEmpty;

  bool get isNotEmpty => this._underlyingQueue.isNotEmpty;

  void clear() => this._underlyingQueue.clear();

  T peek() {
    if (this.isEmpty) {
      throw StateError('Cannot peek() on empty stack.');
    }
    return this._underlyingQueue.last;
  }

  T pop() {
    if (this.isEmpty) {
      throw StateError('Cannot pop() on empty stack.');
    }
    return this._underlyingQueue.removeLast();
  }

  void push(final T element) => this._underlyingQueue.addLast(element);
}
