import 'package:couchdb/couchdb.dart';
import 'package:dotenv/dotenv.dart' as dotenv show load, env;
import "package:test/test.dart";

import 'clients.dart';
import 'credentials.dart';
import 'database_names.dart';
import 'document_ids.dart';
import 'mock_http_client.dart';

/// To run the tests, a local .env.test file is required.
/// A sample .env.test.sample file is provided for you to copy into your local
/// environment.
main() {
  dotenv.load('.env.test');

  /// CouchDbClient _factory_
  final clients = Clients();

  final host = dotenv.env['COUCHDB_TEST_HOST'] ?? 'localhost';
  final port = dotenv.env['COUCHDB_TEST_PORT'] ?? 5984;
  final scheme = dotenv.env['COUCHDB_TEST_SCHEME'] ?? 'http';

  /// Mock HTTP client to process API requests
  final _mockHttpClient = MockHttpClient().client;

  final _liveClient = clients.makeClient();

  group('Database names', () {
    databaseValidNames.forEach((dbName) {
      test("Create then delete database: $dbName", () async {
        final database = Database(_liveClient, dbName);
        expect(await database.create(), isA<DatabaseResponse>());
        expect(database.delete(), completion(isA<DatabaseResponse>()));
      });
    });

    databaseInvalidNames.forEach((dbName) {
      test("Should not be able to create database: $dbName", () async {
        final database = Database(_liveClient, dbName);
        expect(() => database.create(), throwsException);
      });
    });
  });

  group("Documents in database name with slash /", () {
    final dbName = 'test/with/slashes/';
    final database = Database(_liveClient, dbName);

    setUp(() async => await database.create());
    tearDown(() async => await database.delete());

    test("Create then delete regular document in database: $dbName", () async {
      final docContent = {
        'some': 'random text',
      };
      final result = await database.createDoc(docContent);
      expect(result, isA<DatabaseResponse>());
      expect(database.documents.deleteDoc(result.id, result.rev),
          completion(isA<DocumentsResponse>()));
    });
  });

  group("Document ids", () {
    final dbNamePrefix =
        dotenv.env['COUCHDB_TEST_DB_PREFIX'] ?? 'couchdb_dart-test';
    final dbName = "${dbNamePrefix}-doc_ids_tests";
    final database = Database(_liveClient, dbName);
    final docs = Documents(_liveClient, dbName);

    // Also possible with current implementation, but not part of [DatabaseInterface]
    //final docs = database.documents;

    setUp(() async => await database.create());
    tearDown(() async => await database.delete());

    documentValidIds.forEach((docId) {
      test("Document: $docId", () async {
        final creation = await docs.insertDoc(docId, {'content': 'test'});
        expect(creation, isA<DocumentsResponse>());
        expect(creation.ok, isTrue);
        expect(creation.id, equals(docId));
        expect(await docs.docExists(docId), isTrue);
        expect(await docs.deleteDoc(docId, creation.rev),
            isA<DocumentsResponse>());
      });
    });
  });

  group("Basic Authentication", () {
    credentials.forEach((username, password) {
      test(
          "Credentials with special characters are properly sent: $username / $password",
          () {
        final mockClient = clients.makeMockClient(username, password);
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
        final mockClient = clients.makeMockClient(username, "wrong-$password");
        expect(() async => await mockClient.authenticate(), throwsException);
      });
    });
  });

  group("Cookie Authentication", () {
    credentials.forEach((username, password) {
      test(
          "Credentials with special characters are properly sent: $username / $password",
          () async {
        final mockClient = clients.makeMockClient(username, password, 'cookie');
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
            clients.makeMockClient(username, "wrong-$password", 'cookie');
        expect(() async => await mockClient.authenticate(), throwsException);
      });
    });
  });
}
