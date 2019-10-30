import 'package:couchdb/couchdb.dart';

abstract class Base {
  /// Instance of connected client
  final ClientInterface client;

  Base(this.client);
}
