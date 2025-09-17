import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:http/http.dart' as http;

import 'package:walkmoney/service/config.dart';
import 'package:walkmoney/screen/receipt.dart';
import 'package:walkmoney/service/member_service.dart';
import 'package:walkmoney/palette.dart'; // Assuming you have a palette.dart file for colors

class AddloanScreen extends StatefulWidget {
  AddloanScreen({Key? key, required this.accountno, required this.balance})
    : super(key: key);
  final String accountno;
  final String balance;

  @override
  State<AddloanScreen> createState() => _AddloanScreenState();
}

class _AddloanScreenState extends State<AddloanScreen> {
  final TextEditingController _amountController = TextEditingController();
  List infoLoan = [];
  String docId = "";
  String time = "";
  String typeAcc = "";
  bool isLoading = false;
  final f = NumberFormat('#,###', 'th_TH');
  final f1 = NumberFormat('###', 'th_TH');
  int? selectedChipValue;

  final List<int> chipValues = [500, 1000, 2000, 5000];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeLocale();
    });
  }

  Future<void> _initializeLocale() async {
    await initializeDateFormatting('th');
    loadData(widget.accountno);
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _showLoanHistorySheet() async {
    List<dynamic> history = [];
    try {
      history = await MemberService.getMovementLoan(widget.accountno);
    } catch (e) {
      history = [];
    }
    print(history);
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (ctx) {
        if (history.isEmpty) {
          return SizedBox(
            height: 220,
            child: Center(
              child: Text('ไม่มีประวัติการกู้', style: TextStyle(fontSize: 18)),
            ),
          );
        }
        return SizedBox(
          height: 400,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'ประวัติการกู้',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    final item = history[index];
                    // Format date if available
                    String formattedDate = item["movementDate"] ?? '';
                    try {
                      if (formattedDate.isNotEmpty) {
                        final date = DateTime.parse(formattedDate);
                        final buddhistYear = date.year + 543;
                        formattedDate =
                            DateFormat('d MMM', 'th').format(date) +
                            ' ' +
                            buddhistYear.toString();
                      }
                    } catch (_) {}
                    return ListTile(
                      leading: Icon(Icons.receipt_long, color: Colors.orange),
                      title: Text(
                        'จำนวน ${item["totalAmount"] ?? "-"} ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('วันที่ชำระ ${formattedDate}'),
                      trailing: Text(
                        item["docNo"] ?? '',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    );
                  },
                  separatorBuilder: (context, index) => Divider(height: 1),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'ชำระเงินกู้',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white),
            tooltip: 'ประวัติการกู้',
            onPressed: _showLoanHistorySheet,
          ),
        ],
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
              'เลขที่สัญญา',
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
                  "ยอดหนี้คงเหลือ",
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
                    color: Colors.red,
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
          'จำนวนเงินที่ต้องการชำระ',
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

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          backgroundColor: Colors.orange,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          elevation: 5,
        ),
        onPressed: isLoading ? null : _submitPayment,
        child:
            isLoading
                ? const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                )
                : const Text(
                  'ยืนยันการชำระเงินกู้',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
      ),
    );
  }

  Future<void> _submitPayment() async {
    if (_amountController.text.isEmpty) {
      _showErrorDialog('กรุณาระบุจำนวนเงิน !');
      return;
    }

    if (isLoading) return;
    setState(() => isLoading = true);

    try {
      docId =
          "LO" +
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
        _amountController.text,
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
            builder:
                (context) => ReceiptScreen(
                  title: "ชำระเงินกู้สำเร็จ",
                  name: infoLoan[0]["accountName"].toString(),
                  accountno: infoLoan[0]["accountNo"].toString(),
                  amount: double.parse(_amountController.text),
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
    } catch (e) {
      setState(() => isLoading = false);
      _showErrorDialog('เกิดข้อผิดพลาด: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header Icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.error_outline_rounded,
                    size: 40,
                    color: Colors.red.shade400,
                  ),
                ),
                const SizedBox(height: 20),

                // Title
                Text(
                  'เกิดข้อผิดพลาด',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Palette.kToDark.shade800,
                  ),
                ),
                const SizedBox(height: 12),

                // Message
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Palette.kToDark.shade600,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 30),

                // OK Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.red.shade400, Colors.red.shade600],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'ตกลง',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
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
          _amountController.text = f1.format(
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
          double.parse(_amountController.text);

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
