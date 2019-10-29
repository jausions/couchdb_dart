import 'dart:convert';

import 'package:http/http.dart' show Request, Response, BaseClient;
import 'package:http/testing.dart';

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
  };

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

  Future<Response> requestHandler(Request request) {
    if (!_isAuthorizedAccess(request)) {
      return Future.value(Response(_failedAuthenticationPayload, 401,
          request: request, headers: _responseHttpHeaders));
    }

    final pathSegments = request.url.pathSegments;

    // Root URL / ?
    if (pathSegments.isEmpty) {
      return Future.value(rootHandler(request));
    }

    switch (pathSegments[0]) {
      case '_all_dbs':
        return Future.value(_all_dbsHandler(request));
      case '_session':
        return Future.value(_sessionHandler(request));
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
  Response _all_dbsHandler(Request request) {
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

  /// Handles the requests made to the _session path
  Response _sessionHandler(Request request) {
    // Login
    if (request.method == 'POST') {
      return _sessionLoginHandler(request);
    }
    // Logout
    if (request.method == 'DELETE') {
      return _sessionLogoutHandler(request);
    }

    return Response(_notImplementedPayload, 501,
        request: request, headers: _responseHttpHeaders);
  }

  Response _sessionLoginHandler(Request request) {
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

  Response _sessionLogoutHandler(Request request) {
    final Map<String, String> headers =
        Map<String, String>.from(_responseHttpHeaders);

    headers.addAll({
      'Set-Cookie':
          "$sessionCookieName=; Expires=Wed, 21 Oct 2015 07:28:00 GMT",
    });
    return Response(_simpleOkPayload, 200, request: request, headers: headers);
  }
}
