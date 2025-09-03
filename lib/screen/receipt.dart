import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:walkmoney/screen/menu.dart';
import 'package:walkmoney/service/config.dart';
import 'package:http/http.dart' as http;
import 'package:walkmoney/screen/accountinfo.dart';
import 'package:walkmoney/palette.dart';

class ReceiptScreen extends StatefulWidget {
  final String title;
  final String name;
  final String accountno;
  final double amount;
  final String docId;
  final String time;
  final String personId;
  const ReceiptScreen({
    Key? key,
    required this.title,
    required this.name,
    required this.accountno,
    required this.amount,
    required this.docId,
    required this.time,
    required this.personId,
  }) : super(key: key);

  @override
  _ReceiptScreenState createState() => _ReceiptScreenState();
}

class _ReceiptScreenState extends State<ReceiptScreen> {
  final _screenshotController = ScreenshotController();

  var f = NumberFormat('#,###', 'th_TH');
  late List person = [];

  @override
  void initState() {
    super.initState();
    getperson();
    // Auto-save image when entering this screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _autoSaveImage();
    });
  }

  Future<void> _autoSaveImage() async {
    try {
      // Wait a bit for the UI to fully render
      await Future.delayed(const Duration(milliseconds: 500));
      final image = await _screenshotController.captureFromWidget(
        _getTicketReceiptView(),
      );
      await save(image);

      // Show success notification
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('บันทึกใบเสร็จเรียบร้อยแล้ว'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } catch (e) {
      print('Auto-save failed: $e');
      // Show error notification
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.error, color: Colors.white),
                SizedBox(width: 8),
                Text('เกิดข้อผิดพลาดในการบันทึกรูป'),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }

  Future<void> getperson() async {
    var url = Uri.parse(
      Config.UrlApi +
          '/api/GetMemberByPersonId?PersonId=' +
          '${widget.personId}' +
          '&Cusid=' +
          Config.CusId,
    );
    var headers = {
      'Verify_identity': Config.Verify_identity,
      "Accept": "application/json",
    };

    var response = await http.get(url, headers: headers);
    var json = jsonDecode(response.body);
    person = json;
  }

  Future<bool> savepicback() async {
    final image = await _screenshotController.captureFromWidget(
      _getTicketReceiptView(),
    );
    save(image);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder:
            (context) => AccountinfoScreen(
              personid: person[0]['personId'],
              idcardshow: person[0]['idcardshow'],
              idcard: person[0]['idcard'],
              name:
                  person[0]['title'] +
                  person[0]['firstName'] +
                  ' ' +
                  person[0]['lastName'],
              adress1:
                  person[0]['addrNo'] +
                  ' ม.' +
                  person[0]['moo'] +
                  ' ต.' +
                  person[0]['locality'] +
                  ' อ.' +
                  person[0]['district'] +
                  ' จ.' +
                  person[0]['province'] +
                  ' ' +
                  person[0]['zipCode'],
              adress2:
                  person[0]['addrNo1'] +
                  ' ม.' +
                  person[0]['moo1'] +
                  ' ต.' +
                  person[0]['locality1'] +
                  ' อ.' +
                  person[0]['district1'] +
                  ' จ.' +
                  person[0]['province1'] +
                  ' ' +
                  person[0]['zipCode1'],
              phone: person[0]['phone'],
            ),
      ),
    );

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => savepicback(),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Palette.kToDark.shade100, Palette.kToDark.shade900],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Screenshot(
              controller: _screenshotController,
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 480),
                        child: _getTicketReceiptView(),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),

                    child: Column(
                      children: [
                        _PrimaryButton(
                          icon: Icons.share,
                          label: 'แชร์',
                          onPressed: () async {
                            final image = await _screenshotController
                                .captureFromWidget(_getTicketReceiptView());

                            await share(image);
                          },
                        ),
                        const SizedBox(height: 12),
                        _PrimaryButton(
                          icon: Icons.home,
                          label: 'หน้าหลัก',
                          onPressed: () async {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Menuscreen(tab: '0'),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<String?> share(Uint8List bytes) async {
    final directory = await getApplicationDocumentsDirectory();
    final time = DateTime.now()
        .toIso8601String()
        .replaceAll('.', '-')
        .replaceAll(":", "-");
    final image = File('${directory.path}/screenshot_$time.png');
    await image.writeAsBytes(bytes);
    await Share.shareXFiles([XFile(image.path)], text: 'ใบเสร็จ');
    return image.path;
  }

  Future<String?> save(Uint8List bytes) async {
    final directory = await getApplicationDocumentsDirectory();
    final time = DateTime.now()
        .toIso8601String()
        .replaceAll('.', '-')
        .replaceAll(":", "-");
    final image = File('${directory.path}/screenshot_$time.png');
    image.writeAsBytesSync(bytes);
    // บันทึกไฟล์เป็นการแชร์เท่านั้น ไม่บันทึกลงแกลเลอรี่
    return null;
  }

  Widget _getTicketReceiptView() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 20,
            offset: Offset(0, 10),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header section
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),

            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),

                  child: Image.asset(
                    'assets/images/Checkru.png',
                    width: 52,
                    height: 52,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  widget.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '  ${DateFormat("dd/MM/yyyy").format(DateTime.now())} ${widget.time}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12),
                ),

                Text(
                  "รหัสอ้างอิง : ${widget.docId}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),

          Divider(),

          // Info section
          Container(
            padding: const EdgeInsets.all(16),

            child: Column(
              children: [
                const SizedBox(height: 15),
                _infoRow('ชื่อ-นามสกุล', widget.name),
                const SizedBox(height: 10),
                _infoRow('เลขที่บัญชี', widget.accountno),
                const SizedBox(height: 10),
                _infoRow('จำนวนเงิน', f.format(widget.amount)),
                const SizedBox(height: 45),
                Divider(),
                _infoRow('ผู้บันทึกรายการ', Config.Name),
              ],
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 5,
          child: Text(
            '$label :',
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 7,
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  const _PrimaryButton({
    Key? key,
    required this.icon,
    required this.label,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: const BorderSide(color: Colors.white, width: 1.5),
          backgroundColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        label: Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
