import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/device_location_model.dart';
import '../models/vworld_address_model.dart';
import '../repositories/device_location_repository.dart';


class DeviceLocationState {
  final AsyncValue<DeviceLocationData?> deviceLocation;
  final AsyncValue<VworldAddressData?> vworldAddress;

  DeviceLocationState({
    this.deviceLocation = const AsyncValue.data(null),
    this.vworldAddress = const AsyncValue.data(null),
  });

  DeviceLocationState copyWith({
    AsyncValue<DeviceLocationData?>? deviceLocation,
    AsyncValue<VworldAddressData?>? vworldAddress,
  }) {
    return DeviceLocationState(
      deviceLocation: deviceLocation ?? this.deviceLocation,
      vworldAddress: vworldAddress ?? this.vworldAddress,
    );
  }
}

class DeviceLocationNotifier extends StateNotifier<DeviceLocationState> {
  final DeviceLocationRepository repository;

  DeviceLocationNotifier(this.repository) : super(DeviceLocationState());

  Future<void> fetchLocationAndAddress() async {
    try {
      // 위치 데이터 로딩 상태
      state = state.copyWith(
        deviceLocation: const AsyncValue.loading(),
        vworldAddress: const AsyncValue.loading(),
      );

      // 디바이스 위치 가져오기
      final deviceLocation = await repository.getDeviceLocation();

      // VWORLD API로 주소 가져오기
      final vworldAddress = await repository.getAddressFromVworld(
        deviceLocation.latitude,
        deviceLocation.longitude,
      );

      // 성공 상태 업데이트
      state = state.copyWith(
        deviceLocation: AsyncValue.data(deviceLocation),
        vworldAddress: AsyncValue.data(vworldAddress),
      );
    } catch (e, stack) {
      // 에러 상태 업데이트
      state = state.copyWith(
        deviceLocation: AsyncValue.error(e, stack),
        vworldAddress: AsyncValue.error(e, stack),
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