import 'dart:convert';
import 'package:http/http.dart' as http;
import '../service/config.dart';

class MemberService {
  static Future<dynamic> getMemberData(String cusId) async {
    final url = Uri.parse("${Config.UrlApi}/api/GetMember?Sys=2&Cusid=$cusId");
    final headers = {
      'Verify_identity': Config.Verify_identity,
      "Accept": "application/json",
    };
    final response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load member data');
    }
  }
}
