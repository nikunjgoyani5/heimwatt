class GeocodeResult {
  final String formattedAddress;
  final Location location;
  final String placeId;

  GeocodeResult({
    required this.formattedAddress,
    required this.location,
    required this.placeId,
  });

  factory GeocodeResult.fromJson(Map<String, dynamic> json) {
    return GeocodeResult(
      formattedAddress: json['formatted_address'] ?? '',
      location: Location.fromJson(json['geometry']?['location'] ?? {}),
      placeId: json['place_id'] ?? '',
    );
  }
}

class Location {
  final double lat;
  final double lng;

  Location({required this.lat, required this.lng});

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      lat: (json['lat'] ?? json['latitude'] ?? 0.0).toDouble(),
      lng: (json['lng'] ?? json['longitude'] ?? 0.0).toDouble(),
    );
  }
}

class GeocodeResponse {
  final List<GeocodeResult> results;
  final String status;

  GeocodeResponse({required this.results, required this.status});

  factory GeocodeResponse.fromJson(Map<String, dynamic> json) {
    return GeocodeResponse(
      results: (json['results'] as List<dynamic>?)
              ?.map((e) => GeocodeResult.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      status: json['status'] ?? '',
    );
  }
}

