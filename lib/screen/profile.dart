import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:walkmoney/palette.dart';
import 'package:walkmoney/screen/passcode.dart';
import 'package:walkmoney/service/config.dart';
import 'package:http/http.dart' as http;

import '../model/infologin.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final formkey = GlobalKey<FormState>();
  final txtPinold = TextEditingController();
  final txtPinnew = TextEditingController();
  bool light = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'ตั้งค่า',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
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
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _buildProfileCard(),
                const SizedBox(height: 20.0),
                _buildSettingsCard(),
                const SizedBox(height: 30.0),
                _buildAppInfo(),
                const SizedBox(height: 60.0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Card(
      elevation: 8.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      color: Colors.white.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 30,
              backgroundImage: ExactAssetImage('assets/images/member10.png'),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    Config.UserName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "ID: ${Config.UserId}",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsCard() {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      color: Colors.white.withOpacity(0.95),
      child: Column(
        children: <Widget>[
          _buildSettingsItem(
            icon: Icons.cancel_outlined,
            color: Colors.redAccent,
            title: "ยกเลิกผู้ใช้งาน",
            onTap: _showCancelUserDialog,
          ),
          _buildDivider(),
          _buildSettingsItem(
            icon: Icons.pin_outlined,
            color: Colors.blueAccent,
            title: "เปลี่ยน PIN",
            onTap: _showChangePinDialog,
          ),
          _buildDivider(),
          _buildSettingsItem(
            icon: Icons.logout,
            color: Colors.orangeAccent,
            title: "ลงชื่อออก",
            onTap: _showLogoutDialog,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required Color color,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title),
      trailing: const Icon(Icons.keyboard_arrow_right),
      onTap: onTap,
    );
  }

  Widget _buildAppInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "walkmoney App",
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "บริษัทมิกซ์โปร์ แอดวานซ์ จำกัด",
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
              const SizedBox(height: 8),
              Text(
                "โทร 02-446-3834-1",
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
              const SizedBox(height: 8),
              Text(
                Config.Test ? "Version  Test" : "Version  2.0.0",
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showCancelUserDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('ต้องการยกเลิกผู้ใช้งาน?'),
          content: const Text(
            'การดำเนินการนี้จะลบข้อมูลทั้งหมดและไม่สามารถย้อนกลับได้',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ยกเลิก'),
            ),
            ElevatedButton(
              onPressed: () async {
                SharedPreferences preferences =
                    await SharedPreferences.getInstance();
                await preferences.clear();
                _clerMac();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => PassCodeScreen()),
                  (Route<dynamic> route) => false,
                );
              },
              child: const Text('ยืนยัน'),
            ),
          ],
        );
      },
    );
  }

  void _showChangePinDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          scrollable: true,
          title: const Text('เปลี่ยน PIN'),
          content: Form(
            key: formkey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'PIN เดิม',
                    icon: Icon(Icons.lock_open),
                  ),
                  controller: txtPinold,
                  maxLength: 6,
                  keyboardType: TextInputType.number,
                  validator: RequiredValidator(errorText: "กรุณากำหนด PIN"),
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'PIN ใหม่',
                    icon: Icon(Icons.lock),
                  ),
                  maxLength: 6,
                  controller: txtPinnew,
                  keyboardType: TextInputType.number,
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return "กรุณากำหนด PIN ใหม่";
                    }
                    if (val.length < 6) {
                      return "PIN ต้องมี 6 หลัก";
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("ยกเลิก"),
            ),
            ElevatedButton(
              child: const Text("ตกลง"),
              onPressed: () async {
                if (formkey.currentState!.validate()) {
                  if (Config.Pin == txtPinold.text) {
                    SharedPreferences preferences =
                        await SharedPreferences.getInstance();
                    await preferences.clear();
                    final List<List<infologin>> tList = [
                      [
                        infologin(
                          cusid: Config.CusId,
                          password: Config.Password,
                          pin: txtPinnew.text,
                          username: Config.UserName,
                          userId: Config.UserId,
                          cpId: Config.CpId,
                          cpName: Config.CpName,
                          name: Config.Name,
                          Imei: Config.Imei,
                        ),
                      ],
                    ];
                    _addToSP(tList);
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => PassCodeScreen()),
                      (Route<dynamic> route) => false,
                    );
                  } else {
                    Navigator.pop(context);
                    _showErrorDialog('PIN เดิมไม่ถูกต้อง');
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('ต้องการออกจากระบบ?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ยกเลิก'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => PassCodeScreen()),
                  (Route<dynamic> route) => false,
                );
              },
              child: const Text('ตกลง'),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder:
          (BuildContext context) => AlertDialog(
            title: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('ตกลง'),
              ),
            ],
          ),
    );
  }

  Future<void> _addToSP(List<List<infologin>> tList) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('loginlist', jsonEncode(tList));
  }

  Future<void> _clerMac() async {
    var url = Uri.parse(
      "${Config.UrlApi}/api/UpdateRegister?userid=${Config.UserId}&Cusid=${Config.CusId}",
    );
    var headers = {
      'Verify_identity': Config.Verify_identity,
      "Accept": "application/json",
    };
    await http.post(url, headers: headers);
  }

  Container _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      width: double.infinity,
      height: 1.0,
      color: Colors.grey.shade300,
    );
  }
}
