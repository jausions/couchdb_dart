import 'package:couchdb/couchdb.dart';

/// This [PassthruValidator] class does not check nor validate anything.
/// It allows testing how the code behaves when unchecked data are sent
/// to CouchDB.
class PassthruValidator implements ValidatorInterface {
  bool isDesignDocumentId(String ddocId) => true;

  bool isLocalDocumentId(String docId) => true;

  bool isValidAttachmentName(String attName) => true;

  bool isValidDatabaseName(String dbName) => true;

  bool isValidDesignDocumentId(String ddocId) => true;

  bool isValidDocumentId(String docId) => true;

  bool isValidLocalDocumentId(String docId) => true;

  String validateAttachmentName(String attName) => attName;

  String validateDatabaseName(String dbName) => dbName;

  String validateDesignDocId(String ddocId) => ddocId;

  String validateDocId(String docId) => docId;

  String validateLocalDocId(String docId) => docId;
}
