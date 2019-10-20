import 'package:couchdb/src/utils/urls.dart';
import "package:test/test.dart";

main() {
  group("urlEncodePath()", () {
    test("Empty path", () {
      expect(urlEncodePath(''), '/');
    });

    test("Root /", () {
      expect(urlEncodePath('/'), '//');
    });

    test("Single-level path", () {
      expect(urlEncodePath('path'), '/path');
    });

    test("Single-level with trailing slash path/", () {
      expect(urlEncodePath('path/'), '/path/');
    });

    test("Multi-level path/path2/", () {
      expect(urlEncodePath('path/path2/'), '/path/path2/');
    });

    test("Multi-level path/path2/path3", () {
      expect(urlEncodePath('path/path2/path3'), '/path/path2/path3');
    });

    test("With spaces hel lo", () {
      expect(urlEncodePath('hel lo'), '/hel+lo');
    });

    test("Double encodes percents", () {
      expect(urlEncodePath('%25'), '/%2525');
    });
  });
}
