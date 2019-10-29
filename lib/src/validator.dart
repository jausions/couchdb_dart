import 'package:couchdb/couchdb.dart';

class Validator implements ValidatorInterface {
  final _dbNameRegexp = RegExp(r'^[a-z][a-z0-9_$()+/-]*$');

  /// Checks if [dbName] is a suitable database name.
  bool isValidDatabaseName(String dbName) {
    return _dbNameRegexp.hasMatch(dbName);
  }

  /// Tells whether [ddocId] could be for a design document id.
  bool isDesignDocumentId(String ddocId) {
    return ddocId.length > 8 && ddocId.substring(0, 8) == "_design/";
  }

  /// Tells whether [docId] could be for a local document id.
  bool isLocalDocumentId(String docId) {
    return docId.length > 7 && docId.substring(0, 7) == "_local/";
  }

  /// Checks if [ddocId] is a suitable id for design documents.
  bool isValidDesignDocumentId(String ddocId) {
    return isDesignDocumentId(ddocId);
  }

  /// Checks if [docId] is a suitable id for a "regular" document
  /// (i.e. not a design nor a local document.)
  bool isValidDocumentId(String docId) {
    return docId.isNotEmpty && docId.substring(0, 1) != "_";
  }

  /// Checks if [docId] is a suitable id for local documents.
  bool isValidLocalDocumentId(String docId) {
    return isLocalDocumentId(docId);
  }

  /// Validates [dbName] against naming rules for database names.
  /// If the check fails an [ArgumentError] exception is thrown.
  String validateDatabaseName(String dbName) {
    if (!isValidDatabaseName(dbName)) {
      throw ArgumentError.value(dbName, null, r'''Incorrect database name!
      Name must be composed by following next rules:
        - Name must begin with a lowercase letter (a-z)
        - Lowercase characters (a-z)
        - Digits (0-9)
        - Any of the characters _, $, (, ), +, -, and /.''');
    }
    return dbName;
  }

  /// Validates [ddocId] against naming rules for design document ids.
  /// If the check fails an [ArgumentError] exception is thrown.
  String validateDesignDocId(String ddocId) {
    if (!isValidDesignDocumentId(ddocId)) {
      throw ArgumentError.value(ddocId, null,
          'Malformed design document id: The id must start with "_design/".');
    }
    return ddocId;
  }

  /// Validates [docId] against naming rules for "regular" document ids.
  /// If the check fails an [ArgumentError] exception is thrown.
  String validateDocId(String docId) {
    if (!isValidDocumentId(docId)) {
      throw ArgumentError.value(docId, null,
          'Invalid document id: The id cannot start with an underscore "_".');
    }
    return docId;
  }

  /// Validates [docId] against naming rules for local document ids.
  /// If the check fails an [ArgumentError] exception is thrown.
  String validateLocalDocId(String docId) {
    if (!isValidLocalDocumentId(docId)) {
      throw ArgumentError.value(docId, null,
          'Malformed local document id: The id must start with "_local/".');
    }
    return docId;
  }
}
