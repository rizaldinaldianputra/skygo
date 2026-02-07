import 'package:dio/dio.dart';
import 'package:latlong2/latlong.dart';

class LocationService {
  final Dio _dio = Dio(); // Separate Dio instance for external APIs

  // Free Nominatim & OSRM endpoints.
  // NOTE: For production, use your own hosted instance or paid service.
  final String nominatimUrl = "https://nominatim.openstreetmap.org/search";
  final String osrmUrl = "https://router.project-osrm.org/route/v1/driving";

  Future<List<Map<String, dynamic>>> searchAddress(String query) async {
    if (query.isEmpty) return [];

    try {
      // Nominatim requires a User-Agent
      final response = await _dio.get(
        nominatimUrl,
        queryParameters: {
          'q': query,
          'format': 'json',
          'limit': 5,
          'addressdetails': 1,
          'countrycodes': 'id',
        },
        options: Options(headers: {'User-Agent': 'com.skygo.user'}),
      );

      if (response.statusCode == 200) {
        final List data = response.data; // Dio decodes JSON automatically
        return data
            .map(
              (item) => {
                'display_name': item['display_name'],
                'lat': double.parse(item['lat']),
                'lon': double.parse(item['lon']),
              },
            )
            .toList();
      }
      return [];
    } catch (e) {
      print("Geocoding Error: $e");
      return [];
    }
  }

  Future<Map<String, dynamic>?> getRoute(LatLng start, LatLng end) async {
    final url =
        '$osrmUrl/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?overview=full&geometries=geojson';

    try {
      final response = await _dio.get(url);
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['code'] == 'Ok' &&
            data['routes'] != null &&
            (data['routes'] as List).isNotEmpty) {
          return data['routes'][0]; // Return first route
        }
      }
      return null;
    } catch (e) {
      print("Routing Error: $e");
      return null;
    }
  }

  // Helper to decode OSRM text geometry if needed,
  // but we asked for geojson which is easier to parse directly into points usually,
  // or we can just use the coordinates from geojson.
  List<LatLng> parseRouteCoordinates(Map<String, dynamic> routeData) {
    final geometry = routeData['geometry'];
    final List coordinates = geometry['coordinates'];

    return coordinates.map((coord) {
      // GeoJSON is [lon, lat]
      return LatLng(coord[1], coord[0]);
    }).toList();
  }
}
