/// A domain-level error.
///
/// The data layer converts every raw exception (Firebase error codes, bad
/// documents, transaction outcomes) into one of these, so the presentation
/// layer never has to know where an error came from.
sealed class Failure implements Exception {
  /// Creates a failure with a message that is safe to show to the user.
  const Failure(this.message);

  /// A human-readable explanation of what went wrong.
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// Firestore could not be reached, for example because the device is offline.
class NetworkFailure extends Failure {
  /// Creates a [NetworkFailure].
  const NetworkFailure()
    : super('Couldn’t reach the server. Check your connection and try again.');
}

/// The Firestore security rules rejected the request.
class PermissionFailure extends Failure {
  /// Creates a [PermissionFailure].
  const PermissionFailure() : super('You don’t have permission to do that.');
}

/// The item no longer exists, usually because someone deleted it.
class ItemNotFoundFailure extends Failure {
  /// Creates an [ItemNotFoundFailure].
  const ItemNotFoundFailure()
    : super('This item no longer exists. It may have been deleted.');
}

/// Someone else marked the item as claimed first.
class AlreadyClaimedFailure extends Failure {
  /// Creates an [AlreadyClaimedFailure].
  const AlreadyClaimedFailure()
    : super('Someone has already marked this item as claimed.');
}

/// Anything else that went wrong.
class UnknownFailure extends Failure {
  /// Creates an [UnknownFailure].
  const UnknownFailure() : super('Something unexpected happened.');
}
