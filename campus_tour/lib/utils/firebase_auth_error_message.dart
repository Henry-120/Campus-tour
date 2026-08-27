import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'account_data_sync_exception.dart';

String firebaseAuthErrorMessage(Object error) {
  if (error is PlatformException) {
    return _platformAuthErrorMessage(error);
  }
  if (error is! FirebaseAuthException) {
    return 'utils.firebase.auth.error.message.s001'.tr;
  }

  return switch (error.code) {
    'invalid-email' => 'utils.firebase.auth.error.message.s014'.tr,
    'missing-email' => 'utils.firebase.auth.error.message.s031'.tr,
    'missing-password' => 'utils.firebase.auth.error.message.s015'.tr,
    'weak-password' => 'utils.firebase.auth.error.message.s016'.tr,
    'password-does-not-meet-requirements' =>
      'utils.firebase.auth.error.message.s032'.tr,
    'user-not-found' => 'utils.firebase.auth.error.message.s017'.tr,
    'wrong-password' ||
    'invalid-credential' => 'utils.firebase.auth.error.message.s018'.tr,
    'email-already-in-use' => 'utils.firebase.auth.error.message.s019'.tr,
    'account-exists-with-different-credential' =>
      'utils.firebase.auth.error.message.s020'.tr,
    'provider-already-linked' => 'utils.firebase.auth.error.message.s021'.tr,
    'credential-already-in-use' => 'utils.firebase.auth.error.message.s022'.tr,
    'requires-recent-login' => 'utils.firebase.auth.error.message.s023'.tr,
    'too-many-requests' => 'utils.firebase.auth.error.message.s007'.tr,
    'network-request-failed' => 'utils.firebase.auth.error.message.s006'.tr,
    'operation-not-allowed' => 'utils.firebase.auth.error.message.s024'.tr,
    'user-disabled' => 'utils.firebase.auth.error.message.s025'.tr,
    'user-token-expired' ||
    'invalid-user-token' => 'utils.firebase.auth.error.message.s026'.tr,
    'invalid-api-key' ||
    'app-not-authorized' ||
    'invalid-app-credential' => 'utils.firebase.auth.error.message.s027'.tr,
    'quota-exceeded' => 'utils.firebase.auth.error.message.s028'.tr,
    'internal-error' => 'utils.firebase.auth.error.message.s029'.tr,
    'google-sign-in-cancelled' => 'utils.firebase.auth.error.message.s033'.tr,
    'google-account-mismatch' => 'utils.firebase.auth.error.message.s038'.tr,
    _ => 'utils.firebase.auth.error.message.s030'.tr,
  };
}

bool isGoogleSignInCancellation(Object error) {
  final code = _normalizedErrorCode(error);
  return const {
    'canceled',
    'cancelled',
    'sign-in-canceled',
    'sign-in-cancelled',
    'google-sign-in-cancelled',
  }.contains(code);
}

String googleAuthErrorMessage(Object error) {
  if (isGoogleSignInCancellation(error)) {
    return 'utils.firebase.auth.error.message.s033'.tr;
  }

  if (error is PlatformException) {
    final code = _normalizedErrorCode(error);
    if (code == 'network-error' || code == 'network-request-failed') {
      return 'utils.firebase.auth.error.message.s006'.tr;
    }
    if (code == 'sign-in-required') {
      return 'utils.firebase.auth.error.message.s056'.tr;
    }
    if (code == 'developer-error' ||
        code == '10' ||
        _hasGoogleConfigurationSignal(error)) {
      return 'utils.firebase.auth.error.message.s034'.tr;
    }
    return 'utils.firebase.auth.error.message.s035'.tr;
  }

  if (error is FirebaseAuthException) {
    return switch (error.code) {
      'invalid-credential' ||
      'invalid-oauth-response' => 'utils.firebase.auth.error.message.s036'.tr,
      'operation-not-allowed' => 'utils.firebase.auth.error.message.s037'.tr,
      _ => firebaseAuthErrorMessage(error),
    };
  }

  return 'utils.firebase.auth.error.message.s035'.tr;
}

bool isAppleSignInCancellation(Object error) {
  final code = _normalizedErrorCode(error);
  return const {
    'canceled',
    'cancelled',
    'web-context-canceled',
    'popup-closed-by-user',
    'cancelled-popup-request',
  }.contains(code);
}

String appleAuthErrorMessage(Object error) {
  if (isAppleSignInCancellation(error)) {
    return 'utils.firebase.auth.error.message.s002'.tr;
  }
  if (error is! FirebaseAuthException) {
    return 'utils.firebase.auth.error.message.s011'.tr;
  }

  return switch (error.code) {
    'account-exists-with-different-credential' =>
      'utils.firebase.auth.error.message.s003'.tr,
    'credential-already-in-use' ||
    'email-already-in-use' => 'utils.firebase.auth.error.message.s004'.tr,
    'provider-already-linked' => 'utils.firebase.auth.error.message.s012'.tr,
    'user-not-found' => 'utils.firebase.auth.error.message.s013'.tr,
    'operation-not-allowed' => 'utils.firebase.auth.error.message.s005'.tr,
    'network-request-failed' => 'utils.firebase.auth.error.message.s006'.tr,
    'too-many-requests' => 'utils.firebase.auth.error.message.s007'.tr,
    'invalid-credential' ||
    'invalid-oauth-response' => 'utils.firebase.auth.error.message.s008'.tr,
    'unauthorized-domain' => 'utils.firebase.auth.error.message.s009'.tr,
    'web-context-already-present' =>
      'utils.firebase.auth.error.message.s010'.tr,
    'popup-blocked' => 'utils.firebase.auth.error.message.s053'.tr,
    'web-storage-unsupported' => 'utils.firebase.auth.error.message.s055'.tr,
    'requires-recent-login' => 'utils.firebase.auth.error.message.s023'.tr,
    'user-disabled' => 'utils.firebase.auth.error.message.s025'.tr,
    'user-token-expired' ||
    'invalid-user-token' => 'utils.firebase.auth.error.message.s026'.tr,
    'invalid-api-key' ||
    'app-not-authorized' ||
    'invalid-app-credential' ||
    'invalid-oauth-client-id' ||
    'invalid-provider-id' => 'utils.firebase.auth.error.message.s054'.tr,
    'internal-error' => 'utils.firebase.auth.error.message.s029'.tr,
    _ => 'utils.firebase.auth.error.message.s011'.tr,
  };
}

String accountAuthErrorMessage(Object error) {
  if (error is! FirebaseAuthException) {
    return firebaseAuthErrorMessage(error);
  }

  return switch (error.code) {
    'user-not-found' => 'utils.firebase.auth.error.message.s039'.tr,
    'provider-already-linked' => 'utils.firebase.auth.error.message.s040'.tr,
    _ => firebaseAuthErrorMessage(error),
  };
}

String accountDataSyncErrorMessage(Object error) {
  final syncError = error is AccountDataSyncException ? error : null;
  final cause = syncError?.cause ?? error;
  final detail = _firestoreErrorDetail(cause);
  final key = syncError?.operation == AccountDataSyncOperation.registration
      ? 'utils.firebase.auth.error.message.s042'
      : 'utils.firebase.auth.error.message.s041';
  return key.trParams({'detail': detail});
}

String _firestoreErrorDetail(Object error) {
  if (error is! FirebaseException) {
    return 'utils.firebase.auth.error.message.s052'.tr;
  }

  return switch (error.code) {
    'permission-denied' => 'utils.firebase.auth.error.message.s043'.tr,
    'unavailable' ||
    'cancelled' ||
    'aborted' => 'utils.firebase.auth.error.message.s044'.tr,
    'deadline-exceeded' => 'utils.firebase.auth.error.message.s045'.tr,
    'unauthenticated' => 'utils.firebase.auth.error.message.s046'.tr,
    'resource-exhausted' => 'utils.firebase.auth.error.message.s047'.tr,
    'not-found' => 'utils.firebase.auth.error.message.s048'.tr,
    'failed-precondition' => 'utils.firebase.auth.error.message.s049'.tr,
    'data-loss' => 'utils.firebase.auth.error.message.s050'.tr,
    'internal' || 'unknown' => 'utils.firebase.auth.error.message.s051'.tr,
    _ => 'utils.firebase.auth.error.message.s052'.tr,
  };
}

String _platformAuthErrorMessage(PlatformException error) {
  final code = _normalizedErrorCode(error);
  if (isGoogleSignInCancellation(error)) {
    return 'utils.firebase.auth.error.message.s033'.tr;
  }
  if (code == 'network-error' || code == 'network-request-failed') {
    return 'utils.firebase.auth.error.message.s006'.tr;
  }
  return 'utils.firebase.auth.error.message.s030'.tr;
}

String _normalizedErrorCode(Object error) {
  final rawCode = switch (error) {
    FirebaseAuthException() => error.code,
    PlatformException() => error.code,
    _ => '',
  };
  return rawCode.trim().toLowerCase().replaceAll('_', '-');
}

bool _hasGoogleConfigurationSignal(PlatformException error) {
  final details = '${error.message ?? ''} ${error.details ?? ''}'.toLowerCase();
  return details.contains('developer_error') ||
      details.contains('code: 10') ||
      details.contains('apiexception: 10') ||
      details.contains('client id') ||
      details.contains('clientid') ||
      details.contains('url scheme') ||
      details.contains('configuration');
}
