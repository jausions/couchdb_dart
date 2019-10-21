import 'package:couchdb/couchdb.dart';

import 'base.dart';

mixin HttpMixin on Base {
  Future<bool> httpHeadExists(String path, Map<String, String> headers) async {
    try {
      await client.head(path, reqHeaders: headers);
    } on CouchDbException catch (e) {
      if (e.code != 404) {
        rethrow;
      }
      return false;
    }
    return true;
  }
}