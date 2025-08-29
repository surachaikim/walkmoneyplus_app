import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:walkmoney/screen/accountinfo.dart';
import 'package:walkmoney/service/config.dart';
import 'package:http/http.dart' as http;

class ScanIdcardScreen extends StatefulWidget {
  ScanIdcardScreen({Key? key}) : super(key: key);

  @override
  State<ScanIdcardScreen> createState() => _ScanIdcardScreenState();
}

class _ScanIdcardScreenState extends State<ScanIdcardScreen> {
  bool textScanning = false;

  XFile? imageFile;
  String scannedText = "";
  List persons = [];

  final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  late final InputImage inputImage;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: const Text("แสกนบัตรประชาชน")),
      backgroundColor: Colors.grey.shade200,
      body: Container(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 15),
                if (!textScanning && imageFile == null)
                  Container(width: 300, height: 300, color: Colors.grey[300]!),
                if (imageFile != null)
                  Container(
                    width: 300,
                    height: 300,
                    child: Image.file(File(imageFile!.path)),
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    /*Container(
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        padding: const EdgeInsets.only(top: 10),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.grey,
                            shadowColor: Colors.grey[400],
                            elevation: 10,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0)),
                          ),
                          onPressed: () {
                            getImage(ImageSource.gallery);
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                                vertical: 5, horizontal: 5),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.image,
                                  size: 30,
                                ),
                                Text(
                                  "Gallery",
                                  style: TextStyle(
                                      fontSize: 13, color: Colors.grey[600]),
                                )
                              ],
                            ),
                          ),
                        )),*/
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      padding: const EdgeInsets.only(top: 10),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.grey,
                          backgroundColor: Colors.white,
                          shadowColor: Colors.grey[400],
                          elevation: 10,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        onPressed: () {
                          getImage(ImageSource.camera);
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                            vertical: 5,
                            horizontal: 5,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.camera_alt, size: 30),
                              Text(
                                "ถ่ายรูป",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  child: Text(scannedText, style: TextStyle(fontSize: 20)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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

    if (response.body != []) {
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
      textScanning = false;
      _showMyDialog();
    }
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('แจ้งเตือน'),
          content: SingleChildScrollView(
            child: ListBody(children: <Widget>[Text('ไม่พบสมาชิก !!!')]),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('ตกลง'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
  }
}
