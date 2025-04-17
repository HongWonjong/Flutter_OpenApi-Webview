import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/device_location_model.dart';
import '../models/vworld_address_model.dart';
import '../models/vworld_search_result.dart';


class DeviceLocationRepository {
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
    const double earthRadius = 6378137.0; // 지구 반지름 (미터)
    final double x = longitude * earthRadius * pi / 180;
    final double y = log(tan((90 + latitude) * pi / 360)) * earthRadius;
    return {'x': x, 'y': y};
  }

  // BBox 계산 (중심 좌표와 반경을 기반으로)
  Map<String, double> _calculateBBox(double latitude, double longitude, int radius) {
    final mercator = _wgs84ToMercator(latitude, longitude);
    final double x = mercator['x']!;
    final double y = mercator['y']!;
    // 반경을 기반으로 좌하단(min)과 우상단(max) 좌표 계산
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
    print('Checking if location service is enabled...');
    bool serviceEnabled;
    try {
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
    } catch (e) {
      print('Error checking location service: $e');
      throw Exception('위치 서비스 확인 중 오류 발생: $e');
    }
    if (!serviceEnabled) {
      print('Location service is disabled.');
      throw Exception('위치 서비스가 비활성화되었습니다.');
    }
    print('Location service is enabled.');

    print('Checking location permissions...');
    LocationPermission permission;
    try {
      permission = await Geolocator.checkPermission();
    } catch (e) {
      print('Error checking location permissions: $e');
      throw Exception('위치 권한 확인 중 오류 발생: $e');
    }
    print('Current permission: $permission');
    if (permission == LocationPermission.denied) {
      print('Location permission denied, requesting permission...');
      try {
        permission = await Geolocator.requestPermission();
      } catch (e) {
        print('Error requesting location permission: $e');
        throw Exception('위치 권한 요청 중 오류 발생: $e');
      }
      print('Permission after request: $permission');
      if (permission == LocationPermission.denied) {
        print('Location permission denied after request.');
        throw Exception('위치 권한이 거부되었습니다.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print('Location permission denied forever.');
      try {
        await Geolocator.openAppSettings();
        print('Opened app settings for location permission.');
      } catch (e) {
        print('Error opening app settings: $e');
      }
      throw Exception('위치 권한이 영구적으로 거부되었습니다. 설정에서 권한을 허용해주세요.');
    }

    print('Getting current position...');
    Position position;
    try {
      position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      print('Error getting current position: $e');
      throw Exception('현재 위치를 가져오는 중 오류 발생: $e');
    }

    print('Position retrieved: latitude=${position.latitude}, longitude=${position.longitude}');
    if (!_isValidKoreanCoordinate(position.latitude, position.longitude)) {
      print('Invalid Korean coordinates: latitude=${position.latitude}, longitude=${position.longitude}');
      // 기본값으로 수원 좌표 사용
      print('Falling back to default Suwon coordinates: latitude=37.2636, longitude=127.0286');
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
      print('VWORLD_API_KEY not found in .env');
      throw Exception('VWORLD_API_KEY가 .env 파일에 설정되지 않았습니다.');
    }

    print('Using latitude=$latitude, longitude=$longitude for VWORLD address request');
    const String baseUrl = 'http://api.vworld.kr/req/address';
    final uri = Uri.parse(
      '$baseUrl?service=address&request=getaddress&version=2.0&point=$longitude,$latitude&type=both&key=$apiKey&format=json',
    );

    print('Fetching address from VWORLD API: $uri');
    final response = await http.get(uri);

    print('VWORLD API Response Status: ${response.statusCode}');
    print('VWORLD API Response Body: ${response.body}');
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      print('VWORLD API Response Parsed: $jsonData');
      if (jsonData['response']['status'] != 'OK') {
        print('VWORLD API Error Status: ${jsonData['response']['status']}');
        if (jsonData['response']['error'] != null) {
          print('VWORLD API Error Message: ${jsonData['response']['error']}');
        }
        throw Exception('VWORLD API 응답 오류: ${jsonData['response']['status']}');
      }
      try {
        return VworldAddressData.fromJson(jsonData);
      } catch (e) {
        print('Error parsing VworldAddressData: $e');
        throw Exception('VWORLD 주소 데이터 파싱 오류: $e');
      }
    } else {
      print('VWORLD API Failed with Status Code: ${response.statusCode}');
      throw Exception('VWORLD API 호출 실패: ${response.statusCode}');
    }
  }

  // VWORLD API로 주변 주소 목록 검색
  Future<List<VworldSearchResult>> searchNearbyAddresses(
      double latitude,
      double longitude, {
        String query = '행정복지센터',
        int radius = 1000,
        int size = 10,
        int page = 1,
      }) async {
    final String? apiKey = dotenv.env['VWORLD_API_KEY'];
    if (apiKey == null) {
      print('VWORLD_API_KEY not found in .env');
      throw Exception('VWORLD_API_KEY가 .env 파일에 설정되지 않았습니다.');
    }

    print('Using latitude=$latitude, longitude=$longitude for VWORLD search request');
    // BBox 계산
    final bbox = _calculateBBox(latitude, longitude, radius);
    final double minX = bbox['minX']!;
    final double minY = bbox['minY']!;
    final double maxX = bbox['maxX']!;
    final double maxY = bbox['maxY']!;
    print('Calculated BBox: minX=$minX, minY=$minY, maxX=$maxX, maxY=$maxY');

    print('Search parameters: query=$query, size=$size, page=$page');
    const String baseUrl = 'http://api.vworld.kr/req/search';
    final uri = Uri.parse(
      '$baseUrl?service=search&request=search&version=2.0&crs=EPSG:900913&bbox=$minX,$minY,$maxX,$maxY&size=$size&page=$page&query=$query&type=place&format=json&errorformat=json&key=$apiKey',
    );

    print('Fetching nearby addresses from VWORLD API: $uri');
    final response = await http.get(uri);

    print('VWORLD Search Response Status: ${response.statusCode}');
    print('VWORLD Search Response Body: ${response.body}');
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      print('VWORLD Search Response Parsed: $jsonData');
      if (jsonData['response']['status'] != 'OK') {
        print('VWORLD Search API Error Status: ${jsonData['response']['status']}');
        if (jsonData['response']['error'] != null) {
          print('VWORLD Search API Error Message: ${jsonData['response']['error']}');
        }
        throw Exception('VWORLD 검색 API 응답 오류: ${jsonData['response']['status']}');
      }
      final items = (jsonData['response']['result']['items'] as List<dynamic>?) ?? [];
      print('VWORLD Search Result Items: ${items.length} items found');
      try {
        return items.map((item) => VworldSearchResult.fromJson(item)).toList();
      } catch (e) {
        print('Error parsing VworldSearchResult items: $e');
        throw Exception('VWORLD 검색 결과 데이터 파싱 오류: $e');
      }
    } else {
      print('VWORLD Search API Failed with Status Code: ${response.statusCode}');
      throw Exception('VWORLD 검색 API 호출 실패: ${response.statusCode}');
    }
  }
}