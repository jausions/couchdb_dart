import 'package:meta/meta.dart';

import 'interfaces/client_interface.dart';
import 'interfaces/design_documents_interface.dart';
import 'responses/design_documents_response.dart';
import 'utils/urls.dart';

/// Class to operate on design documents of a database
class DesignDocuments implements DesignDocumentsInterface {
  // Database name
  final String dbName;

  /// URL-encoded database name
  final String _dbNameUrl;

  /// Instance of connected client
  final ClientInterface client;

  /// The [DesignDocuments] class takes a [ClientInterface] implementation instance
  /// and a database name [dbName].
  DesignDocuments(this.client, String dbName)
      : _dbNameUrl = Uri.encodeQueryComponent(
            client.validator.validateDatabaseName(dbName)),
        dbName = dbName;

  @override
  Future<DesignDocumentsResponse> designDocHeaders(String ddocId,
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
    final ddocIdUrl =
        urlEncodePath(client.validator.validateDesignDocId(ddocId));

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

    final path = '$_dbNameUrl$ddocIdUrl?'
        '${queryStringFromMap(queryParams)}';

    final result = await client.head(path, reqHeaders: headers);
    return DesignDocumentsResponse.from(result);
  }

  @override
  Future<DesignDocumentsResponse> designDoc(String ddocId,
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
    final ddocIdUrl =
        urlEncodePath(client.validator.validateDesignDocId(ddocId));

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

    final path = '$_dbNameUrl$ddocIdUrl?'
        '${queryStringFromMap(queryParams)}';

    final result = await client.get(path, reqHeaders: headers);
    return DesignDocumentsResponse.from(result);
  }

  @override
  Future<DesignDocumentsResponse> insertDesignDoc(
      String ddocId, Map<String, Object> body,
      {Map<String, String> headers,
      String rev,
      String batch,
      bool newEdits = true}) async {
    final ddocIdUrl =
        urlEncodePath(client.validator.validateDesignDocId(ddocId));

    final Map<String, Object> queryParams = {
      'new_edits': newEdits,
      if (rev != null) 'rev': rev,
      if (batch != null) 'batch': batch,
    };

    final path = '$_dbNameUrl$ddocIdUrl?'
        '${queryStringFromMap(queryParams)}';

    final result = await client.put(path, reqHeaders: headers, body: body);
    return DesignDocumentsResponse.from(result);
  }

  @override
  Future<DesignDocumentsResponse> deleteDesignDoc(String ddocId, String rev,
      {Map<String, String> headers, String batch}) async {
    final ddocIdUrl =
        urlEncodePath(client.validator.validateDesignDocId(ddocId));

    final Map<String, Object> queryParams = {
      'rev': rev,
      if (batch != null) 'batch': batch,
    };

    final path = '$_dbNameUrl$ddocIdUrl?'
        '${queryStringFromMap(queryParams)}';

    final result = await client.delete(path, reqHeaders: headers);
    return DesignDocumentsResponse.from(result);
  }

  @override
  Future<DesignDocumentsResponse> copyDesignDoc(String ddocId,
      {Map<String, String> headers, String rev, String batch}) async {
    final ddocIdUrl =
        urlEncodePath(client.validator.validateDesignDocId(ddocId));

    final Map<String, Object> queryParams = {
      if (rev != null) 'rev': rev,
      if (batch != null) 'batch': batch,
    };

    final path = '$_dbNameUrl$ddocIdUrl?'
        '${queryStringFromMap(queryParams)}';

    final result = await client.copy(path, reqHeaders: headers);
    return DesignDocumentsResponse.from(result);
  }

  @override
  Future<DesignDocumentsResponse> designDocAttachmentInfo(
      String ddocId, String attName,
      {Map<String, String> headers, String rev}) async {
    final ddocIdUrl =
        urlEncodePath(client.validator.validateDesignDocId(ddocId));

    final Map<String, Object> queryParams = {
      if (rev != null) 'rev': rev,
    };

    final path = '$_dbNameUrl$ddocIdUrl/$attName?'
        '${queryStringFromMap(queryParams)}';

    final result = await client.head(path, reqHeaders: headers);
    return DesignDocumentsResponse.from(result);
  }

  @override
  Future<DesignDocumentsResponse> designDocAttachment(
      String ddocId, String attName,
      {Map<String, String> headers, String rev}) async {
    final ddocIdUrl =
        urlEncodePath(client.validator.validateDesignDocId(ddocId));

    final Map<String, Object> queryParams = {
      if (rev != null) 'rev': rev,
    };

    final path = '$_dbNameUrl$ddocIdUrl/$attName?'
        '${queryStringFromMap(queryParams)}';

    final result = await client.get(path, reqHeaders: headers);
    return DesignDocumentsResponse.from(result);
  }

  @override
  Future<DesignDocumentsResponse> uploadDesignDocAttachment(
      String ddocId, String attName, Object body,
      {Map<String, String> headers, String rev}) async {
    final ddocIdUrl =
        urlEncodePath(client.validator.validateDesignDocId(ddocId));

    final Map<String, Object> queryParams = {
      if (rev != null) 'rev': rev,
    };

    final path = '$_dbNameUrl$ddocIdUrl/$attName?'
        '${queryStringFromMap(queryParams)}';

    final result = await client.put(path, reqHeaders: headers, body: body);
    return DesignDocumentsResponse.from(result);
  }

  @override
  Future<DesignDocumentsResponse> deleteDesignDocAttachment(
      String ddocId, String attName,
      {@required String rev, Map<String, String> headers, String batch}) async {
    final ddocIdUrl =
        urlEncodePath(client.validator.validateDesignDocId(ddocId));

    final Map<String, Object> queryParams = {
      'rev': rev,
      if (batch != null) 'batch': batch,
    };

    final path = '$_dbNameUrl$ddocIdUrl/$attName?'
        '${queryStringFromMap(queryParams)}';

    final result = await client.delete(path, reqHeaders: headers);
    return DesignDocumentsResponse.from(result);
  }

  @override
  Future<DesignDocumentsResponse> designDocInfo(String ddocId,
      {Map<String, String> headers}) async {
    final ddocIdUrl =
        urlEncodePath(client.validator.validateDesignDocId(ddocId));

    final path = '$_dbNameUrl$ddocIdUrl/_info';

    final result = await client.get(path, reqHeaders: headers);
    return DesignDocumentsResponse.from(result);
  }

  @override
  Future<DesignDocumentsResponse> executeViewFunction(
      String ddocId, String viewName,
      {bool conflicts = false,
      bool descending = false,
      Object endKey,
      String endKeyDocId,
      bool group = false,
      int groupLevel,
      bool includeDocs = false,
      bool attachments = false,
      bool attEncodingInfo = false,
      bool inclusiveEnd = true,
      Object key,
      List<Object> keys,
      int limit,
      bool reduce = false, // for solving conflict with [conflicts]
      int skip = 0,
      bool sorted = true,
      bool stable = false,
      String stale,
      Object startKey,
      String startKeyDocId,
      String update = 'true',
      bool updateSeq = false,
      Map<String, String> headers}) async {
    final ddocIdUrl =
        urlEncodePath(client.validator.validateDesignDocId(ddocId));

    final Map<String, Object> queryParams = {
      if (!reduce) 'conflicts': conflicts,
      'descending': descending,
      if (endKey != null) 'endkey': endKey,
      if (endKeyDocId != null) 'endkey_docid': endKeyDocId,
      'group': group,
      if (groupLevel != null) 'group_level': groupLevel,
      'include_docs': includeDocs,
      'attachments': attachments,
      'att_encoding_info': attEncodingInfo,
      'inclusive_end': inclusiveEnd,
      if (key != null) 'key': key,
      if (keys != null) 'keys': keys,
      if (limit != null) 'limit': limit,
      if (reduce != null) 'reduce': reduce,
      'skip': skip,
      'sorted': sorted,
      'stable': stable,
      if (stale != null) 'stale': stale,
      if (startKey != null) 'startkey': startKey,
      if (startKeyDocId != null) 'startkey_docid': startKeyDocId,
      'update': update,
      'update_seq': updateSeq,
    };

    final path = '$_dbNameUrl$ddocIdUrl/_view/$viewName?'
        '${queryStringFromMap(queryParams)}';

    final result = await client.get(path, reqHeaders: headers);
    return DesignDocumentsResponse.from(result);
  }

  @override
  Future<DesignDocumentsResponse> executeViewFunctionWithKeys(
      String ddocId, String viewName,
      {@required List<Object> keys,
      bool conflicts = false,
      bool descending = false,
      Object endKey,
      String endKeyDocId,
      bool group = false,
      int groupLevel,
      bool includeDocs = false,
      bool attachments = false,
      bool attEncodingInfo = false,
      bool inclusiveEnd = true,
      Object key,
      int limit,
      bool reduce = false, // Reason is the same as above
      int skip = 0,
      bool sorted = true,
      bool stable = false,
      String stale,
      Object startKey,
      String startKeyDocId,
      String update = 'true',
      bool updateSeq = false,
      Map<String, String> headers}) async {
    final ddocIdUrl =
        urlEncodePath(client.validator.validateDesignDocId(ddocId));

    final Map<String, Object> queryParams = {
      if (!reduce) 'conflicts': conflicts,
      'descending': descending,
      if (endKey != null) 'endkey': endKey,
      if (endKeyDocId != null) 'endkey_docid': endKeyDocId,
      'group': group,
      if (groupLevel != null) 'group_level': groupLevel,
      'include_docs': includeDocs,
      'attachments': attachments,
      'att_encoding_info': attEncodingInfo,
      'inclusive_end': inclusiveEnd,
      if (key != null) 'key': key,
      if (limit != null) 'limit': limit,
      if (reduce != null) 'reduce': reduce,
      'skip': skip,
      'sorted': sorted,
      'stable': stable,
      if (stale != null) 'stale': stale,
      if (startKey != null) 'startkey': startKey,
      if (startKeyDocId != null) 'startkey_docid': startKeyDocId,
      'update': update,
      'update_seq': updateSeq,
    };

    final path = '$_dbNameUrl$ddocIdUrl/_view/$viewName?'
        '${queryStringFromMap(queryParams)}';

    final body = <String, List<Object>>{'keys': keys};

    final result = await client.post(path, reqHeaders: headers, body: body);
    return DesignDocumentsResponse.from(result);
  }

  @override
  Future<DesignDocumentsResponse> executeViewQueries(
      String ddocId, String viewName, List<Object> queries) async {
    final ddocIdUrl =
        urlEncodePath(client.validator.validateDesignDocId(ddocId));

    final path = '$_dbNameUrl$ddocIdUrl/_view/$viewName/queries';

    final body = <String, List<Object>>{'queries': queries};

    final result = await client.post(path, body: body);
    return DesignDocumentsResponse.from(result);
  }

  @override
  Future<DesignDocumentsResponse> executeShowFunctionForNull(
      String ddocId, String funcName,
      {String format}) async {
    final ddocIdUrl =
        urlEncodePath(client.validator.validateDesignDocId(ddocId));

    final Map<String, Object> queryParams = {
      if (format != null) 'format': format,
    };

    final path = '$_dbNameUrl$ddocIdUrl/_show/$funcName?'
        '${queryStringFromMap(queryParams)}';

    final result = await client.get(path);
    return DesignDocumentsResponse.from(result);
  }

  @override
  Future<DesignDocumentsResponse> executeShowFunctionForDocument(
      String ddocId, String funcName, String docId,
      {String format}) async {
    final ddocIdUrl =
        urlEncodePath(client.validator.validateDesignDocId(ddocId));

    final Map<String, Object> queryParams = {
      if (format != null) 'format': format,
    };

    final path = '$_dbNameUrl$ddocIdUrl/_show/$funcName/$docId?'
        '${queryStringFromMap(queryParams)}';

    final result = await client.get(path);
    return DesignDocumentsResponse.from(result);
  }

  @override
  Future<DesignDocumentsResponse> executeListFunctionForView(
      String ddocId, String funcName, String view,
      {String format}) async {
    final ddocIdUrl =
        urlEncodePath(client.validator.validateDesignDocId(ddocId));

    final Map<String, Object> queryParams = {
      if (format != null) 'format': format,
    };

    final path = '$_dbNameUrl$ddocIdUrl/_list/$funcName/$view?'
        '${queryStringFromMap(queryParams)}';

    final result = await client.get(path);
    return DesignDocumentsResponse.from(result);
  }

  @override
  Future<DesignDocumentsResponse> executeListFunctionForViewFromDoc(
      String ddocId, String funcName, String otherDoc, String view,
      {String format}) async {
    final ddocIdUrl =
        urlEncodePath(client.validator.validateDesignDocId(ddocId));

    final Map<String, Object> queryParams = {
      if (format != null) 'format': format,
    };

    final path = '$_dbNameUrl$ddocIdUrl/_list/$funcName/$otherDoc/$view?'
        '${queryStringFromMap(queryParams)}';

    final result = await client.get(path);
    return DesignDocumentsResponse.from(result);
  }

  @override
  Future<DesignDocumentsResponse> executeUpdateFunctionForNull(
      String ddocId, String funcName, Object body) async {
    final ddocIdUrl =
        urlEncodePath(client.validator.validateDesignDocId(ddocId));

    final path = '$_dbNameUrl$ddocIdUrl/_update/$funcName';

    final result = await client.post(path, body: body);
    return DesignDocumentsResponse.from(result);
  }

  @override
  Future<DesignDocumentsResponse> executeUpdateFunctionForDocument(
      String ddocId, String funcName, String docId, Object body) async {
    final ddocIdUrl =
        urlEncodePath(client.validator.validateDesignDocId(ddocId));

    final path = '$_dbNameUrl$ddocIdUrl/_update/$funcName/$docId';

    final result = await client.put(path, body: body);
    return DesignDocumentsResponse.from(result);
  }

  @override
  Future<DesignDocumentsResponse> rewritePath(
    String ddocId,
    String path,
  ) async {
    final ddocIdUrl =
        urlEncodePath(client.validator.validateDesignDocId(ddocId));

    final result = await client.put('$_dbNameUrl$ddocIdUrl/_rewrite/$path');
    return DesignDocumentsResponse.from(result);
  }
}
