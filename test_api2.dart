import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final url = Uri.parse('https://grofery.in/api/user/all-target-gifts');
  final headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer 1061|vmdi7uWgkNGeW2xpqIs4oZJ0SxLABvOrTQpFUNH30559b182',
  };

  final response = await http.get(url, headers: headers);
  print('Status: ${response.statusCode}');
  print('Body: ${response.body}');
}
