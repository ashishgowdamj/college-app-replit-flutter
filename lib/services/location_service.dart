import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/location_suggestion.dart';

class LocationService {
  static const _endpoint = 'https://nominatim.openstreetmap.org/search';

  /// Search places with optional country bias (e.g., 'in' for India)
  static Future<List<LocationSuggestion>> searchPlaces(
    String query, {
    String countryCodes = 'in',
    int limit = 8,
  }) async {
    if (query.trim().isEmpty) return [];

    final uri = Uri.parse(_endpoint).replace(queryParameters: {
      'q': query,
      'format': 'json',
      'addressdetails': '1',
      'limit': '$limit',
      'countrycodes': countryCodes,
    });

    final resp = await http.get(
      uri,
      headers: {
        // Nominatim requires a valid User-Agent identifying the application
        'User-Agent': 'CollegeCampusApp/1.0 (contact: support@example.com)',
      },
    );

    if (resp.statusCode != 200) {
      return [];
    }

    final data = json.decode(resp.body) as List<dynamic>;
    return data
        .whereType<Map<String, dynamic>>()
        .map((e) => LocationSuggestion.fromNominatim(e))
        .toList(growable: false);
  }
}
