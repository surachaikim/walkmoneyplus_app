import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:walkmoney/service/config.dart';

class DepositService {
  // Load account info for deposit
  static Future<List<dynamic>> loadAccountInfo(String accountNo) async {
    var url = Uri.parse(
      '${Config.UrlApi}/api/GetDepositByAccountNo?Sys=2&AccountNo=$accountNo&Cusid=${Config.CusId}',
    );
    var headers = {
      'Verify_identity': Config.Verify_identity,
      "Accept": "application/json",
    };
    var response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load account info');
    }
  }

  // Update balance after deposit
  static Future<void> updateBalance(String accountNo, double newBalance) async {
    var url = Uri.parse(
      '${Config.UrlApi}/api/UpdateBalance?AccountNo=$accountNo&Balance=$newBalance&Cusid=${Config.CusId}',
    );
    var headers = {'Verify_identity': Config.Verify_identity};
    var response = await http.post(url, headers: headers);
    if (response.statusCode != 200) {
      throw Exception('Failed to update balance');
    }
  }

  // Add deposit data
  static Future<bool> addDepositData({
    required String accountNo,
    required String accountName,
    required String amount,
    required DateTime movementDate,
    required String personId,
    required String docId,
    required String time,
  }) async {
    var url = Uri.parse(
      '${Config.UrlApi}/api/InsertDeposit?AccountNo=$accountNo'
      '&AccountName=$accountName'
      '&Amount=$amount'
      '&MovementDate=$movementDate'
      '&PersonId=$personId'
      '&UserId=${Config.UserId}'
      '&Type=DP'
      '&Cusid=${Config.CusId}'
      '&DocId=$docId'
      '&Time=$time',
    );

    var headers = {
      'Verify_identity': Config.Verify_identity,
      "Accept": "application/json",
    };
    var response = await http.post(url, headers: headers);
    return response.body == "true";
  }
}
