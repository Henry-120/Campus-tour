import 'dart:convert';

import 'package:flutter/services.dart';

class SuggestionLocation {
  const SuggestionLocation({
    required this.name,
    required this.category,
    required this.latitude,
    required this.longitude,
  });

  final String name;
  final String category;
  final double latitude;
  final double longitude;

  // [L-01]
  factory SuggestionLocation.fromJson(Map<String, dynamic> json) {
    final name = json['名稱'];
    final category = json['種類'];
    final latitude = json['緯度'];
    final longitude = json['經度'];

    // [L-02]
    if (name is! String || name.trim().isEmpty) {
      throw const FormatException('地景資料缺少有效的「名稱」欄位');
    }

    // [L-03]
    if (category is! String || category.trim().isEmpty) {
      throw const FormatException('地景資料缺少有效的「種類」欄位');
    }

    // [L-04]
    if (latitude is! num || longitude is! num) {
      throw const FormatException('地景資料缺少有效的「緯度」或「經度」欄位');
    }

    // [L-05]
    return SuggestionLocation(
      name: name.trim(),
      category: category.trim(),
      latitude: latitude.toDouble(),
      longitude: longitude.toDouble(),
    );
  }
}

class JsonToSuggestionService {
  JsonToSuggestionService({AssetBundle? assetBundle})
    : assetBundle = assetBundle ?? rootBundle;

  final AssetBundle assetBundle;

  // [L-06]
  Future<List<SuggestionLocation>> loadLocations(
    List<String> assetPaths,
  ) async {
    final locations = <SuggestionLocation>[];

    // [L-07]
    for (final assetPath in assetPaths) {
      final loadedLocations = await loadLocationsFromAsset(assetPath);
      locations.addAll(loadedLocations);
    }

    // [L-08]
    return List.unmodifiable(locations);
  }

  // [L-09]
  Future<List<SuggestionLocation>> loadLocationsFromAsset(
    String assetPath,
  ) async {
    final jsonText = await assetBundle.loadString(assetPath);
    final decodedJson = jsonDecode(jsonText);

    // [L-10]
    if (decodedJson is! List) {
      throw FormatException('地景 JSON 根節點必須是陣列: $assetPath');
    }

    // [L-11]
    return parseLocations(decodedJson, sourceName: assetPath);
  }

  // [L-12]
  List<SuggestionLocation> parseLocations(
    List<dynamic> rawLocations, {
    String sourceName = 'inline json',
  }) {
    final locations = <SuggestionLocation>[];

    // [L-13]
    for (var index = 0; index < rawLocations.length; index += 1) {
      final rawLocation = rawLocations[index];

      // [L-14]
      if (rawLocation is! Map) {
        throw FormatException('地景資料第 ${index + 1} 筆不是物件: $sourceName');
      }

      // [L-15]
      final json = Map<String, dynamic>.from(rawLocation);
      locations.add(SuggestionLocation.fromJson(json));
    }

    // [L-16]
    return List.unmodifiable(locations);
  }
}
