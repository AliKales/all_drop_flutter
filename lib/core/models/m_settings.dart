class MSettings {
  int? minByte;
  int? version;

  MSettings({
    this.minByte,
    this.version,
  });

  factory MSettings.fromJson(Map<String, dynamic> json) {
    return MSettings(
      minByte: json['minByte'] as int?,
      version: json['version'] as int?,
    );
  }
}