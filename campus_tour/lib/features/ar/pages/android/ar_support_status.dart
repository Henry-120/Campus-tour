enum AndroidArSupportStatus {
  supportedInstalled,
  supportedNotInstalled,
  supportedApkTooOld,
  unsupportedDevice,
  checking,
  error;

  factory AndroidArSupportStatus.fromPlatformValue(String? value) {
    return switch (value) {
      'SUPPORTED_INSTALLED' => supportedInstalled,
      'SUPPORTED_NOT_INSTALLED' => supportedNotInstalled,
      'SUPPORTED_APK_TOO_OLD' => supportedApkTooOld,
      'UNSUPPORTED_DEVICE_NOT_CAPABLE' => unsupportedDevice,
      'UNKNOWN_CHECKING' => checking,
      _ => error,
    };
  }

  bool get needsInstall =>
      this == supportedNotInstalled || this == supportedApkTooOld;
}
