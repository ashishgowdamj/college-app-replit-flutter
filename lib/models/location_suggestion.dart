import 'package:flutter/foundation.dart';

@immutable
class LocationSuggestion {
  final String displayName;
  final String? city;
  final String? state;
  final double latitude;
  final double longitude;

  const LocationSuggestion({
    required this.displayName,
    required this.latitude,
    required this.longitude,
    this.city,
    this.state,
  });

  factory LocationSuggestion.fromNominatim(Map<String, dynamic> json) {
    final lat = double.tryParse(json['lat']?.toString() ?? '') ?? 0.0;
    final lon = double.tryParse(json['lon']?.toString() ?? '') ?? 0.0;
    final addr = json['address'] as Map<String, dynamic>?;
    return LocationSuggestion(
      displayName: json['display_name']?.toString() ?? '',
      latitude: lat,
      longitude: lon,
      city: addr?['city']?.toString() ?? addr?['town']?.toString() ?? addr?['village']?.toString(),
      state: addr?['state']?.toString(),
    );
  }
}
