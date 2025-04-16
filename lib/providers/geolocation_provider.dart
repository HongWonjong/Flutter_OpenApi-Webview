import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/geolocation_model.dart';
import '../repositories/geolocation_repository.dart';


class GeoLocationState {
  final AsyncValue<GeoLocationData?> data;

  GeoLocationState(this.data);
}

class GeoLocationNotifier extends StateNotifier<GeoLocationState> {
  GeoLocationNotifier() : super(GeoLocationState(const AsyncValue.data(null)));

  Future<void> fetchGeoLocation() async {
    state = GeoLocationState(const AsyncValue.loading());
    try {
      final repository = GeoLocationRepository();
      final geoLocation = await repository.fetchGeoLocation();
      state = GeoLocationState(AsyncValue.data(geoLocation));
    } catch (e, stackTrace) {
      state = GeoLocationState(AsyncValue.error(e, stackTrace));
    }
  }
}

final geoLocationProvider =
StateNotifierProvider<GeoLocationNotifier, GeoLocationState>(
      (ref) => GeoLocationNotifier(),
);