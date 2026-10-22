class InstalledUpdateInfo {
  const InstalledUpdateInfo({
    required this.applicationId,
    required this.versionName,
    required this.versionCode,
    required this.supportedAbis,
    required this.sdkInt,
    required this.supported,
  });

  final String applicationId;
  final String versionName;
  final int versionCode;
  final List<String> supportedAbis;
  final int sdkInt;
  final bool supported;
}
