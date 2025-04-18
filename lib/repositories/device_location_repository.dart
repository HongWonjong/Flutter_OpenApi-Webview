import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/device_location_model.dart';
import '../models/vworld_address_model.dart';
import '../models/vworld_search_result.dart';

class DeviceLocationRepository {
  final Dio _dio = Dio();

  // 한국 좌표 범위 확인
  bool _isValidKoreanCoordinate(double latitude, double longitude) {
    const double minLatitude = 33.0;
    const double maxLatitude = 38.5;
    const double minLongitude = 124.5;
    const double maxLongitude = 132.0;

    return latitude >= minLatitude &&
        latitude <= maxLatitude &&
        longitude >= minLongitude &&
        longitude <= maxLongitude;
  }

  // WGS84 좌표를 EPSG:900913 (Mercator) 좌표로 변환
  Map<String, double> _wgs84ToMercator(double latitude, double longitude) {
    const double earthRadius = 6378137.0;
    final double x = longitude * earthRadius * pi / 180;
    final double y = log(tan((90 + latitude) * pi / 360)) * earthRadius;
    return {'x': x, 'y': y};
  }

  // BBox 계산
  Map<String, double> _calculateBBox(double latitude, double longitude, int radius) {
    final mercator = _wgs84ToMercator(latitude, longitude);
    final double x = mercator['x']!;
    final double y = mercator['y']!;
    final double minX = x - radius;
    final double minY = y - radius;
    final double maxX = x + radius;
    final double maxY = y + radius;
    return {
      'minX': minX,
      'minY': minY,
      'maxX': maxX,
      'maxY': maxY,
    };
  }

  // Geolocator로 디바이스 위치 가져오기
  Future<DeviceLocationData> getDeviceLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('위치 서비스가 비활성화되었습니다.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('위치 권한이 거부되었습니다.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      await Geolocator.openAppSettings();
      throw Exception('위치 권한이 영구적으로 거부되었습니다. 설정에서 권한을 허용해주세요.');
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    if (!_isValidKoreanCoordinate(position.latitude, position.longitude)) {
      return DeviceLocationData(
        latitude: 37.2636,
        longitude: 127.0286,
        country: '대한민국',
        region: '수원시',
      );
    }

    return DeviceLocationData(
      latitude: position.latitude,
      longitude: position.longitude,
      country: '대한민국',
      region: null,
    );
  }

  // VWORLD API로 주소 가져오기
  Future<VworldAddressData> getAddressFromVworld(double latitude, double longitude) async {
    final String? apiKey = dotenv.env['VWORLD_API_KEY'];
    if (apiKey == null) {
      throw Exception('VWORLD_API_KEY가 .env 파일에 설정되지 않았습니다.');
    }

    const String baseUrl = 'http://api.vworld.kr/req/address';
    final uri = Uri.parse(
      '$baseUrl?service=address&request=getaddress&version=2.0&point=$longitude,$latitude&type=both&key=$apiKey&format=json',
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      if (jsonData['response']['status'] != 'OK') {
        throw Exception('VWORLD API 응답 오류: ${jsonData['response']['status']}');
      }
      return VworldAddressData.fromJson(jsonData);
    } else {
      throw Exception('VWORLD API 호출 실패: ${response.statusCode}');
    }
  }

  // VWORLD API로 주변 주소 목록 검색
  Future<List<VworldSearchResult>> searchNearbyAddresses(
      double latitude,
      double longitude, {
        String query = '',
        int radius = 1000,
        int size = 10,
        int page = 1,
      }) async {
    final String? apiKey = dotenv.env['VWORLD_API_KEY'];
    if (apiKey == null) {
      throw Exception('VWORLD_API_KEY가 .env 파일에 설정되지 않았습니다.');
    }

    final bbox = _calculateBBox(latitude, longitude, radius);
    final double minX = bbox['minX']!;
    final double minY = bbox['minY']!;
    final double maxX = bbox['maxX']!;
    final double maxY = bbox['maxY']!;

    const String baseUrl = 'http://api.vworld.kr/req/search';
    final uri = Uri.parse(
      '$baseUrl?service=search&request=search&version=2.0&crs=EPSG:900913&bbox=$minX,$minY,$maxX,$maxY&size=$size&page=$page&query=$query&type=place&format=json&errorformat=json&key=$apiKey',
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      if (jsonData['response']['status'] != 'OK') {
        throw Exception('VWORLD 검색 API 응답 오류: ${jsonData['response']['status']}');
      }
      final items = (jsonData['response']['result']['items'] as List<dynamic>?) ?? [];
      return items.map((item) => VworldSearchResult.fromJson(item)).toList();
    } else {
      throw Exception('VWORLD 검색 API 호출 실패: ${response.statusCode}');
    }
  }
  // 네이버 지역검색 API로 첫 번째 유효한 URL 가져오기
  Future<String?> getNaverLocalSearchUrl(String query) async {
    final String? clientId = dotenv.env['NAVER_CLIENT_ID'];
    final String? clientSecret = dotenv.env['NAVER_CLIENT_SECRET'];
    if (clientId == null || clientSecret == null) {
      throw Exception('NAVER_CLIENT_ID 또는 NAVER_CLIENT_SECRET이 .env 파일에 설정되지 않았습니다.');
    }

    try {
      final response = await _dio.get(
        'https://openapi.naver.com/v1/search/local.json',
        queryParameters: {
          'query': query,
          'display': 1, // 최대 5개 결과 가져와서 유효한 링크 찾기
          'sort': 'random',
        },
        options: Options(
          headers: {
            'X-Naver-Client-Id': clientId,
            'X-Naver-Client-Secret': clientSecret,
          },
        ),
      );

      if (response.statusCode == 200) {
        final jsonData = response.data;
        print('네이버 지역검색 응답: $jsonData');

        if (jsonData['items'] is List && jsonData['items'].isNotEmpty) {
          for (var item in jsonData['items']) {
            if (item['link'] is String && item['link'].isNotEmpty) {
              return item['link'] as String; // 첫 번째 유효한 링크 반환
            }
          }
        }
        return null; // 유효한 링크 없음
      } else {
        throw Exception('네이버 지역검색 API 호출 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('네이버 검색 오류: $e');
      throw Exception('네이버 지역검색 중 오류 발생: $e');
    }
  }
}