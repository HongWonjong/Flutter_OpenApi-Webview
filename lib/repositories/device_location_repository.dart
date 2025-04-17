import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../models/device_location_model.dart';
import '../models/vworld_address_model.dart';
import '../models/vworld_search_result.dart';


class DeviceLocationRepository {
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
      throw Exception('위치 권한이 영구적으로 거부되었습니다.');
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

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
        String query = '행정복지센터', // 기본값: "행정복지센터"
        int radius = 1000,
      }) async {
    final String? apiKey = dotenv.env['VWORLD_API_KEY'];
    if (apiKey == null) {
      throw Exception('VWORLD_API_KEY가 .env 파일에 설정되지 않았습니다.');
    }

    const String baseUrl = 'http://api.vworld.kr/req/search';
    final uri = Uri.parse(
      '$baseUrl?service=search&request=search&version=2.0&query=$query&category=place&point=$longitude,$latitude&radius=$radius&key=$apiKey&format=json',
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
}