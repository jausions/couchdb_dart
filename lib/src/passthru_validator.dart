import 'package:couchdb/couchdb.dart';

/// This [PassthruValidator] class does not check not validate anything.
/// It allows testing how the code behaves when unchecked data are sent
/// to CouchDB.
class PassthruValidator implements ValidatorInterface {
  @override
  bool isDesignDocumentId(String ddocId) => true;

  @override
  bool isLocalDocumentId(String docId) => true;

  @override
  bool isValidDatabaseName(String dbName) => true;

  @override
  bool isValidDesignDocumentId(String ddocId) => true;

  @override
  bool isValidDocumentId(String docId) => true;

  @override
  bool isValidLocalDocumentId(String docId) => true;

  @override
  String validateDatabaseName(String dbName) => dbName;

  @override
  String validateDesignDocId(String ddocId) => ddocId;

  @override
  String validateDocId(String docId) => docId;

  @override
  String validateLocalDocId(String docId) => docId;
}
