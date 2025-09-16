import 'dart:async';

import 'package:flutter/material.dart';

import 'package:walkmoney/screen/profile.dart';
import 'package:walkmoney/screen/chartdashbord.dart';
import 'package:walkmoney/screen/exit-popup.dart';
// import 'package:walkmoney/screen/print.dart';
import 'package:walkmoney/screen/history.dart';
import 'package:walkmoney/screen/serachname.dart';
import 'package:walkmoney/service/config.dart';
import 'package:http/http.dart' as http;

import 'search.dart';
import 'passcode.dart';

class Menuscreen extends StatefulWidget {
  const Menuscreen({Key? key, required this.tab}) : super(key: key);
  final String tab;

  @override
  State<StatefulWidget> createState() {
    return _MenuscreenState();
  }
}

class _MenuscreenState extends State<Menuscreen> with WidgetsBindingObserver {
  Timer? _logoutTimer;
  DateTime? _lastActive;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _selectedIndex = int.parse(widget.tab);
    _resetLogoutTimer();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _logoutTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _lastActive = DateTime.now();
      _logoutTimer?.cancel();
    } else if (state == AppLifecycleState.resumed) {
      if (_lastActive != null) {
        final diff = DateTime.now().difference(_lastActive!);
        if (diff.inMinutes >= 10) {
          _performLogout();
          return;
        }
      }
      _resetLogoutTimer();
    }
  }

  void _resetLogoutTimer() {
    _logoutTimer?.cancel();
    _logoutTimer = Timer(const Duration(minutes: 10), _performLogout);
    _lastActive = DateTime.now();
  }

  void _performLogout() {
    _logoutTimer?.cancel();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text('หมดเวลาการใช้งาน'),
            content: const Text('คุณไม่ได้ใช้งานเป็นเวลานาน ระบบจะออกจากระบบ'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const PassCodeScreen()),
                    (route) => false,
                  );
                },
                child: const Text('ตกลง'),
              ),
            ],
          ),
    );
  }

  int _selectedIndex = 0;
  final List<Widget> _pageWidget = <Widget>[
    SearchMainScreen(),
    ChartDBScreen(),
    SerachnameScreen(),
    HistoryScreen(),
    ProfileScreen(),
  ];
  final List<BottomNavigationBarItem> _menuBar = <BottomNavigationBarItem>[
    BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'หน้าหลัก'),
    BottomNavigationBarItem(
      icon: Icon(Icons.dashboard_rounded),
      label: 'ข้อมูล',
    ),
    BottomNavigationBarItem(icon: Icon(Icons.search_rounded), label: 'ค้นชื่อ'),
    BottomNavigationBarItem(
      icon: Icon(Icons.history_rounded),
      label: 'ประวัติ',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.settings_rounded),
      label: 'ตั้งค่า',
    ),
  ];
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _resetLogoutTimer();
  }

  Future<bool> updateuselogin(username, password, st) async {
    var url = Uri.parse(
      Config.UrlApi +
          '/api/UpdateUseLogin?User=' +
          username +
          '&password=' +
          password +
          '&st=' +
          st +
          '&Cusid=' +
          Config.CusId,
    );

    var headers = {
      'Verify_identity': Config.Verify_identity,
      "Accept": "application/json",
    };
    var response = await http.post(url, headers: headers);

    if (response.statusCode != 400) {
      return Future<bool>.value(true);
    } else {
      return Future<bool>.value(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => showExitPopup(context),
      child: Scaffold(
        extendBody: true,
        body: _pageWidget.elementAt(_selectedIndex),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, -2),
              ),
            ],
            border: Border(
              top: BorderSide(color: Colors.grey.shade300, width: 0.5),
            ),
          ),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            onTap: _onItemTapped,
            backgroundColor: Colors.white,
            unselectedItemColor: Colors.grey,
            selectedItemColor: Color.fromARGB(255, 0, 0, 0),
            currentIndex: _selectedIndex,
            items: _menuBar,
            selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
            showUnselectedLabels: true,
            elevation: 0,
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: FloatingActionButton(
          backgroundColor: Color.fromARGB(255, 1, 15, 41),
          elevation: 8,
          tooltip: 'ค้นหา (ชื่อ-นามสกุล)',
          child: Icon(Icons.search, color: Colors.white, size: 30),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SerachnameScreen()),
            );
          },
        ),
      ),
    );
  }
}
