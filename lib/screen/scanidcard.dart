import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:http/http.dart' as http;
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:walkmoney/service/config.dart';
import 'package:walkmoney/palette.dart';
import 'package:camera/camera.dart';
import 'package:walkmoney/screen/scan_camera.dart';
import 'package:walkmoney/screen/memberinfo.dart';

class ScanIdcardScreen extends StatefulWidget {
  const ScanIdcardScreen({Key? key}) : super(key: key);

  @override
  State<ScanIdcardScreen> createState() => _ScanIdcardScreenState();
}

class _ScanIdcardScreenState extends State<ScanIdcardScreen> {
  bool _isScanning = false;
  String _statusText = '';
  List _persons = [];
  String? _lastId; // raw 13-digit idcard extracted

  final TextRecognizer _textRecognizer = TextRecognizer(
    script: TextRecognitionScript.latin,
  );
  final BarcodeScanner _barcodeScanner = BarcodeScanner(
    formats: [BarcodeFormat.pdf417, BarcodeFormat.qrCode],
  );
  List<CameraDescription>? _cameras;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        centerTitle: true,
        title: const Text('แสกนบัตรประชาชน'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
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
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(top: 10),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Illustration
                        Center(
                          child: Image.asset(
                            'assets/images/idcard.png',
                            width: 120,
                            height: 120,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Status banner
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color:
                                _isScanning
                                    ? Colors.amber.withOpacity(0.15)
                                    : (_statusText.contains('ไม่พบ') ||
                                        _statusText.contains('ผิดพลาด'))
                                    ? Colors.red.withOpacity(0.1)
                                    : Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color:
                                  _isScanning
                                      ? Colors.amber.shade300
                                      : (_statusText.contains('ไม่พบ') ||
                                          _statusText.contains('ผิดพลาด'))
                                      ? Colors.red.shade300
                                      : Colors.green.shade300,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _isScanning
                                    ? Icons.autorenew_rounded
                                    : (_statusText.contains('ไม่พบ') ||
                                        _statusText.contains('ผิดพลาด'))
                                    ? Icons.error_outline
                                    : Icons.verified_rounded,
                                size: 18,
                                color:
                                    _isScanning
                                        ? Colors.amber.shade800
                                        : (_statusText.contains('ไม่พบ') ||
                                            _statusText.contains('ผิดพลาด'))
                                        ? Colors.red.shade700
                                        : Colors.green.shade800,
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  _statusText.isEmpty
                                      ? 'พร้อมสแกน'
                                      : _statusText,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color:
                                        _isScanning
                                            ? Colors.amber.shade800
                                            : (_statusText.contains('ไม่พบ') ||
                                                _statusText.contains('ผิดพลาด'))
                                            ? Colors.red.shade700
                                            : Colors.green.shade800,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Guidance
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blueGrey.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.blueGrey.withOpacity(0.15),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Icon(
                                Icons.info_outline,
                                size: 18,
                                color: Colors.blueGrey,
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'ถ่ายภาพบัตรให้ชัด อ่านได้ทั้งตัวอักษรและบาร์โค้ด (PDF417) โดยจัดบัตรให้เต็มกรอบและแสงสว่างพอ',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed:
                                _isScanning ? null : _openCameraWithFrame,
                            icon: const Icon(Icons.camera_alt),
                            label: const Text('ถ่ายรูป'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              backgroundColor: Colors.indigo,
                              foregroundColor: Colors.white,
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (_isScanning)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: CircularProgressIndicator(),
                            ),
                          ),
                        if (!_isScanning &&
                            _lastId != null &&
                            _persons.isNotEmpty)
                          Card(
                            elevation: 1,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.person,
                                        color: Colors.green,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          '${_persons[0]['title']}${_persons[0]['firstName']} ${_persons[0]['lastName']}',
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.badge_outlined,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        '${_persons[0]['idcardshow']}',
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Icon(
                                        Icons.location_on_outlined,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          '${_persons[0]['addrNo']} ม.${_persons[0]['moo']} ต.${_persons[0]['locality']} อ.${_persons[0]['district']} จ.${_persons[0]['province']} ${_persons[0]['zipCode']}',
                                          style: const TextStyle(fontSize: 13),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        if (!_isScanning && _lastId != null && _persons.isEmpty)
                          Card(
                            elevation: 0,
                            color: Colors.red.withOpacity(0.06),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: Colors.red.withOpacity(0.2),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.search_off,
                                    color: Colors.red.shade700,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'ไม่พบสมาชิก',
                                    style: TextStyle(
                                      color: Colors.red.shade700,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // _pickImage removed; using live camera with overlay instead

  Future<void> _openCameraWithFrame() async {
    try {
      setState(() => _isScanning = false);
      // Lazy load available cameras
      _cameras ??= await availableCameras();
      if (!mounted) return;
      final XFile? photo = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ScanCameraScreen(cameras: _cameras!),
          fullscreenDialog: true,
        ),
      );
      if (photo == null) return;
      setState(() {
        _isScanning = true;
        _statusText = 'กำลังประมวลผล...';
      });
      final id = await _extractThaiIdFromImage(photo);
      if (!mounted) return;
      if (id != null) {
        setState(() {
          _lastId = id;
          _statusText = 'พบเลขบัตร: ${_formatThaiId(id)}';
        });
        await _fetchMemberByIdcard(id);
      } else {
        setState(() {
          _statusText = 'ไม่พบเลขบัตร ลองถ่ายใหม่ให้ชัดขึ้น';
          _isScanning = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _statusText = 'ไม่สามารถเปิดกล้องได้';
        _isScanning = false;
      });
    }
  }

  Future<String?> _extractThaiIdFromImage(XFile image) async {
    final input = InputImage.fromFilePath(image.path);

    // Try barcode first
    try {
      final barcodes = await _barcodeScanner.processImage(input);
      for (final code in barcodes) {
        final raw = code.rawValue ?? '';
        final id = _parseThaiIdFromText(raw);
        if (id != null) return id;
      }
    } catch (_) {}

    // Fallback to OCR
    try {
      final result = await _textRecognizer.processImage(input);
      final text = result.text;
      final id = _parseThaiIdFromText(text);
      if (id != null) return id;
    } catch (_) {}

    return null;
  }

  String? _parseThaiIdFromText(String text) {
    final normalized = text.replaceAll('\n', ' ');
    final regex = RegExp(r'(\d[- ]?\d{4}[- ]?\d{5}[- ]?\d{2}[- ]?\d|\d{13})');
    final match = regex.firstMatch(normalized);
    if (match == null) return null;
    final digits = match.group(0)!.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length != 13) return null;
    if (!_isValidThaiId(digits)) return null;
    return digits;
  }

  bool _isValidThaiId(String digits) {
    if (digits.length != 13) return false;
    int sum = 0;
    for (int i = 0; i < 12; i++) {
      sum += int.parse(digits[i]) * (13 - i);
    }
    final check = (11 - (sum % 11)) % 10;
    return check == int.parse(digits[12]);
  }

  String _formatThaiId(String digits) {
    if (digits.length != 13) return digits;
    return '${digits[0]}-${digits.substring(1, 5)}-${digits.substring(5, 10)}-${digits.substring(10, 12)}-${digits.substring(12)}';
  }

  Future<void> _fetchMemberByIdcard(String idcard) async {
    // Check internet connectivity quickly
    final hasInternet = await InternetConnectionChecker().hasConnection;
    if (!hasInternet) {
      if (!mounted) return;
      setState(() {
        _isScanning = false;
        _statusText = 'ไม่มีการเชื่อมต่ออินเทอร์เน็ต';
      });
      await _showAlert('ไม่มีการเชื่อมต่ออินเทอร์เน็ต');
      return;
    }

    // Validate required configuration
    if (Config.CusId.isEmpty) {
      if (!mounted) return;
      setState(() {
        _isScanning = false;
        _statusText = 'Cusid ว่าง กรุณาเข้าสู่ระบบใหม่';
      });
      await _showAlert('Cusid ว่าง กรุณาเข้าสู่ระบบใหม่');
      return;
    }

    final url = Uri.parse(
      '${Config.UrlApi}/api/GetMemberByIdcard?Idcard=$idcard&Cusid=${Config.CusId}',
    );
    final headers = {
      'Verify_identity': Config.Verify_identity,
      'Accept': 'application/json',
    };

    http.Response resp;
    try {
      resp = await http
          .get(url, headers: headers)
          .timeout(const Duration(seconds: 12));
    } on TimeoutException {
      if (!mounted) return;
      setState(() {
        _isScanning = false;
        _statusText = 'การเชื่อมต่อล้มเหลว (หมดเวลา)';
      });
      await _showAlert('การเชื่อมต่อล้มเหลว (หมดเวลา)');
      return;
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isScanning = false;
        _statusText = 'เกิดข้อผิดพลาดในการเชื่อมต่อ';
      });
      await _showAlert('เกิดข้อผิดพลาดในการเชื่อมต่อ');
      return;
    }

    if (!mounted) return;
    try {
      if (resp.statusCode != 200) {
        setState(() {
          _isScanning = false;
          _statusText = 'เซิร์ฟเวอร์ตอบกลับผิดพลาด (HTTP ${resp.statusCode})';
          _persons = [];
        });
        return;
      }

      final body = resp.body;
      if (body.isEmpty) {
        setState(() {
          _isScanning = false;
          _statusText = 'ข้อมูลว่างจากเซิร์ฟเวอร์';
          _persons = [];
        });
        return;
      }

      final data = jsonDecode(body);
      if (data is List && data.isNotEmpty) {
        setState(() {
          _persons = data;
          _isScanning = false;
          _statusText = 'พบสมาชิก ${data.length} รายการ';
        });
        // Navigate to Memberinfo for the first matched person
        if (!mounted) return;
        final p = data[0];
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (_) => Memberinfo(
                  personid: p['personId']?.toString() ?? '',
                  name:
                      '${p['title'] ?? ''}${p['firstName'] ?? ''} ${p['lastName'] ?? ''}',
                  idcard: p['idcard']?.toString() ?? (_lastId ?? ''),
                  idcardshow: p['idcardshow']?.toString() ?? '',
                  adress1:
                      '${p['addrNo'] ?? ''} ม.${p['moo'] ?? ''} ต.${p['locality'] ?? ''} อ.${p['district'] ?? ''} จ.${p['province'] ?? ''} ${p['zipCode'] ?? ''}',
                  adress2:
                      '${p['addrNo1'] ?? ''} ม.${p['moo1'] ?? ''} ต.${p['locality1'] ?? ''} อ.${p['district1'] ?? ''} จ.${p['province1'] ?? ''} ${p['zipCode1'] ?? ''}',
                  phone: p['phone']?.toString() ?? '',
                ),
          ),
        );
      } else {
        setState(() {
          _persons = [];
          _isScanning = false;
          _statusText = 'ไม่พบสมาชิก';
        });
      }
    } catch (e) {
      setState(() {
        _isScanning = false;
        _statusText = 'เกิดข้อผิดพลาดในการประมวลผลข้อมูล';
        _persons = [];
      });
    }
  }

  Future<void> _showAlert(String message) async {
    if (!mounted) return;
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder:
          (context) => AlertDialog(
            title: const Text('แจ้งเตือน'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('ตกลง'),
              ),
            ],
          ),
    );
  }

  @override
  void dispose() {
    _textRecognizer.close();
    _barcodeScanner.close();
    super.dispose();
  }
}

// Overlay painter removed for simplified UX (no preview mode)
