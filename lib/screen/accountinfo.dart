import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:walkmoney/widgets/beautiful_loading.dart';
import 'package:walkmoney/service/account_service.dart';

import 'package:walkmoney/screen/adddeposit.dart';
import 'package:walkmoney/screen/addloan.dart';
import 'package:walkmoney/screen/addwithdraw.dart';
import 'package:walkmoney/screen/menu.dart';
import 'package:card_loading/card_loading.dart';

class AccountinfoScreen extends StatefulWidget {
  AccountinfoScreen({
    Key? key,
    required this.personid,
    required this.name,
    required this.idcard,
    required this.idcardshow,
    required this.adress1,
    required this.adress2,
    required this.phone,
  }) : super(key: key);

  final String personid;
  final String name;
  final String idcard;
  final String idcardshow;
  final String adress1;
  final String adress2;
  final String phone;

  @override
  State<AccountinfoScreen> createState() => _AccountinfoScreenState();
}

class _AccountinfoScreenState extends State<AccountinfoScreen> {
  late PageController _pageController;

  List Accountinfo = [];
  List loaninfo = [];
  late List info = [];
  late List info2 = [];

  var f = NumberFormat('#,###.00', 'th_TH');

  String accountNo = '';
  String accountName = '';
  String typeAccName = '';
  String statusAcc = '';

  String typeLoanName = "";
  String accountLoanNo = '';
  String accountLoanName = '';
  String loanBalance = '';
  String minpayment = '';

  int currentIndex = 0;
  bool loading = true;
  bool loadingacc = false;
  bool loadingacc2 = false;

  bool isHovered = false;
  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _pageController = PageController(viewportFraction: 0.8, initialPage: 0);
  }

  Future<void> _loadInitialData() async {
    try {
      await Future.wait([_loadAccountData(), _loadLoanData()]);
    } catch (e) {
      print('Error loading initial data: $e');
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  Future<void> _loadAccountData() async {
    try {
      final accounts = await AccountService.getAccountDeposit(widget.idcard);
      if (accounts.isNotEmpty) {
        Accountinfo = accounts;
        await _getAccountDetails(accounts[0]["accountNo"]);
      }
    } catch (e) {
      print('Error loading account data: $e');
    }
  }

  Future<void> _loadLoanData() async {
    try {
      final loans = await AccountService.getAccountLoan(widget.idcard);
      if (loans.isNotEmpty) {
        loaninfo = loans;
        await _getLoanDetails(loans[0]["accountNo"]);
      }
    } catch (e) {
      print('Error loading loan data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? const BeautifulLoading(message: 'กำลังโหลดข้อมูลบัญชี')
        : DefaultTabController(
          length: 3, // length of tabs
          initialIndex: 0,
          child: Scaffold(
            appBar: AppBar(
              bottom: const TabBar(
                labelColor: Colors.orange,
                indicatorColor: Colors.orange,
                automaticIndicatorColorAdjustment: true,
                unselectedLabelColor: Colors.white,
                labelStyle: TextStyle(fontWeight: FontWeight.w800),
                tabs: [
                  Tab(text: 'เงินฝาก'),
                  Tab(text: 'สินเชื่อ'),
                  Tab(text: 'สมาชิก'),
                ],
              ),
              centerTitle: true,
              title: Text("ทำรายการ"),
              leading: IconButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Menuscreen(tab: '0'),
                    ),
                  );
                },
                icon: Icon(Icons.home),
              ),
            ),
            body: TabBarView(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Column(
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width,
                            height: 150,
                            child: PageView.builder(
                              itemCount: Accountinfo.length,
                              pageSnapping: true,
                              controller: _pageController,
                              onPageChanged: (page) async {
                                setState(() {
                                  loadingacc = true;
                                  currentIndex = page;
                                });

                                try {
                                  await _getAccountDetails(
                                    '${Accountinfo[page]["accountNo"]}',
                                  );
                                } catch (e) {
                                  print('Error loading account details: $e');
                                }

                                Timer(const Duration(milliseconds: 500), () {
                                  if (mounted) {
                                    setState(() {
                                      loadingacc = false;
                                    });
                                  }
                                });
                              },
                              itemBuilder: (context, index) {
                                return Container(
                                  margin: EdgeInsets.all(10),
                                  child: Column(
                                    children: [
                                      Card(
                                        shape: RoundedRectangleBorder(
                                          side: BorderSide(
                                            color: Color.fromARGB(
                                              179,
                                              182,
                                              189,
                                              202,
                                            ),
                                            width: 1,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            15,
                                          ),
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            ListTile(
                                              tileColor: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.only(
                                                  topRight: Radius.circular(
                                                    20.0,
                                                  ),
                                                  topLeft: Radius.circular(
                                                    20.0,
                                                  ),
                                                ),
                                              ),
                                              title: Column(
                                                children: [
                                                  Text(
                                                    'ยอดเงินคงเหลือ',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(height: 10),
                                            Text(
                                              '${Accountinfo[index]["balance"]}' +
                                                  " ฿",
                                              style: TextStyle(
                                                fontSize: 25,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                            SizedBox(height: 20),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(bottom: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: _buildIndicator(),
                            ),
                          ),
                          if (Accountinfo.length > 0) ...[
                            loadingacc
                                ? Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: CardLoading(
                                    height: 180,
                                    width: 350,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(15),
                                    ),
                                    margin: EdgeInsets.only(bottom: 10),
                                  ),
                                )
                                : Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    5,
                                    10,
                                    5,
                                    20,
                                  ),
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                    child: Column(
                                      children: [
                                        ListTile(
                                          leading: Icon(Icons.menu_book),
                                          tileColor: Color.fromARGB(
                                            173,
                                            42,
                                            142,
                                            241,
                                          ),
                                          title: Text(
                                            accountNo,
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(10),
                                          child: Column(
                                            children: [
                                              Row(
                                                children: <Widget>[
                                                  Text(
                                                    'ชื่อบัญชี :',
                                                    style:
                                                        GoogleFonts.kodchasan(
                                                          color: Colors.grey,
                                                          fontSize: 14,
                                                        ),
                                                  ),
                                                  Expanded(child: Container()),
                                                  RichText(
                                                    text: TextSpan(
                                                      children: [
                                                        TextSpan(
                                                          text: accountName,
                                                          style:
                                                              GoogleFonts.kodchasan(
                                                                color:
                                                                    Colors
                                                                        .black,
                                                                fontSize: 14,
                                                              ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 15),
                                              Row(
                                                children: <Widget>[
                                                  Text(
                                                    'ประเภทบัญชี :',
                                                    style:
                                                        GoogleFonts.kodchasan(
                                                          color: Colors.grey,
                                                          fontSize: 14,
                                                        ),
                                                  ),
                                                  Expanded(child: Container()),
                                                  RichText(
                                                    text: TextSpan(
                                                      children: [
                                                        TextSpan(
                                                          text: typeAccName,
                                                          style:
                                                              GoogleFonts.kodchasan(
                                                                color:
                                                                    Colors
                                                                        .black,
                                                                fontSize: 14,
                                                              ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 15),
                                              Row(
                                                children: <Widget>[
                                                  Text(
                                                    'สถานะบัญชี :',
                                                    style:
                                                        GoogleFonts.kodchasan(
                                                          color: Colors.grey,
                                                          fontSize: 14,
                                                        ),
                                                  ),
                                                  Expanded(child: Container()),
                                                  RichText(
                                                    text: TextSpan(
                                                      children: [
                                                        TextSpan(
                                                          text: statusAcc,
                                                          style:
                                                              GoogleFonts.kodchasan(
                                                                color:
                                                                    Colors
                                                                        .black,
                                                                fontSize: 14,
                                                              ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 25),
                                      ],
                                    ),
                                  ),
                                ),
                            SizedBox(height: 15),
                            loadingacc
                                ? CardLoading(
                                  height: 30,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(15),
                                  ),
                                  width: 100,
                                  margin: EdgeInsets.only(bottom: 10),
                                )
                                : Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          minimumSize: const Size.fromHeight(
                                            40,
                                          ),
                                          backgroundColor:
                                              Colors.green, // background
                                        ),
                                        onPressed: () async {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (context) => AdddepositScreen(
                                                    accountno:
                                                        '${info[0]["accountNo"]}',
                                                    balance:
                                                        '${info[0]["balance"]}',
                                                  ),
                                            ),
                                          );
                                        },
                                        child: const Text(
                                          "ฝากเงิน",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      if (statusAcc == "ห้ามถอน")
                                        ...[]
                                      else ...[
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            minimumSize: const Size.fromHeight(
                                              40,
                                            ),
                                            backgroundColor: Colors.red, // NEW
                                          ),
                                          onPressed: () async {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder:
                                                    (
                                                      context,
                                                    ) => AddwithdrawScreen(
                                                      accountno:
                                                          '${info[0]["accountNo"]}',
                                                      balance:
                                                          '${info[0]["balance"]}',
                                                    ),
                                              ),
                                            );
                                          },
                                          child: const Text("ถอนเงิน"),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                          ] else ...[
                            Text("ไม่พบบัญชี"),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Column(
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width,
                            height: 150,
                            child: PageView.builder(
                              itemCount: loaninfo.length,
                              pageSnapping: true,
                              controller: _pageController,
                              onPageChanged: (page) async {
                                setState(() {
                                  loadingacc = true;
                                  currentIndex = page;
                                });

                                try {
                                  await _getLoanDetails(
                                    '${loaninfo[page]["accountNo"]}',
                                  );
                                } catch (e) {
                                  print('Error loading loan details: $e');
                                }

                                Timer(const Duration(milliseconds: 500), () {
                                  if (mounted) {
                                    setState(() {
                                      loadingacc = false;
                                    });
                                  }
                                });
                              },
                              itemBuilder: (context, index) {
                                return Container(
                                  margin: EdgeInsets.all(10),
                                  child: Column(
                                    children: [
                                      Card(
                                        shape: RoundedRectangleBorder(
                                          side: BorderSide(
                                            color: Color.fromARGB(
                                              179,
                                              201,
                                              202,
                                              206,
                                            ),
                                            width: 1,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            15,
                                          ),
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            ListTile(
                                              tileColor: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.only(
                                                  topRight: Radius.circular(
                                                    15.0,
                                                  ),
                                                  topLeft: Radius.circular(
                                                    15.0,
                                                  ),
                                                ),
                                              ),
                                              title: Column(
                                                children: [
                                                  Text(
                                                    'ยอดกู้คงเหลือ',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(height: 10),
                                            Text(
                                              f.format(
                                                    double.parse(
                                                      '${loaninfo[index]["loanBalance"]}',
                                                    ),
                                                  ) +
                                                  " ฿",
                                              style: TextStyle(
                                                fontSize: 25,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                            SizedBox(height: 20),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(bottom: 40),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: _buildIndicator2(),
                            ),
                          ),
                          if (loaninfo.length > 0) ...[
                            loadingacc
                                ? Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: CardLoading(
                                    height: 180,
                                    width: 350,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(15),
                                    ),
                                    margin: EdgeInsets.only(bottom: 10),
                                  ),
                                )
                                : Card(
                                  clipBehavior: Clip.antiAlias,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Column(
                                    children: [
                                      ListTile(
                                        leading: Icon(Icons.book),
                                        tileColor: Color.fromARGB(
                                          174,
                                          248,
                                          165,
                                          87,
                                        ),
                                        title: Text(
                                          accountLoanNo,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Column(
                                          children: [
                                            Row(
                                              children: <Widget>[
                                                Text(
                                                  'ชื่อบัญชี :',
                                                  style: GoogleFonts.kodchasan(
                                                    color: Colors.grey,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                Expanded(child: Container()),
                                                RichText(
                                                  text: TextSpan(
                                                    children: [
                                                      TextSpan(
                                                        text: accountLoanName,
                                                        style:
                                                            GoogleFonts.kodchasan(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 14,
                                                            ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 15),
                                            Row(
                                              children: <Widget>[
                                                Text(
                                                  'ประเภทบัญชี :',
                                                  style: GoogleFonts.kodchasan(
                                                    color: Colors.grey,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                Expanded(child: Container()),
                                                RichText(
                                                  text: TextSpan(
                                                    children: [
                                                      TextSpan(
                                                        text: typeLoanName,
                                                        style:
                                                            GoogleFonts.kodchasan(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 14,
                                                            ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 15),
                                            Row(
                                              children: <Widget>[
                                                Text(
                                                  'ยอดที่ต้องชำระ :',
                                                  style: GoogleFonts.kodchasan(
                                                    color: Colors.grey,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                Expanded(child: Container()),
                                                RichText(
                                                  text: TextSpan(
                                                    children: [
                                                      TextSpan(
                                                        text: minpayment,
                                                        style:
                                                            GoogleFonts.kodchasan(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 14,
                                                            ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 10),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 25),
                                    ],
                                  ),
                                ),
                            SizedBox(height: 15),
                            loadingacc
                                ? CardLoading(
                                  height: 30,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(15),
                                  ),
                                  width: 100,
                                  margin: EdgeInsets.only(bottom: 10),
                                )
                                : Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          minimumSize: const Size.fromHeight(
                                            40,
                                          ),

                                          backgroundColor: Colors.orange, // NEW
                                        ),
                                        onPressed: () async {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (context) => AddloanScreen(
                                                    accountno:
                                                        '${info2[0]["accountNo"]}',
                                                    balance:
                                                        '${info2[0]["loanBalance"]}',
                                                  ),
                                            ),
                                          );
                                        },
                                        child: const Text("ชำระสินเชื่อ"),
                                      ),
                                    ],
                                  ),
                                ),
                          ] else ...[
                            Text("ไม่มีบัญชีสินเชื่อ"),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(12),
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ข้อมูลทั่วไป',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Divider(),
                          ListTile(
                            title: Text('ชื่อ-นามสกุล'),
                            subtitle: Text(widget.name),
                          ),
                          ListTile(
                            title: Text('เลขบัตรประชาชน'),
                            subtitle: Text(widget.idcardshow),
                          ),
                          ListTile(
                            title: Text('รหัสสมาชิก'),
                            subtitle: Text(widget.personid),
                          ),
                          SizedBox(height: 12),
                          Text(
                            'ข้อมูลที่อยู่',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Divider(),
                          ListTile(
                            title: Text('ที่อยู่ปัจจุบัน'),
                            subtitle: Text(widget.adress1),
                          ),
                          ListTile(
                            title: Text('ที่อยู่ที่ทำงาน'),
                            subtitle: Text(widget.adress2),
                          ),
                          SizedBox(height: 12),
                          Text(
                            'ข้อมูลอื่นๆ',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Divider(),
                          ListTile(
                            title: Text('เบอร์โทร'),
                            subtitle: Text(widget.phone),
                          ),
                          ListTile(title: Text('Email'), subtitle: Text('')),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
  }

  void Onclick(bool isHovered) => setState(() {
    this.isHovered = isHovered;
  });
  Widget _indicatior(bool isActive) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 400),
      height: 8,
      width: isActive ? 15 : 8,
      margin: EdgeInsets.only(right: 5),
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 248, 123, 20),
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }

  Future<void> _getAccountDetails(String accountNo) async {
    try {
      final accountDetails = await AccountService.getDepositByAccountNo(
        accountNo,
      );
      if (accountDetails.isNotEmpty) {
        info = accountDetails;
        accountName = '${info[0]["accountName"]}';
        accountNo = '${info[0]["accountNo"]}';
        typeAccName = '${info[0]["typeAccName"]}';

        final status = '${info[0]["status"]}';
        if (status == "1") {
          statusAcc = 'เปิดบัญชี';
        } else if (status == "2") {
          statusAcc = 'ห้ามถอน';
        } else if (status == "3") {
          statusAcc = 'ปิดบัญชี';
        }

        if (mounted) {
          setState(() {});
        }
      }
    } catch (e) {
      print('Error getting account details: $e');
    }
  }

  Future<void> _getLoanDetails(String accountNo) async {
    try {
      final loanDetails = await AccountService.getLoanByAccountNo(accountNo);
      if (loanDetails.isNotEmpty) {
        info2 = loanDetails;
        accountLoanName = '${info2[0]["accountName"]}';
        accountLoanNo = '${info2[0]["accountNo"]}';
        typeLoanName = '${info2[0]["typeLoanName"]}';
        loanBalance = '${info2[0]["loanBalance"]}';
        minpayment = f.format(double.parse('${info2[0]["minPayment"]}'));

        if (mounted) {
          setState(() {});
        }
      }
    } catch (e) {
      print('Error getting loan details: $e');
    }
  }

  List<Widget> _buildIndicator() {
    List<Widget> indicators = [];
    for (var i = 0; i < Accountinfo.length; i++) {
      if (currentIndex == i) {
        indicators.add(_indicatior(true));
      } else {
        indicators.add(_indicatior(false));
      }
    }
    return indicators;
  }

  List<Widget> _buildIndicator2() {
    List<Widget> indicators = [];
    for (var i = 0; i < loaninfo.length; i++) {
      if (currentIndex == i) {
        indicators.add(_indicatior(true));
      } else {
        indicators.add(_indicatior(false));
      }
    }
    return indicators;
  }

  String generateRandomString(int len) {
    var r = Random();
    const _chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    return List.generate(
      len,
      (index) => _chars[r.nextInt(_chars.length)],
    ).join();
  }
}
