import 'package:couchdb/couchdb.dart';
import 'package:meta/meta.dart';

import 'base.dart';
import 'utils/urls.dart';

/// The Local (non-replicating) document interface allows to create local documents
/// that are not replicated to other databases
class LocalDocuments extends Base implements LocalDocumentsInterface {
  // Database name
  final String dbName;

  /// URL-encoded database name
  final String _dbNameUrl;

  /// Create LocalDocuments by accepting web-based or server-based client
  LocalDocuments(CouchDbClient client, String dbName)
      : _dbNameUrl = client.encoder
            .encodeDatabaseName(client.validator.validateDatabaseName(dbName)),
        dbName = dbName,
        super(client);

  @override
  Future<LocalDocumentsResponse> localDocs(
      {bool conflicts = false,
      bool descending = false,
      String endKey,
      String endKeyDocId,
      bool includeDocs = false,
      bool inclusiveEnd = true,
      String key,
      List<String> keys,
      int limit,
      int skip = 0,
      String startKey,
      String startKeyDocId,
      bool updateSeq = false,
      Map<String, String> headers}) async {
    //
    final Map<String, Object> queryParams = {
      'conflicts': conflicts,
      'descending': descending,
      if (endKey != null) 'endkey': endKey,
      if (endKeyDocId != null) 'endkey_docid': endKeyDocId,
      'include_docs': includeDocs,
      'inclusive_end': inclusiveEnd,
      if (key != null) 'key': key,
      if (keys != null) 'keys': keys,
      if (limit != null) 'limit': limit,
      'skip': skip,
      if (startKey != null) 'startkey': startKey,
      if (startKeyDocId != null) 'startkey_docid': startKeyDocId,
      'update_seq': updateSeq,
    };

    final path = '$_dbNameUrl/_local_docs?'
        '${queryStringFromMap(queryParams)}';

    final result = await client.get(path, reqHeaders: headers);
    return LocalDocumentsResponse.from(result);
  }

  @override
  Future<LocalDocumentsResponse> localDocsWithKeys(
      {@required List<String> keys,
      bool conflicts = false,
      bool descending = false,
      String endKey,
      String endKeyDocId,
      bool includeDocs = false,
      bool inclusiveEnd = true,
      String key,
      int limit,
      int skip = 0,
      String startKey,
      String startKeyDocId,
      bool updateSeq = false}) async {
    //
    final Map<String, Object> queryParams = {
      'onflicts': conflicts,
      'descending': descending,
      if (endKey != null) 'endkey': endKey,
      if (endKeyDocId != null) 'endkey_docid': endKeyDocId,
      'include_docs': includeDocs,
      'inclusive_end': inclusiveEnd,
      if (key != null) 'key': key,
      if (limit != null) 'limit': limit,
      'skip': skip,
      if (startKey != null) 'startkey': startKey,
      if (startKeyDocId != null) 'startkey_docid': startKeyDocId,
      'update_seq': updateSeq,
    };

    final path = '$_dbNameUrl/_local_docs?'
        '${queryStringFromMap(queryParams)}';

    final body = <String, List<String>>{'keys': keys};

    final result = await client.post(path, body: body);
    return LocalDocumentsResponse.from(result);
  }

  @override
  Future<LocalDocumentsResponse> localDoc(String docId,
      {Map<String, String> headers,
      bool conflicts = false,
      bool deletedConflicts = false,
      bool latest = false,
      bool localSeq = false,
      bool meta = false,
      Object openRevs,
      String rev,
      bool revs = false,
      bool revsInfo = false}) async {
    final docIdUrl = client.encoder
        .encodeLocalDocId(client.validator.validateLocalDocId(docId));

    final Map<String, Object> queryParams = {
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
    return LocalDocumentsResponse.from(result);
  }

  @override
  Future<LocalDocumentsResponse> copyLocalDoc(String docId,
      {Map<String, String> headers, String rev, String batch}) async {
    final docIdUrl = client.encoder
        .encodeLocalDocId(client.validator.validateLocalDocId(docId));

    final Map<String, Object> queryParams = {
      if (rev != null) 'rev': rev,
      if (batch != null) 'batch': batch,
    };

    final path = '$_dbNameUrl/$docIdUrl?'
        '${queryStringFromMap(queryParams)}';

    final result = await client.copy(path, reqHeaders: headers);
    return LocalDocumentsResponse.from(result);
  }

  @override
  Future<LocalDocumentsResponse> deleteLocalDoc(String docId, String rev,
      {Map<String, String> headers, String batch}) async {
    final docIdUrl = client.encoder
        .encodeLocalDocId(client.validator.validateLocalDocId(docId));

    final Map<String, Object> queryParams = {
      'rev': rev,
      if (batch != null) 'batch': batch,
    };

    final path = '$_dbNameUrl/$docIdUrl?'
        '${queryStringFromMap(queryParams)}';

    final result = await client.delete(path, reqHeaders: headers);
    return LocalDocumentsResponse.from(result);
  }

  @override
  Future<LocalDocumentsResponse> insertLocalDoc(
      String docId, Map<String, Object> body,
      {Map<String, String> headers,
      String rev,
      String batch,
      bool newEdits = true}) async {
    final docIdUrl = client.encoder
        .encodeLocalDocId(client.validator.validateLocalDocId(docId));

    final Map<String, Object> queryParams = {
      'new_edits': newEdits,
      if (rev != null) 'rev': rev,
      if (batch != null) 'batch': batch,
    };

    final path = '$_dbNameUrl/$docIdUrl?'
        '${queryStringFromMap(queryParams)}';

    final result = await client.put(path, reqHeaders: headers, body: body);
    return LocalDocumentsResponse.from(result);
  }
}
