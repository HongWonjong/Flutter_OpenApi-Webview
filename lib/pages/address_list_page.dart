import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../components/current_location_cart.dart';
import '../components/geolocator_card.dart';
import '../components/address_list_view.dart';
import '../models/device_location_model.dart';
import '../models/geolocation_model.dart';
import '../models/vworld_search_result.dart';
import '../providers/device_location_provider.dart';
import '../providers/geolocation_provider.dart';

class AddressListPage extends ConsumerStatefulWidget {
  const AddressListPage({super.key});

  @override
  ConsumerState<AddressListPage> createState() => _AddressListPageState();
}

class _AddressListPageState extends ConsumerState<AddressListPage> {
  final TextEditingController _titleController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // GeoLocation 상태 구독 (GeoLocationAPI)
    final geoLocationState = ref.watch(geoLocationProvider).data;
    // DeviceLocation 상태 구독 (Geolocator 및 VWORLD)
    final deviceLocationState = ref.watch(deviceLocationProvider);

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
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: '위치 제목 입력',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // 현재 위치 검색 버튼 (원형 아이콘)
                FloatingActionButton(
                  onPressed: () {
                    // GeoLocationAPI 데이터 가져오기
                    ref.read(geoLocationProvider.notifier).fetchGeoLocation();
                    // Geolocator 및 VWORLD 데이터 가져오기
                    ref.read(deviceLocationProvider.notifier).fetchLocationAndAddress();
                  },
                  backgroundColor: Colors.purple,
                  child: const Icon(Icons.my_location, color: Colors.white),
                ),
              ],
            ),
          ),
          // API 호출 결과 표시 (위치 및 주소)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // GeoLocationAPI 데이터 표시 (첫 번째 카드)
                geoLocationState.when(
                  data: (geoLocation) {
                    if (geoLocation == null) {
                      return const SizedBox.shrink();
                    }
                    return CurrentLocationCard(
                      geoLocation: geoLocation,
                      title: _titleController.text.isEmpty
                          ? 'GeoLocationAPI'
                          : '${_titleController.text} (GeoLocationAPI)',
                    );
                  },
                  loading: () => const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  ),
                  error: (error, _) => Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('GeoLocationAPI 에러: $error', style: const TextStyle(color: Colors.red)),
                  ),
                ),
                // Geolocator 데이터 표시 (두 번째 카드)
                deviceLocationState.deviceLocation.when(
                  data: (deviceLocation) {
                    if (deviceLocation == null) {
                      return const SizedBox.shrink();
                    }
                    return GeolocatorCard(
                      deviceLocation: deviceLocation,
                      title: _titleController.text.isEmpty
                          ? 'Geolocator'
                          : _titleController.text,
                    );
                  },
                  loading: () => const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  ),
                  error: (error, _) => Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Geolocator 에러: $error', style: const TextStyle(color: Colors.red)),
                  ),
                ),
              ],
            ),
          ),
          // VWORLD API에서 가져온 주변 주소 목록 표시
          Expanded(
            child: deviceLocationState.nearbyAddresses.when(
              data: (addresses) {
                if (addresses.isEmpty) {
                  return const Center(child: Text('주변에 행정복지센터가 없습니다.'));
                }
                return AddressListView(addresses: addresses);
              },
              loading: () => const Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
              error: (error, _) => Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('주소 목록 에러: $error', style: const TextStyle(color: Colors.red)),
              ),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.purple[50],
    );
  }
}