import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final url = Uri.parse('https://grofery.in/api/user/claim-target-gift');
  final headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer 1061|vmdi7uWgkNGeW2xpqIs4oZJ0SxLABvOrTQpFUNH30559b182',
  };

  final response = await http.post(
    url,
    headers: headers,
    body: jsonEncode({'target_id': 6, 'address_id': 44}),
  );
  
  if (response.body.startsWith('{')) {
    final json = jsonDecode(response.body);
    print('Message: ${json["message"]}');
    print('Exception: ${json["exception"]}');
    print('File: ${json["file"]}');
    print('Line: ${json["line"]}');
  } else {
    print(response.body);
  }
}
