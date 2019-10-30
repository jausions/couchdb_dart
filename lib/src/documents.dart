import 'package:couchdb/couchdb.dart';
import 'package:http_parser/http_parser.dart';
import 'package:meta/meta.dart';

import 'base.dart';
import 'http_mixin.dart';
import 'utils/urls.dart';

/// Class that implements methods to create, read, update and delete documents
/// within the database. This class only deals with _non-special_ documents. For
/// local documents use [LocalDocuments] and for design documents use
/// [DesignDocuments].
class Documents extends Base with HttpMixin implements DocumentsInterface {
  /// URL-encoded database name
  final String _dbNameUrl;

  // Database name
  final String dbName;

  /// The [Documents] class takes a [ClientInterface] implementation instance
  /// and a database name [dbName].
  Documents(CouchDbClient client, String dbName)
      : _dbNameUrl = client.encoder
            .encodeDatabaseName(client.validator.validateDatabaseName(dbName)),
        dbName = dbName,
        super(client);

  @override
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
      bool revsInfo = false}) async {
    final docIdUrl =
        client.encoder.encodeDocId(client.validator.validateDocId(docId));

    final Map<String, Object> queryParams = {
      'attachments': attachments,
      'att_encoding_info': attEncodingInfo,
      if (attsSince != null) 'atts_since': attsSince,
      'conflicts': conflicts,
      'deleted_conflicts': deletedConflicts,
      'latest': latest,
      'local_seq': localSeq,
      'meta': meta,
      if (openRevs != null) 'open_revs': openRevs,
      if (rev != null) 'rev': rev,
      'revs': revs,
      'revs_info': revsInfo,
    };

    final path = '$_dbNameUrl/$docIdUrl?'
        '${queryStringFromMap(queryParams)}';

    return httpHeadExists(path, headers);
  }

  @override
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
      bool revsInfo = false}) async {
    final docIdUrl =
        client.encoder.encodeDocId(client.validator.validateDocId(docId));

    final Map<String, Object> queryParams = {
      'attachments': attachments,
      'att_encoding_info': attEncodingInfo,
      if (attsSince != null) 'atts_since': attsSince,
      'conflicts': conflicts,
      'deleted_conflicts': deletedConflicts,
      'latest': latest,
      'local_seq': localSeq,
      'meta': meta,
      if (openRevs != null) 'open_revs': openRevs,
      if (rev != null) 'rev': rev,
      'revs': revs,
      'revs_info': revsInfo,
    };

    final path = '$_dbNameUrl/$docIdUrl?'
        '${queryStringFromMap(queryParams)}';

    final result = await client.head(path, reqHeaders: headers);
    return result.headers;
  }

  @override
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
      bool revsInfo = false}) async {
    final docIdUrl =
        client.encoder.encodeDocId(client.validator.validateDocId(docId));

    final Map<String, Object> queryParams = {
      'attachments': attachments,
      'att_encoding_info': attEncodingInfo,
      if (attsSince != null) 'atts_since': attsSince,
      'conflicts': conflicts,
      'deleted_conflicts': deletedConflicts,
      'latest': latest,
      'local_seq': localSeq,
      'meta': meta,
      if (openRevs != null) 'open_revs': openRevs,
      if (rev != null) 'rev': rev,
      'revs': revs,
      'revs_info': revsInfo,
    };

    final path = '$_dbNameUrl/$docIdUrl?'
        '${queryStringFromMap(queryParams)}';

    final result = await client.get(path, reqHeaders: headers);
    return DocumentsResponse.from(result);
  }

  @override
  Future<DocumentsResponse> insertDoc(String docId, Map<String, Object> body,
      {Map<String, String> headers,
      String rev,
      String batch,
      bool newEdits = true}) async {
    final docIdUrl =
        client.encoder.encodeDocId(client.validator.validateDocId(docId));

    final Map<String, Object> queryParams = {
      'new_edits': newEdits,
      if (rev != null) 'rev': rev,
      if (batch != null) 'batch': batch,
    };

    final path = '$_dbNameUrl/$docIdUrl?'
        '${queryStringFromMap(queryParams)}';

    final result = await client.put(path, reqHeaders: headers, body: body);
    return DocumentsResponse.from(result);
  }

  @override
  Future<DocumentsResponse> deleteDoc(String docId, String rev,
      {Map<String, String> headers, String batch}) async {
    final docIdUrl =
        client.encoder.encodeDocId(client.validator.validateDocId(docId));

    final Map<String, Object> queryParams = {
      'rev': rev,
      if (batch != null) 'batch': batch,
    };

    final path = '$_dbNameUrl/$docIdUrl?'
        '${queryStringFromMap(queryParams)}';

    final result = await client.delete(path, reqHeaders: headers);
    return DocumentsResponse.from(result);
  }

  @override
  Future<DocumentsResponse> copyDoc(String docId, String destinationId,
      {Map<String, String> headers,
      String rev,
      String destinationRev,
      String batch}) async {
    client.validator.validateDocId(destinationId);
    final docIdUrl =
        client.encoder.encodeDocId(client.validator.validateDocId(docId));

    final Map<String, Object> queryParams = {
      if (rev != null) 'rev': rev,
      if (batch != null) 'batch': batch,
    };

    final path = '$_dbNameUrl/$docIdUrl?'
        '${queryStringFromMap(queryParams)}';

    final destinationQS = queryStringFromMap({
      if (destinationRev != null) 'rev': destinationRev,
    });

    final destination =
        (destinationQS == '') ? destinationId : '$destinationId?$destinationQS';

    headers ??= <String, String>{};
    headers['Destination'] = destination;

    final result = await client.copy(path, reqHeaders: headers);
    return DocumentsResponse.from(result);
  }

  @override
  Future<bool> attachmentExists(String docId, String attName,
      {Map<String, String> headers, String rev}) async {
    final docIdUrl =
        client.encoder.encodeDocId(client.validator.validateDocId(docId));

    final Map<String, Object> queryParams = {
      if (rev != null) 'rev': rev,
    };

    final path = '$_dbNameUrl/$docIdUrl/$attName?'
        '${queryStringFromMap(queryParams)}';

    return httpHeadExists(path, headers);
  }

  @override
  Future<CaseInsensitiveMap<String>> attachmentHeadersInfo(
      String docId, String attName,
      {Map<String, String> headers, String rev}) async {
    final docIdUrl =
        client.encoder.encodeDocId(client.validator.validateDocId(docId));

    final Map<String, Object> queryParams = {
      if (rev != null) 'rev': rev,
    };

    final path = '$_dbNameUrl/$docIdUrl/$attName?'
        '${queryStringFromMap(queryParams)}';

    final result = await client.head(path, reqHeaders: headers);
    return result.headers;
  }

  @override
  Future<DocumentsResponse> attachment(String docId, String attName,
      {Map<String, String> headers, String rev}) async {
    final docIdUrl =
        client.encoder.encodeDocId(client.validator.validateDocId(docId));

    final Map<String, Object> queryParams = {
      if (rev != null) 'rev': rev,
    };

    final path = '$_dbNameUrl/$docIdUrl/$attName?'
        '${queryStringFromMap(queryParams)}';

    final result = await client.get(path, reqHeaders: headers);
    return DocumentsResponse.from(result);
  }

  @override
  Future<DocumentsResponse> uploadAttachment(
      String docId, String attName, Object body,
      {Map<String, String> headers, String rev}) async {
    final docIdUrl =
        client.encoder.encodeDocId(client.validator.validateDocId(docId));

    final Map<String, Object> queryParams = {
      if (rev != null) 'rev': rev,
    };

    final path = '$_dbNameUrl/$docIdUrl/$attName?'
        '${queryStringFromMap(queryParams)}';

    final result = await client.put(path, reqHeaders: headers, body: body);
    return DocumentsResponse.from(result);
  }

  @override
  Future<DocumentsResponse> deleteAttachment(String docId, String attName,
      {@required String rev, Map<String, String> headers, String batch}) async {
    final docIdUrl =
        client.encoder.encodeDocId(client.validator.validateDocId(docId));

    final Map<String, Object> queryParams = {
      'rev': rev,
      if (batch != null) 'batch': batch,
    };

    final path = '$_dbNameUrl/$docIdUrl/$attName?'
        '${queryStringFromMap(queryParams)}';

    final result = await client.delete(path, reqHeaders: headers);
    return DocumentsResponse.from(result);
  }
}
