import 'package:cloud_functions/cloud_functions.dart';

class AccountDeletionService {
  AccountDeletionService({FirebaseFunctions? functions})
    : _functions =
          functions ?? FirebaseFunctions.instanceFor(region: 'asia-east1');

  final FirebaseFunctions _functions;

  Future<void> deleteCurrentAccountData() async {
    final result = await _functions.httpsCallable('deleteMyAccount').call();
    final data = result.data;

    if (data is! Map || data['success'] != true) {
      throw FirebaseFunctionsException(
        code: 'invalid-response',
        message: 'The account deletion service returned an invalid response.',
      );
    }
  }
}
