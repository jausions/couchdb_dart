/// Converts URL query params from map to a string.
/// The result neither starts with ? nor &.
///
/// > Note that this function does not support repeated
/// > keys.
String queryStringFromMap(Map<String, Object> queryParams) {
  return queryParams.keys.fold('', (queryString, key) {
    final glue = (queryString.isEmpty) ? '' : '&';
    return "$queryString$glue${Uri.encodeQueryComponent(key)}"
        '=${Uri.encodeQueryComponent(queryParams[key].toString())}';
  });
}

/// URL encode each element of a path and prefix with a slash `/`
String urlEncodePath(String path) => path.split('/').fold(
    '', (pathUrl, pathPart) => "$pathUrl/${Uri.encodeQueryComponent(pathPart)}");
