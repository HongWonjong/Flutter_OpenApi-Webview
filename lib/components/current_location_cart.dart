import 'package:flutter/material.dart';
import '../models/geolocation_model.dart';

class CurrentLocationCard extends StatelessWidget {
  final GeoLocationData geoLocation;
  final String title;

  const CurrentLocationCard({
    super.key,
    required this.geoLocation,
    this.title = '현재 위치', // 기본값: "현재 위치"
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: SizedBox(
        height: 180,
        width: 180,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title, // 동적으로 전달된 제목 사용
                style: const TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8.0),
              Text(
                '국가: ${geoLocation.country}\n'
                    '지역 코드: ${geoLocation.code}\n'
                    '시/도: ${geoLocation.r1}\n'
                    '구/군: ${geoLocation.r2}\n'
                    '동/면/읍: ${geoLocation.r3}',
                style: const TextStyle(
                  fontSize: 14.0,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}