class MSettings {
  int? minByte;
  int? version;
  final bool? isAvailable;

  MSettings({
    this.minByte,
    this.version,
    this.isAvailable,
  });

  factory MSettings.fromJson(Map<String, dynamic> json) {
    return MSettings(
      minByte: json['minByte'] as int?,
      version: json['versionAndroid'] as int?,
      isAvailable: json['available'] as bool?,
    );
  }
}
