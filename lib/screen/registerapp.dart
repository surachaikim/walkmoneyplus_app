import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';
// import 'package:walkmoney/model/cusid.dart';
// import 'package:walkmoney/model/profile.dart';
import 'package:walkmoney/palette.dart';
// import 'package:walkmoney/screen/login.dart';
import 'package:walkmoney/screen/passcode.dart';
// import 'package:walkmoney/screen/process.dart';
import 'package:walkmoney/service/config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
// import 'package:get_mac/get_mac.dart';
import 'package:device_info_plus/device_info_plus.dart';

import 'package:permission_handler/permission_handler.dart';

// import '../loading.dart';
import '../model/infologin.dart';

class RegisterAppScreen extends StatefulWidget {
  RegisterAppScreen({Key? key}) : super(key: key);

  @override
  State<RegisterAppScreen> createState() => _RegisterAppScreenState();
}

class _RegisterAppScreenState extends State<RegisterAppScreen> {
  final formkey = GlobalKey<FormState>();
  // final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  bool userchk = false;
  String Mac = '';
  bool loading = false;
  List infoLogin = [];
  List cusinfo = [];
  // String _MacCheck = "";
  String _cusid = '';
  String _username = '';
  String _password = '';
  String _pin = '';
  // String _platformVersion = 'Unknown';

  List<List<infologin>> info = [];

  // Secret taps for API config
  int _secretTapCount = 0;
  Timer? _secretTapTimer;

  Future<void> initPlatformState() async {
    String deviceId = "";
    // String deviceName = "";

    try {
      if (await Permission.contacts.request().isGranted) {
        // Either the permission was already granted before or the user just granted it.
      }

      Map<Permission, PermissionStatus> statuses =
          await [
            Permission.camera,
            Permission.storage,
            Permission.phone,
          ].request();
      print(statuses[Permission.location]);
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      deviceId = androidInfo.id;
      // androidInfo.model; // device name not used
    } on PlatformException {
      // deviceId = 'Failed to get device id.';
    }
    if (!mounted) return;
    setState(() {
      // _MacCheck = deviceId;
      Mac = deviceId;
    });
  }

  @override
  void initState() {
    super.initState();
    initPlatformState();
    _loadApiUrlFromPrefs();
  }

  @override
  void dispose() {
    _secretTapTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadApiUrlFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString('api_url');
      if (saved != null && saved.isNotEmpty && saved != Config.UrlApi) {
        Config.UrlApi = saved;
      }
    } catch (_) {}
  }

  void _onSecretTitleTap() {
    // 5 taps within 2 seconds opens the API config dialog
    _secretTapTimer?.cancel();
    _secretTapTimer = Timer(const Duration(seconds: 2), () {
      _secretTapCount = 0;
    });
    _secretTapCount++;
    if (_secretTapCount >= 5) {
      _secretTapCount = 0;
      _secretTapTimer?.cancel();
      _showApiConfigDialog();
    }
  }

  void _showApiConfigDialog() {
    const devUrl = 'https://mixprodev.mcloudcenter.com/WalkMoney';
    const pdUrl = 'https://mcloudcenter.com/WalkMoney';
    String selected =
        (Config.UrlApi == devUrl)
            ? 'dev'
            : (Config.UrlApi == pdUrl)
            ? 'pd'
            : 'pd';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('ตั้งค่า API'),
          content: StatefulBuilder(
            builder: (context, setStateSB) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioListTile<String>(
                    value: 'dev',
                    groupValue: selected,
                    onChanged: (v) => setStateSB(() => selected = v!),
                    title: const Text('DEV'),
                    subtitle: const Text(
                      'https://mixprodev.mcloudcenter.com/WalkMoney',
                    ),
                  ),
                  RadioListTile<String>(
                    value: 'pd',
                    groupValue: selected,
                    onChanged: (v) => setStateSB(() => selected = v!),
                    title: const Text('PD'),
                    subtitle: const Text('https://mcloudcenter.com/WalkMoney'),
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ยกเลิก'),
            ),
            ElevatedButton(
              onPressed: () async {
                final url = selected == 'dev' ? devUrl : pdUrl;
                try {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString('api_url', url);
                  Config.UrlApi = url;
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('ใช้ API: ${selected.toUpperCase()}'),
                      ),
                    );
                  }
                } catch (e) {
                  _showErrorDialog('ไม่สามารถบันทึกการตั้งค่าได้');
                }
              },
              child: const Text('บันทึก'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          IgnorePointer(
            ignoring: loading,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Palette.kToDark.shade100, Palette.kToDark.shade900],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: SingleChildScrollView(
                  child: Card(
                    elevation: 12,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    color: Colors.white.withOpacity(0.95),
                    margin: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 32,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Form(
                        key: formkey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 10),
                            GestureDetector(
                              onTap: _onSecretTitleTap,
                              child: Text(
                                "ลงทะเบียนผู้ใช้งาน",
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Palette.kToDark.shade400,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 30),
                            _buildTextFormField(
                              label: 'ชื่อผู้ใช้งาน',
                              hint: 'ชื่อผู้ใช้งาน (MBS)',
                              icon: Icons.person,
                              onSaved: (val) => _username = val!,
                            ),
                            const SizedBox(height: 20),
                            _buildTextFormField(
                              label: 'รหัสผ่านผู้ใช้งาน',
                              hint: 'รหัสผ่านผู้ใช้งาน (MBS)',
                              icon: Icons.lock,
                              obscureText: true,
                              onSaved: (val) => _password = val!,
                            ),
                            const SizedBox(height: 20),
                            _buildTextFormField(
                              label: 'รหัสอ้างอิง',
                              hint: 'รหัสอ้างอิง',
                              icon: Icons.badge,
                              onSaved: (val) => _cusid = val!,
                            ),
                            const SizedBox(height: 20),
                            _buildTextFormField(
                              label: 'กำหนด PIN',
                              hint: 'ใส่ตัวเลข 6 ตัว',
                              icon: Icons.pin,
                              maxLength: 6,
                              keyboardType: TextInputType.number,
                              onSaved: (val) => _pin = val!,
                            ),
                            const SizedBox(height: 30),
                            _buildRegisterButton(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (loading) _buildLoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildTextFormField({
    required String label,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    int? maxLength,
    TextInputType? keyboardType,
    required FormFieldSetter<String> onSaved,
  }) {
    return TextFormField(
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Palette.kToDark.shade200, width: 2),
        ),
        hintText: hint,
        labelText: label,
        prefixIcon: Icon(icon, color: Palette.kToDark.shade200),
      ),
      obscureText: obscureText,
      maxLength: maxLength,
      keyboardType: keyboardType,
      validator: RequiredValidator(errorText: "กรุณากรอกข้อมูล"),
      onSaved: onSaved,
    );
  }

  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        icon:
            loading
                ? SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                : const Icon(Icons.check_circle_outline, size: 28),
        label: Text(
          loading ? "กำลังดำเนินการ..." : "ลงทะเบียน",
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Palette.kToDark.shade400,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 6,
        ),
        onPressed: loading ? null : _handleRegister,
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.45),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  height: 26,
                  width: 26,
                  child: CircularProgressIndicator(strokeWidth: 3),
                ),
                const SizedBox(width: 16),
                Text(
                  'กำลังลงทะเบียน...',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Palette.kToDark.shade500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleRegister() async {
    if (formkey.currentState?.validate() != true) return;
    formkey.currentState?.save();

    if (_pin.length != 6) {
      _showErrorDialog('กรุณากำหนด PIN 6 ตัว');
      return;
    }

    setState(() => loading = true);

    try {
      bool userExists = await _checkUser(_username, _cusid);
      if (userExists) {
        await _loadLoginInfo(_username, "");
        await _getCusid();

        if (infoLogin.isNotEmpty && cusinfo.isNotEmpty) {
          final List<List<infologin>> tList = [
            [
              infologin(
                cusid: _cusid,
                password: _password,
                pin: _pin,
                username: _username,
                userId: infoLogin[0]["userId"].toString(),
                name: infoLogin[0]["name"].toString(),
                cpId: cusinfo[0]["cpId"],
                cpName: cusinfo[0]["cpName"],
                Imei: Mac,
              ),
            ],
          ];

          await _addToSP(tList);
          await _addPassword(_password, _cusid, _username);

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => PassCodeScreen()),
          );
        } else {
          _showErrorDialog('ข้อมูลการลงทะเบียนไม่สมบูรณ์');
        }
      } else {
        _showErrorDialog('ไม่พบชื่อผู้ใช้งาน หรือ มีการลงทะเบียนแล้ว');
      }
    } catch (e) {
      _showErrorDialog('เกิดข้อผิดพลาด: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(message),
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

  Future<bool> _loadLoginInfo(String username, String password) async {
    var url = Uri.parse(
      '${Config.UrlApi}/api/GetLogin?username=$username&password=$password&cusid=$_cusid',
    );
    var headers = {
      'Verify_identity': Config.Verify_identity,
      "Accept": "application/json",
    };
    var response = await http.get(url, headers: headers);

    if (response.statusCode == 200 && response.body.isNotEmpty) {
      var json = jsonDecode(response.body);
      infoLogin = json;
      return true;
    }
    return false;
  }

  Future<void> _getCusid() async {
    var url = Uri.parse("${Config.UrlApi}/api/GetConstant?Cusid=$_cusid");
    var headers = {
      'Verify_identity': Config.Verify_identity,
      "Accept": "application/json",
    };
    var response = await http.get(url, headers: headers);
    if (response.statusCode == 200 && response.body.isNotEmpty) {
      var json = jsonDecode(response.body);
      cusinfo = json;
    }
  }

  Future<void> _addToSP(List<List<infologin>> tList) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('loginlist', jsonEncode(tList));
  }

  Future<void> _addPassword(String pass, String cusid, String user) async {
    var url = Uri.parse(
      "${Config.UrlApi}/api/UpdateLogin?Password=$pass&Cusid=$cusid&User=$user&Mac=$Mac",
    );
    var headers = {
      'Verify_identity': Config.Verify_identity,
      "Accept": "application/json",
    };
    await http.post(url, headers: headers);
  }

  Future<bool> _checkUser(String user, String cusid) async {
    var url = Uri.parse(
      "${Config.UrlApi}/api/CheckUser?User=$user&Cusid=$cusid",
    );
    var headers = {
      'Verify_identity': Config.Verify_identity,
      "Accept": "application/json",
    };
    var response = await http.get(url, headers: headers);
    return response.body == "true";
  }
}
