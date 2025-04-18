class VworldAddressData {
  final String roadAddress;
  final String jibunAddress;
  final String administrativeArea;
  final String administrativeSubArea;
  final String postalCode;

  VworldAddressData({
    required this.roadAddress,
    required this.jibunAddress,
    required this.administrativeArea,
    required this.administrativeSubArea,
    required this.postalCode,
  });

  factory VworldAddressData.fromJson(Map<String, dynamic> json) {
    final result = json['response']['result'] is List ? json['response']['result'][0] : {};
    final structure = result['structure'] ?? {};
    return VworldAddressData(
      roadAddress: result['text']?.toString() ?? '',
      jibunAddress: structure['level4L']?.toString() ?? '', // 동/면/읍
      administrativeArea: structure['level1']?.toString() ?? '', // 시/도
      administrativeSubArea: structure['level2']?.toString() ?? '', // 구/군
      postalCode: result['zipcode']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'roadAddress': roadAddress,
    'jibunAddress': jibunAddress,
    'administrativeArea': administrativeArea,
    'administrativeSubArea': administrativeSubArea,
    'postalCode': postalCode,
  };
}