import 'dart:async';

import 'package:firebase_core/firebase_core.dart';

import '../../domain/entities/item.dart';
import '../../domain/failures/failure.dart';
import '../../domain/repositories/item_repository.dart';
import '../datasources/item_remote_data_source.dart';

/// Reads and writes items through Firestore and reports problems as
/// [Failure]s.
class ItemRepositoryImpl implements ItemRepository {
  /// Creates a repository that uses [remoteDataSource].
  const ItemRepositoryImpl({required this.remoteDataSource});

  /// Where the items live.
  final ItemRemoteDataSource remoteDataSource;

  @override
  Stream<List<Item>> watchItems() {
    return remoteDataSource.watchItems().transform(_failureMapper());
  }

  @override
  Stream<Item?> watchItem(String id) {
    return remoteDataSource.watchItem(id).transform(_failureMapper());
  }

  @override
  Future<void> addItem(ItemDraft draft) {
    return _guard(() => remoteDataSource.addItem(draft));
  }

  @override
  Future<void> claimItem(String id) async {
    final outcome = await _guard(() => remoteDataSource.claimItem(id));
    switch (outcome) {
      case ClaimOutcome.claimed:
        return;
      case ClaimOutcome.alreadyClaimed:
        throw const AlreadyClaimedFailure();
      case ClaimOutcome.notFound:
        throw const ItemNotFoundFailure();
    }
  }

  @override
  Future<void> deleteItem(String id) {
    return _guard(() => remoteDataSource.deleteItem(id));
  }

  @override
  Future<bool> seedItems() {
    return _guard(remoteDataSource.seedItems);
  }

  /// Runs [action] and rethrows anything it throws as a [Failure].
  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } catch (error) {
      throw mapError(error);
    }
  }

  /// Passes data through unchanged and turns every error into a [Failure].
  StreamTransformer<T, T> _failureMapper<T>() {
    return StreamTransformer.fromHandlers(
      handleError: (error, stackTrace, sink) {
        sink.addError(mapError(error), stackTrace);
      },
    );
  }

  /// Converts a raw error into the matching [Failure].
  ///
  /// The codes are listed at
  /// https://firebase.google.com/docs/reference/js/firestore_.firestoreerrorcode
  static Failure mapError(Object error) {
    return switch (error) {
      Failure() => error,
      FirebaseException(code: 'permission-denied' || 'unauthenticated') =>
        const PermissionFailure(),
      FirebaseException(code: 'unavailable' || 'deadline-exceeded') =>
        const NetworkFailure(),
      FirebaseException(code: 'not-found') => const ItemNotFoundFailure(),
      _ => const UnknownFailure(),
    };
  }
}
