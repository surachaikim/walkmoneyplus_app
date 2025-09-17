import 'dart:convert';
import 'package:http/http.dart' as http;
import '../service/config.dart';

class MemberService {
  // Get loan history for an idcard
  static Future<List<dynamic>> getLoanHistory(String idcard) async {
    try {
      final loanAccounts = await getAccountLoan(idcard);
      // You may want to process/format loanAccounts here if needed
      return loanAccounts;
    } catch (e) {
      throw Exception('Failed to load loan history: $e');
    }
  }

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

  static Future<List<dynamic>> getAccountDeposit(String idcard) async {
    final url = Uri.parse(
      '${Config.UrlApi}/api/GetAccountDeposit?Cusid=${Config.CusId}&Idcard=$idcard',
    );

    final headers = {
      'Verify_identity': Config.Verify_identity,
      'Accept': 'application/json',
    };

    try {
      final response = await http
          .get(url, headers: headers)
          .timeout(const Duration(seconds: 300));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load deposit accounts');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<List<dynamic>> getAccountLoan(String idcard) async {
    final url = Uri.parse(
      '${Config.UrlApi}/api/GetAccountLoan?Idcard=$idcard&Cusid=${Config.CusId}',
    );

    final headers = {
      'Verify_identity': Config.Verify_identity,
      'Accept': 'application/json',
    };

    try {
      final response = await http
          .get(url, headers: headers)
          .timeout(const Duration(seconds: 300));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 400) {
        return []; // No loan accounts found
      } else {
        throw Exception('Failed to load loan accounts');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<List<dynamic>> getMovement(String accountNo) async {
    final url = Uri.parse(
      '${Config.UrlApi}/api/GetMovement?Cusid=${Config.CusId}&AccountNo=$accountNo',
    );

    final headers = {
      'Verify_identity': Config.Verify_identity,
      'Accept': 'application/json',
    };

    try {
      final response = await http
          .get(url, headers: headers)
          .timeout(const Duration(seconds: 300));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load movement data');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<List<dynamic>> getMovementLoan(String accountNo) async {
    final url = Uri.parse(
      '${Config.UrlApi}/api/GetMovementLoan?Cusid=${Config.CusId}&AccountNo=$accountNo',
    );

    final headers = {
      'Verify_identity': Config.Verify_identity,
      'Accept': 'application/json',
    };

    try {
      final response = await http
          .get(url, headers: headers)
          .timeout(const Duration(seconds: 300));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load loan movement data');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
