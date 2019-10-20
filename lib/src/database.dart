import 'dart:convert';

import 'package:meta/meta.dart';

import 'exceptions/couchdb_exception.dart';
import 'interfaces/client_interface.dart';
import 'interfaces/database_interface.dart';
import 'responses/database_response.dart';
import 'responses/response.dart';
import 'utils/urls.dart';

/// Class that implements methods for interacting with entire database
/// in CouchDB
class Database implements DatabaseInterface {
  /// Database name (URL-encoded)
  final String _dbNameUrl;

  // Database name
  final String dbName;

  /// Instance of connected client
  final ClientInterface client;

  /// The [Database] class takes a [ClientInterface] implementation instance
  /// and a database name [dbName].
  Database(this.client, String dbName)
      : _dbNameUrl = Uri.encodeQueryComponent(
            client.validator.validateDatabaseName(dbName)),
        dbName = dbName;

  @override
  Future<DatabaseResponse> summaryInfo() async {
    Response result;
    try {
      result = await client.head(_dbNameUrl);
    } on CouchDbException catch (e) {
      e.response = Response(<String, String>{
        'error': 'Not found',
        'reason': 'Database doesn\'t exist.'
      }).errorResponse();
      rethrow;
    }
    return DatabaseResponse.from(result);
  }

  @override
  Future<DatabaseResponse> info() async {
    final result = await client.get(_dbNameUrl);
    return DatabaseResponse.from(result);
  }

  @override
  Future<DatabaseResponse> create({int q = 8}) async {
    final path = '$_dbNameUrl?q=$q';
    final result = await client.put(path);
    return DatabaseResponse.from(result);
  }

  @override
  Future<DatabaseResponse> delete() async {
    final result = await client.delete(_dbNameUrl);
    return DatabaseResponse.from(result);
  }

  @override
  Future<DatabaseResponse> createDoc(Map<String, Object> doc,
      {String batch, Map<String, String> headers}) async {
    final Map<String, Object> queryParams = {
      if (batch != null) 'batch': batch,
    };

    final path = '$_dbNameUrl'
        '${queryStringFromMap(queryParams)}';

    final result = await client.post(path, body: doc, reqHeaders: headers);
    return DatabaseResponse.from(result);
  }

  @override
  Future<DatabaseResponse> allDocs(
      {bool conflicts = false,
      bool descending = false,
      Object endKey,
      String endKeyDocId,
      bool group = false,
      int groupLevel,
      bool includeDocs = false,
      bool attachments = false,
      bool altEncodingInfo = false,
      bool inclusiveEnd = true,
      Object key,
      List<Object> keys,
      int limit,
      bool reduce,
      int skip,
      bool sorted = true,
      bool stable = false,
      String stale,
      Object startKey,
      String startKeyDocId,
      String update,
      bool updateSeq = false}) async {
    //
    final Map<String, Object> queryParams = {
      'conflicts': conflicts,
      'descending': descending,
      if (endKey != null) "endkey": jsonEncode(endKey),
      if (endKeyDocId != null) "endkey_docid": endKeyDocId,
      'group': group,
      if (groupLevel != null) "group_level": groupLevel,
      'include_docs': includeDocs,
      'attachments': attachments,
      'alt_encoding_info': altEncodingInfo,
      'inclusive_end': inclusiveEnd,
      if (key != null) "key": jsonEncode(key),
      if (keys != null) "keys": jsonEncode(keys),
      if (limit != null) "limit": limit,
      if (reduce != null) "reduce": reduce,
      if (skip != null) "skip": skip,
      'sorted': sorted,
      'stable': stable,
      if (stale != null) "stale": stale,
      if (startKey != null) "startkey": jsonEncode(startKey),
      if (startKeyDocId != null) "startkey_docid": startKeyDocId,
      if (update != null) "update": update,
      'update_seq': updateSeq,
    };

    final path = '$_dbNameUrl/_all_docs'
        '${queryStringFromMap(queryParams)}';

    final result = await client.get(path);
    return DatabaseResponse.from(result);
  }

  @override
  Future<DatabaseResponse> docsByKeys({List<String> keys}) async {
    final body = <String, List<String>>{'keys': keys};

    final result = (keys == null)
        ? await client.post('$_dbNameUrl/_all_docs')
        : await client.post('$_dbNameUrl/_all_docs', body: body);
    return DatabaseResponse.from(result);
  }

  @override
  Future<DatabaseResponse> allDesignDocs(
      {bool conflicts = false,
      bool descending = false,
      String endKey,
      String endKeyDocId,
      bool includeDocs = false,
      bool inclusiveEnd = true,
      String key,
      String keys,
      int limit,
      int skip = 0,
      String startKey,
      String startKeyDocId,
      bool updateSeq = false}) async {
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

    final path = '$_dbNameUrl/_design_docs?'
        '${queryStringFromMap(queryParams)}';

    final result = await client.get(path);
    return DatabaseResponse.from(result);
  }

  @override
  Future<DatabaseResponse> designDocsByKeys(List<String> keys) async {
    final path = '$_dbNameUrl/_design_docs';
    final body = <String, List<String>>{'keys': keys};
    final result = await client.post(path, body: body);
    return DatabaseResponse.from(result);
  }

  @override
  Future<DatabaseResponse> queriesDocsFrom(
      List<Map<String, Object>> queries) async {
    final path = '$_dbNameUrl/_all_docs/queries';
    final body = <String, List<Map<String, Object>>>{'queries': queries};
    final result = await client.post(path, body: body);
    return DatabaseResponse.from(result);
  }

  @override
  Future<DatabaseResponse> bulkDocs(List<Object> docs,
      {@required bool revs}) async {
    final path = '$_dbNameUrl?revs=$revs';
    final body = <String, List<Object>>{'docs': docs};
    final result = await client.post(path, body: body);
    return DatabaseResponse.from(result);
  }

  @override
  Future<DatabaseResponse> insertBulkDocs(List<Object> docs,
      {bool newEdits = true, Map<String, String> headers}) async {
    final path = '$_dbNameUrl/_bulk_docs';
    final body = <String, Object>{'docs': docs, 'new_edits': newEdits};
    final result = await client.post(path, body: body, reqHeaders: headers);
    return DatabaseResponse.from(result);
  }

  @override
  Future<DatabaseResponse> find(Map<String, Object> selector,
      {int limit = 25,
      int skip,
      List<Object> sort,
      List<String> fields,
      Object useIndex,
      int r = 1,
      String bookmark,
      bool update = true,
      bool stable,
      String stale = 'false',
      bool executionStats = false}) async {
    final body = <String, Object>{
      'selector': selector,
      'limit': limit,
      'r': r,
      'bookmark': bookmark,
      'update': update,
      'stale': stale,
      'execution_stats': executionStats
    };
    if (skip != null) {
      body['skip'] = skip;
    }
    if (sort != null) {
      body['sort'] = sort;
    }
    if (fields != null) {
      body['fields'] = fields;
    }
    if (useIndex != null) {
      body['use_index'] = useIndex;
    }
    if (stable != null) {
      body['stable'] = stable;
    }

    final result = await client.post('$_dbNameUrl/_find', body: body);
    return DatabaseResponse.from(result);
  }

  @override
  Future<DatabaseResponse> createIndex(
      {@required List<String> indexFields,
      String ddoc,
      String name,
      String type = 'json',
      Map<String, Object> partialFilterSelector}) async {
    final body = <String, Object>{
      'index': <String, List<String>>{'fields': indexFields},
      'type': type
    };
    if (ddoc != null) {
      body['ddoc'] = ddoc;
    }
    if (name != null) {
      body['name'] = name;
    }
    if (partialFilterSelector != null) {
      body['partial_filter_selector'] = partialFilterSelector;
    }

    final result = await client.post('$_dbNameUrl/_index', body: body);
    return DatabaseResponse.from(result);
  }

  @override
  Future<DatabaseResponse> indexes() async {
    final result = await client.get('$_dbNameUrl/_index');
    return DatabaseResponse.from(result);
  }

  @override
  Future<DatabaseResponse> deleteIndex(String designDoc, String name) async {
    final result =
        await client.delete('$_dbNameUrl/_index/$designDoc/json/$name');
    return DatabaseResponse.from(result);
  }

  @override
  Future<DatabaseResponse> explain(Map<String, Object> selector,
      {int limit = 25,
      int skip,
      List<Object> sort,
      List<String> fields,
      Object useIndex,
      int r = 1,
      String bookmark,
      bool update = true,
      bool stable,
      String stale = 'false',
      bool executionStats = false}) async {
    final body = <String, Object>{
      'selector': selector,
      'limit': limit,
      'r': r,
      'bookmark': bookmark,
      'update': update,
      'stale': stale,
      'execution_stats': executionStats
    };
    if (skip != null) {
      body['skip'] = skip;
    }
    if (sort != null) {
      body['sort'] = sort;
    }
    if (fields != null) {
      body['fields'] = fields;
    }
    if (useIndex != null) {
      body['use_index'] = useIndex;
    }
    if (stable != null) {
      body['stable'] = stable;
    }

    final result = await client.post('$_dbNameUrl/_explain', body: body);
    return DatabaseResponse.from(result);
  }

  @override
  Future<DatabaseResponse> shards() async {
    final result = await client.get('$_dbNameUrl/_shards');
    return DatabaseResponse.from(result);
  }

  @override
  Future<DatabaseResponse> shard(String docId) async {
    final result = await client.get('$_dbNameUrl/_shards/$docId');
    return DatabaseResponse.from(result);
  }

  @override
  Future<DatabaseResponse> synchronizeShards() async {
    final result = await client.post('$_dbNameUrl/_sync_shards');
    return DatabaseResponse.from(result);
  }

  @override
  Future<Stream<DatabaseResponse>> changes(
      {List<String> docIds,
      bool conflicts = false,
      bool descending = false,
      String feed = 'normal',
      String filter,
      int heartbeat = 60000,
      bool includeDocs = false,
      bool attachments = false,
      bool attEncodingInfo = false,
      int lastEventId,
      int limit,
      String since = '0',
      String style = 'main_only',
      int timeout = 60000,
      String view,
      int seqInterval}) async {
    //
    final Map<String, Object> queryParams = {
      if (docIds != null) 'doc_ids': docIds,
      'conflicts': conflicts,
      'descending': descending,
      'feed': feed,
      if (filter != null) 'filter': filter,
      'heartbeat': heartbeat,
      'include_docs': includeDocs,
      'attachments': attachments,
      'att_encoding_info': attEncodingInfo,
      if (lastEventId != null) 'last-event-id': lastEventId,
      if (limit != null) 'limit': limit,
      'since': since,
      'style': style,
      'timeout': timeout,
      if (view != null) 'view': view,
      if (seqInterval != null) 'seq_interval': seqInterval,
    };

    final path = '$_dbNameUrl/_changes?'
        '${queryStringFromMap(queryParams)}';

    final streamedRes = await client.streamed('get', path);

    switch (feed) {
      case 'longpoll':
        var strRes = await streamedRes.join();
        strRes = '{"result": [$strRes';
        return Stream<DatabaseResponse>.fromFuture(
            Future<DatabaseResponse>.value(
                DatabaseResponse.from(Response(jsonDecode(strRes)))));

      case 'continuous':
        final mappedRes = streamedRes.map((v) => v.replaceAll('}\n{', '},\n{'));
        return mappedRes.map((v) =>
            DatabaseResponse.from(Response(jsonDecode('{"result": [$v]}'))));

      case 'eventsource':
        final mappedRes = streamedRes
            .map((v) => v.replaceAll(RegExp('\n+data'), '},\n{data'))
            .map((v) => v.replaceAll('data', '"data"'))
            .map((v) => v.replaceAll('\nid', ',\n"id"'));
        return mappedRes.map((v) =>
            DatabaseResponse.from(Response(jsonDecode('{"result": [{$v}]}'))));

      default:
        var strRes = await streamedRes.join();
        strRes = '{"result": [$strRes';
        return Stream<DatabaseResponse>.fromFuture(
            Future<DatabaseResponse>.value(
                DatabaseResponse.from(Response(jsonDecode(strRes)))));
    }
  }

  @override
  Future<Stream<DatabaseResponse>> postChanges(
      {List<String> docIds,
      bool conflicts = false,
      bool descending = false,
      String feed = 'normal',
      String filter = '_doc_ids',
      int heartbeat = 60000,
      bool includeDocs = false,
      bool attachments = false,
      bool attEncodingInfo = false,
      int lastEventId,
      int limit,
      String since = '0',
      String style = 'main_only',
      int timeout = 60000,
      String view,
      int seqInterval}) async {
    //
    final Map<String, Object> queryParams = {
      'conflicts': conflicts,
      'descending': descending,
      'feed': feed,
      'filter': filter,
      'heartbeat': heartbeat,
      'include_docs': includeDocs,
      'attachments': attachments,
      'att_encoding_info': attEncodingInfo,
      if (lastEventId != null) 'last-event-id': lastEventId,
      if (limit != null) 'limit': limit,
      'since': since,
      'style': style,
      'timeout': timeout,
      if (view != null) 'view': view,
      if (seqInterval != null) 'seq_interval': seqInterval,
    };

    final path = '$_dbNameUrl/_changes?'
        '${queryStringFromMap(queryParams)}';

    final body = <String, List<String>>{'doc_ids': docIds};

    final streamedRes = await client.streamed('post', path, body: body);

    switch (feed) {
      case 'longpoll':
        var strRes = await streamedRes.join();
        strRes = '{"result": [$strRes';
        return Stream<DatabaseResponse>.fromFuture(
            Future<DatabaseResponse>.value(
                DatabaseResponse.from(Response(jsonDecode(strRes)))));

      case 'continuous':
        final mappedRes = streamedRes.map((v) => v.replaceAll('}\n{', '},\n{'));
        return mappedRes.map((v) =>
            DatabaseResponse.from(Response(jsonDecode('{"result": [$v]}'))));

      case 'eventsource':
        final mappedRes = streamedRes
            .map((v) => v.replaceAll(RegExp('\n+data'), '},\n{data'))
            .map((v) => v.replaceAll('data', '"data"'))
            .map((v) => v.replaceAll('\nid', ',\n"id"'));
        return mappedRes.map((v) =>
            DatabaseResponse.from(Response(jsonDecode('{"result": [{$v}]}'))));

      default:
        var strRes = await streamedRes.join();
        strRes = '{"result": [$strRes';
        return Stream<DatabaseResponse>.fromFuture(
            Future<DatabaseResponse>.value(
                DatabaseResponse.from(Response(jsonDecode(strRes)))));
    }
  }

  @override
  Future<DatabaseResponse> compact() async {
    final result = await client.post('$_dbNameUrl/_compact');
    return DatabaseResponse.from(result);
  }

  @override
  Future<DatabaseResponse> compactViewIndexesWith(String ddocName) async {
    final result = await client.post('$_dbNameUrl/_compact/$ddocName');
    return DatabaseResponse.from(result);
  }

  @override
  Future<DatabaseResponse> ensureFullCommit() async {
    final result = await client.post('$_dbNameUrl/_ensure_full_commit');
    return DatabaseResponse.from(result);
  }

  @override
  Future<DatabaseResponse> viewCleanup() async {
    final result = await client.post('$_dbNameUrl/_view_cleanup');
    return DatabaseResponse.from(result);
  }

  @override
  Future<DatabaseResponse> security() async {
    final result = await client.get('$_dbNameUrl/_security');
    return DatabaseResponse.from(result);
  }

  @override
  Future<DatabaseResponse> setSecurity(
      Map<String, Map<String, List<String>>> security) async {
    final result = await client.put('$_dbNameUrl/_security', body: security);
    return DatabaseResponse.from(result);
  }

  @override
  Future<DatabaseResponse> purge(Map<String, List<String>> docs) async {
    final result = await client.post('$_dbNameUrl/_purge', body: docs);
    return DatabaseResponse.from(result);
  }

  @override
  Future<DatabaseResponse> purgedInfosLimit() async {
    final result = await client.get('$_dbNameUrl/_purged_infos_limit');
    return DatabaseResponse.from(result);
  }

  @override
  Future<DatabaseResponse> setPurgedInfosLimit(int limit) async {
    final result =
        await client.put('$_dbNameUrl/_purged_infos_limit', body: limit);
    return DatabaseResponse.from(result);
  }

  @override
  Future<DatabaseResponse> missingRevs(Map<String, List<String>> revs) async {
    final result = await client.post('$_dbNameUrl/_missing_revs', body: revs);
    return DatabaseResponse.from(result);
  }

  @override
  Future<DatabaseResponse> revsDiff(Map<String, List<String>> revs) async {
    final result = await client.post('$_dbNameUrl/_revs_diff', body: revs);
    return DatabaseResponse.from(result);
  }

  @override
  Future<DatabaseResponse> revsLimit() async {
    final result = await client.get('$_dbNameUrl/_revs_limit');
    return DatabaseResponse.from(result);
  }

  /// Sets the maximum number of document revisions that will be tracked by CouchDB,
  /// even after compaction has occurred
  @override
  Future<DatabaseResponse> setRevsLimit(int limit) async {
    final result = await client.put('$_dbNameUrl/_revs_limit', body: limit);
    return DatabaseResponse.from(result);
  }
}
