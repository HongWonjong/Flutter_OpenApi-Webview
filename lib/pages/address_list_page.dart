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
import '../providers/search_query_provider.dart';

class AddressListPage extends ConsumerStatefulWidget {
  const AddressListPage({super.key});

  @override
  ConsumerState<AddressListPage> createState() => _AddressListPageState();
}

class _AddressListPageState extends ConsumerState<AddressListPage> {
  final TextEditingController _titleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Sync TextField with searchQueryProvider
    _titleController.text = ref.read(searchQueryProvider);
    _titleController.addListener(() {
      ref.read(searchQueryProvider.notifier).state = _titleController.text;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final geoLocationState = ref.watch(geoLocationProvider).data;
    final deviceLocationState = ref.watch(deviceLocationProvider);

    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 50),
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: '내 주변에서 찾고 싶은 것',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                FloatingActionButton(
                  onPressed: () {
                    ref.read(geoLocationProvider.notifier).fetchGeoLocation();
                    ref.read(deviceLocationProvider.notifier).fetchLocationAndAddress();
                  },
                  backgroundColor: Colors.purple,
                  child: const Icon(Icons.my_location, color: Colors.white),
                ),
              ],
            ),
          ),
          // Rest of the UI remains the same
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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