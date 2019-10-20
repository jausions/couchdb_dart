import 'dart:convert';

import 'package:meta/meta.dart';

import 'interfaces/client_interface.dart';
import 'interfaces/server_interface.dart';
import 'responses/server_response.dart';
import 'utils/urls.dart';

/// Server interface provides the basic interface to a CouchDB server
/// for obtaining CouchDB information and getting and setting configuration information
class Server implements ServerInterface {
  /// Instance of connected client
  final ClientInterface _client;

  /// Create Server by accepting web-based or server-based client
  Server(this._client);

  @override
  Future<ServerResponse> activeTasks({Map<String, String> headers}) async {
    final result = await _client.get('_active_tasks', reqHeaders: headers);
    return ServerResponse.from(result);
  }

  @override
  Future<ServerResponse> allDbs({
    Map<String, String> headers,
    bool descending = false,
    Object endKey,
    int limit,
    int skip,
    Object startKey,
  }) async {
    final Map<String, Object> queryParams = {
      'descending': descending,
      if (endKey != null) 'endkey': jsonEncode(endKey),
      if (limit != null) 'limit': limit,
      if (skip != null) 'skip': skip,
      if (startKey != null) 'startkey': jsonEncode(startKey),
    };

    final path = '_all_dbs?'
        '${queryStringFromMap(queryParams)}';

    final result = await _client.get(path, reqHeaders: headers);
    return ServerResponse.from(result);
  }

  @override
  Future<ServerResponse> dbsInfo(List<String> keys) async {
    final body = <String, List<String>>{'keys': keys};

    final result = await _client.post('_dbs_info', body: body);
    return ServerResponse.from(result);
  }

  @override
  Future<ServerResponse> clusterSetupStatus(
      {List<String> ensureDbsExist, Map<String, String> headers}) async {
    //
    final Map<String, Object> queryParams = {
      if (ensureDbsExist != null) 'ensure_dbs_exist': ensureDbsExist,
    };

    final path = '_cluster_setup?'
        '${queryStringFromMap(queryParams)}';

    final result = await _client.get(path, reqHeaders: headers);
    return ServerResponse.from(result);
  }

  @override
  Future<ServerResponse> configureCouchDb(
      {@required String action,
      String bindAddress,
      String username,
      String password,
      int port,
      int nodeCount,
      String remoteNode,
      String remoteCurrentUser,
      String remoteCurrentPassword,
      String host,
      List<String> ensureDbsExist,
      Map<String, String> headers}) async {
    final body = <String, Object>{'action': action};

    switch (action) {
      case 'enable_single_node':
        body['bind_address'] = bindAddress;
        body['username'] = username;
        body['password'] = password;
        body['port'] = port;
        break;

      case 'enable_cluster':
        body['bind_address'] = bindAddress;
        body['username'] = username;
        body['password'] = password;
        body['port'] = port;
        body['node_count'] = nodeCount;
        body['remote_node'] = remoteNode;
        body['remote_current_user'] = remoteCurrentUser;
        body['remote_current_password'] = remoteCurrentPassword;
        break;

      case 'add_node':
        body['username'] = username;
        body['password'] = password;
        body['port'] = port;
        body['host'] = host;
        break;
    }

    if (ensureDbsExist != null) {
      body['ensure_dbs_exist'] = ensureDbsExist;
    }

    final result =
        await _client.post('_cluster_setup', reqHeaders: headers, body: body);
    return ServerResponse.from(result);
  }

  @override
  Future<ServerResponse> couchDbInfo({Map<String, String> headers}) async {
    final result = await _client.get('', reqHeaders: headers);
    return ServerResponse.from(result);
  }

  @override
  Future<ServerResponse> dbUpdates(
      {String feed = 'normal',
      int timeout = 60,
      int heartbeat = 60000,
      String since,
      Map<String, String> headers}) async {
    //
    final Map<String, Object> queryParams = {
      'feed': feed,
      'timeout': timeout,
      if (feed == 'longpoll' || feed == 'continuous' || feed == 'eventsource')
        'heartbeat': heartbeat,
      if (since != null) 'since': since,
    };

    final path = '_db_updates?'
        '${queryStringFromMap(queryParams)}';

    final result = await _client.get(path, reqHeaders: headers);
    return ServerResponse.from(result);
  }

  @override
  Future<ServerResponse> membership({Map<String, String> headers}) async {
    final result = await _client.get('_membership', reqHeaders: headers);
    return ServerResponse.from(result);
  }

  @override
  Future<ServerResponse> nodeStats(
      {String nodeName = '_local',
      String statisticSection,
      String statisticId,
      Map<String, String> headers}) async {
    final path = (statisticSection != null && statisticId != null)
        ? '_node/$nodeName/_stats/$statisticSection/$statisticId'
        : '_node/$nodeName/_stats';

    final result = await _client.get(path, reqHeaders: headers);
    return ServerResponse.from(result);
  }

  @override
  Future<ServerResponse> replicate(
      {bool cancel,
      bool continuous,
      bool createTarget,
      List<String> docIds,
      String filterFunJS,
      String proxy,
      Object source,
      Object target,
      Map<String, String> headers}) async {
    final body = <String, Object>{};

    if (cancel != null) {
      body['cancel'] = cancel;
    }
    if (continuous != null) {
      body['continuous'] = continuous;
    }
    if (createTarget != null) {
      body['create_target'] = createTarget;
    }
    if (docIds != null) {
      body['doc_ids'] = docIds;
    }
    if (filterFunJS != null) {
      body['filter'] = filterFunJS;
    }
    if (proxy != null) {
      body['proxy'] = proxy;
    }
    if (source != null) {
      body['source'] = source;
    }
    if (target != null) {
      body['target'] = target;
    }

    final result =
        await _client.post('_replicate', reqHeaders: headers, body: body);
    return ServerResponse.from(result);
  }

  @override
  Future<ServerResponse> schedulerJobs({int limit, int skip}) async {
    final Map<String, Object> queryParams = {
      if (limit != null) 'limit': limit,
      if (skip != null) 'skip': skip,
    };
    final path = '_scheduler/jobs?'
        '${queryStringFromMap(queryParams)}';

    final result = await _client.get(path);
    return ServerResponse.from(result);
  }

  @override
  Future<ServerResponse> schedulerDocs({int limit, int skip}) async {
    final Map<String, Object> queryParams = {
      if (limit != null) 'limit': limit,
      if (skip != null) 'skip': skip,
    };
    final path = '_scheduler/docs?'
        '${queryStringFromMap(queryParams)}';

    final result = await _client.get(path);
    return ServerResponse.from(result);
  }

  @override
  Future<ServerResponse> schedulerDocsWithReplicatorDbName(
      {String replicator = '_replicator', int limit, int skip}) async {
    final Map<String, Object> queryParams = {
      if (limit != null) 'limit': limit,
      if (skip != null) 'skip': skip,
    };
    final path = '_scheduler/docs/$replicator?'
        '${queryStringFromMap(queryParams)}';

    final result = await _client.get(path);
    return ServerResponse.from(result);
  }

  @override
  Future<ServerResponse> schedulerDocsWithDocId(String docId,
      {String replicator = '_replicator'}) async {
    final result = await _client.get('_scheduler/docs/$replicator/$docId');
    return ServerResponse.from(result);
  }

  @override
  Future<ServerResponse> systemStatsForNode(
      {String nodeName = '_local', Map<String, String> headers}) async {
    final result =
        await _client.get('_node/$nodeName/_system', reqHeaders: headers);
    return ServerResponse.from(result);
  }

  @override
  Future<ServerResponse> up() async {
    final result = await _client.get('_up');
    return ServerResponse.from(result);
  }

  @override
  Future<ServerResponse> uuids(
      {int count = 1, Map<String, String> headers}) async {
    final result =
        await _client.get('_uuids?count=$count', reqHeaders: headers);
    return ServerResponse.from(result);
  }
}
