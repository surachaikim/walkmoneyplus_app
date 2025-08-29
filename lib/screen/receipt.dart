import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

// import 'package:bluetooth_thermal_printer/bluetooth_thermal_printer.dart';
// import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
// import 'package:ticketview/ticketview.dart';
import 'package:walkmoney/screen/memberinfo.dart';
import 'package:walkmoney/screen/menu.dart';
import 'package:walkmoney/service/config.dart';
import 'package:http/http.dart' as http;
import 'package:walkmoney/screen/accountinfo.dart';
import 'package:image/image.dart' as IMG;

// import 'Back-popup.dart';

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

// bool _showTicketView = true;
bool connected = false;

class _ReceiptScreenState extends State<ReceiptScreen> {
  final _screenshotController = ScreenshotController();

  late List<String> imagePaths = [];
  var f = NumberFormat('#,###', 'th_TH');
  late List person = [];

  @override
  void initState() {
    super.initState();
    getperson();
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
        backgroundColor: Color.fromARGB(248, 1, 67, 248),
        body: Screenshot(
          controller: _screenshotController,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[SizedBox(height: 25)],
                ),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.all(10),
                    child: _getTicketReceiptView(),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    ElevatedButton(
                      onPressed: () async {
                        final image = await _screenshotController
                            .captureFromWidget(_getTicketReceiptView());
                        save(image);
                        share(image);
                      },
                      child: const Icon(Icons.share),
                    ),
                    SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: () async {
                        final image = await _screenshotController
                            .captureFromWidget(_getTicketReceiptView());
                        save(image);

                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => Memberinfo(
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
                      },
                      child: const Text('ย้อนกลับ'),
                    ),
                    SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: () async {
                        final image = await _screenshotController
                            .captureFromWidget(_getTicketReceiptView());
                        save(image);
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Menuscreen(tab: '0'),
                          ),
                        );
                      },
                      child: const Icon(Icons.home),
                    ),
                    // SizedBox(
                    //   width: 20,
                    // ),
                    // ElevatedButton(
                    //   onPressed: () async {
                    //     connected ? this.printR() : null;

                    //     // final image = await _screenshotController
                    //     //     .captureFromWidget(_getTicketReceiptView());
                    //     // save(image);
                    //   },
                    //   child: const Icon(Icons.print),
                    // ),
                    SizedBox(height: 25),
                  ],
                ),
              ],
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

  Future<String> saveImage(Uint8List bytes) async {
    final time = DateTime.now()
        .toIso8601String()
        .replaceAll('.', '-')
        .replaceAll(":", "-");
    final directory = await getApplicationDocumentsDirectory();
    final image = File('${directory.path}/screenshot_$time.png');
    image.writeAsBytesSync(bytes);
    // บันทึกไฟล์แล้วคืนค่า path
    return image.path;
  }

  Uint8List? resizeImage(Uint8List data) {
    Uint8List? resizedData = data;
    IMG.Image? img = IMG.decodeImage(data);
    IMG.Image resized = IMG.copyResize(img!, width: 764, height: 920);
    resizedData = IMG.encodeJpg(resized) as Uint8List?;
    return resizedData;
  }

  Widget _getTicketInfoView() {
    return Center(
      child: Container(
        height: 160,
        margin: EdgeInsets.all(10),
        child: Container(), // เดิมใช้ TicketView ซึ่งไม่รองรับ null safety
      ),
    );
  }

  Widget _getTicketReceiptView() {
    // เดิมใช้ TicketView ซึ่งไม่รองรับ null safety
    return Container(
      padding: EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 22, 52, 117),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Image.asset("assets/images/Checkru.png", width: 50, height: 50),
          SizedBox(height: 10),
          Text(
            '${widget.title}',
            style: TextStyle(
              fontSize: 20,
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 30),
          Row(
            children: <Widget>[
              Text(
                'ชื่อ-นามสกุล :',
                style: GoogleFonts.prompt(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Expanded(child: Container()),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '${widget.name}',
                      style: GoogleFonts.prompt(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: <Widget>[
              Text(
                'เลขที่บัญชี :',
                style: GoogleFonts.kodchasan(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Expanded(child: Container()),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '${widget.accountno}',
                      style: GoogleFonts.kodchasan(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: <Widget>[
              Text(
                'วันที่ทำรายการ :',
                style: GoogleFonts.kodchasan(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Expanded(child: Container()),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text:
                          DateFormat(
                            "dd/MM/yyyy",
                          ).format(DateTime.now()).toString() +
                          " " +
                          '${widget.time}',
                      style: GoogleFonts.kodchasan(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: <Widget>[
              Text(
                'ผู้บันทึกรายการ :',
                style: GoogleFonts.kodchasan(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Expanded(child: Container()),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: Config.Name,
                      style: GoogleFonts.kodchasan(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: <Widget>[
              Text(
                'เลขอ้างอิง :',
                style: GoogleFonts.kodchasan(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Expanded(child: Container()),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '${widget.docId}',
                      style: GoogleFonts.kodchasan(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 30),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'จำนวนเงินทำรายการ',
                  style: GoogleFonts.kodchasan(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: f.format(double.parse('${widget.amount}')),
                  style: GoogleFonts.kodchasan(
                    color: Colors.black,
                    fontSize: 25,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
