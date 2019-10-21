import 'dart:convert';

import 'package:couchdb/couchdb.dart';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http show BaseClient, Client, Request;
import 'package:http_parser/http_parser.dart';

import '../exceptions/couchdb_exception.dart';
import '../interfaces/client_interface.dart';
import '../interfaces/validator_interface.dart';
import '../responses/response.dart';

/// Client for interacting with database via server-side and web applications
class CouchDbClient implements ClientInterface {
  /// Creates instance of client with [username], [password], [host], [port],
  /// [cors], [auth], [scheme] of the connection and
  /// [secret] (needed for proxy authentication) parameters.
  /// Make sure that CouchDb application have `CORS` enabled.
  ///
  /// [auth] may be one of:
  ///
  ///     - basic (default)
  ///     - cookie
  ///     - proxy
  ///
  /// [scheme] may be one of:
  ///
  ///   - http
  ///   - https (if `SSL` set to `true`)
  ///
  /// A [httpClient] instance can be provided to use instead of the standard
  /// client from package:http.
  CouchDbClient(
      {String username,
      String password,
      String scheme = 'http',
      String host = '0.0.0.0',
      int port = 5984,
      this.auth = 'basic',
      this.cors = false,
      String secret,
      String path,
      http.BaseClient httpClient,
      ValidatorInterface validator})
      : secret = utf8.encode(secret != null ? secret : ''),
        _httpClient = httpClient ?? http.Client(),
        validator = validator ?? Validator() {
    if (username == null && password != null) {
      throw CouchDbException(401,
          response: Response(<String, Object>{
            'error': 'Authorization failed',
            'reason': 'You must provide username if password is non null!'
          }).errorResponse());
    } else if (username != null && password == null) {
      throw CouchDbException(401,
          response: Response(<String, Object>{
            'error': 'Authorization failed',
            'reason': 'You must provide password if username is non null!'
          }).errorResponse());
    }

    final userInfo = username == null && password == null
        ? null
//        : '$username:$password';
        : '${Uri.encodeQueryComponent(username)}:${Uri.encodeQueryComponent(password)}';

    final regExp = RegExp(r'http[s]?://');
    if (host.startsWith(regExp)) {
      host = host.replaceFirst(regExp, '');
    }
    _connectUri = Uri(
        scheme: scheme, host: host, port: port, userInfo: userInfo, path: path);
  }

  /// Create [CouchDbClient] instance from [uri] and
  /// [auth], [cors] and [secret] params.
  ///
  /// A [httpClient] instance can be provided to use instead of the standard
  /// client from package:http.
  CouchDbClient.fromUri(Uri uri,
      {this.auth = 'basic',
      this.cors = false,
      String secret,
      http.BaseClient httpClient,
        ValidatorInterface validator})
      : secret = utf8.encode(secret != null ? secret : ''),
        _httpClient = httpClient ?? http.Client(),
        validator = validator ?? Validator() {
    final properUri = Uri(
      scheme: (uri.scheme == '') ? 'http' : uri.scheme,
      userInfo: uri.userInfo,
      host: (uri.host == '') ? '127.0.0.1' : uri.host,
      port: (uri.port <= 0) ? 5984 : uri.port,
    );
    _connectUri = properUri;
  }

  /// Create [Client] instance from [uri] and
  /// [auth], [cors] and [secret] params.
  ///
  /// A [httpClient] instance can be provided to use instead of the standard
  /// client from package:http.
  CouchDbClient.fromString(String uri,
      {String auth = 'basic',
      bool cors = false,
      String secret,
      http.BaseClient httpClient})
      : this.fromUri(Uri.tryParse(uri),
            auth: auth, cors: cors, secret: secret, httpClient: httpClient);

  /// Host of database instance
  String get host => _connectUri.host;

  /// Port database listened to
  int get port => _connectUri.port;

  /// Username of database user
  String get username => _connectUri.userInfo.isNotEmpty
      ? Uri.decodeQueryComponent(_connectUri.userInfo.split(':')[0])
      : '';

  /// Password of database user
  String get password => _connectUri.userInfo.isNotEmpty
      ? Uri.decodeQueryComponent(_connectUri.userInfo.split(':')[1])
      : '';

  /// Origin to be sent in CORS header
  String get origin => _connectUri.origin;

  /// Base64 encoded [username] and [password]
  String get authCredentials => username.isNotEmpty && password.isNotEmpty
      ? base64
          .encode(utf8.encode(Uri.decodeQueryComponent(_connectUri.userInfo)))
      : '';

  /// Gets unmodifiable request headers of this client
  Map<String, String> get headers => Map<String, String>.unmodifiable(_headers);

  /// Authentication type used in requests
  ///
  /// May be one of:
  ///
  ///     - basic
  ///     - cookie
  ///     - proxy
  ///
  String auth;

  /// Holds authentication cookies
  String _cookies;

  /// Tells if CORS is enabled
  final bool cors;

  /// Holds secret for proxy authentication
  final List<int> secret;

  /// Web Client for requests
  final http.BaseClient _httpClient;

  /// Value validator
  final ValidatorInterface validator;

  /// Request headers
  ///
  /// Already contains `Accept` and `Content-Type` headers defaults to `application/json`.
  final Map<String, String> _headers = <String, String>{
    'Accept': 'application/json',
    'Content-Type': 'application/json'
  };

  /// Store connection info about connection like **scheme**,
  /// **host**, **port**, **userInfo**
  Uri _connectUri;

  /// Sets headers to [_headers]
  ///
  /// You can directly set your own headers as follows:
  /// ```dart
  /// final client = CouchDbWebClient(username: 'name', password: 'pass');
  /// client.modifyRequestHeaders(<String, String>{ ... })
  /// ```
  /// or define it using methods [head], [get], [put], [post],
  /// [delete] and [copy].
  void modifyRequestHeaders(Map<String, String> reqHeaders) {
    // If [reqHeaders] is null addAll method takes empty Map
    _headers.addAll(reqHeaders ?? <String, String>{});

    switch (auth) {
      case 'cookie':
        if (_cookies != null) {
          _headers['Cookie'] = _cookies;
        }
        break;
      case 'proxy':
        _headers['X-Auth-CouchDB-UserName'] = username;
        if (secret != null) {
          final encodedUsername = utf8.encode(username);
          _headers['X-Auth-CouchDB-Token'] =
              Hmac(sha1, secret).convert(encodedUsername).toString();
        }
        break;
      default:
        final basicAuth = authCredentials;
        if (basicAuth.isNotEmpty) {
          _headers['Authorization'] = 'Basic $basicAuth';
        }
    }
    if (cors) {
      _headers['Origin'] = origin;
    }
  }

  /// HEAD method
  Future<Response> head(String path,
      {Map<String, String> reqHeaders}) async {
    modifyRequestHeaders(reqHeaders);

    final res =
        await _httpClient.head(Uri.parse('$origin/$path'), headers: headers);

    _checkForErrorStatusCode(res.statusCode, headers: res.headers);

    return Response(null, headers: res.headers);
  }

  /// GET method
  Future<Response> get(String path, {Map<String, String> reqHeaders}) async {
    Map<String, Object> json;

    modifyRequestHeaders(reqHeaders);

    final uriString = path.isNotEmpty ? '$origin/$path' : '$origin';
    final res = await _httpClient.get(Uri.parse(uriString), headers: headers);

    final bodyUTF8 = utf8.decode(res.bodyBytes);
    final responseHeaders = CaseInsensitiveMap<String>.from(res.headers);
    if (responseHeaders['content-type'].startsWith(RegExp(r'^application/json;?'))) {
      final resBody = jsonDecode(bodyUTF8);

      if (resBody is int) {
        json = <String, Object>{'limit': resBody};
      } else if (resBody is List) {
        json = <String, Object>{'list': List<Object>.from(resBody)};
      } else {
        json = Map<String, Object>.from(resBody);
      }
    } else {
      // When body isn't JSON-valid then Response try parse field from [json]
      // and if it is null - error is thrown
      json = <String, Object>{};
    }

    _checkForErrorStatusCode(res.statusCode,
        body: bodyUTF8, headers: res.headers);

    return Response(json, raw: bodyUTF8, headers: res.headers);
  }

  /// PUT method
  Future<Response> put(String path,
      {Object body, Map<String, String> reqHeaders}) async {
    modifyRequestHeaders(reqHeaders);

    Object encodedBody;
    if (body != null) {
      body is Map ? encodedBody = jsonEncode(body) : encodedBody = body;
    }

    final url = Uri.parse('$origin/$path');
    final res = await _httpClient.put(url, headers: headers, body: encodedBody);

    final bodyUTF8 = utf8.decode(res.bodyBytes);
    final resBody = jsonDecode(bodyUTF8);
    final json = Map<String, Object>.from(resBody);

    _checkForErrorStatusCode(res.statusCode,
        body: bodyUTF8, headers: res.headers);

    return Response(json, headers: res.headers);
  }

  /// POST method
  Future<Response> post(String path,
      {Object body, Map<String, String> reqHeaders}) async {
    modifyRequestHeaders(reqHeaders);

    Object encodedBody;
    if (body != null) {
      encodedBody = (body is Map) ? jsonEncode(body) : body;
    }

    final res = await _httpClient.post(Uri.parse('$origin/$path'),
        headers: headers, body: encodedBody);

    final bodyUTF8 = utf8.decode(res.bodyBytes);
    final resBody = jsonDecode(bodyUTF8);

    Map<String, Object> json;
    if (resBody is List) {
      json = <String, Object>{'list': List<Object>.from(resBody)};
    } else {
      json = Map<String, Object>.from(resBody);
    }

    _checkForErrorStatusCode(res.statusCode,
        body: bodyUTF8, headers: res.headers);

    return Response(json, headers: res.headers);
  }

  /// DELETE method
  Future<Response> delete(String path,
      {Map<String, String> reqHeaders}) async {
    modifyRequestHeaders(reqHeaders);

    final res =
        await _httpClient.delete(Uri.parse('$origin/$path'), headers: headers);

    final bodyUTF8 = utf8.decode(res.bodyBytes);
    final resBody = jsonDecode(bodyUTF8);
    final json = Map<String, Object>.from(resBody);

    _checkForErrorStatusCode(res.statusCode,
        body: bodyUTF8, headers: res.headers);

    return Response(json, headers: res.headers);
  }

  /// COPY method
  Future<Response> copy(String path,
      {Map<String, String> reqHeaders}) async {
    modifyRequestHeaders(reqHeaders);
    final request = http.Request('COPY', Uri.parse('$origin/$path'));
    request.headers.addAll(headers);

    final res = await _httpClient.send(request);

    final body = await res.stream.transform(utf8.decoder).join();

    final resBody = jsonDecode(body);
    final json = Map<String, Object>.from(resBody);

    _checkForErrorStatusCode(res.statusCode, body: body, headers: res.headers);

    return Response(json, headers: res.headers);
  }

  /// Makes request with specific [method] and with long or
  /// continuous connection
  ///
  /// Returns undecoded response.
  Future<Stream<String>> streamed(String method, String path,
      {Object body, Map<String, String> reqHeaders}) async {
    modifyRequestHeaders(reqHeaders);

    final uriString = path.isNotEmpty ? '$origin/$path' : '$origin';
    final request = http.Request(method, Uri.parse(uriString));
    request.headers.addAll(headers);
    if (body != null && (method == 'post' || method == 'put')) {
      request.body =
          body is Map || body is List ? jsonEncode(body) : body.toString();
    }
    final res = await _httpClient.send(request);

    final resStream = res.stream.asBroadcastStream().transform(utf8.decoder);
    _checkForErrorStatusCode(res.statusCode,
        body: await resStream.first, headers: res.headers);

    return resStream;
  }

  /// Checks if response is returned with status codes lower than
  /// `200` of greater than `304`
  ///
  /// Throws a `CouchDbException` if status code is out of range `200-304`.
  void _checkForErrorStatusCode(int code,
      {String body, Map<String, String> headers}) {
    if (code < 200 || code > 304) {
      throw CouchDbException(code,
          response:
              Response(jsonDecode(body ?? 'null'), headers: headers).errorResponse());
    }
  }

  /// Initiates new session for specified user credentials by
  /// providing `Cookie` value
  ///
  /// If [next] parameter was provided the response will trigger redirection
  /// to the specified location in case of successful authentication.
  ///
  /// Structured response is available in `ServerResponse`.
  ///
  /// Returns JSON like:
  /// ```json
  /// {'ok': true, 'name': 'root', 'roles': ['_admin']}
  /// ```
  Future<Response> authenticate([String next]) async {
    final path = (next != null) ? '_session?next=$next' : '_session';

    Response res = await post(path,
        body: <String, String>{'name': username, 'password': password});
    _cookies = res.headers['set-cookie'];

    return res;
  }

  /// Closes user’s session by instructing the browser to clear the cookie
  ///
  /// Structured response is available in `ServerResponse`.
  ///
  /// Returns JSON like:
  /// ```json
  /// {'ok': true}
  /// ```
  Future<Response> logout() async {
    Response res = await delete('_session');
    _cookies = null;
    return res;
  }

  /// Returns information about the authenticated user, including a
  /// User Context Object, the authentication method and database
  /// that were used, and a list of configured
  /// authentication handlers on the server
  ///
  /// Structured response is available in `ServerResponse`.
  ///
  /// Returns JSON like:
  /// ```json
  /// {
  ///     'info': {
  ///         'authenticated': 'cookie',
  ///         'authentication_db': '_users',
  ///         'authentication_handlers': [
  ///             'cookie',
  ///             'default'
  ///         ]
  ///     },
  ///     'ok': true,
  ///     'userCtx': {
  ///         'name': 'root',
  ///         'roles': [
  ///             '_admin'
  ///         ]
  ///     }
  /// }
  /// ```
  Future<Response> userInfo({bool basic = false}) async {
    Response res;
    final prevAuth = auth;

    if (basic) {
      auth = 'basic';
    }

    res = await get('_session');

    auth = prevAuth;
    return res;
  }
}
