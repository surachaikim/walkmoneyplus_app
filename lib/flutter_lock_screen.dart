library flutter_lock_screen;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
// import 'package:card_settings/helpers/converter_functions.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:walkmoney/screen/passcode.dart';
import 'package:walkmoney/service/config.dart';
import 'package:http/http.dart' as http;

typedef void DeleteCode();
typedef Future<bool> PassCodeVerify(List<int> passcode);

class LockScreen extends StatefulWidget {
  /// Password on success method
  final VoidCallback onSuccess;

  /// Password finger function for auth
  final VoidCallback? fingerFunction;

  /// Password finger verify for auth
  final bool? fingerVerify;

  /// screen title
  final String title;

  /// Pass length
  final int passLength;

  /// Wrong password dialog
  final bool? showWrongPassDialog;

  /// Showing finger print area
  final bool? showFingerPass;

  /// Wrong password dialog title
  final String? wrongPassTitle;

  /// Wrong password dialog content
  final String? wrongPassContent;

  /// Wrong password dialog button text
  final String? wrongPassCancelButtonText;

  /// Background image
  final String? bgImage;

  /// Color for numbers
  final Color? numColor;

  /// Finger print image
  final Widget? fingerPrintImage;

  /// border color
  final Color? borderColor;

  /// foreground color
  final Color? foregroundColor;

  /// Password verify
  final PassCodeVerify passCodeVerify;

  /// Lock Screen constructer
  LockScreen({
    required this.onSuccess,
    required this.title,
    this.borderColor,
    this.foregroundColor = Colors.transparent,
    required this.passLength,
    required this.passCodeVerify,
    this.fingerFunction,
    this.fingerVerify = false,
    this.showFingerPass = false,
    this.bgImage,
    this.numColor = Colors.black,
    this.fingerPrintImage,
    this.showWrongPassDialog = false,
    this.wrongPassTitle,
    this.wrongPassContent,
    this.wrongPassCancelButtonText,
  }) : assert(passLength <= 8),
       assert(borderColor != null),
       assert(foregroundColor != null);

  @override
  _LockScreenState createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  var _currentCodeLength = 0;
  var _inputCodes = <int>[];
  var _currentState = 0;
  Color circleColor = Color.fromARGB(255, 1, 55, 172);

  _onCodeClick(int code) {
    if (_currentCodeLength < widget.passLength) {
      setState(() {
        _currentCodeLength++;
        _inputCodes.add(code);
      });

      if (_currentCodeLength == widget.passLength) {
        widget.passCodeVerify(_inputCodes).then((onValue) {
          if (onValue) {
            setState(() {
              _currentState = 1;
            });
            widget.onSuccess();
          } else {
            _currentState = 2;
            new Timer(new Duration(milliseconds: 1000), () {
              setState(() {
                _currentState = 0;
                _currentCodeLength = 0;
                _inputCodes.clear();
              });
            });
            if (widget.showWrongPassDialog!) {
              _showToast(context);
              // showDialog(
              //     barrierDismissible: false,
              //     context: context,
              //     builder: (BuildContext context) {
              //       return Center(
              //         child: AlertDialog(
              //           title: Text(
              //             widget.wrongPassTitle!,

              //           ),
              //           content: Text(
              //             widget.wrongPassContent!,

              //           ),
              //           actions: <Widget>[
              //             ElevatedButton(
              //               onPressed: () => Navigator.pop(context),
              //               child: Text(
              //                 widget.wrongPassCancelButtonText!,
              //                 style: TextStyle(
              //                     color: Color.fromARGB(255, 4, 18, 94)),
              //               ),
              //             )
              //           ],
              //         ),
              //       );
              //     });
            }
          }
        });
      }
    }
  }

  void _showToast(BuildContext context) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: const Text("PIN ไม่ถูกต้อง !!! "),
        backgroundColor: Colors.red,
      ),
    );
  }

  _fingerPrint() {
    if (widget.fingerVerify!) {
      widget.onSuccess();
    }
  }

  _deleteCode() {
    setState(() {
      if (_currentCodeLength > 0) {
        _currentState = 0;
        _currentCodeLength--;
        _inputCodes.removeAt(_currentCodeLength);
      }
    });
  }

  _deleteAllCode() {
    setState(() {
      if (_currentCodeLength > 0) {
        _currentState = 0;
        _currentCodeLength = 0;
        _inputCodes.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(milliseconds: 200), () {
      _fingerPrint();
    });
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        image:
            widget.bgImage != null
                ? DecorationImage(
                  image: AssetImage(widget.bgImage!),
                  fit: BoxFit.fill,
                )
                : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            flex: 3,
            child: Container(
              child: Stack(
                children: <Widget>[
                  ClipPath(
                    child: Container(
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(height: Platform.isIOS ? 60 : 150),
                          Text(
                            widget.title,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: Platform.isIOS ? 50 : 20),
                          CodePanel(
                            codeLength: widget.passLength,
                            currentLength: _currentCodeLength,
                            borderColor: widget.borderColor,
                            foregroundColor: widget.foregroundColor,
                            deleteCode: _deleteCode,
                            fingerVerify: widget.fingerVerify!,
                            status: _currentState,
                          ),
                        ],
                      ),
                    ),
                  ),
                  widget.showFingerPass!
                      ? Positioned(
                        top:
                            MediaQuery.of(context).size.height /
                            (Platform.isIOS ? 4 : 5),
                        left: 20,
                        bottom: 10,
                        child: GestureDetector(
                          onTap: () {
                            widget.fingerFunction!();
                          },
                          child: widget.fingerPrintImage!,
                        ),
                      )
                      : Container(),
                ],
              ),
            ),
          ),
          Expanded(
            flex: Platform.isIOS ? 5 : 5,
            child: Container(
              padding: EdgeInsets.only(left: 0, top: 0),
              child: NotificationListener<OverscrollIndicatorNotification>(
                onNotification: (overscroll) {
                  return true;
                },
                child: GridView.count(
                  crossAxisCount: 3,
                  childAspectRatio: 1.6,
                  mainAxisSpacing: 18,
                  padding: EdgeInsets.all(35),
                  children: <Widget>[
                    buildContainerCircle(1),
                    buildContainerCircle(2),
                    buildContainerCircle(3),
                    buildContainerCircle(4),
                    buildContainerCircle(5),
                    buildContainerCircle(6),
                    buildContainerCircle(7),
                    buildContainerCircle(8),
                    buildContainerCircle(9),
                    buildRemoveIcon(Icons.cancel),
                    buildContainerCircle(0),
                    buildContainerIcon(Icons.arrow_back_ios_new),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('ต้องการยกเลิกผู้ใช้งาน?'),
                          actions: <Widget>[
                            OutlinedButton(
                              onPressed: () async {
                                SharedPreferences preferences =
                                    await SharedPreferences.getInstance();
                                await preferences.clear();
                                ClerMac();
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                    builder: (context) => PassCodeScreen(),
                                  ),
                                  (Route<dynamic> route) => false,
                                );
                              },
                              child: Text('ตกลง'),
                              style: ElevatedButton.styleFrom(),
                            ),
                            OutlinedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text('ยกเลิก'),
                              style: ElevatedButton.styleFrom(),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Text(
                    "ยกเลิกผู้ใช้งาน",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> ClerMac() async {
    var url = Uri.parse(
      Config.UrlApi +
          "/api/UpdateRegister?userid=" +
          Config.UserId +
          "&Cusid=" +
          Config.CusId,
    );

    var headers = {
      'Verify_identity': Config.Verify_identity,
      "Accept": "application/json",
    };
    var response = await http.post(url, headers: headers);
    var json = jsonDecode(response.body);
  }

  Widget buildContainerCircle(int number) {
    return SizedBox(
      width: 60,
      height: 60,
      child: InkResponse(
        highlightColor: Colors.red,
        onTap: () {
          _onCodeClick(number);
        },
        child: Container(
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 1, 55, 172),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: Colors.white, blurRadius: 1, spreadRadius: 0.5),
            ],
          ),
          child: Center(
            child: Text(
              number.toString(),
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.normal,
                color: widget.numColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildRemoveIcon(IconData icon) {
    return SizedBox(
      width: 60,
      height: 60,
      child: InkResponse(
        onTap: () {
          if (0 < _currentCodeLength) {
            _deleteAllCode();
          }
        },
        child: Container(
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 1, 55, 172),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: Colors.white, blurRadius: 1, spreadRadius: 0.5),
            ],
          ),
          child: Center(child: Icon(icon, size: 30, color: widget.numColor)),
        ),
      ),
    );
  }

  Widget buildContainerIcon(IconData icon) {
    return SizedBox(
      width: 60,
      height: 60,
      child: InkResponse(
        onTap: () {
          if (0 < _currentCodeLength) {
            setState(() {
              circleColor = Color.fromARGB(255, 62, 99, 180);
            });
            Future.delayed(Duration(milliseconds: 200)).then((func) {
              setState(() {
                circleColor = Color.fromARGB(255, 1, 55, 172);
              });
            });
          }
          _deleteCode();
        },
        child: Container(
          decoration: BoxDecoration(
            color: circleColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: Colors.white, blurRadius: 1, spreadRadius: 0.5),
            ],
          ),
          child: Center(child: Icon(icon, size: 30, color: widget.numColor)),
        ),
      ),
    );
  }
}

class CodePanel extends StatelessWidget {
  final codeLength;
  final currentLength;
  final borderColor;
  final bool? fingerVerify;
  final foregroundColor;
  final H = 15.0;
  final W = 40.0;
  final DeleteCode? deleteCode;
  final int? status;
  CodePanel({
    this.codeLength,
    this.currentLength,
    this.borderColor,
    this.foregroundColor,
    this.deleteCode,
    this.fingerVerify,
    this.status,
  }) : assert(codeLength > 0),
       assert(currentLength >= 0),
       assert(currentLength <= codeLength),
       assert(deleteCode != null),
       assert(status == 0 || status == 1 || status == 2);

  @override
  Widget build(BuildContext context) {
    var circles = <Widget>[];
    var color = borderColor;
    int circlePice = 1;

    if (fingerVerify == true) {
      do {
        circles.add(
          SizedBox(
            width: W,
            height: H,
            child: new Container(
              decoration: new BoxDecoration(
                shape: BoxShape.circle,
                border: new Border.all(color: color, width: 1.0),
                color: Colors.green.shade500,
              ),
            ),
          ),
        );
        circlePice++;
      } while (circlePice <= codeLength);
    } else {
      if (status == 1) {
        color = Colors.green.shade500;
      }
      if (status == 2) {
        color = Colors.red.shade500;
      }
      for (int i = 1; i <= codeLength; i++) {
        if (i > currentLength) {
          circles.add(
            SizedBox(
              width: W,
              height: H,
              child: Container(
                decoration: new BoxDecoration(
                  shape: BoxShape.circle,
                  border: new Border.all(color: color, width: 1.0),
                  color: foregroundColor,
                ),
              ),
            ),
          );
        } else {
          circles.add(
            new SizedBox(
              width: W,
              height: H,
              child: new Container(
                decoration: new BoxDecoration(
                  shape: BoxShape.circle,
                  border: new Border.all(color: color, width: 1.0),
                  color: color,
                ),
              ),
            ),
          );
        }
      }
    }

    return new SizedBox.fromSize(
      size: new Size(MediaQuery.of(context).size.width, 25.0),
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox.fromSize(
            size: new Size(40.0 * codeLength, H),
            child: new Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: circles,
            ),
          ),
        ],
      ),
    );
  }
}

class BgClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height / 1.5);
    path.lineTo(size.width, 0);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
