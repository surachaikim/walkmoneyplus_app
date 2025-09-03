import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:walkmoney/service/config.dart';

class AccountService {
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
          .timeout(const Duration(seconds: 90));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load account deposit data');
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
          .timeout(const Duration(seconds: 90));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 400) {
        return []; // No loan accounts found
      } else {
        throw Exception('Failed to load account loan data');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<List<dynamic>> getDepositByAccountNo(String accountNo) async {
    final url = Uri.parse(
      '${Config.UrlApi}/api/GetDepositByAccountNo?AccountNo=$accountNo&Cusid=${Config.CusId}',
    );

    final headers = {
      'Verify_identity': Config.Verify_identity,
      'Accept': 'application/json',
    };

    try {
      final response = await http
          .get(url, headers: headers)
          .timeout(const Duration(seconds: 90));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load deposit details');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<List<dynamic>> getLoanByAccountNo(String accountNo) async {
    final url = Uri.parse(
      '${Config.UrlApi}/api/GetLoanByAccountNo?AccountNo=$accountNo&Cusid=${Config.CusId}',
    );

    final headers = {
      'Verify_identity': Config.Verify_identity,
      'Accept': 'application/json',
    };

    try {
      final response = await http
          .get(url, headers: headers)
          .timeout(const Duration(seconds: 90));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load loan details');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
