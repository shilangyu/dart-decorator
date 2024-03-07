import 'dart:async';

// ignore: implementation_imports
import 'package:_fe_analyzer_shared/src/macros/api.dart';

typedef DecoratorWrapper = dynamic Function(
  List<dynamic>? positionalArguments, [
  Map<Symbol, dynamic>? namedArguments,
]);
typedef Decorator = DecoratorWrapper Function(Function);

/// A functional decorator. It wraps a function with another function.
/// Can be thought of as adding a middleware.
///
/// To be applied on a private function '_$name', and will generate a decorated
/// version under the name '$name'.
macro class Decorate implements FunctionDeclarationsMacro {
  const Decorate(this.decoratorName);

  /// The name of the function that will serve as a wrapper. It has to exist in scope.
  final String decoratorName;

  @override
  FutureOr<void> buildDeclarationsForFunction(
    FunctionDeclaration function,
    DeclarationBuilder builder,
  ) async {
    final functionName = function.identifier.name;
    if (!functionName.startsWith('_')) {
      throw ArgumentError(
        'Decorator should only be used on private functions.',
      );
    }
    // TOOD: composability. This is an important feature of decorators.

    // name with leading underscore removed
    final newFunctionName = functionName.substring(1);
    final proxyFunctionName = '__$newFunctionName';

    final dyn = await builder.resolveIdentifier(
      Uri.parse('dart:core'),
      'dynamic',
    );
    final symbol = await builder.resolveIdentifier(
      Uri.parse('dart:core'),
      'Symbol',
    );

    builder.declareInLibrary(
      DeclarationCode.fromParts([
        'final $proxyFunctionName = $decoratorName($functionName);',
        '/// Generated from `$functionName` with `$decoratorName` applied.\n',
        function.returnType.code,
        ' $newFunctionName',
        // TODO: not implemented in macros yet
        // if (function.typeParameters.isNotEmpty) ...[
        //   '<',
        //   for (final type in function.typeParameters) ...[type.name, ', '],
        //   '>',
        // ],
        '(',
        for (final param in function.positionalParameters) ...[
          param.type.code,
          ' ${param.identifier.name}, ',
        ],
        if (function.namedParameters.isNotEmpty) ...[
          '{',
          for (final param in function.namedParameters) ...[
            '${param.isRequired ? 'required' : ''} ',
            param.type.code,
            ' ${param.identifier.name}, ',
          ],
          '}',
        ],
        ') => $proxyFunctionName(',
        // TODO: ugh oh, allocating a list and a map for every call, can this be skipped? Prolly not
        if (function.positionalParameters.isNotEmpty) ...[
          '[',
          for (final param in function.positionalParameters)
            '${param.identifier.name}, ',
          '],',
        ] else
          'null, ',
        if (function.namedParameters.isNotEmpty) ...[
          '<',
          symbol,
          ', ',
          dyn,
          '>{',
          for (final param in function.namedParameters)
            '#${param.identifier.name}: ${param.identifier.name}, ',
          '}',
        ],
        ');',
      ]),
    );
  }
}
