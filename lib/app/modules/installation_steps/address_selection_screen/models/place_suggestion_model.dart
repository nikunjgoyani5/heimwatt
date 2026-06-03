class PlaceSuggestion {
  final String displayName;
  final String formattedAddress;
  final String? priceLevel;

  PlaceSuggestion({
    required this.displayName,
    required this.formattedAddress,
    this.priceLevel,
  });

  factory PlaceSuggestion.fromJson(Map<String, dynamic> json) {
    return PlaceSuggestion(
      displayName: json['displayName']?['text'] ?? '',
      formattedAddress: json['formattedAddress'] ?? '',
      priceLevel: json['priceLevel'],
    );
  }
}

class PlacesSearchResponse {
  final List<PlaceSuggestion> places;

  PlacesSearchResponse({required this.places});

  factory PlacesSearchResponse.fromJson(Map<String, dynamic> json) {
    return PlacesSearchResponse(
      places: (json['places'] as List<dynamic>?)
              ?.map((e) => PlaceSuggestion.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

