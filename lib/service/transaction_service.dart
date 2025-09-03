import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:walkmoney/service/config.dart';

class TransactionService {
  /// Get transaction type by user
  static Future<List<dynamic>> getTransactionTypeByUser(String type) async {
    final url = Uri.parse(
      '${Config.UrlApi}/api/GetTransactionTypebyuser?Cusid=${Config.CusId}&Type=$type&User=${Config.UserId}',
    );

    final headers = {
      'Verify_identity': Config.Verify_identity,
      'Accept': 'application/json',
    };

    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load transactions');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Cancel transaction
  static Future<void> cancelTransaction(String docId) async {
    final url = Uri.parse(
      '${Config.UrlApi}/api/CanceldTransaction?DocId=$docId&St=1&CusId=${Config.CusId}',
    );

    final headers = {
      'Verify_identity': Config.Verify_identity,
      'Accept': 'application/json',
    };

    try {
      final response = await http.post(url, headers: headers);

      if (response.statusCode != 200) {
        throw Exception('Failed to cancel transaction');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Get deposit account details by account number for withdrawal
  static Future<List<dynamic>> getWithdrawByAccountNo(String accountNo) async {
    final url = Uri.parse(
      '${Config.UrlApi}/api/GetDepositByAccountNo?Sys=2&AccountNo=$accountNo&Cusid=${Config.CusId}',
    );

    final headers = {
      'Verify_identity': Config.Verify_identity,
      'Accept': 'application/json',
    };

    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load withdrawal account details');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Get deposit account details by account number
  static Future<List<dynamic>> getDepositByAccountNo(String accountNo) async {
    final url = Uri.parse(
      '${Config.UrlApi}/api/GetDepositByAccountNo?AccountNo=$accountNo&Cusid=${Config.CusId}',
    );

    final headers = {
      'Verify_identity': Config.Verify_identity,
      'Accept': 'application/json',
    };

    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load account details');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Update account balance
  static Future<void> updateBalance(String accountNo, double balance) async {
    final url = Uri.parse(
      '${Config.UrlApi}/api/UpdateBalance?AccountNo=$accountNo&Balance=$balance&Cusid=${Config.CusId}',
    );

    final headers = {
      'Verify_identity': Config.Verify_identity,
      'Accept': 'application/json',
    };

    try {
      final response = await http.post(url, headers: headers);

      if (response.statusCode != 200) {
        throw Exception('Failed to update balance');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
