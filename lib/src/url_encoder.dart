import 'package:couchdb/couchdb.dart';

/// Encodes database names and document ids to be suitable for inclusion in URLs
/// of the CouchDB API calls.
class UrlEncoder implements EncoderInterface {
  String encodeDatabaseName(String dbName) {
    return Uri.encodeQueryComponent(dbName);
  }

  String encodeDesignDocId(String ddocId) {
    if (ddocId.startsWith('_design/')) {
      return '_design/'
          "${Uri.encodeQueryComponent(ddocId.substring(8))}";
    }
    return Uri.encodeQueryComponent(ddocId);
  }

  String encodeDocId(String docId) {
    return Uri.encodeQueryComponent(docId);
  }

  String encodeLocalDocId(String docId) {
    if (docId.startsWith('_local/')) {
      return '_local/'
          "${Uri.encodeQueryComponent(docId.substring(7))}";
    }
    return Uri.encodeQueryComponent(docId);
  }

  String encodeAttachmentName(String attName) {
    return Uri.encodeQueryComponent(attName);
  }
}
