enum ArSupportStatus {
  ready,
  checking,
  installationRequested,
  unsupportedDevice,
  permissionDenied,
  permissionPermanentlyDenied,
  restricted,
  unavailablePlatform,
  error,
}

class ArSupportResult {
  const ArSupportResult(this.status, {this.details});

  final ArSupportStatus status;
  final String? details;

  bool get canStart => status == ArSupportStatus.ready;
  bool get canRetry => switch (status) {
    ArSupportStatus.checking ||
    ArSupportStatus.installationRequested ||
    ArSupportStatus.permissionDenied ||
    ArSupportStatus.error => true,
    _ => false,
  };
  bool get canOpenSettings =>
      status == ArSupportStatus.permissionPermanentlyDenied;
}

abstract interface class ArSupportService {
  Future<ArSupportResult> prepare();
}
