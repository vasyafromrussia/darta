library darta.builder;

import 'package:build/build.dart';
import 'package:darta/src/data_class_generator.dart';
import 'package:source_gen/source_gen.dart';

Builder dataClassBuilder(BuilderOptions options) =>
    SharedPartBuilder([DataClassGenerator()], 'data');
