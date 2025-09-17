import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:walkmoney/screen/receipt.dart';
import 'package:walkmoney/service/deposit_service.dart';
import 'package:walkmoney/service/member_service.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeLocale();
    });
  }

  Future<void> _initializeLocale() async {
    await initializeDateFormatting('th');
    _loadAccountInfo();
  }

  Future<void> _loadAccountInfo() async {
    try {
      var data = await DepositService.loadAccountInfo(widget.accountno);
      if (mounted) {
        if (data.isEmpty) {
          _showErrorDialog('ไม่พบข้อมูลบัญชี');
          setState(() {
            infoDeposit = [];
            typeAcc = "";
          });
        } else {
          setState(() {
            infoDeposit = data;
            typeAcc = data[0]["typeAccName"].toString();
          });
        }
      }
    } catch (e) {
      // Handle error, maybe show dialog
      _showErrorDialog('Failed to load account info: $e');
      if (mounted) {
        setState(() {
          infoDeposit = [];
          typeAcc = "";
        });
      }
    }
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
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white),
            tooltip: 'ประวัติการฝาก',
            onPressed: () => _showDepositHistorySheet(),
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

  Future<void> _showDepositHistorySheet() async {
    List<dynamic> history = [];
    try {
      history = await MemberService.getMovement(widget.accountno);
    } catch (e) {
      history = [];
    }
    if (!mounted) return;
    // Filter only items with deposit > 0
    final depositHistory =
        history.where((item) {
          final deposit = num.tryParse(item["deposit"].toString()) ?? 0;
          return deposit > 0;
        }).toList();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (ctx) {
        if (depositHistory.isEmpty) {
          return SizedBox(
            height: 220,
            child: Center(
              child: Text('ไม่มีประวัติการฝาก', style: TextStyle(fontSize: 18)),
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
                  'ประวัติการฝาก',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  itemCount: depositHistory.length,
                  itemBuilder: (context, index) {
                    final item = depositHistory[index];
                    // Format movementDate to Thai Buddhist year (พ.ศ.)
                    String formattedDate = item["movementDate"];
                    try {
                      final date = DateTime.parse(item["movementDate"]);
                      final buddhistYear = date.year + 543;
                      formattedDate =
                          DateFormat('d MMM', 'th').format(date) +
                          ' ' +
                          buddhistYear.toString();
                    } catch (_) {}
                    return ListTile(
                      leading: Icon(Icons.receipt_long, color: Colors.teal),
                      title: Text(
                        'จำนวน ${item["deposit"]} ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('วันที่ $formattedDate'),
                      trailing: Text(
                        item["docId"] ?? item["docNo"] ?? '',
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
                  '${widget.balance} ',
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

    if (infoDeposit.isEmpty) {
      _showErrorDialog('ข้อมูลบัญชีไม่พร้อมใช้งาน');
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
      print(e);
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

    await DepositService.updateBalance(infoDeposit[0]["accountNo"], newBalance);
  }

  Future<bool> _addData() async {
    return await DepositService.addDepositData(
      accountNo: infoDeposit[0]["accountNo"],
      accountName: infoDeposit[0]["accountName"],
      amount: _amountController.text,
      movementDate: DateTime.now(),
      personId: infoDeposit[0]["personId"],
      docId: docId,
      time: time,
    );
  }

  String _generateRandomString(int len) {
    var r = Random();
    const chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    return List.generate(len, (index) => chars[r.nextInt(chars.length)]).join();
  }
}
