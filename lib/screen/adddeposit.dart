import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:walkmoney/screen/receipt.dart';
import 'package:walkmoney/service/config.dart';
import 'package:walkmoney/service/loading3.dart';
import 'package:walkmoney/palette.dart'; // Assuming you have a palette.dart file for colors

class AdddepositScreen extends StatefulWidget {
  final String accountno;
  final String balance;

  const AdddepositScreen({
    Key? key,
    required this.accountno,
    required this.balance,
  }) : super(key: key);

  @override
  State<AdddepositScreen> createState() => _AdddepositScreenState();
}

class _AdddepositScreenState extends State<AdddepositScreen> {
  final TextEditingController _amountController = TextEditingController();
  List<dynamic> infoDeposit = [];
  String docId = "";
  String time = "";
  bool isLoading = false;
  String typeAcc = "";
  int? selectedChipValue;

  final List<int> chipValues = [100, 500, 1000, 5000];

  @override
  void initState() {
    super.initState();
    _loadAccountInfo(widget.accountno);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'ฝากเงิน',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Palette.kToDark.shade100, Palette.kToDark.shade900],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAccountCard(),
                const SizedBox(height: 30),
                _buildAmountSection(),
                const SizedBox(height: 10),
                _buildChoiceChips(),
                const SizedBox(height: 40),
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAccountCard() {
    return Card(
      elevation: 8.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      color: Colors.white.withOpacity(0.9),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'เลขที่บัญชี',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.accountno,
              style: TextStyle(
                color: Palette.kToDark.shade400,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              typeAcc,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Divider(height: 30, thickness: 1),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "ยอดเงินคงเหลือ",
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${widget.balance} ฿',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'จำนวนเงินที่ต้องการฝาก',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _amountController,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Colors.tealAccent[100],
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.black.withOpacity(0.2),
            hintText: '0.00',
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
            prefixText: '฿ ',
            prefixStyle: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.tealAccent[100],
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide.none,
            ),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
      ],
    );
  }

  Widget _buildChoiceChips() {
    return Center(
      child: Wrap(
        spacing: 10.0,
        runSpacing: 8.0,
        alignment: WrapAlignment.center,
        children:
            chipValues.map((value) {
              final isSelected = selectedChipValue == value;
              return ChoiceChip(
                label: Text(
                  NumberFormat('#,###').format(value),
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                selected: isSelected,
                onSelected: (bool selected) {
                  setState(() {
                    if (selected) {
                      selectedChipValue = value;
                      _amountController.text = value.toString();
                    } else {
                      selectedChipValue = null;
                    }
                  });
                },
                backgroundColor: Colors.white.withOpacity(0.7),
                selectedColor: Colors.teal,
                elevation: 4,
                pressElevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  side: BorderSide(
                    color: isSelected ? Colors.teal : Colors.transparent,
                    width: 1.5,
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          backgroundColor: Colors.teal,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          elevation: 5,
        ),
        onPressed: isLoading ? null : _submitDeposit,
        child:
            isLoading
                ? const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                )
                : const Text(
                  'ยืนยันการฝากเงิน',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
      ),
    );
  }

  Future<void> _submitDeposit() async {
    if (_amountController.text.isEmpty) {
      _showErrorDialog('กรุณาระบุจำนวนเงิน');
      return;
    }

    setState(() => isLoading = true);

    try {
      docId =
          "DP" +
          _generateRandomString(5) +
          DateFormat.Hms(
            'th',
          ).format(DateTime.now()).toString().replaceAll(RegExp(r'[:.]'), "");
      time = DateFormat.Hms('th').format(DateTime.now().toLocal());

      await _updateBalance();
      bool success = await _addData();

      if (success) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (context) => ReceiptScreen(
                  title: "ฝากเงินสำเร็จ",
                  name: infoDeposit[0]["accountName"].toString(),
                  accountno: infoDeposit[0]["accountNo"].toString(),
                  amount: double.parse(_amountController.text),
                  docId: docId,
                  time: time,
                  personId: infoDeposit[0]["personId"].toString(),
                ),
          ),
        );
      } else {
        _showErrorDialog('ทำรายการไม่สำเร็จ กรุณาลองใหม่อีกครั้ง');
      }
    } catch (e) {
      _showErrorDialog('เกิดข้อผิดพลาด: $e');
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(message, style: const TextStyle(fontSize: 16)),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ตกลง'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateBalance() async {
    double currentBalance =
        double.tryParse(
          infoDeposit[0]["balance"].toString().replaceAll(RegExp(r','), ''),
        ) ??
        0.0;
    double depositAmount = double.parse(_amountController.text);
    double newBalance = currentBalance + depositAmount;

    var url = Uri.parse(
      '${Config.UrlApi}/api/UpdateBalance?AccountNo=${infoDeposit[0]["accountNo"]}&Balance=$newBalance&Cusid=${Config.CusId}',
    );
    var headers = {'Verify_identity': Config.Verify_identity};
    await http.post(url, headers: headers);
  }

  Future<void> _loadAccountInfo(String accountNo) async {
    var url = Uri.parse(
      '${Config.UrlApi}/api/GetDepositByAccountNo?Sys=2&AccountNo=$accountNo&Cusid=${Config.CusId}',
    );
    var headers = {
      'Verify_identity': Config.Verify_identity,
      "Accept": "application/json",
    };
    var response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      var json = jsonDecode(response.body);
      setState(() {
        infoDeposit = json;
        typeAcc =
            infoDeposit.isNotEmpty
                ? infoDeposit[0]["typeAccName"].toString()
                : "";
      });
    }
  }

  Future<bool> _addData() async {
    var url = Uri.parse(
      '${Config.UrlApi}/api/InsertDeposit?AccountNo=${infoDeposit[0]["accountNo"]}'
      '&AccountName=${infoDeposit[0]["accountName"]}'
      '&Amount=${_amountController.text}'
      '&MovementDate=${DateTime.now()}'
      '&PersonId=${infoDeposit[0]["personId"]}'
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

  String _generateRandomString(int len) {
    var r = Random();
    const chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    return List.generate(len, (index) => chars[r.nextInt(chars.length)]).join();
  }
}
