import 'package:flutter_openapi_webview/providers/search_query_provider.dart';
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
  final Ref ref;

  DeviceLocationNotifier(this.repository, this.ref) : super(DeviceLocationState());

  Future<void> fetchLocationAndAddress() async {
    try {
      state = state.copyWith(
        deviceLocation: const AsyncValue.loading(),
        vworldAddress: const AsyncValue.loading(),
        nearbyAddresses: const AsyncValue.loading(),
      );

      final deviceLocation = await repository.getDeviceLocation();
      final vworldAddress = await repository.getAddressFromVworld(
        deviceLocation.latitude,
        deviceLocation.longitude,
      );

      final query = ref.read(searchQueryProvider);
      final nearbyAddresses = await repository.searchNearbyAddresses(
        deviceLocation.latitude,
        deviceLocation.longitude,
        query: query.isEmpty ? '행정복지센터' : query,
        radius: 1000,
      );

      state = state.copyWith(
        deviceLocation: AsyncValue.data(deviceLocation),
        vworldAddress: AsyncValue.data(vworldAddress),
        nearbyAddresses: AsyncValue.data(nearbyAddresses),
      );
    } catch (e, stack) {
      state = state.copyWith(
        deviceLocation: AsyncValue.error(e, stack),
        vworldAddress: AsyncValue.error(e, stack),
        nearbyAddresses: AsyncValue.error(e, stack),
      );
    }
  }
}

final deviceLocationProvider = StateNotifierProvider<DeviceLocationNotifier, DeviceLocationState>((ref) {
  final repository = ref.watch(deviceLocationRepositoryProvider);
  return DeviceLocationNotifier(repository, ref);
});

final deviceLocationRepositoryProvider = Provider<DeviceLocationRepository>((ref) {
  return DeviceLocationRepository();
});