import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:intl/intl.dart';
import 'package:walkmoney/model/deposit.dart';
import 'package:http/http.dart' as http;
import 'package:enhanced_drop_down/enhanced_drop_down.dart';

import 'package:walkmoney/service/config.dart';
import 'package:walkmoney/screen/menu.dart';
import 'package:walkmoney/screen/receipt.dart';

import '../service/loading3.dart';

class AddloanScreen extends StatefulWidget {
  AddloanScreen({Key? key, required this.accountno, required this.balance})
      : super(key: key);
  final String accountno;
  final String balance;

  @override
  State<AddloanScreen> createState() => _AddloanScreenState();
}

class _AddloanScreenState extends State<AddloanScreen> {
  final TextEditingController textAmount = TextEditingController();
  List infoLoan = [];
  String docId = "";
  String time = "";
  String typeAcc = "";
  bool isLoading = false;
  final f = NumberFormat('#,###', 'th_TH');
  final f1 = NumberFormat('###', 'th_TH');

  @override
  void initState() {
    super.initState();
    loadData(widget.accountno);
  }

  @override
  void dispose() {
    textAmount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ชำระเงินกู้'),
        shadowColor: Color.fromARGB(255, 8, 64, 129),
      ),
      backgroundColor: Colors.white,
      body: Container(
        padding: const EdgeInsets.fromLTRB(10, 20, 10, 10),
        child: Column(
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 5,
              child: Column(
                children: [
                  ListTile(
                    title: Text(
                      'เลขที่สัญญา : ${widget.accountno}',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(" " + typeAcc),
                    tileColor: Colors.grey[100],
                  ),
                  SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(30, 5, 10, 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "ยอดหนี้คงเหลือ",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[400],
                          ),
                        ),
                        Text(
                          '${widget.balance} ฿',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(10, 20, 10, 10),
                    child: Row(
                      children: [
                        Text(
                          'จำนวนเงินค่างวด',
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(25, 10, 25, 10),
                    child: TextField(
                      controller: textAmount,
                      decoration: InputDecoration(
                        border: UnderlineInputBorder(),
                        hintText: 'ระบุจำนวนเงิน',
                      ),
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.orange[700],
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            isLoading
                ? Loading3()
                : Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(40), // NEW
                        ),
                        onPressed: _submitPayment,
                        child: Text('ชำระ'),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitPayment() async {
    if (textAmount.text.isEmpty) {
      _showErrorDialog('กรุณาระบุจำนวนเงิน !');
      return;
    }

    if (isLoading) return;
    setState(() => isLoading = true);

    docId = "LO" +
        generateRandomString(5) +
        DateFormat.Hms('th')
            .format(DateTime.now())
            .toString()
            .replaceAll('.', '')
            .replaceAll(":", "");
    time = DateFormat.Hms('th').format(DateTime.now().toLocal());

    bool success = await addData(
      infoLoan[0]["accountNo"].toString(),
      infoLoan[0]["accountName"].toString(),
      textAmount.text,
      DateTime.now().toString(),
      infoLoan[0]["personId"].toString(),
      'LO',
      docId,
      time,
    );

    if (success) {
      await updateBalance();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ReceiptScreen(
            title: "ชำระเงินกู้สำเร็จ",
            name: infoLoan[0]["accountName"].toString(),
            accountno: infoLoan[0]["accountNo"].toString(),
            amount: double.parse(textAmount.text),
            docId: docId,
            time: time,
            personId: infoLoan[0]["personId"].toString(),
          ),
        ),
      );
    } else {
      setState(() => isLoading = false);
      _showErrorDialog('เกิดข้อผิดพลาดในการบันทึกข้อมูล');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            message,
            style: TextStyle(fontSize: 16),
          ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('ตกลง'),
            ),
          ],
        );
      },
    );
  }

  Future<void> loadData(String accountNo) async {
    try {
      var url = Uri.parse(
        '${Config.UrlApi}/api/GetLoanByAccountNo?AccountNo=$accountNo&Cusid=${Config.CusId}',
      );

      var headers = {
        'Verify_identity': Config.Verify_identity,
        "Accept": "application/json",
      };
      var response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        var json = jsonDecode(response.body);
        setState(() {
          infoLoan = json;
          textAmount.text = f1.format(
            double.parse(infoLoan[0]["minPayment"].toString()),
          );
          typeAcc = infoLoan[0]["typeLoanName"].toString();
        });
      } else {
        // Handle error
      }
    } catch (e) {
      // Handle exception
    }
  }

  Future<void> updateBalance() async {
    try {
      var totalAmount =
          double.parse(infoLoan[0]["totalAmount"].toString()) -
              double.parse(textAmount.text);

      var url = Uri.parse(
        '${Config.UrlApi}/api/UpdateLoanTotal?AccountNo=${infoLoan[0]["accountNo"]}&Balance=$totalAmount&Cusid=${Config.CusId}',
      );

      var headers = {'Verify_identity': Config.Verify_identity};
      await http.post(url, headers: headers);
    } catch (e) {
      // Handle exception
    }
  }

  static Future<bool> addData(
    String accountNo,
    String accountName,
    String amount,
    String movementDate,
    String personId,
    String type,
    String docId,
    String time,
  ) async {
    try {
      var url = Uri.parse(
        '${Config.UrlApi}/api/InsertLoan?AccountNo=$accountNo&AccountName=$accountName&Amount=$amount&MovementDate=$movementDate&PersonId=$personId&Type=$type&UserId=${Config.UserId}&Cusid=${Config.CusId}&DocId=$docId&Time=$time',
      );

      var headers = {
        'Verify_identity': Config.Verify_identity,
        "Accept": "application/json",
      };
      var response = await http.post(url, headers: headers);

      return response.body == "true";
    } catch (e) {
      return false;
    }
  }

  String generateRandomString(int len) {
    var r = Random();
    const _chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    return List.generate(
      len,
      (index) => _chars[r.nextInt(_chars.length)],
    ).join();
  }
}