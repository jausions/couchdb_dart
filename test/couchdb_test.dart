import 'package:couchdb/couchdb.dart';
import 'package:dotenv/dotenv.dart' as dotenv show load, env;
import 'package:http/http.dart' as http;
import "package:test/test.dart";

import 'credentials.dart';
import 'mock_http_client.dart';

/// To run the tests, a local .env.test file is required.
/// A sample .env.test.sample file is provided for you to copy into your local
/// environment.
main() {
  dotenv.load('.env.test');

  final dbName = dotenv.env['COUCHDB_TEST_DB'] ?? 'couchdb_dart-test';
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

  CouchDbClient _makeClient([String username, String password]) {
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

  CouchDbClient _makeMockClient(String username, String password,
      [String auth = 'basic']) {
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

  final client = _makeClient();
  final server = Server(client);
  final database = server.database(dbName);
  final designDocs = database.designDocuments;
  final docs = database.documents;
  final localDocs = database.localDocuments;

  group("Server operations", () {
    test("_all_dbs", () async {
      final result = await server.allDbs(startKey: '_users', endKey: '_users');
      expect(result, isList);
      expect(result.contains('_users'), isTrue);
    });

    test("_dbs_info", () async {
      final result = await server.dbsInfo(['_users']);
      expect(result, isA<ServerResponse>());
      expect(result.list.length, equals(1));
    });
  });

  group("Database operations", () {
    test("Create then delete database", () async {
      expect(await database.create(), isA<DatabaseResponse>());
      expect(database.delete(), completion(isA<DatabaseResponse>()));
    });

    test("_users database exists", () {
      final usersDb = Database(client, '_users');
      expect(usersDb.exists(), completion(isTrue));
    });

    test("Fake database does not exist", () {
      final unknownDb =
          Database(client, '_unknown_db_520b0dde-82b6-4da7-94eb-ab61233acafa');
      expect(unknownDb.exists(), completion(isFalse));
    });
  });

  group("Document operations", () {
    setUp(() async => await database.create());
    tearDown(() async => await database.delete());

    test("Create then delete document", () async {
      final doc = await docs.insertDoc("my_test_doc", {'centent': "blank"});
      expect(doc, isA<DocumentsResponse>());
      expect(docs.deleteDoc(doc.id, doc.rev), completion(isA<DocumentsResponse>()));
    });
  });

  group("Basic Authentication", () {
    credentials.forEach((username, password) {
      test(
          "Credentials with special characters are properly sent: $username / $password",
          () {
        final mockClient = _makeMockClient(username, password);
        final server = Server(mockClient);
        expect(server.allDbs(), completion(isA<List<String>>()));
      });

      test(
          ".fromUri(): Credentials with special characters are properly sent: $username / $password",
          () {
        final uri = Uri(
          scheme: scheme,
          userInfo:
              "${Uri.encodeQueryComponent(username)}:${Uri.encodeQueryComponent(password)}",
          host: host,
          port: port,
        );
        final mockClient =
            CouchDbClient.fromUri(uri, httpClient: _mockHttpClient);
        final server = Server(mockClient);
        expect(server.allDbs(), completion(isA<List<String>>()));
      });

      test(
          ".fromString(): Credentials with special characters are properly sent: $username / $password",
          () {
        final userInfo =
            "${Uri.encodeQueryComponent(username)}:${Uri.encodeQueryComponent(password)}";
        final uri = "$scheme://$userInfo@$host:$port";
        final mockClient =
            CouchDbClient.fromString(uri, httpClient: _mockHttpClient);
        final server = Server(mockClient);
        expect(server.allDbs(), completion(isA<List<String>>()));
      });
    });

    /// This test checks that our mock server detects wrong passwords.
    test("The mock client detects wrong passwords", () async {
      await Future.forEach(credentials.keys, (username) async {
        final password = credentials[username];
        final mockClient = _makeMockClient(username, "wrong-$password");
        expect(() async => await mockClient.authenticate(), throwsException);
      });
    });
  });

  group("Cookie Authentication", () {
    credentials.forEach((username, password) {
      test(
          "Credentials with special characters are properly sent: $username / $password",
          () async {
        final mockClient = _makeMockClient(username, password, 'cookie');
        expect(await mockClient.authenticate(), isA<Response>());
        final server = Server(mockClient);
        expect(server.allDbs(), completion(isA<List<String>>()));
      });

      test(
          ".fromUri(): Credentials with special characters are properly sent: $username / $password",
          () async {
        final uri = Uri(
          scheme: scheme,
          userInfo:
              "${Uri.encodeQueryComponent(username)}:${Uri.encodeQueryComponent(password)}",
          host: host,
          port: port,
        );
        final mockClient = CouchDbClient.fromUri(uri,
            httpClient: _mockHttpClient, auth: 'cookie');
        expect(await mockClient.authenticate(), isA<Response>());
        final server = Server(mockClient);
        expect(server.allDbs(), completion(isA<List<String>>()));
      });

      test(
          ".fromString(): Credentials with special characters are properly sent: $username / $password",
          () async {
        final userInfo =
            "${Uri.encodeQueryComponent(username)}:${Uri.encodeQueryComponent(password)}";
        final uri = "$scheme://$userInfo@$host:$port";
        final mockClient = CouchDbClient.fromString(uri,
            httpClient: _mockHttpClient, auth: 'cookie');
        expect(await mockClient.authenticate(), isA<Response>());
        final server = Server(mockClient);
        expect(server.allDbs(), completion(isA<List<String>>()));
      });
    });

    /// This test checks that our mock server detects wrong passwords.
    /// If we don't do that type of test we won't know if the mock server
    /// knows the difference between right and wrong passwords.
    test("The mock client detects wrong passwords", () async {
      await Future.forEach(credentials.keys, (username) async {
        final password = credentials[username];
        final mockClient =
            _makeMockClient(username, "wrong-$password", 'cookie');
        expect(() async => await mockClient.authenticate(), throwsException);
      });
    });
  });
}
