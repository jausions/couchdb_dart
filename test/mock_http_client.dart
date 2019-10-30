import 'dart:convert';

import 'package:http/http.dart' show Request, Response, BaseClient;
import 'package:http/testing.dart';
import 'package:uuid/uuid.dart';

import 'cookies.dart';
import 'credentials.dart';

/// A mock HTTP client to intercept HTTP requests and return mocked up responses.
/// The only authentication scheme supported at this time is Basic authentication.
class MockHttpClient {
  BaseClient get client {
    return MockClient(requestHandler);
  }

  static const sessionCookieName = 'mock_couchdb_server';
  static const mockDatabaseName = "mock-test-db";

  final _failedAuthenticationPayload = jsonEncode({
    "error": "unauthorized",
    "reason": "Name or password is incorrect.",
  });

  final _incompleteDataPayload = jsonEncode({
    "error": "bad request",
    "reason": "The data you sent is incomplete.",
  });

  final _invalidMimeTypePayload = jsonEncode({
    "error": "bad request",
    "reason": "The Content-Type is not supported.",
  });

  final _notImplementedPayload = jsonEncode({
    "error": "not implemented",
    "reason": "You are using the mock HTTP client.",
  });

  final _simpleOkPayload = jsonEncode({
    "ok": true,
  });

  final _wrongHttpMethodPayload = jsonEncode({
    "error": "bad request",
    "reason": "Wrong HTTP method for URL (mock HTTP client)",
  });

  final Map<String, String> _responseHttpHeaders = {
    'Content-Type': 'application/json',
    'Server': 'Mock CouchDb (Dart)',
  };

  final uuidGenerator = Uuid();

  bool _isJsonContentType(Request request) {
    final contentType = request.headers['content-type'];
    if (contentType == null) {
      return false;
    }
    return contentType.startsWith(RegExp(r'^application/json;?'));
  }

  bool _isValidBase64Authentication(base64Value) {
    final decoded = utf8.decode(base64.decode(base64Value));
    final splitAt = decoded.indexOf(':');
    final username = decoded.substring(0, splitAt);
    final password = decoded.substring(splitAt + 1);

    return _isValidUserPassword(username, password);
  }

  bool _isValidUserPassword(String username, String password) {
    if (!credentials.containsKey(username)) {
      return false;
    }
    return credentials[username] == password;
  }

  bool _isAuthorizedAccess(Request request) {
    // We check the HTTP Basic authentication header or the session cookie's value.
    // This works only because of the way we create the session cookie.
    final authentication = request.headers['authorization'];
    final cookies = parseHttpCookieHeader(request.headers['cookie'] ?? '');
    final authString = authentication ?? cookies[sessionCookieName] ?? '';

    if (authString.isNotEmpty) {
      if (authString.startsWith(RegExp(r'^Basic[+ ]'))) {
        return _isValidBase64Authentication(authString.substring(6));
      }
    }

    // Public access
    return true;
  }

  /// Dispatches the incoming API request
  Future<Response> requestHandler(Request request) {
    if (!_isAuthorizedAccess(request)) {
      return Future.value(Response(_failedAuthenticationPayload, 401,
          request: request, headers: _responseHttpHeaders));
    }

    final pathSegments = request.url.pathSegments;

    try {
      // Root URL / ?
      if (pathSegments.isEmpty) {
        return Future.value(rootHandler(request));
      }

      switch (pathSegments[0]) {
        case '_all_dbs':
          return Future.value(allDbsHandler(request));
        case '_session':
          return Future.value(sessionHandler(request));
        case '_uuids':
          return Future.value(uuidsHandler(request));
        case '_active_tasks':
        case '_dbs_info':
        case '_cluster_setup':
        case '_db_updates':
        case '_membership':
        case '_replicate':
        case '_scheduler':
        case '_node':
        case '_utils':
        case '_up':
        case 'favicon.ico':
          return Future.value(Response(_notImplementedPayload, 501,
              request: request, headers: _responseHttpHeaders));
      }

      // The rest is handled as if sent to a specific database
      return databaseHandler(pathSegments, request);
    } on Exception catch (e) {
      final error = {
        "error": "Mock server error",
        "reason": "An exception was thrown: $e",
      };
      return Future.value(Response(jsonEncode(error), 500, request: request));
    }
  }

  /// Dispatches the request for a specific database
  Future<Response> databaseHandler(List<String> path, Request request) {
    final dbName = path[0];

    if (path.length == 1) {
      return Future.value(dbHandler(dbName, request));
    }

    switch (path[1]) {
      case '_all_docs':
      case '_design_docs':
      case '_bulk_get':
      case '_bulk_docs':
      case '_find':
      case '_index':
      case '_explain':
      case '_shards':
      case '_sync_shards':
      case '_chnages':
      case '_compact':
      case '_ensure_full_commit':
      case '_view_cleanup':
      case '_security':
      case '_purge':
      case '_purged_infos_limit':
      case '_missing_revs':
      case '_revs_diff':
      case '_revs_limit':
        return Future.value(Response(_notImplementedPayload, 501,
            request: request, headers: _responseHttpHeaders));
    }

    return Future.value(Response(_notImplementedPayload, 501,
        request: request, headers: _responseHttpHeaders));
  }

  /// Handles the requests made to the / path
  Response rootHandler(Request request) {
    if (request.method == 'GET') {
      final info = {
        "couchdb": "You reached the mock server.",
        "uuid": "8abadba97f974e76bb9dfb779be0c8ad",
        "vendor": {"name": "CouchDB Dart Client", "version": "0.7.0"},
        "version": "0.7.0"
      };
      return Response(jsonEncode(info), 200,
          request: request, headers: _responseHttpHeaders);
    }
    return Response(_wrongHttpMethodPayload, 400,
        request: request, headers: _responseHttpHeaders);
  }

  /// Handles the requests mode to the /_all_dbs path
  Response allDbsHandler(Request request) {
    if (request.method == 'GET') {
      final dbs = [
        "_global_changes",
        "_replicator",
        "_users",
        mockDatabaseName
      ];
      return Response(jsonEncode(dbs), 200,
          request: request, headers: _responseHttpHeaders);
    }
    return Response(_wrongHttpMethodPayload, 400,
        request: request, headers: _responseHttpHeaders);
  }

  /// Handles the requests made to the /_uuids path
  Response uuidsHandler(Request request) {
    if (request.method != 'GET') {
      return Response(_wrongHttpMethodPayload, 400,
          request: request, headers: _responseHttpHeaders);
    }

    final qs = request.url.queryParameters;
    var count;
    if (!qs.containsKey('count')) {
      count = 1;
    } else {
      final qsCount = int.tryParse(qs['count']);
      if (qsCount == null || qsCount < 0 || qsCount > 20) {
        return Response(
            jsonEncode({
              "error": "bad request",
              "reason": "Mock server says: `count` is out of range (0-20).",
            }),
            400,
            request: request,
            headers: _responseHttpHeaders);
      }
      count = qsCount;
    }

    final uuids = {
      'uuids': [
        for (var i = 1; i <= count; ++i) uuidGenerator.v4().replaceAll('-', ''),
      ]
    };
    return Response(jsonEncode(uuids), 200,
        request: request, headers: _responseHttpHeaders);
  }

  /// Handles the requests made to a /{db} path
  Response dbHandler(String dbName, Request request) {
    // Add document
    if (request.method == 'POST') {
      return dbPostHandler(dbName, request);
    }

    return Response(_notImplementedPayload, 501,
        request: request, headers: _responseHttpHeaders);
  }

  /// Handles the requests made to a /{db} path with POST HTTP method.
  /// This would try to add a document to the database.
  ///
  /// This handler checks the `_id` for special values to behave accordingly.
  ///
  ///   - `conflict` will trigger a 409 HTTP status code
  Response dbPostHandler(String dbName, Request request) {
    final json = jsonDecode(request.body);

    // @TODO Check and mimic CouchDB behavior when POST body is not a JSON object
    if (!(json is Map)) {
      return Response(_incompleteDataPayload, 400,
          request: request, headers: _responseHttpHeaders);
    }

    final id = json['_id'] ?? uuidGenerator.v4();

    switch (id) {
      case 'conflict':
        final conflict = {
          "error": "conflict",
          "reason": "Mock document update conflict.",
        };
        return Response(jsonEncode(conflict), 409,
            request: request, headers: _responseHttpHeaders);
    }

    final batch = request.url.queryParameters['batch'] ?? 'no';
    final code = (batch == 'ok') ? 202 : 201;

    return Response(_notImplementedPayload, 501,
        request: request, headers: _responseHttpHeaders);
  }

  /// Handles the requests made to the /_session path
  Response sessionHandler(Request request) {
    // Login
    if (request.method == 'POST') {
      return sessionPostHandler(request);
    }
    // Logout
    if (request.method == 'DELETE') {
      return sessionDeleteHandler(request);
    }

    return Response(_notImplementedPayload, 501,
        request: request, headers: _responseHttpHeaders);
  }

  /// Handles logging in when accessing /_session with POST HTTP method
  Response sessionPostHandler(Request request) {
    if (!_isJsonContentType(request)) {
      return Response(_invalidMimeTypePayload, 400,
          request: request, headers: _responseHttpHeaders);
    }

    final bodyUTF8 = utf8.decode(request.bodyBytes);
    final resBody = jsonDecode(bodyUTF8);
    Map<String, Object> json = Map<String, Object>.from(resBody);

    if (!json.containsKey('name') || !json.containsKey('password')) {
      return Response(_incompleteDataPayload, 400,
          request: request, headers: _responseHttpHeaders);
    }

    if (!_isValidUserPassword(json['name'], json['password'])) {
      return Response(_failedAuthenticationPayload, 401,
          request: request, headers: _responseHttpHeaders);
    }

    // We store the username and password almost like a Basic HTTP authentication.
    // That simplifies validation of sessions.
    final base64 =
        base64Encode(utf8.encode("${json['name']}:${json['password']}"));

    final Map<String, String> headers =
        Map<String, String>.from(_responseHttpHeaders);

    headers.addAll({
      'Set-Cookie': '$sessionCookieName=Basic+$base64',
    });

    return Response(_simpleOkPayload, 200, request: request, headers: headers);
  }

  /// Handles logging out when accessing /_session with DELETE HTTP method
  Response sessionDeleteHandler(Request request) {
    final Map<String, String> headers =
        Map<String, String>.from(_responseHttpHeaders);

    headers.addAll({
      'Set-Cookie':
          "$sessionCookieName=; Expires=Wed, 21 Oct 2015 07:28:00 GMT",
    });
    return Response(_simpleOkPayload, 200, request: request, headers: headers);
  }
}
