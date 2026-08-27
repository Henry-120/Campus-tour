enum AccountDataSyncOperation { signIn, registration }

/// Authentication succeeded, but the signed-in user's Firestore-backed data
/// could not be created or loaded.
class AccountDataSyncException implements Exception {
  const AccountDataSyncException({
    required this.operation,
    required this.cause,
    required this.stackTrace,
  });

  final AccountDataSyncOperation operation;
  final Object cause;
  final StackTrace stackTrace;

  @override
  String toString() =>
      'AccountDataSyncException(${operation.name}, cause: $cause)';
}
