import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:walkmoney/loading.dart';
import 'package:walkmoney/screen/searchidcard.dart';
import 'package:walkmoney/service/config.dart';
import 'package:http/http.dart' as http;

import '../model/deposit.dart';

import 'package:card_swiper/card_swiper.dart';
import 'package:walkmoney/screen/receipt.dart';
import 'package:walkmoney/screen/adddeposit.dart';
import 'package:walkmoney/screen/addloan.dart';
import 'package:walkmoney/screen/addwithdraw.dart';
import 'package:walkmoney/model/loan.dart';

import 'package:walkmoney/screen/menu.dart';
import 'package:card_loading/card_loading.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'depositinfo.dart';
import 'mycardloan.dart';
import 'serachname.dart';

class LoaninfoScreen extends StatefulWidget {
  LoaninfoScreen({
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
  State<LoaninfoScreen> createState() => _LoaninfoScreenState();
}

class _LoaninfoScreenState extends State<LoaninfoScreen> {
  late PageController _pageController;
  final _controller = PageController();

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
  int cardNum = 0;
  @override
  void initState() {
    super.initState();

    loadDataloan(widget.idcard);

    _pageController = PageController(viewportFraction: 0.8, initialPage: 0);
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? Loading()
        : Scaffold(
            backgroundColor: Colors.grey[300],
            body: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('ทำรายการสินเชื่อ', style: TextStyle(fontSize: 26)),
                      ],
                    ),
                  ),
                  SizedBox(height: 25),
                  if (loaninfo.length > 0) ...[
                    Container(
                      height: 230,
                      child: PageView.builder(
                        scrollDirection: Axis.horizontal,
                        controller: _controller,
                        onPageChanged: _onPageViewChange,
                        itemBuilder: (context, index) {
                          return mycardloan(
                            balance: loaninfo[index]["loanBalance"],
                            cardNumber: index,
                            name: loaninfo[index]["accountName"],
                            accountno: loaninfo[index]["accountNo"],
                            typeaccount: loaninfo[index]["typeLoanName"],
                            status: loaninfo[index]["status"],
                            color: Color.fromARGB(255, 206, 112, 4),
                            minpay: loaninfo[index]["minPayment"].toString(),
                          );
                        },
                        itemCount: loaninfo.length,
                      ),
                    ),
                  ] else ...[
                    Container(
                      height: 200,
                      child: PageView(
                        scrollDirection: Axis.horizontal,
                        children: [Center(child: Text("ไม่มีบัญชี !"))],
                      ),
                    ),
                  ],
                  SizedBox(height: 25),
                  SmoothPageIndicator(
                    controller: _controller,
                    count: loaninfo.length,
                    effect: ExpandingDotsEffect(activeDotColor: Colors.orange),
                  ),
                  SizedBox(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      InkWell(
                        child: Column(
                          children: [
                            Container(
                              height: 80,
                              width: 80,
                              padding: EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.shade400,
                                    blurRadius: 20,
                                    spreadRadius: 10,
                                  ),
                                ],
                              ),
                              child: Center(
                                child:
                                    Image.asset('assets/images/payloan.png'),
                              ),
                            ),
                            SizedBox(height: 12),
                            Text(
                              "ชำระสินเชื่อ",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        onTap: loaninfo.isNotEmpty
                            ? () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AddloanScreen(
                                      accountno:
                                          '${loaninfo[cardNum]["accountNo"]}',
                                      balance:
                                          '${loaninfo[cardNum]["loanBalance"]}',
                                    ),
                                  ),
                                );
                              }
                            : null,
                      ),
                      InkWell(
                        child: Column(
                          children: [
                            Container(
                              height: 80,
                              width: 80,
                              padding: EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.shade400,
                                    blurRadius: 20,
                                    spreadRadius: 10,
                                  ),
                                ],
                              ),
                              child: Center(
                                child:
                                    Image.asset('assets/images/history.png'),
                              ),
                            ),
                            SizedBox(height: 12),
                            Text(
                              "ประวัติ",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) {
                              return GestureDetector(
                                onTap: () => Navigator.of(context).pop(),
                                child: Container(
                                  color: Color.fromRGBO(0, 0, 0, 0.001),
                                  child: GestureDetector(
                                    onTap: () {},
                                    child: DraggableScrollableSheet(
                                      initialChildSize: 0.7,
                                      minChildSize: 0.3,
                                      maxChildSize: 0.8,
                                      builder: (_, controller) {
                                        return Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.only(
                                              topLeft: const Radius.circular(
                                                25.0,
                                              ),
                                              topRight: const Radius.circular(
                                                25.0,
                                              ),
                                            ),
                                          ),
                                          child: Column(
                                            children: [
                                              IconButton(
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                                icon: Icon(Icons.close),
                                              ),
                                              SizedBox(height: 10),
                                              Text(
                                                "รายการรับชำระ",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              SizedBox(height: 25),
                                              Expanded(
                                                child: ListView.separated(
                                                  padding:
                                                      const EdgeInsets.all(
                                                    8,
                                                  ),
                                                  itemCount: 5,
                                                  itemBuilder: (
                                                    BuildContext context,
                                                    int index,
                                                  ) {
                                                    return Container(
                                                      height: 50,
                                                      child: ListTile(
                                                        leading: CircleAvatar(
                                                          backgroundImage:
                                                              AssetImage(
                                                            'assets/images/stamp.png',
                                                          ),
                                                        ),
                                                        title: Text(
                                                          "สินเชื่อเลขที่ LO021515",
                                                        ),
                                                        subtitle: Text(
                                                          'วันที่ 12/12/2566',
                                                        ),
                                                        trailing:
                                                            Text('5000'),
                                                      ),
                                                    );
                                                  },
                                                  separatorBuilder: (
                                                    BuildContext context,
                                                    int index,
                                                  ) =>
                                                      const Divider(),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                      InkWell(
                        child: Column(
                          children: [
                            Container(
                              height: 80,
                              width: 80,
                              padding: EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.shade400,
                                    blurRadius: 20,
                                    spreadRadius: 10,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Image.asset(
                                    'assets/images/personal.png'),
                              ),
                            ),
                            SizedBox(height: 12),
                            Text(
                              "ข้อมูลสมาชิก",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) {
                              return GestureDetector(
                                onTap: () => Navigator.of(context).pop(),
                                child: Container(
                                  color: Color.fromRGBO(0, 0, 0, 0.001),
                                  child: GestureDetector(
                                    onTap: () {},
                                    child: DraggableScrollableSheet(
                                      initialChildSize: 0.9,
                                      minChildSize: 0.3,
                                      maxChildSize: 0.9,
                                      builder: (_, controller) {
                                        return Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.only(
                                              topLeft: const Radius.circular(
                                                25.0,
                                              ),
                                              topRight: const Radius.circular(
                                                25.0,
                                              ),
                                            ),
                                          ),
                                          child: Column(
                                            children: [
                                              IconButton(
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                                icon: Icon(Icons.close),
                                              ),
                                              SizedBox(height: 10),
                                              Text(
                                                "ข้อมูลสมาชิก",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              SizedBox(height: 25),
                                              Expanded(
                                                child: SingleChildScrollView(
                                                  child: Padding(
                                                    padding:
                                                        EdgeInsets.all(16),
                                                    child: Card(
                                                      elevation: 2,
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                          12,
                                                        ),
                                                      ),
                                                      child: Padding(
                                                        padding:
                                                            EdgeInsets.all(
                                                          16,
                                                        ),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              'ข้อมูลทั่วไป',
                                                              style: TextStyle(
                                                                fontSize: 18,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                            Divider(),
                                                            ListTile(
                                                              title: Text(
                                                                'ชื่อ-นามสกุล',
                                                              ),
                                                              subtitle: Text(
                                                                widget.name,
                                                              ),
                                                            ),
                                                            ListTile(
                                                              title: Text(
                                                                'เลขบัตรประชาชน',
                                                              ),
                                                              subtitle: Text(
                                                                widget
                                                                    .idcardshow,
                                                              ),
                                                            ),
                                                            ListTile(
                                                              title: Text(
                                                                'รหัสสมาชิก',
                                                              ),
                                                              subtitle: Text(
                                                                widget
                                                                    .personid,
                                                              ),
                                                            ),
                                                            SizedBox(
                                                                height: 12),
                                                            Text(
                                                              'ข้อมูลที่อยู่',
                                                              style: TextStyle(
                                                                fontSize: 18,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                            Divider(),
                                                            ListTile(
                                                              title: Text(
                                                                'ที่อยู่ปัจจุบัน',
                                                              ),
                                                              subtitle: Text(
                                                                widget
                                                                    .adress1,
                                                              ),
                                                            ),
                                                            ListTile(
                                                              title: Text(
                                                                'ที่อยู่ที่ทำงาน',
                                                              ),
                                                              subtitle: Text(
                                                                widget
                                                                    .adress2,
                                                              ),
                                                            ),
                                                            SizedBox(
                                                                height: 12),
                                                            Text(
                                                              'ข้อมูลอื่นๆ',
                                                              style: TextStyle(
                                                                fontSize: 18,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                            Divider(),
                                                            ListTile(
                                                              title: Text(
                                                                'เบอร์โทร',
                                                              ),
                                                              subtitle: Text(
                                                                widget.phone,
                                                              ),
                                                            ),
                                                            ListTile(
                                                              title: Text(
                                                                'Email',
                                                              ),
                                                              subtitle:
                                                                  Text(''),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      InkWell(
                        child: Column(
                          children: [
                            Container(
                              height: 80,
                              width: 80,
                              padding: EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.shade400,
                                    blurRadius: 20,
                                    spreadRadius: 10,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Image.asset('assets/images/dpwh.png'),
                              ),
                            ),
                            SizedBox(height: 12),
                            Text(
                              "ฝาก/ถอน",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DepositinfoScreen(
                                personid: widget.personid,
                                idcardshow: widget.idcardshow,
                                idcard: widget.idcard,
                                name: widget.name,
                                adress1: widget.adress1,
                                adress2: widget.adress2,
                                phone: widget.phone,
                              ),
                            ),
                          );
                        },
                      ),
                      InkWell(
                        child: Column(
                          children: [
                            Container(
                              height: 80,
                              width: 80,
                              padding: EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.shade400,
                                    blurRadius: 20,
                                    spreadRadius: 10,
                                  ),
                                ],
                              ),
                              child: Center(
                                child:
                                    Image.asset('assets/images/search.png'),
                              ),
                            ),
                            SizedBox(height: 12),
                            Text(
                              "ค้นหา(ชื่อ)",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SerachnameScreen(),
                            ),
                          );
                        },
                      ),
                      InkWell(
                        child: Column(
                          children: [
                            Container(
                              height: 80,
                              width: 80,
                              padding: EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.shade400,
                                    blurRadius: 20,
                                    spreadRadius: 10,
                                  ),
                                ],
                              ),
                              child: Center(
                                child:
                                    Image.asset('assets/images/search3.png'),
                              ),
                            ),
                            SizedBox(height: 12),
                            Text(
                              "ค้นหา",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Menuscreen(tab: '0'),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
  }

  _onPageViewChange(int page) {
    print("Current Page: " + page.toString());
    cardNum = page;
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

  void loadDataloan(idcard) async {
    var url = Uri.parse(
      Config.UrlApi +
          '/api/GetAccountLoan?Idcard=' +
          idcard +
          '&Cusid=' +
          Config.CusId,
    );

    var headers = {
      'Verify_identity': Config.Verify_identity,
      "Accept": "application/json",
    };
    var response = await http.get(url, headers: headers).timeout(
      const Duration(seconds: 90),
      onTimeout: () {
        setState(() {
          loading = false;
        });

        return http.Response('Error', 408);
      },
    );

    if (response.statusCode == 400) {
      setState(() {
        loading = false;
      });
    } else if (response.statusCode == 200) {
      var json = jsonDecode(response.body);
      loaninfo = [];
      loaninfo = json;
      setState(() {
        loading = false;
      });
    }
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

  static Future<bool> AddDatLoan(
    AccountNo,
    AccountName,
    String Amount,
    MovementDate,
    PersonId,
    Type,
    DocId,
  ) async {
    var url = Uri.parse(
      Config.UrlApi +
          '/api/InsertLoan?AccountNo=' +
          AccountNo +
          '&AccountName=' +
          AccountName +
          '&Amount=' +
          Amount +
          '&MovementDate=' +
          MovementDate +
          '&PersonId=' +
          PersonId +
          '&Type=' +
          Type +
          '&UserId=' +
          Config.UserId +
          '&Cusid=' +
          Config.CusId +
          '&DocId=' +
          DocId,
    );

    var headers = {
      'Verify_identity': Config.Verify_identity,
      "Accept": "application/json",
    };
    var response = await http.post(url, headers: headers);

    if (response.body == "true") {
      return Future<bool>.value(true);
    } else {
      return Future<bool>.value(false);
    }
  }
}