class VworldSearchResult {
  final String id;
  final String title;
  final String roadAddress;
  final String parcelAddress;
  final String? category;
  final double x;
  final double y;

  VworldSearchResult({
    required this.id,
    required this.title,
    required this.roadAddress,
    required this.parcelAddress,
    this.category,
    required this.x,
    required this.y,
  });

  factory VworldSearchResult.fromJson(Map<String, dynamic> json) {
    final address = json['address'] is Map ? json['address'] as Map<String, dynamic> : {};
    final point = json['point'] is Map ? json['point'] as Map<String, dynamic> : {};
    return VworldSearchResult(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      roadAddress: address['road']?.toString() ?? '',
      parcelAddress: address['parcel']?.toString() ?? '',
      category: json['category']?.toString(),
      x: double.tryParse(point['x']?.toString() ?? '0.0') ?? 0.0,
      y: double.tryParse(point['y']?.toString() ?? '0.0') ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'roadAddress': roadAddress,
    'parcelAddress': parcelAddress,
    'category': category,
    'x': x,
    'y': y,
  };
}