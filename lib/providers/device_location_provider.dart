import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/device_location_model.dart';
import '../models/vworld_address_model.dart';
import '../models/vworld_search_result.dart';
import '../repositories/device_location_repository.dart';

class DeviceLocationState {
  final AsyncValue<DeviceLocationData?> deviceLocation;
  final AsyncValue<VworldAddressData?> vworldAddress;
  final AsyncValue<List<VworldSearchResult>> nearbyAddresses;

  DeviceLocationState({
    this.deviceLocation = const AsyncValue.data(null),
    this.vworldAddress = const AsyncValue.data(null),
    this.nearbyAddresses = const AsyncValue.data([]),
  });

  DeviceLocationState copyWith({
    AsyncValue<DeviceLocationData?>? deviceLocation,
    AsyncValue<VworldAddressData?>? vworldAddress,
    AsyncValue<List<VworldSearchResult>>? nearbyAddresses,
  }) {
    return DeviceLocationState(
      deviceLocation: deviceLocation ?? this.deviceLocation,
      vworldAddress: vworldAddress ?? this.vworldAddress,
      nearbyAddresses: nearbyAddresses ?? this.nearbyAddresses,
    );
  }
}

class DeviceLocationNotifier extends StateNotifier<DeviceLocationState> {
  final DeviceLocationRepository repository;

  DeviceLocationNotifier(this.repository) : super(DeviceLocationState());

  Future<void> fetchLocationAndAddress() async {
    try {
      print('Starting fetchLocationAndAddress...');
      // 위치 데이터 로딩 상태
      state = state.copyWith(
        deviceLocation: const AsyncValue.loading(),
        vworldAddress: const AsyncValue.loading(),
        nearbyAddresses: const AsyncValue.loading(),
      );

      // 디바이스 위치 가져오기
      print('Fetching device location...');
      final deviceLocation = await repository.getDeviceLocation();
      print('Device location fetched: latitude=${deviceLocation.latitude}, longitude=${deviceLocation.longitude}');

      // VWORLD API로 주소 가져오기
      print('Fetching address from VWORLD...');
      final vworldAddress = await repository.getAddressFromVworld(
        deviceLocation.latitude,
        deviceLocation.longitude,
      );
      print('VWORLD address fetched: roadAddress=${vworldAddress.roadAddress}, administrativeArea=${vworldAddress.administrativeArea}');

      // VWORLD API로 주변 주소 목록 검색
      print('Fetching nearby addresses from VWORLD...');
      final nearbyAddresses = await repository.searchNearbyAddresses(
        deviceLocation.latitude,
        deviceLocation.longitude,
        query: '행정복지센터',
        radius: 1000,
      );
      print('Nearby addresses fetched: ${nearbyAddresses.length} items');
      print('Nearby addresses: ${nearbyAddresses.map((addr) => addr.title).toList()}');

      // 성공 상태 업데이트
      state = state.copyWith(
        deviceLocation: AsyncValue.data(deviceLocation),
        vworldAddress: AsyncValue.data(vworldAddress),
        nearbyAddresses: AsyncValue.data(nearbyAddresses),
      );
      print('State updated successfully: deviceLocation=${state.deviceLocation}, vworldAddress=${state.vworldAddress}, nearbyAddresses=${state.nearbyAddresses}');
    } catch (e, stack) {
      print('Error in fetchLocationAndAddress: $e');
      print('Stack trace: $stack');
      // 에러 상태 업데이트
      state = state.copyWith(
        deviceLocation: AsyncValue.error(e, stack),
        vworldAddress: AsyncValue.error(e, stack),
        nearbyAddresses: AsyncValue.error(e, stack),
      );
    }
  }
}

// DeviceLocationRepository 프로바이더
final deviceLocationRepositoryProvider = Provider<DeviceLocationRepository>((ref) {
  return DeviceLocationRepository();
});

// DeviceLocationNotifier 프로바이더
final deviceLocationProvider = StateNotifierProvider<DeviceLocationNotifier, DeviceLocationState>((ref) {
  final repository = ref.watch(deviceLocationRepositoryProvider);
  return DeviceLocationNotifier(repository);
});