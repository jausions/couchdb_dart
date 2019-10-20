import 'package:couchdb/couchdb.dart';

import '../responses/response.dart';

/// Client for interacting with CouchDB server
abstract class ClientInterface {
  /// To validate database names, document ids, and so on
  final ValidatorInterface validator;

  ClientInterface(this.validator);

  /// HEAD method
  Future<Response> head(String path, {Map<String, String> reqHeaders});

  /// GET method
  Future<Response> get(String path, {Map<String, String> reqHeaders});

  /// PUT method
  Future<Response> put(String path,
      {Object body, Map<String, String> reqHeaders});

  /// POST method
  Future<Response> post(String path,
      {Object body, Map<String, String> reqHeaders});

  /// DELETE method
  Future<Response> delete(String path, {Map<String, String> reqHeaders});

  /// COPY method
  Future<Response> copy(String path, {Map<String, String> reqHeaders});

  /// Makes request with specific [method] and with long or
  /// continuous connection
  ///
  /// Returns undecoded response.
  Future<Stream<String>> streamed(String method, String path,
      {Object body, Map<String, String> reqHeaders});

  /// Initiates new session for specified user credentials by
  /// providing `Cookie` value
  ///
  /// If [next] parameter was provided the response will trigger redirection
  /// to the specified location in case of successful authentication.
  ///
  /// Structured response is available in `ServerModelResponse`.
  ///
  /// Returns JSON like:
  /// ```json
  /// {'ok': true, 'name': 'root', 'roles': ['_admin']}
  /// ```
  Future<Response> authenticate([String next]);

  /// Closes user’s session by instructing the browser to clear the cookie
  ///
  /// Structured response is available in `ServerModelResponse`.
  ///
  /// Returns JSON like:
  /// ```json
  /// {'ok': true}
  /// ```
  Future<Response> logout();

  /// Returns information about the authenticated user, including a
  /// User Context Object, the authentication method and database
  /// that were used, and a list of configured
  /// authentication handlers on the server
  ///
  /// Structured response is available in `ServerModelResponse`.
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
  Future<Response> userInfo({bool basic = false});
}
