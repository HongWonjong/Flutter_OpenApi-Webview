class DeviceLocationData {
  final double latitude;
  final double longitude;
  final String? country;
  final String? region;

  DeviceLocationData({
    required this.latitude,
    required this.longitude,
    this.country,
    this.region,
  });

  factory DeviceLocationData.fromPosition(Map<String, dynamic> position) {
    return DeviceLocationData(
      latitude: position['latitude'] as double,
      longitude: position['longitude'] as double,
      country: position['country'] as String?,
      region: position['region'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
    'country': country,
    'region': region,
  };
}