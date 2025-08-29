import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:walkmoney/palette.dart';
import 'package:walkmoney/service/config.dart';
import 'package:walkmoney/screen/receipt.dart';
import '../service/loading3.dart';

class AddwithdrawScreen extends StatefulWidget {
  final String accountno;
  final String balance;

  const AddwithdrawScreen({
    Key? key,
    required this.accountno,
    required this.balance,
  }) : super(key: key);

  @override
  State<AddwithdrawScreen> createState() => _AddwithdrawScreenState();
}

class _AddwithdrawScreenState extends State<AddwithdrawScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _idCardController = TextEditingController();
  List<dynamic> infoDeposit = [];
  String docId = "";
  String bal = "";
  String time = "";
  bool isLoading = false;
  String typeAcc = "";
  int? selectedChipValue;

  final List<int> chipValues = [100, 500, 1000, 5000];
  final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  @override
  void initState() {
    super.initState();
    _loadAccountInfo(widget.accountno);
    _getBalance(widget.accountno);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'ถอนเงิน',
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
                if (isLoading)
                  const Center(child: Loading3())
                else
                  _buildActionButtons(),
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
          'จำนวนเงินที่ต้องการถอน',
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
            color: Colors.orangeAccent[100],
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
              color: Colors.orangeAccent[100],
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
                selectedColor: Colors.orange,
                elevation: 4,
                pressElevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  side: BorderSide(
                    color: isSelected ? Colors.orange : Colors.transparent,
                    width: 1.5,
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.camera_alt, color: Colors.white),
            label: const Text(
              'ยืนยันและสแกนบัตร',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              backgroundColor: Colors.orange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              elevation: 5,
            ),
            onPressed:
                () => _validateAndProceed(() => _getImage(ImageSource.camera)),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.credit_card, color: Colors.white),
            label: const Text(
              'ยืนยันด้วยเลขบัตร',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              backgroundColor: Colors.teal,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              elevation: 5,
            ),
            onPressed: () => _validateAndProceed(_showIdCardDialog),
          ),
        ),
      ],
    );
  }

  void _validateAndProceed(VoidCallback onSuccess) {
    if (_amountController.text.isEmpty) {
      _showErrorDialog('กรุณาระบุจำนวนเงิน');
      return;
    }
    if (double.parse(_amountController.text) > double.parse(bal)) {
      _showErrorDialog('ยอดเงินในบัญชีไม่เพียงพอ');
      return;
    }
    onSuccess();
  }

  Future<void> _showIdCardDialog() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('กรุณาใส่เลขบัตรประชาชน'),
          content: TextField(
            controller: _idCardController,
            decoration: const InputDecoration(border: OutlineInputBorder()),
            keyboardType: TextInputType.number,
            maxLength: 13,
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ยกเลิก'),
            ),
            ElevatedButton(
              onPressed: () {
                if (infoDeposit.isNotEmpty &&
                    infoDeposit[0]["idcard"].toString() ==
                        _idCardController.text) {
                  Navigator.pop(context);
                  _processWithdrawal();
                } else {
                  Navigator.pop(context);
                  _showErrorDialog('เลขบัตรประชาชนไม่ถูกต้อง');
                }
              },
              child: const Text('ยืนยัน'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _getImage(ImageSource source) async {
    try {
      final pickedImage = await ImagePicker().pickImage(source: source);
      if (pickedImage != null) {
        setState(() => isLoading = true);
        final recognizedId = await _getRecognisedText(pickedImage);
        if (infoDeposit.isNotEmpty &&
            infoDeposit[0]["idcard"].toString() == recognizedId) {
          _processWithdrawal();
        } else {
          _showErrorDialog('ไม่พบเลขบัตรประชาชนบนบัตร หรือข้อมูลไม่ถูกต้อง');
          setState(() => isLoading = false);
        }
      }
    } catch (e) {
      _showErrorDialog('เกิดข้อผิดพลาดในการสแกนบัตร');
      setState(() => isLoading = false);
    }
  }

  Future<String> _getRecognisedText(XFile image) async {
    final inputImage = InputImage.fromFilePath(image.path);
    final recognizedText = await textRecognizer.processImage(inputImage);
    String result = "";
    for (TextBlock block in recognizedText.blocks) {
      for (TextLine line in block.lines) {
        // Simple check for a 13-digit number string
        String cleanedText = line.text.replaceAll(RegExp(r'[-\s]'), '');
        if (cleanedText.length == 13 && int.tryParse(cleanedText) != null) {
          result = cleanedText;
          break;
        }
      }
      if (result.isNotEmpty) break;
    }
    return result;
  }

  Future<void> _processWithdrawal() async {
    setState(() => isLoading = true);
    try {
      docId =
          "WD" +
          _generateRandomString(5) +
          DateFormat.Hms(
            'th',
          ).format(DateTime.now()).toString().replaceAll(RegExp(r'[:.]'), "");
      time = DateFormat.Hms('th').format(DateTime.now().toLocal());

      bool success = await _addData();
      if (success) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (context) => ReceiptScreen(
                  title: "ถอนเงินสำเร็จ",
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
        _showErrorDialog('ทำรายการไม่สำเร็จ');
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
      builder:
          (BuildContext context) => AlertDialog(
            title: Text(message, style: const TextStyle(fontSize: 16)),
            actions: <Widget>[
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('ตกลง'),
              ),
            ],
          ),
    );
  }

  Future<void> _getBalance(String accountNo) async {
    var url = Uri.parse(
      '${Config.UrlApi}/api/GetBalance?AccountNo=$accountNo&Cusid=${Config.CusId}',
    );
    var headers = {'Verify_identity': Config.Verify_identity};
    var response = await http.get(url, headers: headers);
    if (mounted) {
      setState(() => bal = response.body);
    }
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
    if (response.statusCode == 200 && mounted) {
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
      '${Config.UrlApi}/api/InsertWithdraw?AccountNo=${infoDeposit[0]["accountNo"]}'
      '&AccountName=${infoDeposit[0]["accountName"]}'
      '&Amount=${_amountController.text}'
      '&MovementDate=${DateTime.now()}'
      '&PersonId=${infoDeposit[0]["personId"]}'
      '&UserId=${Config.UserId}'
      '&Type=WD'
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
