import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:walkmoney/screen/registerapp.dart';
import 'package:walkmoney/screen/passcode.dart';

class CheckRegisterScreen extends StatefulWidget {
  const CheckRegisterScreen({Key? key}) : super(key: key);

  @override
  State<CheckRegisterScreen> createState() => _CheckRegisterScreenState();
}

class _CheckRegisterScreenState extends State<CheckRegisterScreen> {
  bool? isRegistered;

  @override
  void initState() {
    super.initState();
    checkRegistered();
  }

  Future<void> checkRegistered() async {
    final prefs = await SharedPreferences.getInstance();
    final loginList = prefs.getString('loginlist');
    setState(() {
      isRegistered = loginList != null && loginList.isNotEmpty;
    });
    if (isRegistered == true) {
      Future.delayed(Duration(milliseconds: 500), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => PassCodeScreen()),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isRegistered == null) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (isRegistered == false) {
      return RegisterAppScreen();
    }
    // ถ้าลงทะเบียนแล้วจะถูกนำไป passcode โดยอัตโนมัติ
    return Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
