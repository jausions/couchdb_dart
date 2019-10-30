import 'package:couchdb/couchdb.dart';
import 'package:dotenv/dotenv.dart' as dotenv show load, env;
import "package:test/test.dart";

import 'clients.dart';

/// To run the tests, a local .env.test file is required.
/// A sample .env.test.sample file is provided for you to copy into your local
/// environment.
main() {
  dotenv.load('.env.test');

  /// CouchDbClient _factory_
  final clients = Clients();

  final dbNamePrefix =
      dotenv.env['COUCHDB_TEST_DB_PREFIX'] ?? 'couchdb_dart-test';

  final _liveClient = clients.makeClient();

  group("Server operations", () {
    final server = Server(_liveClient);

    test("/", () async {
      final result = await server.couchDbInfo();
      expect(result, isA<ServerResponse>());
      expect(result.version, isNotEmpty);
    });

    test("/_active_tasks", () {
      expect(server.activeTasks(), completion(isA<ServerResponse>()));
    });

    test("/_all_dbs", () async {
      final result = await server.allDbs(startKey: '_users', endKey: '_users');
      expect(result, isList);
      expect(result.contains('_users'), isTrue);
    });

    test("/_dbs_info", () async {
      final result = await server.dbsInfo(['_users']);
      expect(result, isA<ServerResponse>());
      expect(result.list.length, equals(1));
    });

    test("/_db_updates", () {
      expect(server.dbUpdates(), completion(isA<ServerResponse>()));
    });

    test("/_membership", () {
      expect(server.membership(), completion(isA<ServerResponse>()));
    });

    test("/_scheduler/jobs", () {
      expect(server.schedulerJobs(), completion(isA<ServerResponse>()));
    });

    test("/_scheduler/docs", () {
      expect(server.schedulerDocs(), completion(isA<ServerResponse>()));
    });

    test("/_up", () async {
      final result = await server.up();
      expect(result, isA<ServerResponse>());
      expect(result.status, equals('ok'));
    });

    test("/_uuids", () async {
      final result = await server.uuids(count: 5);
      expect(result, isList);
      expect(result.length, equals(5));
    });

    test("/_uuids/?count=0", () async {
      final result = await server.uuids(count: 0);
      expect(result, isList);
      expect(result, isEmpty);
    });
  });

  group("Database existence", () {
    final database =
        Database(_liveClient, "${dbNamePrefix}-db_existence_tests");

    test("Create then delete database", () async {
      expect(await database.create(), isA<DatabaseResponse>());
      expect(await database.delete(), isA<DatabaseResponse>());
    });

    test("_users database exists", () {
      final usersDb = Database(_liveClient, '_users');
      expect(usersDb.exists(), completion(isTrue));
    });

    test("Fake database does not exist", () {
      final unknownDb = Database(
          _liveClient, '_unknown_db_520b0dde-82b6-4da7-94eb-ab61233acafa');
      expect(unknownDb.exists(), completion(isFalse));
    });
  });

  group("Database operations", () {
    final _usersDb = Database(_liveClient, '_users');

    test("/_users HEAD", () async {
      final result = await _usersDb.headersInfo();
      expect(result, isMap);
    });

    test("/_users GET", () async {
      final info = await _usersDb.info();
      expect(info, isA<DatabaseResponse>());
      expect(info.dbName, equals('_users'));
    });

    test('/_users/_all_docs', () async {
      final result = await _usersDb.allDocs();
      expect(result, isA<DatabaseResponse>());
    });
  });

  group("Document operations", () {
    final database =
        Database(_liveClient, "${dbNamePrefix}-doc_operations_tests");
    final docs = database.documents;

    setUp(() async => await database.create());
    tearDown(() async => await database.delete());

    test("Create then delete document", () async {
      final doc = await docs.insertDoc("my_test_doc", {'content': "blank"});
      expect(doc, isA<DocumentsResponse>());
      expect(docs.deleteDoc(doc.id, doc.rev),
          completion(isA<DocumentsResponse>()));
    });

    test('List all documents', () async {
      await docs.insertDoc("my_test_all_docs", {'test': true});
      final result = await database.allDocs();
      expect(result, isA<DatabaseResponse>());
      expect(result.totalRows, equals(1));
      expect(result.rows, isNotEmpty);
      expect(result.rows[0].containsKey('id'), isTrue);
      expect(result.rows[0]['id'], equals('my_test_all_docs'));
    });
  });
}
