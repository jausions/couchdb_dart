/// Exception that triggers when a document conflict is detected
class ConflictException implements Exception {
  ConflictException(this.dbName, this.docId)
      : message = "Conflict detected for document _id: `$docId` in database `$dbName`.";

  /// Database name in which the conflict occurred
  final String dbName;

  /// Document id for which the conflict occurred
  final String docId;

  /// Message of the exception
  final String message;

  @override
  String toString() {
    return message;
  }
}
