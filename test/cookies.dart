// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS link
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE link.
//
// Source: https://github.com/dart-lang/sdk/blob/61c52b30c32beeb56ca8bebd93f9abac3cf4cf1a/sdk/lib/_http/http_impl.dart
// AUTHORS: https://github.com/dart-lang/sdk/blob/61c52b30c32beeb56ca8bebd93f9abac3cf4cf1a/AUTHORS
// LICENSE: https://github.com/dart-lang/sdk/blob/61c52b30c32beeb56ca8bebd93f9abac3cf4cf1a/LICENSE

/// Parses a "Cookie" HTTP header value according to the rules in RFC 6265.
Map<String, String> parseHttpCookieHeader(String headerValue) {
  Map<String, String> cookies = {};

  int index = 0;

  bool done() => index == -1 || index == headerValue.length;

  void skipWS() {
    while (!done()) {
      if (headerValue[index] != " " && headerValue[index] != "\t") {
        return;
      }
      index++;
    }
  }

  String parseName() {
    int start = index;
    while (!done()) {
      if (headerValue[index] == " " ||
          headerValue[index] == "\t" ||
          headerValue[index] == "=") {
        break;
      }
      index++;
    }
    return headerValue.substring(start, index);
  }

  String parseValue() {
    int start = index;
    while (!done()) {
      if (headerValue[index] == " " ||
          headerValue[index] == "\t" ||
          headerValue[index] == ";") {
        break;
      }
      index++;
    }
    return headerValue.substring(start, index);
  }

  bool expect(String expected) {
    if (done()) return false;
    if (headerValue[index] != expected) {
      return false;
    }
    index++;
    return true;
  }

  while (!done()) {
    skipWS();
    if (done()) {
      break;
    }
    String name = parseName();
    skipWS();
    if (!expect("=")) {
      index = headerValue.indexOf(';', index);
      continue;
    }
    skipWS();
    String value = parseValue();
    try {
      cookies[name] = value;
    } catch (_) {
      // Skip it, invalid cookie data.
    }
    skipWS();
    if (done()) {
      break;
    }
    if (!expect(";")) {
      index = headerValue.indexOf(';', index);
      continue;
    }
  }
  return cookies;
}
