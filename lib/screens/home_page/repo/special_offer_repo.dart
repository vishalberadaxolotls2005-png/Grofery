import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:grofery_user/config/api_routes.dart';

class SpecialOfferRepository {
  Future<Map<String, dynamic>> fetchSpecialOffers() async {
    try {
      final response = await http.get(Uri.parse(ApiRoutes.specialOfferBannersApi));
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load special offers');
      }
    } catch (e) {
      throw Exception('Error fetching special offers: $e');
    }
  }
}
