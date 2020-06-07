import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:darta/annotations.dart';
import 'package:source_gen/source_gen.dart';

class DataClassGenerator extends GeneratorForAnnotation<Data> {
  @override
  String generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    if (!(element is ClassElement && element.isAbstract)) {
      throw ('Only abstract classes can be annotated with @Data');
    }

    final classElement = element as ClassElement;
    return _withTemplate(_ClassData(classElement));
  }
}

String _withTemplate(_ClassData data) => '''
  class ${data.implementationName} implements ${data.className} {
    
    ${data.implementationFields}
    
    ${data.implementationName}(${data.implementationConstructorParameters});
    
    @override 
    String toString() => '${data.className}(${data.toStringPresentation})';
    
    @override 
    bool operator ==(Object other) =>
        identical(this, other) ||
        (other is ${data.className} && runtimeType == other.runtimeType
          && ${data.equalityPresentation});
    
    @override 
    int get hashCode => ${data.hashCodePresentation};
  }    
  
  class ${data.className}Factory {
    static ${data.className} create(${data.namedArguments}) => 
      ${data.implementationName}(${data.namedAssignments});
      
    static ${data.className} fromMap(Map<String, dynamic> map) => 
      ${data.implementationName}(${data.fromMapArguments});     
  }
  
  extension ${data.className}DataClass on ${data.className} {
    ${data.className} copyWith(${data.namedArguments}) {
      if (${data.equalityChecks}) { 
        return this; 
      }
      
      return ${data.implementationName}(   
        ${data.copyConstructorArguments}
      );
    }
  
    Map<String, dynamic> toMap() => {${data.toMapPairs}};
  }
''';

class _ClassData {
  final ClassElement _classElement;

  String get className => _classElement.displayName;

  String get implementationName => '_${_classElement.displayName}';

  String get implementationFields => _implementationFieldsMapper.value;

  String get implementationConstructorParameters =>
      _implementationConstructorParametersMapper.value;

  String get toStringPresentation => _toStringPresentationMapper.value;

  String get equalityPresentation => _equalityPresentationMapper.value;

  String get hashCodePresentation => _hashCodePresentationMapper.value;

  String get namedArguments => _namedArgumentsMapper.value;

  String get namedAssignments => _namedAssignmentsMapper.value;

  String get fromMapArguments => _fromMapArgumentsMapper.value;

  String get equalityChecks => _equalityChecksMapper.value;

  String get copyConstructorArguments => _copyConstructorArgumentsMapper.value;

  String get toMapPairs => _toMapPairsMapper.value;

  final _FieldMapper _implementationFieldsMapper =
      _FieldMapper(mapper: (type, name) => '@override $type $name;');
  final _FieldMapper _implementationConstructorParametersMapper =
      _FieldMapper(mapper: (_, name) => 'this.$name,', start: '{', end: '}');
  final _FieldMapper _toStringPresentationMapper = _FieldMapper(
      mapper: (_, name) => '$name: \${$name.toString()}', separator: ', ');
  final _FieldMapper _equalityPresentationMapper = _FieldMapper(
      mapper: (_, name) => '$name == other.$name', separator: ' && ');
  final _FieldMapper _hashCodePresentationMapper =
      _FieldMapper(mapper: (_, name) => '$name.hashCode', separator: ' ^ ');
  final _FieldMapper _namedArgumentsMapper = _FieldMapper(
      mapper: (type, name) => '$type $name,', start: '{', end: '}');
  final _FieldMapper _namedAssignmentsMapper =
      _FieldMapper(mapper: (type, name) => '$name: $name,');
  final _FieldMapper _fromMapArgumentsMapper =
      _FieldMapper(mapper: (type, name) => '$name: map[\'$name\'] as $type,');
  final _FieldMapper _equalityChecksMapper = _FieldMapper(
      mapper: (type, name) => '($name == null || identical($name, this.$name))',
      separator: ' && ');
  final _FieldMapper _copyConstructorArgumentsMapper =
      _FieldMapper(mapper: (_, name) => '$name: $name ?? this.$name,');
  final _FieldMapper _toMapPairsMapper =
      _FieldMapper(mapper: (_, name) => '\'$name\': $name,');

  _ClassData(this._classElement) {
    final mappers = <_FieldMapper>[
      _implementationFieldsMapper,
      _implementationConstructorParametersMapper,
      _toStringPresentationMapper,
      _equalityPresentationMapper,
      _hashCodePresentationMapper,
      _namedArgumentsMapper,
      _namedAssignmentsMapper,
      _fromMapArgumentsMapper,
      _equalityChecksMapper,
      _copyConstructorArgumentsMapper,
      _toMapPairsMapper
    ];

    final fields = _classElement.fields;
    for (var i = 0; i < fields.length; i++) {
      mappers.forEach(
          (m) => m.mapAndAppend(fields[i], i == 0, i == fields.length - 1));
    }
  }
}

class _FieldMapper {
  final String Function(String type, String name) mapper;
  final String separator;
  final String start;
  final String end;

  final StringBuffer buffer = StringBuffer();

  String get value => buffer.toString();

  _FieldMapper({
    this.mapper,
    this.separator = '',
    this.start = '',
    this.end = '',
  });

  void mapAndAppend(FieldElement element, bool isFirst, bool isLast) {
    if (isFirst) {
      buffer.write(start);
    }

    buffer.write(mapper(
      element.type.getDisplayString(withNullability: false),
      element.displayName,
    ));

    if (isLast) {
      buffer.write(end);
    } else {
      buffer.write(separator);
    }
  }
}
