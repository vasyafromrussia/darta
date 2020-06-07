Darta is annotation based Dart data classes generator.

## Usage

Just annotate your abstract class with `@Data` annotation:

```dart
import 'package:darta/darta.dart';

part 'example.g.dart';

@Data()
abstract class Dog {
  String get name;
  String get breed;
}
```

Then run `build_runner`. That's all! You got few generated classes:
- Child class implementing `toString()`, `hashCode` and `==`.
- Factory class with `create()` method for usual instantiating and `fromMap()` for instantiating from the map.
- `copyWith()` and `toMap()` extensions.

What you DON'T get:
- Red code until `build_runner` run.
- Polluted code base.
