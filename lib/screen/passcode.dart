import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:walkmoney/model/infologin.dart';
import 'package:walkmoney/palette.dart';
import 'package:walkmoney/screen/menu.dart';
import 'package:walkmoney/screen/registerapp.dart';
import 'package:http/http.dart' as http;
import '../service/config.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import '../service/member_service.dart';

class PassCodeScreen extends StatefulWidget {
  const PassCodeScreen({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  _PassCodeScreenState createState() => _PassCodeScreenState();
}

class _PassCodeScreenState extends State<PassCodeScreen>
    with TickerProviderStateMixin {
  String enteredPin = '';
  String savedPin = '';
  bool isLoading = true;
  List<List<infologin>> info = [];
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  // API URL preload only (config moved to Register screen)
  final TextEditingController _apiController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 24).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
    _apiController.text = Config.UrlApi;
    checkConnection();
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _apiController.dispose();
    super.dispose();
  }

  Future<void> checkConnection() async {
    // Load stored API URL first
    await _loadApiUrlFromPrefs();
    bool result = await InternetConnectionChecker().hasConnection;
    if (result) {
      await loadSharedPreferences();
    } else {
      _showNoInternetDialog();
    }
  }

  Future<void> _loadApiUrlFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString('api_url');
      if (saved != null && saved.isNotEmpty && saved != Config.UrlApi) {
        Config.UrlApi = saved;
        _apiController.text = saved;
      }
    } catch (_) {}
  }

  void _showNoInternetDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.wifi_off, color: Colors.red),
              SizedBox(width: 8),
              Text('ไม่มีอินเทอร์เน็ต'),
            ],
          ),
          content: const Text('กรุณาเชื่อมต่ออินเทอร์เน็ตของคุณ'),
          actions: [
            TextButton(
              child: const Text('ตกลง'),
              onPressed: () {
                Navigator.of(context).pop();
                checkConnection();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> loadSharedPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<dynamic> jsonData = jsonDecode(
        prefs.getString('loginlist') ?? '[]',
      );

      info =
          jsonData.map<List<infologin>>((jsonList) {
            return jsonList.map<infologin>((jsonItem) {
              return infologin.fromJson(jsonItem);
            }).toList();
          }).toList();

      if (info.isNotEmpty) {
        await _setConfigData();
        setState(() {
          savedPin = info[0][0].pin;
          isLoading = false;
        });
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => RegisterAppScreen()),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      _showErrorDialog('เกิดข้อผิดพลาดในการโหลดข้อมูล');
    }
  }

  Future<void> _setConfigData() async {
    Config.CusId = info[0][0].cusid;
    Config.UserId = info[0][0].userId;
    Config.UserName = info[0][0].username;
    Config.CpId = info[0][0].cpId;
    Config.CpName = info[0][0].cpName;
    Config.Password = info[0][0].password;
    Config.Pin = info[0][0].pin;
    Config.Imei = info[0][0].Imei;
    Config.Name = info[0][0].name;

    if (Config.data_member.isEmpty) {
      await _getDataMember();
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Row(
              children: [
                Icon(Icons.error, color: Colors.red),
                SizedBox(width: 8),
                Text('ข้อผิดพลาด'),
              ],
            ),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('ตกลง'),
              ),
            ],
          ),
    );
  }

  void _onNumberPressed(String number) {
    if (enteredPin.length < 6) {
      setState(() {
        enteredPin += number;
      });

      if (enteredPin.length == 6) {
        _verifyPin();
      }
    }
  }

  void _onDeletePressed() {
    if (enteredPin.isNotEmpty) {
      setState(() {
        enteredPin = enteredPin.substring(0, enteredPin.length - 1);
      });
    }
  }

  void _onClearPressed() {
    setState(() {
      enteredPin = '';
    });
  }

  void _verifyPin() {
    if (enteredPin == savedPin) {
      _onSuccessLogin();
    } else {
      _onWrongPin();
    }
  }

  void _onSuccessLogin() {
    HapticFeedback.lightImpact();
    Future.delayed(const Duration(milliseconds: 500), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => Menuscreen(tab: '0')),
      );
    });
  }

  void _onWrongPin() {
    HapticFeedback.heavyImpact();
    _shakeController.forward().then((_) {
      _shakeController.reverse();
    });

    setState(() {
      enteredPin = '';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.error, color: Colors.white),
            SizedBox(width: 8),
            Text('PIN ไม่ถูกต้อง กรุณาลองใหม่'),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text('ยกเลิกผู้ใช้งาน'),
            content: const Text(
              'ต้องการยกเลิกการใช้งานและลงทะเบียนใหม่หรือไม่?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('ยกเลิก'),
              ),
              ElevatedButton(
                onPressed: () async {
                  await _resetUser();
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text(
                  'ตกลง',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  Future<void> _resetUser() async {
    final prefs = await SharedPreferences.getInstance();
    await _clearMac();
    await prefs.clear();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => RegisterAppScreen()),
      (route) => false,
    );
  }

  Future<void> _clearMac() async {
    var url = Uri.parse(
      "${Config.UrlApi}/api/UpdateRegister?userid=${Config.UserId}&Cusid=${Config.CusId}",
    );
    var headers = {
      'Verify_identity': Config.Verify_identity,
      "Accept": "application/json",
    };
    await http.post(url, headers: headers);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Palette.kToDark.shade100, Palette.kToDark.shade900],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
        ),
      );
    }

    return Scaffold(
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
          child: Column(
            children: [
              const Spacer(),
              _buildHeader(),
              const SizedBox(height: 40),
              _buildPinDisplay(),
              const SizedBox(height: 40),
              _buildNumPad(),
              const SizedBox(height: 20),
              _buildResetButton(),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.lock_outline, size: 60, color: Colors.white),
        ),
        const SizedBox(height: 24),
        const Text(
          'กรุณากรอกรหัส PIN',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  // Secret API config removed from this screen.

  Widget _buildPinDisplay() {
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_shakeAnimation.value, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(6, (index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      index < enteredPin.length
                          ? Colors.white
                          : Colors.white.withOpacity(0.3),
                  border: Border.all(color: Colors.white, width: 2),
                ),
              );
            }),
          ),
        );
      },
    );
  }

  Widget _buildNumPad() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: [
          _buildNumRow(['1', '2', '3']),
          const SizedBox(height: 20),
          _buildNumRow(['4', '5', '6']),
          const SizedBox(height: 20),
          _buildNumRow(['7', '8', '9']),
          const SizedBox(height: 20),
          _buildNumRow(['C', '0', '⌫']),
        ],
      ),
    );
  }

  Widget _buildNumRow(List<String> numbers) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: numbers.map((number) => _buildNumButton(number)).toList(),
    );
  }

  Widget _buildNumButton(String number) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        if (number == '⌫') {
          _onDeletePressed();
        } else if (number == 'C') {
          _onClearPressed();
        } else {
          _onNumberPressed(number);
        }
      },
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: Center(
          child:
              number == '⌫'
                  ? const Icon(
                    Icons.backspace_outlined,
                    color: Colors.white,
                    size: 24,
                  )
                  : Text(
                    number,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
        ),
      ),
    );
  }

  Widget _buildResetButton() {
    return TextButton(
      onPressed: _showResetDialog,
      child: Text(
        'ยกเลิกผู้ใช้งาน',
        style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 16),
      ),
    );
  }

  Future<void> _getDataMember() async {
    try {
      final json = await MemberService.getMemberData(Config.CusId);
      if (Config.data_member.isEmpty) {
        Config.data_member = json;
      }
    } catch (e) {
      print('Error getting member data: $e');
    }
  }
}
