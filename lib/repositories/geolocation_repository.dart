import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../models/geolocation_model.dart';

/// GeoLocation API에 직접 요청을 보내는 메서드와 이를 위한 시그니쳐 생성 메서드가 있는 리포지토리.
/// dotenv를 통해 액세스키와 시크릿 키를 가져와서 할당한 후 사용한다.
class GeoLocationRepository {
  final String baseUrl = 'https://geolocation.apigw.ntruss.com/geolocation/v2/geoLocation';
  final String accessKey = dotenv.env['NCP_ACCESS_KEY'] ?? '';
  final String secretKey = dotenv.env['NCP_SECRET_KEY'] ?? '';

  GeoLocationRepository() {
    if (accessKey.isEmpty || secretKey.isEmpty) {
      throw Exception('Access Key or Secret Key is missing in .env file');
    }
  }

  /// 현재 IP 주소를 가져오는 메서드
  Future<String> _getCurrentIp() async {
    try {
      final response = await http.get(Uri.parse('https://api.ipify.org'));
      if (response.statusCode == 200) {
        return response.body; // 예시: 124.52.62.81
      } else {
        throw Exception('Failed to fetch IP address: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching IP: $e');
    }
  }

  /// 현재 IP 주소를 기반으로 GeoLocation 데이터를 가져오는 메서드
  Future<GeoLocationData> fetchGeoLocation() async {
    // 항상 현재 IP를 가져옴
    final targetIp = await _getCurrentIp();

    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final signature = _generateSignature('GET', baseUrl, timestamp, targetIp);

    final response = await http.get(
      Uri.parse('$baseUrl?ip=$targetIp&ext=t&enc=utf8&responseFormatType=json'),
      headers: {
        'x-ncp-apigw-timestamp': timestamp,
        'x-ncp-iam-access-key': accessKey,
        'x-ncp-apigw-signature-v2': signature,
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['geoLocation'] ?? {};
      return GeoLocationData.fromJson(data);
    } else {
      throw Exception('Failed to load geolocation: ${response.statusCode}');
    }
  }

  String _generateSignature(String method, String url, String timestamp, String ip) {
    // 쿼리 파라미터를 포함한 URL 경로 (쿼리 파라미터는 알파벳 순으로 정렬 필요)
    final queryString = 'enc=utf8&ext=t&ip=$ip&responseFormatType=json';
    final urlPath = '/geolocation/v2/geoLocation?$queryString';

    // 시그니처용 문자열 구성
    final stringToSign = '$method $urlPath\n$timestamp\n$accessKey';

    // HMAC-SHA256으로 시그니처 생성
    final key = utf8.encode(secretKey);
    final bytes = utf8.encode(stringToSign);
    final hmacSha256 = Hmac(sha256, key);
    final digest = hmacSha256.convert(bytes);

    // Base64 인코딩
    return base64Encode(digest.bytes);
  }
}