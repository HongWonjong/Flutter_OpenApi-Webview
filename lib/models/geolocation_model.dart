/// 이 클래스는 네이버 클라우드 플랫폼에서 제공하는 GeoLocation API의 응답을 모델링한다.
/// 국가 코드, 지역 코드, 시/도, 구/군, 동/면/읍 정보를 담은 모델 클래스이다.
class GeoLocationData {
  final String country;  // 국가 코드
  final String code;     // 지역 코드
  final String r1;       // 시/도
  final String r2;
  final String r3;		 // 동/면/읍

  GeoLocationData({
    required this.country,
    required this.code,
    required this.r1,
    required this.r2,
    required this.r3,

  });

  factory GeoLocationData.fromJson(Map<String, dynamic> json) {
    return GeoLocationData(
      country: json['country'] ?? '',
      code: json['code'] ?? '',
      r1: json['r1'] ?? '',
      r2: json['r2'] ?? '',
      r3: json['r3'] ?? '',
    );
  }
}