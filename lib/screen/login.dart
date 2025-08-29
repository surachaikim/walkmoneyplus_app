import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:walkmoney/loading.dart';

import 'package:walkmoney/screen/menu.dart';

import 'package:walkmoney/bezierContainer.dart';
import 'package:walkmoney/service/config.dart';
import 'package:http/http.dart' as http;

class LoginScreen extends StatefulWidget {
  LoginScreen({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  List infoLogin = [];
  bool loading = false;
  TextEditingController userController = new TextEditingController();
  TextEditingController passController = new TextEditingController();
  String _cusid = '';
  String _MacCheck = "";
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  @override
  void initState() {
    super.initState();
    // _loadcusid();
    setState(() {});
  }

  Future<bool> loadlogin(username, password) async {
    var url = Uri.parse(
      Config.UrlApi +
          '/api/GetLogin?username=' +
          username +
          '&password=' +
          password +
          '&cusid=' +
          _cusid,
    );

    var headers = {
      'Verify_identity': Config.Verify_identity,
      "Accept": "application/json",
    };
    var response = await http.get(url, headers: headers);

    if (response.statusCode != 400) {
      var json = jsonDecode(response.body);
      infoLogin = json;
      return Future<bool>.value(true);
    } else {
      return Future<bool>.value(false);
    }
  }

  Future<bool> updateuselogin(username, password) async {
    var url = Uri.parse(
      Config.UrlApi +
          '/api/UpdateUseLogin?User=' +
          username +
          '&password=' +
          password +
          '&st=1' +
          '&Cusid=' +
          _cusid,
    );

    var headers = {
      'Verify_identity': Config.Verify_identity,
      "Accept": "application/json",
    };
    var response = await http
        .post(url, headers: headers)
        .timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            setState(() {
              loading = false;
            });
            return http.Response('Error', 408);
          },
        );

    if (response.statusCode != 400) {
      return Future<bool>.value(true);
    } else {
      return Future<bool>.value(false);
    }
  }

  // Future<void> _loadcusid() async {
  //   final SharedPreferences prefs = await _prefs;
  //   _cusid = prefs.getString('cusid') ?? '';

  //   if (_cusid == "") {
  //     Navigator.push(
  //       context,
  //       MaterialPageRoute(builder: (context) => RegisterScreen()),
  //     );
  //   }

  //   setState(() {
  //     Config.CusId = _cusid;
  //   });
  // }

  Widget _entryFieldUser(String title) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 10),
          TextField(
            controller: userController,
            decoration: InputDecoration(
              border: InputBorder.none,
              fillColor: Color(0xfff3f3f4),
              filled: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _entryFieldPassword(String title, {bool isPassword = false}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 10),
          TextField(
            controller: passController,
            obscureText: isPassword,
            decoration: InputDecoration(
              border: InputBorder.none,
              fillColor: Color(0xfff3f3f4),
              filled: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _submitButton() {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(vertical: 15),
      alignment: Alignment.center,
      child: ElevatedButton(
        child: Text('เข้าสู่ระบบ'),
        onPressed: () async {
          setState(() {
            loading = true;
          });
          bool stringFuture = await loadlogin(
            userController.text,
            passController.text,
          );

          bool checkFuture = stringFuture;

          var Username = '';
          var Password = '';
          var UserId = '';
          var Name = '';

          if (checkFuture == true) {
            if (infoLogin.length > 0) {
              if (infoLogin.isEmpty == false) {
                Username = infoLogin[0]["userName"].toString();
                Password = infoLogin[0]["password"].toString();
                UserId = infoLogin[0]["userId"].toString();
                Name = infoLogin[0]["name"].toString();
              }
            }

            if (userController.text != "" && passController.text != "") {
              if (Username == userController.text &&
                  Password == passController.text) {
                if (infoLogin[0]["mac"].toString() == _MacCheck) {
                  Config.UserName = Username;
                  Config.UserId = UserId;
                  Config.CusId = _cusid;
                  Config.Password = Password;
                  Config.Name = Name;
                  /* อัพสถานะ user ให้เข้าใช้งานได้แค่ 1 เครื่อง/1user*/
                  updateuselogin(Username, Password);

                  /**/
                  Navigator.of(context).pushReplacement(
                    new MaterialPageRoute(
                      builder: (BuildContext context) {
                        return Menuscreen(tab: '0');
                      },
                    ),
                  );
                } else {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('คุณไม่ได้ลงทะเบียนใช้งานอุปกรณ์ !!!'),
                        actions: <Widget>[
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                loading = false;
                              });
                              Navigator.pop(context);
                            },
                            child: Text('ตกลง'),
                          ),
                        ],
                      );
                    },
                  );
                }
              } else {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('เข้าสู่ระบบไม่สำเร็จ'),
                      actions: <Widget>[
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              loading = false;
                            });
                            Navigator.pop(context);
                          },
                          child: Text('ตกลง'),
                        ),
                      ],
                    );
                  },
                );
              }
            }
          } else {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('กรุณากรอกชื่อผุ้ใช้/รหัสผู้ใช้'),
                  actions: <Widget>[
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          loading = false;
                        });
                        Navigator.pop(context);
                      },
                      child: Text('ตกลง'),
                    ),
                  ],
                );
              },
            );
          }
        },
      ),
    );
  }

  Widget _divider() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Row(children: <Widget>[SizedBox(width: 20)]),
    );
  }

  Widget _createAccountLabel() {
    return InkWell(
      onTap: () {},
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 20),
        padding: EdgeInsets.all(15),
        alignment: Alignment.bottomCenter,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Versoin 1.0.0',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 10),
            Text(
              'MixproAdvance',
              style: TextStyle(
                color: Color.fromARGB(255, 230, 119, 28),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _title() {
    return Image.asset('assets/images/Logo00.png');
  }

  Widget _usernamePasswordWidget() {
    return Column(
      children: <Widget>[
        _entryFieldUser("ชื่อผู้ใช้งาน"),
        _entryFieldPassword("รหัสผ่าน", isPassword: true),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return loading
        ? Loading()
        : Scaffold(
          backgroundColor: Color.fromARGB(255, 22, 52, 117),
          body: Container(
            height: height,
            child: Stack(
              children: <Widget>[
                Positioned(
                  top: -height * .15,
                  right: -MediaQuery.of(context).size.width * .4,
                  child: BezierContainer(),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(height: height * .2),
                        _title(),
                        SizedBox(height: 50),
                        _usernamePasswordWidget(),
                        SizedBox(height: 20),
                        _submitButton(),
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          alignment: Alignment.centerRight,
                        ),
                        _divider(),
                        SizedBox(height: height * .055),
                        _createAccountLabel(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
  }
}
