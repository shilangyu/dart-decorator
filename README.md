# dart decorator

WIP

Implements the functional decorator mechanism in Dart using macros. See [./lib/decorator.dart](./lib/decorator.dart) for macro implementation and [./bin/decorator.dart](./bin/decorator.dart) for usage.

Example decorator, `cache`:

```dart
DecoratorWrapper cache(Function func) {
  final cache = <String, dynamic>{};

  return (
    positionalArguments, [
    namedArguments,
  ]) {
    final key = jsonEncode([
      positionalArguments,
      namedArguments?.map((k, v) => MapEntry(k.toString(), v)),
    ]);
    if (cache.containsKey(key)) {
      return cache[key];
    }

    return cache[key] =
        Function.apply(func, positionalArguments, namedArguments);
  };
}
```

Which then can be used with:

```dart
@Decorate('cache')
int fib(int nth) {
  return switch (nth) {
    0 => 0,
    1 => 1,
    _ => fib(nth - 1) + fib(nth - 2),
  };
}
```
