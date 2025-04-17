import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../components/current_location_cart.dart';
import '../providers/geolocation_provider.dart';

class AddressListPage extends ConsumerWidget {
  const AddressListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 주소 데이터 리스트 (하드코딩)
    final List<Map<String, String>> addresses = [
      {
        'title': '삼성1동 주민센터',
        'address': '서울특별시 강남구 봉은사로 616 삼성1동 주민센터',
      },
      {
        'title': '삼성2동 주민센터',
        'address': '서울특별시 강남구 봉은사로 419 삼성2동주민센터',
      },
      {
        'title': '코엑스',
        'address': '서울특별시 강남구 영동대로 513',
      },
      {
        'title': '코엑스아쿠아리움',
        'address': '서울특별시 강남구 영동대로 513',
      },
      {
        'title': '현대백화점 무역센터점',
        'address': '서울특별시 강남구 테헤란로 517',
      },
    ];

    // GeoLocation 상태 구독
    final geoLocationState = ref.watch(geoLocationProvider).data;

    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 50),
          // 원형 아이콘 버튼을 포함하는 Container
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: '주소 입력',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // 현재 위치 검색 버튼 (원형 아이콘)
                FloatingActionButton(
                  onPressed: () {
                    ref.read(geoLocationProvider.notifier).fetchGeoLocation();
                  },
                  backgroundColor: Colors.purple,
                  child: const Icon(Icons.my_location, color: Colors.white),
                ),
              ],
            ),
          ),
          // API 호출 결과 표시 (현재 위치)
          geoLocationState.when(
            data: (geoLocation) {
              if (geoLocation == null) {
                return const SizedBox.shrink();
              }
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CurrentLocationCard(title: "GeoLocationAPI",geoLocation: geoLocation),
                  CurrentLocationCard(title: "Geolocator",geoLocation: geoLocation)
                ],
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
            error: (error, _) => Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('에러: $error', style: const TextStyle(color: Colors.red)),
            ),
          ),
          // 기존 주소 리스트
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: addresses.length,
              itemBuilder: (context, index) {
                final address = addresses[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16.0),
                  elevation: 2.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          address['title']!,
                          style: const TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          address['address']!,
                          style: const TextStyle(
                            fontSize: 14.0,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      backgroundColor: Colors.purple[50],
    );
  }
}