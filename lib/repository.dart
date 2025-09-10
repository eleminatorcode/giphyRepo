import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:giphy/gif_model.dart';

class GifRepo {
  GifRepo({required this.apiKey, http.Client? client})
      : _client = client ?? http.Client();

  final String apiKey;
  final http.Client _client;

  // Base for GIF endpoints
  static final Uri _base = Uri.parse('https://api.giphy.com/v1/gifs');

  Future<(List<GifData> items, int totalCount)> _fetch(Uri uri) async {
    final resp = await _client.get(uri);
    if (resp.statusCode != 200) {
      throw Exception('GIPHY ${resp.statusCode}: ${resp.body}');
    }
    final json = jsonDecode(resp.body) as Map<String, dynamic>;
    final data = (json['data'] as List).cast<Map<String, dynamic>>();
    final gifs = data.map(GifData.fromJson).toList();
    final pagination = (json['pagination'] as Map<String, dynamic>);
    final total = (pagination['total_count'] ?? gifs.length) as int;
    return (gifs, total);
  }

  Future<(List<GifData> items, int totalCount)> trending({
    required int offset,
    int limit = 24,
    String rating = 'g',
    String bundle = 'messaging_non_clips',
    String? countryCode,
  }) {
    final uri = _base.replace(
      path: '${_base.path}/trending',
      queryParameters: {
        'api_key': apiKey,
        'limit': '$limit',
        'offset': '$offset',
        'rating': rating,
        'bundle': bundle,
        if (countryCode != null) 'country_code': countryCode,
      },
    );
    return _fetch(uri);
  }

  Future<(List<GifData> items, int totalCount)> search({
    required String query,
    required int offset,
    int limit = 24,
    String rating = 'g',
    String lang = 'en',
    String bundle = 'messaging_non_clips',
    String? countryCode,
  }) {
    final uri = _base.replace(
      path: '${_base.path}/search',
      queryParameters: {
        'api_key': apiKey,
        'q': query,
        'limit': '$limit',
        'offset': '$offset',
        'rating': rating,
        'lang': lang,
        'bundle': bundle,
        if (countryCode != null) 'country_code': countryCode,
      },
    );
    return _fetch(uri);
  }
}
