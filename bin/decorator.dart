import 'dart:convert';
import 'dart:math';

import 'package:decorator/decorator.dart';

DecoratorWrapper cache(Function func) {
  final cache = <String, dynamic>{};

  return (
    positionalArguments, [
    namedArguments,
  ]) {
    final key = jsonEncode([positionalArguments, namedArguments]);
    if (cache.containsKey(key)) {
      return cache[key];
    }

    return cache[key] =
        Function.apply(func, positionalArguments, namedArguments);
  };
}

DecoratorWrapper measure(Function func) {
  return (
    positionalArguments, [
    namedArguments,
  ]) {
    final sw = Stopwatch()..start();
    final result = Function.apply(func, positionalArguments, namedArguments);
    print('Execution time: ${sw.elapsed}');
    return result;
  };
}

@Decorate('cache')
int _fibCached(int nth) {
  return switch (nth) {
    0 => 0,
    1 => 1,
    _ => fibCached(nth - 1) + fibCached(nth - 2),
  };
}

int _fibNotCached(int nth) {
  return switch (nth) {
    0 => 0,
    1 => 1,
    _ => _fibNotCached(nth - 1) + _fibNotCached(nth - 2),
  };
}

@Decorate('measure')
void _time(void Function() func) => func();

void main() {
  const amount = 42;
  final sw = Stopwatch()..start();
  print(
    'Fibonacci $amount not cached: ${_fibNotCached(amount)} in ${sw.elapsed}',
  );
  sw.reset();
  print('Fibonacci $amount cached: ${_fibCached(amount)} in ${sw.elapsed}');

  time(() {
    print('How long could it possibly take??');
    final rand = Random();
    while (rand.nextDouble() > 1e-8) {}
  });
}
