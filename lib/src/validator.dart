import 'package:couchdb/couchdb.dart';

class Validator implements ValidatorInterface {
  final _dbNameRegexp = RegExp(r'^[a-z][a-z0-9_$()+/-]*$');

  bool isValidAttachmentName(String attName) {
    return attName.isNotEmpty;
  }

  bool isValidDatabaseName(String dbName) {
    return _dbNameRegexp.hasMatch(dbName);
  }

  bool isDesignDocumentId(String ddocId) {
    return ddocId.length > 8 && ddocId.substring(0, 8) == "_design/";
  }

  bool isLocalDocumentId(String docId) {
    return docId.length > 7 && docId.substring(0, 7) == "_local/";
  }

  bool isValidDesignDocumentId(String ddocId) {
    return isDesignDocumentId(ddocId);
  }

  bool isValidDocumentId(String docId) {
    return docId.isNotEmpty && docId.substring(0, 1) != "_";
  }

  bool isValidLocalDocumentId(String docId) {
    return isLocalDocumentId(docId);
  }

  String validateAttachmentName(String attName) {
    if (!isValidAttachmentName(attName)) {
      throw ArgumentError.value(attName, null, "Invalid attachment name.");
    }
    return attName;
  }

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

  String validateDesignDocId(String ddocId) {
    if (!isValidDesignDocumentId(ddocId)) {
      throw ArgumentError.value(ddocId, null,
          'Malformed design document id: The id must start with "_design/".');
    }
    return ddocId;
  }

  String validateDocId(String docId) {
    if (!isValidDocumentId(docId)) {
      throw ArgumentError.value(docId, null,
          'Invalid document id: The id cannot start with an underscore "_".');
    }
    return docId;
  }

  String validateLocalDocId(String docId) {
    if (!isValidLocalDocumentId(docId)) {
      throw ArgumentError.value(docId, null,
          'Malformed local document id: The id must start with "_local/".');
    }
    return docId;
  }
}
