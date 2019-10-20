import 'package:http_parser/http_parser.dart';

import 'error_response.dart';

/// Class representing the complete response from CouchDB
class Response {
  /// Creates instance of [Response] with [raw] and [json]
  Response(Map<String, Object> json,
      {Map<String, String> headers, String raw})
      : json = json,
        raw = raw,
        headers = CaseInsensitiveMap.from(headers);

  /// Field that contain raw body of response
  final String raw;

  /// Field that contain JSON itself in order to grab custom fields
  final Map<String, Object> json;

  /// Headers of response
  final CaseInsensitiveMap<String> headers;

  /// Returns error response if any, otherwise return `null`
  ErrorResponse errorResponse() {
    ErrorResponse e;
    if (isError()) {
      e = ErrorResponse(json['error'] as String, json['reason'] as String);
    }
    return e;
  }

  /// Check if this response is error
  bool isError() => json['error'] != null;

  @override
  String toString() => '''
    json - $json
    raw - $raw
    ''';
}
