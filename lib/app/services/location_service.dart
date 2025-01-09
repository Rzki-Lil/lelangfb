import 'dart:convert';
import 'package:flutter/services.dart';

class Province {
  final String id;
  final String name;
  final List<City> regencies;

  Province({
    required this.id,
    required this.name,
    required this.regencies,
  });

  factory Province.fromJson(Map<String, dynamic> json) {
    try {
      return Province(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        regencies: (json['regencies'] as List?)
                ?.map((regency) => City.fromJson(regency))
                .toList() ??
            [],
      );
    } catch (e) {
      print('Error parsing province: $e');
      return Province(id: '', name: '', regencies: []);
    }
  }

  @override
  String toString() => name;
}

class City {
  final String id;
  final String provinceId;
  final String name;

  City({
    required this.id,
    required this.provinceId,
    required this.name,
  });

  factory City.fromJson(Map<String, dynamic> json) {
    try {
      return City(
        id: json['id'] ?? '',
        provinceId: json['province_id'] ?? '',
        name: json['name'] ?? '',
      );
    } catch (e) {
      print('Error parsing city: $e');
      return City(id: '', provinceId: '', name: '');
    }
  }

  @override
  String toString() => name;
}

class LocationService {
  static List<Province> _cachedProvinces = [];

  static Future<List<Province>> getProvinces() async {
    if (_cachedProvinces.isNotEmpty) {
      return _cachedProvinces;
    }

    try {
      final String response =
          await rootBundle.loadString('assets/data/provinsi-kota.json');
      final List<dynamic> data = json.decode(response);
      _cachedProvinces = data.map((json) => Province.fromJson(json)).toList();
      _cachedProvinces.sort((a, b) => a.name.compareTo(b.name));

      return _cachedProvinces;
    } catch (e) {
      print('Error loading provinces: $e');
      return [];
    }
  }

  static List<City> getCities(String provinceId, List<Province> provinces) {
    try {
      final province = provinces.firstWhere(
        (p) => p.id == provinceId,
        orElse: () => Province(id: '', name: '', regencies: []),
      );

      if (province.regencies.isEmpty) {
        print('No cities found for province ID: $provinceId');
        return [];
      }

      List<City> sortedCities = List.from(province.regencies);
      sortedCities.sort((a, b) => a.name.compareTo(b.name));

      return sortedCities;
    } catch (e) {
      print('Error getting cities: $e');
      return [];
    }
  }

  static String formatName(String name) {
    if (name.isEmpty) return '';

    if (name.toUpperCase() == name) {
      return name.split(' ').map((word) {
        if (word.length <= 3) return word;
        return word.substring(0, 1).toUpperCase() +
            word.substring(1).toLowerCase();
      }).join(' ');
    }

    return name.split(' ').map((word) {
      if (word.isEmpty) return '';
      // abbreviations
      if (word.length <= 3 && word.toUpperCase() == word) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  static void clearCache() {
    _cachedProvinces.clear();
  }

  // Add method to get province by ID
  static Province? getProvinceById(String id) {
    try {
      return _cachedProvinces.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  static List<Province> searchProvinces(
      String query, List<Province> provinces) {
    if (query.isEmpty) return provinces;

    final lowercaseQuery = query.toLowerCase();
    return provinces.where((province) {
      return province.name.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  static List<City> searchCities(String query, List<City> cities) {
    if (query.isEmpty) return cities;

    final lowercaseQuery = query.toLowerCase();
    return cities.where((city) {
      return city.name.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  static bool isValidProvinceId(String id, List<Province> provinces) {
    return provinces.any((province) => province.id == id);
  }


  static bool isValidCityId(
      String provinceId, String cityId, List<Province> provinces) {
    final cities = getCities(provinceId, provinces);
    return cities.any((city) => city.id == cityId);
  }
}
