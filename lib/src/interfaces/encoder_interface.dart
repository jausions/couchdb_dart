/// The [EncoderInterface] defines the methods that should be used to encode
/// database names and document ids when communicating with the CouchDB API.
abstract class EncoderInterface {
  /// Encodes [dbName] to be suitable as database name in the API calls.
  String encodeDatabaseName(String dbName);

  /// Encodes [ddocId] to be suitable as design document id in the API calls.
  String encodeDesignDocId(String ddocId);

  /// Encodes [docId] to be suitable as "regular" document id in the API calls.
  String encodeDocId(String docId);

  /// Encodes [docId] to be suitable as local document id in the API calls.
  String encodeLocalDocId(String docId);

  /// Encodes [attName] to be suitable as attachment name in API calls.
  String encodeAttachmentName(String attName);
}
