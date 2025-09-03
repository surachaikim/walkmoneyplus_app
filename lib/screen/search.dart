import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:walkmoney/palette.dart';
import 'package:walkmoney/screen/accountinfo.dart';
import 'package:walkmoney/screen/serachname.dart';
import 'package:walkmoney/service/config.dart';
import 'package:http/http.dart' as http;
import 'package:walkmoney/screen/searchidcard.dart';
import 'package:walkmoney/screen/serachpersonid.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class SearchMainScreen extends StatefulWidget {
  const SearchMainScreen({super.key});

  @override
  State<SearchMainScreen> createState() => _SearchMainScreenState();
}

class _SearchMainScreenState extends State<SearchMainScreen>
    with TickerProviderStateMixin {
  List persons = [];
  bool textScanning = false;
  String scannedText = "";
  XFile? imageFile;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    textRecognizer.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 40, // shorter app bar
        automaticallyImplyLeading: false, // ปิดปุ่มย้อนกลับ
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
              _buildHeader(),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(top: 20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                  ),
                  child:
                      textScanning ? _buildLoadingWidget() : _buildSearchGrid(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final double maxTextWidth =
        MediaQuery.of(context).size.width -
        64; // 16px padding left/right + breathing room
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.22),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.45),
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 10),
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxTextWidth),
                  child: Text(
                    Config.Name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      fontSize: 16,
                      letterSpacing: 0.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.apartment_rounded,
                      size: 16,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                    const SizedBox(width: 6),
                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: maxTextWidth - 40),
                      child: Text(
                        Config.CpName,
                        maxLines: 1,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'ID: ${Config.UserId}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.95),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Palette.kToDark.shade200,
            strokeWidth: 4,
          ),
          const SizedBox(height: 24),
          Text(
            'กำลังสแกนข้อมูล...',
            style: TextStyle(
              fontSize: 18,
              color: Palette.kToDark.shade400,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'โปรดรอสักครู่',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchGrid() {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              Text(
                'ระบบค้นหาสมาชิก',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Palette.kToDark.shade400,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'เลือกวิธีการค้นหาที่ต้องการ',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 1.1,
                  children: [
                    _buildSearchCard(
                      icon: 'assets/images/search1.png',
                      title: 'ค้นหาด้วยชื่อ',
                      subtitle: 'ชื่อ-นามสกุล',
                      colors: [
                        Palette.kToDark.shade200,
                        Palette.kToDark.shade400,
                      ],
                      onTap:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SerachnameScreen(),
                            ),
                          ),
                    ),
                    _buildSearchCard(
                      icon: 'assets/images/search2.png',
                      title: 'ค้นหาด้วยบัตรประชาชน',
                      subtitle: 'เลขบัตร 13 หลัก',
                      colors: [
                        Palette.kToDark.shade200,
                        Palette.kToDark.shade400,
                      ],
                      onTap:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SerachIdcardScreen(),
                            ),
                          ),
                    ),
                    _buildSearchCard(
                      icon: 'assets/images/serach3.png',
                      title: 'สแกนบัตร',
                      subtitle: 'ถ่ายภาพบัตร',
                      colors: [
                        Palette.kToDark.shade300,
                        Palette.kToDark.shade500,
                      ],
                      onTap: () => getImage(ImageSource.camera),
                    ),
                    _buildSearchCard(
                      icon: 'assets/images/search4.png',
                      title: 'ค้นหาด้วยรหัสสมาชิก',
                      subtitle: 'รหัสสมาชิก',
                      colors: [
                        Palette.kToDark.shade300,
                        Palette.kToDark.shade500,
                      ],
                      onTap:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SerachPersonidScreen(),
                            ),
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchCard({
    required String icon,
    required String title,
    required String subtitle,
    required List<Color> colors,
    required VoidCallback onTap,
  }) {
    final Color accent = colors.isNotEmpty ? colors.last : Palette.kToDark;
    return SearchActionCard(
      icon: icon,
      title: title,
      subtitle: subtitle,
      accent: accent,
      onTap: onTap,
    );
  }

  void getImage(ImageSource source) async {
    try {
      final pickedImage = await ImagePicker().pickImage(source: source);
      if (pickedImage != null) {
        setState(() {
          textScanning = true;
        });
        imageFile = pickedImage;
        getRecognisedText(pickedImage);
      }
    } catch (e) {
      setState(() {
        textScanning = false;
      });
      imageFile = null;
      scannedText = "Error occurred while scanning";
    }
  }

  void getRecognisedText(XFile image) async {
    try {
      final RecognizedText recognizedText = await textRecognizer.processImage(
        InputImage.fromFilePath(image.path),
      );

      int lineCount = 0;
      for (TextBlock block in recognizedText.blocks) {
        for (TextLine line in block.lines) {
          lineCount++;
          try {
            if (lineCount == 5 || lineCount == 6 || lineCount == 7) {
              var parts = line.text.split(" ");
              if (parts.length >= 5) {
                scannedText = parts.sublist(0, 5).join("");
                break;
              }
            }
          } catch (_) {}
        }
        if (scannedText.isNotEmpty) break;
      }

      if (scannedText.isNotEmpty) {
        getmemberByqrIdcard(scannedText);
      } else {
        setState(() {
          textScanning = false;
        });
        _showErrorDialog('ไม่สามารถอ่านข้อมูลจากบัตรได้');
      }
    } catch (e) {
      setState(() {
        textScanning = false;
      });
      _showErrorDialog('เกิดข้อผิดพลาดในการสแกน');
    }
  }

  Future<void> getmemberByqrIdcard(String idcard) async {
    try {
      var url = Uri.parse(
        "${Config.UrlApi}/api/GetMemberByIdcard?Idcard=$idcard&Cusid=${Config.CusId}",
      );

      var headers = {
        'Verify_identity': Config.Verify_identity,
        "Accept": "application/json",
      };

      var response = await http.get(url, headers: headers);

      setState(() {
        textScanning = false;
      });

      if (response.body.isNotEmpty) {
        var json = jsonDecode(response.body);
        persons = json;

        if (persons.isNotEmpty) {
          if (!mounted) return;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => AccountinfoScreen(
                    personid: persons[0]['personId'],
                    idcard: persons[0]['idcard'],
                    idcardshow: persons[0]['idcardshow'],
                    name:
                        "${persons[0]['title']}${persons[0]['firstName']} ${persons[0]['lastName']}",
                    adress1:
                        "${persons[0]['addrNo']} ม.${persons[0]['moo']} ต.${persons[0]['locality']} อ.${persons[0]['district']} จ.${persons[0]['province']} ${persons[0]['zipCode']}",
                    adress2:
                        "${persons[0]['addrNo1']} ม.${persons[0]['moo1']} ต.${persons[0]['locality1']} อ.${persons[0]['district1']} จ.${persons[0]['province1']} ${persons[0]['zipCode1']}",
                    phone: persons[0]['phone'],
                  ),
            ),
          );
        } else {
          _showErrorDialog('ไม่พบข้อมูลสมาชิก');
        }
      } else {
        _showErrorDialog('ไม่พบข้อมูลสมาชิก');
      }
    } catch (e) {
      setState(() {
        textScanning = false;
      });
      _showErrorDialog('เกิดข้อผิดพลาดในการค้นหา');
    }
  }

  Future<void> _showErrorDialog(String message) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
              const SizedBox(width: 8),
              Text('แจ้งเตือน'),
            ],
          ),
          content: Text(message, style: TextStyle(fontSize: 16)),
          actions: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Palette.kToDark.shade400,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
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
}

class SearchActionCard extends StatefulWidget {
  final String icon;
  final String title;
  final String subtitle;
  final Color accent;
  final VoidCallback onTap;

  const SearchActionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.onTap,
  });

  @override
  State<SearchActionCard> createState() => _SearchActionCardState();
}

class _SearchActionCardState extends State<SearchActionCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(20);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onTap,
        onHighlightChanged: (v) => setState(() => _pressed = v),
        borderRadius: borderRadius,
        splashColor: widget.accent.withValues(alpha: 0.08),
        highlightColor: widget.accent.withValues(alpha: 0.04),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          transform: Matrix4.identity()..scale(_pressed ? 0.98 : 1.0),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFFFFFF), Color(0xFFF6FAFF)],
            ),
            borderRadius: borderRadius,
            border: Border.all(color: const Color(0xFFE8F0FE), width: 1),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 12,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: widget.accent.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: widget.accent.withValues(alpha: 0.15),
                      width: 1,
                    ),
                  ),
                  child: Image.asset(
                    widget.icon,
                    width: 28,
                    height: 28,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Palette.kToDark.shade400,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
