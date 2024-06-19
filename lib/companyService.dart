import 'dart:convert';
import 'package:flutter_challenge/company.dart';
import 'package:flutter_challenge/locations.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_challenge/assets.dart';

class CompanyService {
  static const String baseUrl = 'fake-api.tractian.com';
  static Future<List<Company>> fetchCompanies() async {
    final response = await http.get(Uri.https('fake-api.tractian.com', '/companies'));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => Company.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load companies');
    }
  }
   static Future<List<Asset>> fetchAssetsByCompanyId(String companyId) async {
    try {
      final response = await http.get(
          Uri.https(baseUrl, '/companies/$companyId/assets'));

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        List<Asset> assets = data
            .map<Asset>((item) => Asset.fromJson(item))
            .toList();
        return assets;
      } else {
        throw Exception('Failed to load assets: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load assets: $e');
    }
  }

  static Future<List<Location>> fetchLocations(String companyId) async {
    final response = await http.get(Uri.https(baseUrl, '/companies/$companyId/locations'));
    if (response.statusCode == 200) {
      List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => Location.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load locations: ${response.statusCode}');
    }
  }

}

