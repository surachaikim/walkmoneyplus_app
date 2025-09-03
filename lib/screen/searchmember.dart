import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:walkmoney/screen/accountinfo.dart';
import 'package:walkmoney/screen/serachname.dart';
import 'package:walkmoney/service/config.dart';
import 'package:http/http.dart' as http;
import 'package:walkmoney/screen/searchidcard.dart';
import 'package:walkmoney/screen/serachpersonid.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:walkmoney/service/loading3.dart';

class SearchScreen extends StatefulWidget {
  SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  int i = 0; // จำลองตัวเลขการเพิ่่มจำนวน
  bool status = false;
  // String _scanBarcode = 'Unknown';

  List persons = [];
  List cusinfo = [];
  String cpName = "";
  String cpId = "";
  bool textScanning = false;

  String scannedText = "";

  XFile? imageFile;

  final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  @override
  void initState() {
    super.initState();
    cpName = Config.CpName;
    cpId = Config.CpId;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: <Widget>[
          Container(
            height: 200,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1976D2), Color(0xFF64B5F6)],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: text(),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 220, 24, 32),
            child:
                textScanning
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(
                            color: Color(0xFF1976D2),
                            strokeWidth: 4,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'กำลังสแกน...',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    )
                    : GridView.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 18,
                      crossAxisSpacing: 18,
                      childAspectRatio: 0.95,
                      children: [
                        _buildSearchButton(
                          icon: 'assets/images/search1.png',
                          label: 'ชื่อ-นามสกุล',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SerachnameScreen(),
                              ),
                            );
                          },
                        ),
                        _buildSearchButton(
                          icon: 'assets/images/search2.png',
                          label: 'เลขบัตร',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SerachIdcardScreen(),
                              ),
                            );
                          },
                        ),
                        _buildSearchButton(
                          icon: 'assets/images/serach3.png',
                          label: 'สแกนบัตร',
                          onTap: () async {
                            getImage(ImageSource.camera);
                          },
                        ),
                        _buildSearchButton(
                          icon: 'assets/images/search4.png',
                          label: 'เลขสมาชิก',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SerachPersonidScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
          ),
          /*   Padding(
            padding: const EdgeInsets.fromLTRB(140, 560, 30, 30),
            child: Container(
                color: Color.fromARGB(255, 248, 247, 245),
                child: Column(
                  children: [
                    Text(
                      "บริษัท มิกซ์โปร แอดวานซ์",
                      style: TextStyle(color: Colors.black, fontSize: 12),
                    ),
                    Text(
                      "โทร 02-4463834-7",
                      style: TextStyle(color: Colors.black, fontSize: 12),
                    ),
                  ],
                )),
          )*/
        ],
      ),
    );
  }

  /*void getImage(ImageSource source) async {
    try {
      final pickedImage = await ImagePicker().pickImage(source: source);
      if (pickedImage != null) {
        textScanning = true;
        imageFile = pickedImage;
        setState(() {});
        getRecognisedText(pickedImage);
      }
    } catch (e) {
      textScanning = false;
      imageFile = null;
      scannedText = "Error occured while scanning";
      setState(() {});
    }
  }*/

  /* void getRecognisedText(XFile image) async {
    final inputImage = InputImage.fromFilePath(image.path);
    final textDetector = GoogleMlKit.vision.textDetector();
    RecognisedText recognisedText = await textDetector.processImage(inputImage);
    await textDetector.close();
    scannedText = "";
    var i = 0;

    for (TextBlock block in recognisedText.blocks) {
      for (TextLine line in block.lines) {
        i++;
        if (i == 3) {
          scannedText = line.text;
          var partStr = scannedText.split(" ");
          scannedText = "";
          scannedText =
              partStr[0] + partStr[1] + partStr[2] + partStr[3] + partStr[4];
          getmemberByqrIdcard(scannedText);
        }
      }
    }
  }*/

  Widget text() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 80, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            cpName,
            style: const TextStyle(
              fontSize: 22,
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            cpId,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.w400,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchButton({
    required String icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      splashColor: const Color(0xFF1976D2).withOpacity(0.12),
      highlightColor: const Color(0xFF1976D2).withOpacity(0.06),
      child: Ink(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE3F2FD), width: 1),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: Color(0xFFE3F2FD),
                  shape: BoxShape.circle,
                ),
                child: Center(child: Image.asset(icon, width: 40, height: 40)),
              ),
              const SizedBox(height: 16),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1976D2),
                  letterSpacing: 0.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> getmemberByqrIdcard(idcard) async {
    var url = Uri.parse(
      Config.UrlApi +
          "/api/GetMemberByIdcard?Idcard=" +
          idcard +
          "&Cusid=" +
          Config.CusId,
    );

    var headers = {
      'Verify_identity': Config.Verify_identity,
      "Accept": "application/json",
    };
    var response = await http.get(url, headers: headers);

    if (response.body != "") {
      var json = jsonDecode(response.body);
      persons = json;
      if (persons.length > 0) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => AccountinfoScreen(
                  personid: persons[0]['personId'],
                  idcard: persons[0]['idcard'],
                  idcardshow: persons[0]['idcardshow'],
                  name:
                      persons[0]['title'] +
                      persons[0]['firstName'] +
                      ' ' +
                      persons[0]['lastName'],
                  adress1:
                      persons[0]['addrNo'] +
                      ' ม.' +
                      persons[0]['moo'] +
                      ' ต.' +
                      persons[0]['locality'] +
                      ' อ.' +
                      persons[0]['district'] +
                      ' จ.' +
                      persons[0]['province'] +
                      ' ' +
                      persons[0]['zipCode'],
                  adress2:
                      persons[0]['addrNo1'] +
                      ' ม.' +
                      persons[0]['moo1'] +
                      ' ต.' +
                      persons[0]['locality1'] +
                      ' อ.' +
                      persons[0]['district1'] +
                      ' จ.' +
                      persons[0]['province1'] +
                      ' ' +
                      persons[0]['zipCode1'],
                  phone: persons[0]['phone'],
                ),
          ),
        );
      }
      textScanning = false;
      setState(() {
        persons = json;
      });
    } else {
      _showMyDialog();
    }
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: const [
              Icon(Icons.warning_amber_rounded, color: Colors.orange),
              SizedBox(width: 8),
              Text('แจ้งเตือน'),
            ],
          ),
          content: const Text('ไม่พบสมาชิก !!!'),
          actions: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF1976D2),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('ตกลง'),
              onPressed: () {
                setState(() {
                  textScanning = false;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> getCusid() async {
    var url = Uri.parse(
      Config.UrlApi + "/api/GetConstant?Cusid=" + Config.CusId,
    );

    var headers = {
      'Verify_identity': Config.Verify_identity,
      "Accept": "application/json",
    };
    var response = await http.get(url, headers: headers);
    var json = jsonDecode(response.body);
    cusinfo = json;

    cpName = '${cusinfo[0]["cpName"]}';
    cpId = '${cusinfo[0]["cpId"]}';
    setState(() {
      cusinfo = json;
      cpName = '${cusinfo[0]["cpName"]}';
      cpId = '${cusinfo[0]["cpId"]}';
    });
  }

  void getImage(ImageSource source) async {
    try {
      final pickedImage = await ImagePicker().pickImage(source: source);
      if (pickedImage != null) {
        textScanning = true;
        imageFile = pickedImage;
        setState(() {});
        getRecognisedText(pickedImage);
      }
    } catch (e) {
      textScanning = false;
      imageFile = null;
      scannedText = "Error occured while scanning";
      setState(() {});
    }
  }

  void getRecognisedText(XFile image) async {
    var i = 0;
    final RecognizedText recognizedText = await textRecognizer.processImage(
      InputImage.fromFilePath(image.path),
    );

    // String text = recognizedText.text;
    for (TextBlock block in recognizedText.blocks) {
      // final String text = block.text;
      // final List<String> languages = block.recognizedLanguages;

      for (TextLine line in block.lines) {
        // Same getters as TextBlock
        i++;
        try {
          if (i == 5) {
            var per = line.text.split(" ");
            scannedText = per[0] + per[1] + per[2] + per[3] + per[4];
          }
        } catch (_) {}

        try {
          if (i == 7) {
            var per = line.text.split(" ");
            scannedText = per[0] + per[1] + per[2] + per[3] + per[4];
          }
        } catch (_) {}

        try {
          if (i == 6) {
            var per = line.text.split(" ");
            scannedText = per[0] + per[1] + per[2] + per[3] + per[4];
          }
        } catch (_) {}

        /* for (TextElement element in line.elements) {
          i++;

          if (i >= 6 && i <= 19) {
            scannedText = scannedText + element.text;
          }
        }*/
      }
    }
    getmemberByqrIdcard(scannedText);

    setState(() {});
  }
}
