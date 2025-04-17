class VworldSearchResult {
  final String title;
  final String roadAddress;
  final String? category;

  VworldSearchResult({
    required this.title,
    required this.roadAddress,
    this.category,
  });

  factory VworldSearchResult.fromJson(Map<String, dynamic> json) {
    final address = json['address'] ?? {};
    return VworldSearchResult(
      title: json['title'] ?? '',
      roadAddress: address['road'] ?? '',
      category: json['category'],
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'roadAddress': roadAddress,
    'category': category,
  };
}