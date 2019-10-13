abstract class ValidatorInterface {
  /// Checks if [dbName] is a suitable database name.
  bool isValidDatabaseName(String dbName);

  /// Tells whether [ddocId] could be for a design document id.
  bool isDesignDocumentId(String ddocId);

  /// Tells whether [docId] could be for a local document id.
  bool isLocalDocumentId(String docId);

  /// Checks if [ddocId] is a suitable id for design documents.
  bool isValidDesignDocumentId(String ddocId);

  /// Checks if [docId] is a suitable id for a "regular" document
  /// (i.e. not a design nor a local document.)
  bool isValidDocumentId(String docId);

  /// Checks if [docId] is a suitable id for local documents.
  bool isValidLocalDocumentId(String docId);

  /// Validates [dbName] against naming rules for database names.
  /// If the check fails an [ArgumentError] exception is thrown.
  void validateDatabaseName(String dbName);

  /// Validates [ddocId] against naming rules for design document ids.
  /// If the check fails an [ArgumentError] exception is thrown.
  void validateDesignDocId(String ddocId);

  /// Validates [docId] against naming rules for "regular" document ids.
  /// If the check fails an [ArgumentError] exception is thrown.
  void validateDocId(String docId);

  /// Validates [docId] against naming rules for local document ids.
  /// If the check fails an [ArgumentError] exception is thrown.
  void validateLocalDocId(String docId);
}
