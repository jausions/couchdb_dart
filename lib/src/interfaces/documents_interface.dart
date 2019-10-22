import 'package:http_parser/http_parser.dart';
import 'package:meta/meta.dart';

import '../responses/documents_response.dart';
import '../responses/response.dart';

/// Class that define methods for create, read, update and delete documents
/// within a database.
abstract class DocumentsInterface {
  /// Returns whether the specified document exists.
  Future<bool> docExists(String docId,
      {Map<String, String> headers,
      bool attachments = false,
      bool attEncodingInfo = false,
      List<String> attsSince,
      bool conflicts = false,
      bool deletedConflicts = false,
      bool latest = false,
      bool localSeq = false,
      bool meta = false,
      Object openRevs,
      String rev,
      bool revs = false,
      bool revsInfo = false});

  /// Returns the HTTP Headers containing a minimal amount of information
  /// about the specified document
  Future<CaseInsensitiveMap<String>> docHeadersInfo(String docId,
      {Map<String, String> headers,
      bool attachments = false,
      bool attEncodingInfo = false,
      List<String> attsSince,
      bool conflicts = false,
      bool deletedConflicts = false,
      bool latest = false,
      bool localSeq = false,
      bool meta = false,
      Object openRevs,
      String rev,
      bool revs = false,
      bool revsInfo = false});

  /// Returns document by the specified [docId] from the database
  ///
  /// Returns JSON like:
  /// ```json
  /// {
  ///     "_id": "SpaghettiWithMeatballs",
  ///     "_rev": "1-917fa2381192822767f010b95b45325b",
  ///     "description": "An Italian-American dish that usually consists of spaghetti, tomato sauce and meatballs.",
  ///     "ingredients": [
  ///         "spaghetti",
  ///         "tomato sauce",
  ///         "meatballs"
  ///     ],
  ///     "name": "Spaghetti with meatballs"
  /// }
  /// ```
  Future<DocumentsResponse> doc(String docId,
      {Map<String, String> headers,
      bool attachments = false,
      bool attEncodingInfo = false,
      List<String> attsSince,
      bool conflicts = false,
      bool deletedConflicts = false,
      bool latest = false,
      bool localSeq = false,
      bool meta = false,
      Object openRevs,
      String rev,
      bool revs = false,
      bool revsInfo = false});

  /// Creates a new named document, or creates a new revision of the existing document
  ///
  /// Returns JSON like:
  /// ```json
  /// {
  ///     "id": "SpaghettiWithMeatballs",
  ///     "ok": true,
  ///     "rev": "1-917fa2381192822767f010b95b45325b"
  /// }
  /// ```
  Future<DocumentsResponse> insertDoc(String docId, Map<String, Object> body,
      {Map<String, String> headers,
      String rev,
      String batch,
      bool newEdits = true});

  /// Marks the specified document as deleted by adding a field `_deleted` with the value `true`
  ///
  /// Returns JSON like:
  /// ```json
  /// {
  ///     "id": "SpaghettiWithMeatballs",
  ///     "ok": true,
  ///     "rev": "1-917fa2381192822767f010b95b45325b"
  /// }
  /// ```
  Future<DocumentsResponse> deleteDoc(String docId, String rev,
      {Map<String, String> headers, String batch});

  /// Copies an existing document to a new or existing document.
  ///
  /// If you are copying to an existing document, you must specify
  /// `destinationRev` as the current rev of the destination doc
  ///
  /// Returns JSON like:
  /// ```json
  /// {
  ///     "id": "SpaghettiWithMeatballs",
  ///     "ok": true,
  ///     "rev": "1-917fa2381192822767f010b95b45325b"
  /// }
  /// ```
  Future<DocumentsResponse> copyDoc(String docId, String destinationId,
      {Map<String, String> headers,
      String rev,
      String destinationRev,
      String batch});

  /// Returns whether the attachment exists
  Future<bool> attachmentExists(String docId, String attName,
      {Map<String, String> headers, String rev});

  /// Returns the HTTP headers containing a minimal amount of information about
  /// the specified attachment
  Future<CaseInsensitiveMap<String>> attachmentHeadersInfo(String docId, String attName,
      {Map<String, String> headers, String rev});

  /// Returns the file attachment associated with the document
  ///
  /// Result is available in [DocumentsResponse.attachment] or [Response.raw] field as bytes of data.
  Future<DocumentsResponse> attachment(String docId, String attName,
      {Map<String, String> headers, String rev});

  /// Uploads the supplied content as an attachment to the specified document
  ///
  /// You must supply the `Content-Type` header, and for an existing document
  /// you must also supply either the [rev] query argument or the `If-Match` HTTP header.
  ///
  /// Returns JSON like:
  /// ```json
  /// {
  ///     "id": "SpaghettiWithMeatballs",
  ///     "ok": true,
  ///     "rev": "1-917fa2381192822767f010b95b45325b"
  /// }
  /// ```
  Future<DocumentsResponse> uploadAttachment(
      String docId, String attName, Object body,
      {Map<String, String> headers, String rev});

  /// Deletes the attachment with filename [attName] of the specified [docId]
  ///
  /// Returns JSON like:
  /// ```json
  /// {
  ///     "id": "SpaghettiWithMeatballs",
  ///     "ok": true,
  ///     "rev": "1-917fa2381192822767f010b95b45325b"
  /// }
  /// ```
  Future<DocumentsResponse> deleteAttachment(String docId, String attName,
      {@required String rev, Map<String, String> headers, String batch});
}
