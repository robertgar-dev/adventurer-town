// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'simulation_save_record.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSimulationSaveRecordCollection on Isar {
  IsarCollection<SimulationSaveRecord> get simulationSaveRecords =>
      this.collection();
}

const SimulationSaveRecordSchema = CollectionSchema(
  name: r'SimulationSaveRecord',
  id: -6597784363494123098,
  properties: {
    r'savedAtUtc': PropertySchema(
      id: 0,
      name: r'savedAtUtc',
      type: IsarType.dateTime,
    ),
    r'stateJson': PropertySchema(
      id: 1,
      name: r'stateJson',
      type: IsarType.string,
    )
  },
  estimateSize: _simulationSaveRecordEstimateSize,
  serialize: _simulationSaveRecordSerialize,
  deserialize: _simulationSaveRecordDeserialize,
  deserializeProp: _simulationSaveRecordDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _simulationSaveRecordGetId,
  getLinks: _simulationSaveRecordGetLinks,
  attach: _simulationSaveRecordAttach,
  version: '3.3.2',
);

int _simulationSaveRecordEstimateSize(
  SimulationSaveRecord object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.stateJson.length * 3;
  return bytesCount;
}

void _simulationSaveRecordSerialize(
  SimulationSaveRecord object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.savedAtUtc);
  writer.writeString(offsets[1], object.stateJson);
}

SimulationSaveRecord _simulationSaveRecordDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SimulationSaveRecord();
  object.id = id;
  object.savedAtUtc = reader.readDateTime(offsets[0]);
  object.stateJson = reader.readString(offsets[1]);
  return object;
}

P _simulationSaveRecordDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _simulationSaveRecordGetId(SimulationSaveRecord object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _simulationSaveRecordGetLinks(
    SimulationSaveRecord object) {
  return [];
}

void _simulationSaveRecordAttach(
    IsarCollection<dynamic> col, Id id, SimulationSaveRecord object) {
  object.id = id;
}

extension SimulationSaveRecordQueryWhereSort
    on QueryBuilder<SimulationSaveRecord, SimulationSaveRecord, QWhere> {
  QueryBuilder<SimulationSaveRecord, SimulationSaveRecord, QAfterWhere>
      anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension SimulationSaveRecordQueryWhere
    on QueryBuilder<SimulationSaveRecord, SimulationSaveRecord, QWhereClause> {
  QueryBuilder<SimulationSaveRecord, SimulationSaveRecord, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<SimulationSaveRecord, SimulationSaveRecord, QAfterWhereClause>
      idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<SimulationSaveRecord, SimulationSaveRecord, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<SimulationSaveRecord, SimulationSaveRecord, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<SimulationSaveRecord, SimulationSaveRecord, QAfterWhereClause>
      idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension SimulationSaveRecordQueryFilter on QueryBuilder<SimulationSaveRecord,
    SimulationSaveRecord, QFilterCondition> {
  QueryBuilder<SimulationSaveRecord, SimulationSaveRecord,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<SimulationSaveRecord, SimulationSaveRecord,
      QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<SimulationSaveRecord, SimulationSaveRecord,
      QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<SimulationSaveRecord, SimulationSaveRecord,
      QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SimulationSaveRecord, SimulationSaveRecord,
      QAfterFilterCondition> savedAtUtcEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'savedAtUtc',
        value: value,
      ));
    });
  }

  QueryBuilder<SimulationSaveRecord, SimulationSaveRecord,
      QAfterFilterCondition> savedAtUtcGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'savedAtUtc',
        value: value,
      ));
    });
  }

  QueryBuilder<SimulationSaveRecord, SimulationSaveRecord,
      QAfterFilterCondition> savedAtUtcLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'savedAtUtc',
        value: value,
      ));
    });
  }

  QueryBuilder<SimulationSaveRecord, SimulationSaveRecord,
      QAfterFilterCondition> savedAtUtcBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'savedAtUtc',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SimulationSaveRecord, SimulationSaveRecord,
      QAfterFilterCondition> stateJsonEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'stateJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SimulationSaveRecord, SimulationSaveRecord,
      QAfterFilterCondition> stateJsonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'stateJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SimulationSaveRecord, SimulationSaveRecord,
      QAfterFilterCondition> stateJsonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'stateJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SimulationSaveRecord, SimulationSaveRecord,
      QAfterFilterCondition> stateJsonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'stateJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SimulationSaveRecord, SimulationSaveRecord,
      QAfterFilterCondition> stateJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'stateJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SimulationSaveRecord, SimulationSaveRecord,
      QAfterFilterCondition> stateJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'stateJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SimulationSaveRecord, SimulationSaveRecord,
          QAfterFilterCondition>
      stateJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'stateJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SimulationSaveRecord, SimulationSaveRecord,
          QAfterFilterCondition>
      stateJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'stateJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SimulationSaveRecord, SimulationSaveRecord,
      QAfterFilterCondition> stateJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'stateJson',
        value: '',
      ));
    });
  }

  QueryBuilder<SimulationSaveRecord, SimulationSaveRecord,
      QAfterFilterCondition> stateJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'stateJson',
        value: '',
      ));
    });
  }
}

extension SimulationSaveRecordQueryObject on QueryBuilder<SimulationSaveRecord,
    SimulationSaveRecord, QFilterCondition> {}

extension SimulationSaveRecordQueryLinks on QueryBuilder<SimulationSaveRecord,
    SimulationSaveRecord, QFilterCondition> {}

extension SimulationSaveRecordQuerySortBy
    on QueryBuilder<SimulationSaveRecord, SimulationSaveRecord, QSortBy> {
  QueryBuilder<SimulationSaveRecord, SimulationSaveRecord, QAfterSortBy>
      sortBySavedAtUtc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'savedAtUtc', Sort.asc);
    });
  }

  QueryBuilder<SimulationSaveRecord, SimulationSaveRecord, QAfterSortBy>
      sortBySavedAtUtcDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'savedAtUtc', Sort.desc);
    });
  }

  QueryBuilder<SimulationSaveRecord, SimulationSaveRecord, QAfterSortBy>
      sortByStateJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stateJson', Sort.asc);
    });
  }

  QueryBuilder<SimulationSaveRecord, SimulationSaveRecord, QAfterSortBy>
      sortByStateJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stateJson', Sort.desc);
    });
  }
}

extension SimulationSaveRecordQuerySortThenBy
    on QueryBuilder<SimulationSaveRecord, SimulationSaveRecord, QSortThenBy> {
  QueryBuilder<SimulationSaveRecord, SimulationSaveRecord, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<SimulationSaveRecord, SimulationSaveRecord, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<SimulationSaveRecord, SimulationSaveRecord, QAfterSortBy>
      thenBySavedAtUtc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'savedAtUtc', Sort.asc);
    });
  }

  QueryBuilder<SimulationSaveRecord, SimulationSaveRecord, QAfterSortBy>
      thenBySavedAtUtcDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'savedAtUtc', Sort.desc);
    });
  }

  QueryBuilder<SimulationSaveRecord, SimulationSaveRecord, QAfterSortBy>
      thenByStateJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stateJson', Sort.asc);
    });
  }

  QueryBuilder<SimulationSaveRecord, SimulationSaveRecord, QAfterSortBy>
      thenByStateJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stateJson', Sort.desc);
    });
  }
}

extension SimulationSaveRecordQueryWhereDistinct
    on QueryBuilder<SimulationSaveRecord, SimulationSaveRecord, QDistinct> {
  QueryBuilder<SimulationSaveRecord, SimulationSaveRecord, QDistinct>
      distinctBySavedAtUtc() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'savedAtUtc');
    });
  }

  QueryBuilder<SimulationSaveRecord, SimulationSaveRecord, QDistinct>
      distinctByStateJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'stateJson', caseSensitive: caseSensitive);
    });
  }
}

extension SimulationSaveRecordQueryProperty on QueryBuilder<
    SimulationSaveRecord, SimulationSaveRecord, QQueryProperty> {
  QueryBuilder<SimulationSaveRecord, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<SimulationSaveRecord, DateTime, QQueryOperations>
      savedAtUtcProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'savedAtUtc');
    });
  }

  QueryBuilder<SimulationSaveRecord, String, QQueryOperations>
      stateJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'stateJson');
    });
  }
}
