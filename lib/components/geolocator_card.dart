import 'package:flutter/material.dart';
import '../models/device_location_model.dart';

class GeolocatorCard extends StatelessWidget {
  final DeviceLocationData deviceLocation;
  final String title;

  const GeolocatorCard({
    super.key,
    required this.deviceLocation,
    this.title = 'Geolocator 위치', // 기본값
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              '위도: ${deviceLocation.latitude}\n'
                  '경도: ${deviceLocation.longitude}\n'
                  '국가: ${deviceLocation.country ?? '알 수 없음'}\n'
                  '지역: ${deviceLocation.region ?? '알 수 없음'}',
              style: const TextStyle(
                fontSize: 14.0,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}