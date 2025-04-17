import 'package:flutter/material.dart';
import '../models/vworld_search_result.dart';

class AddressListView extends StatelessWidget {
  final List<VworldSearchResult> addresses;

  const AddressListView({super.key, required this.addresses});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: addresses.length,
      itemBuilder: (context, index) {
        final address = addresses[index];
        // roadAddress가 없으면 parcelAddress를 사용
        final displayAddress = address.roadAddress.isNotEmpty
            ? address.roadAddress
            : address.parcelAddress.isNotEmpty
            ? address.parcelAddress
            : '주소 정보 없음';
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
                  address.title,
                  style: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  displayAddress,
                  style: const TextStyle(
                    fontSize: 14.0,
                    color: Colors.grey,
                  ),
                ),
                if (address.category != null) ...[
                  const SizedBox(height: 4.0),
                  Text(
                    address.category!,
                    style: const TextStyle(
                      fontSize: 12.0,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}