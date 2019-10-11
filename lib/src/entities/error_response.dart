import '../responses/error_response.dart' as response;

/// Only provided for backward compatibility
@Deprecated("Use responses/ErrorResponse instead")
class ErrorResponse extends response.ErrorResponse {
  /// Creates [ErrorResponse] instance
  ErrorResponse(String error, String reason) : super(error, reason);
}
