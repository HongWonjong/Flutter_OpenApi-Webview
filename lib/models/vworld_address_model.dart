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
    final result = json['response']['result']['structure'] ?? {};
    return VworldAddressData(
      roadAddress: result['text'] ?? '',
      jibunAddress: result['jibun'] ?? '',
      administrativeArea: result['sido'] ?? '',
      administrativeSubArea: result['sigungu'] ?? '',
      postalCode: result['zipcode'] ?? '',
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