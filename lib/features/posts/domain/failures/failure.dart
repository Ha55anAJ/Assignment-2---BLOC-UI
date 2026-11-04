/// A domain-level error.
///
/// The data layer converts every raw exception (sockets, status codes, bad
/// JSON) into one of these, so the presentation layer never has to know where
/// an error came from.
sealed class Failure implements Exception {
  /// Creates a failure with a message that is safe to show to the user.
  const Failure(this.message);

  /// A human-readable explanation of what went wrong.
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// The device could not reach the server, for example because it is offline.
class NetworkFailure extends Failure {
  /// Creates a [NetworkFailure].
  const NetworkFailure()
    : super('Check your internet connection and try again.');
}

/// The server answered, but with an error.
class ServerFailure extends Failure {
  /// Creates a [ServerFailure].
  const ServerFailure()
    : super(
        'The server had a problem handling the request. Try again in a moment.',
      );
}

/// The server answered, but the response was not in the expected shape.
class DataFailure extends Failure {
  /// Creates a [DataFailure].
  const DataFailure()
    : super('The posts came back in a format we could not read.');
}

/// Anything else that went wrong.
class UnknownFailure extends Failure {
  /// Creates an [UnknownFailure].
  const UnknownFailure() : super('Something unexpected happened.');
}
