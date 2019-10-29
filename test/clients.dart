import 'package:couchdb/couchdb.dart';
import 'package:dotenv/dotenv.dart' as dotenv show env;
import 'package:http/http.dart' as http;

import 'credentials.dart';
import 'mock_http_client.dart';

class Clients {
  final host = dotenv.env['COUCHDB_TEST_HOST'] ?? 'localhost';
  final port = dotenv.env['COUCHDB_TEST_PORT'] ?? 5984;
  final scheme = dotenv.env['COUCHDB_TEST_SCHEME'] ?? 'http';

  /// Mock HTTP client to process API requests
  final _mockHttpClient = MockHttpClient().client;

  /// Standard HTTP client
  final _httpClient = http.Client();

  /// To bypass any input validation to not interfere with talking
  /// with the CouchDB server.
  /// The validator is tested separately.
  final _noValidation = PassthruValidator();

  /// Returns a new instance of a client that connects to an actual
  /// CouchDB server.
  CouchDbClient makeClient([String username, String password]) {
    final user = username ?? dotenv.env['COUCHDB_TEST_USERNAME'];
    final pass = password ?? dotenv.env['COUCHDB_TEST_PASSWORD'];

    return CouchDbClient(
      username: user,
      password: pass,
      scheme: scheme,
      host: host,
      port: port,
      httpClient: _httpClient,
      validator: _noValidation,
    );
  }

  /// Returns a new instance of a client that mocks a CouchDB server.
  CouchDbClient makeMockClient(
      [String username, String password, String auth = 'basic']) {
    if (username == null) {
      username = 'admin';
      password = credentials['admin'];
    }
    return CouchDbClient(
      username: username,
      password: password,
      scheme: scheme,
      host: host,
      port: port,
      auth: auth,
      httpClient: _mockHttpClient,
      validator: _noValidation,
    );
  }
}
