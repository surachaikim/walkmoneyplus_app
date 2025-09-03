import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:walkmoney/palette.dart';
import 'package:walkmoney/screen/mycard_loan.dart';
import 'package:walkmoney/widgets/beautiful_loading.dart';
import 'package:walkmoney/service/member_service.dart';

import 'accountdeposit.dart';

class Memberinfo extends StatefulWidget {
  const Memberinfo({
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
  State<Memberinfo> createState() => _MemberinfoState();
}

class _MemberinfoState extends State<Memberinfo> {
  final _controllerdp = PageController();
  final _controllerlo = PageController();

  List Accountinfo = [];
  List movementinfo = [];
  List movementlaontinfo = [];
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

  bool loadinghistory = true;

  bool isHovered = false;
  int cardNum = 0;
  bool _isMemberInfoExpanded = false;
  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      await Future.wait([_loadDepositData(), _loadLoanData()]);
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

  Future<void> _loadDepositData() async {
    try {
      final deposits = await MemberService.getAccountDeposit(widget.idcard);
      if (deposits.isNotEmpty) {
        Accountinfo = deposits;
        await _loadMovementData(deposits[0]["accountNo"]);
      }
    } catch (e) {
      print('Error loading deposit data: $e');
    }
  }

  Future<void> _loadLoanData() async {
    try {
      final loans = await MemberService.getAccountLoan(widget.idcard);
      if (loans.isNotEmpty) {
        loaninfo = loans;
        await _loadLoanMovementData(loans[0]["accountNo"]);
      }
    } catch (e) {
      print('Error loading loan data: $e');
    }
  }

  Future<void> _loadMovementData(String accountNo) async {
    try {
      final movements = await MemberService.getMovement(accountNo);
      movementinfo = movements;
      if (mounted) {
        setState(() {
          loadinghistory = false;
        });
      }
    } catch (e) {
      print('Error loading movement data: $e');
    }
  }

  Future<void> _loadLoanMovementData(String accountNo) async {
    try {
      final movements = await MemberService.getMovementLoan(accountNo);
      movementlaontinfo = movements;
      if (mounted) {
        setState(() {
          loadinghistory = false;
        });
      }
    } catch (e) {
      print('Error loading loan movement data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Palette.kToDark.shade100, Palette.kToDark.shade900],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                title: Text(
                  'ข้อมูลสมาชิก',
                  style: TextStyle(color: Colors.white),
                ),
                centerTitle: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                pinned: true,
                iconTheme: const IconThemeData(color: Colors.white),
              ),
              SliverToBoxAdapter(
                child: Container(
                  padding: EdgeInsets.all(10),
                  child: _buildMemberInfoCard(),
                ),
              ),
              SliverToBoxAdapter(child: Container(child: _buildAccountPages())),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMemberInfoCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 5,
      child: Container(
        padding: EdgeInsets.all(15),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: AssetImage('assets/images/userlist.png'),
                ),
                SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      widget.personid,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
                Spacer(),
                IconButton(
                  icon: Icon(
                    _isMemberInfoExpanded
                        ? Icons.expand_less
                        : Icons.expand_more,
                  ),
                  onPressed: () {
                    setState(() {
                      _isMemberInfoExpanded = !_isMemberInfoExpanded;
                    });
                  },
                ),
              ],
            ),
            if (_isMemberInfoExpanded)
              Column(
                children: [
                  SizedBox(height: 10),
                  Divider(),
                  SizedBox(height: 10),
                  _buildInfoRow(
                    Icons.credit_card,
                    "เลขบัตรประชาชน",
                    widget.idcardshow,
                  ),
                  _buildInfoRow(Icons.phone, "เบอร์โทร", widget.phone),
                  _buildInfoRow(Icons.location_on, "ที่อยู่", widget.adress1),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600]),
          SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: Colors.grey[600])),
              SizedBox(height: 3),
              Text(value, style: TextStyle(fontSize: 14), maxLines: 2),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAccountPages() {
    if (loading) {
      return Container(
        height: MediaQuery.of(context).size.height * 0.5,
        child: const BeautifulLoading(message: 'กำลังโหลดข้อมูลสมาชิก'),
      );
    }

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            tabs: [
              Tab(
                child: Text(
                  'บัญชีเงินฝาก',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              Tab(
                child: Text(
                  'บัญชีเงินกู้',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.tealAccent,
          ),
          Container(
            height: MediaQuery.of(context).size.height * 0.39,
            child: TabBarView(
              children: [_buildDepositPage(), _buildLoanPage()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDepositPage() {
    if (Accountinfo.isEmpty) {
      return Center(
        child: Text(
          "ไม่พบข้อมูลบัญชีเงินฝาก",
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: _controllerdp,
            itemCount: Accountinfo.length,
            itemBuilder: (context, index) {
              var St = "";
              if (Accountinfo[index]["status"] == "1") {
                St = " ปกติ ";
              } else if (Accountinfo[index]["status"] == "2") {
                St = " ห้ามถอน ";
              } else {
                St = " ปิดสัญญา ";
              }
              return MyCardDeposit(
                balance: Accountinfo[index]["balance"],
                cardNumber: index,
                name: Accountinfo[index]["accountName"],
                accountno: Accountinfo[index]["accountNo"],
                typeaccount: Accountinfo[index]["typeAccName"],
                status: St,
                color: Color.fromARGB(255, 6, 116, 206),
                movementinfo: movementinfo,
              );
            },
          ),
        ),
        if (Accountinfo.length > 1)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SmoothPageIndicator(
              controller: _controllerdp,
              count: Accountinfo.length,
              effect: JumpingDotEffect(
                activeDotColor: Colors.tealAccent,
                dotColor: Colors.white54,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildLoanPage() {
    if (loaninfo.isEmpty) {
      return Center(
        child: Text(
          "ไม่พบข้อมูลบัญชีเงินกู้",
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: _controllerlo,
            itemCount: loaninfo.length,
            itemBuilder: (context, index) {
              var Stlo = "";

              if (loaninfo[index]["status"] == "5") {
                Stlo = " ติดตามหนี้ ";
              } else if (loaninfo[index]["status"] == "4") {
                Stlo = " ปิดสัญญา ";
              } else if (loaninfo[index]["status"] == "3") {
                Stlo = " ระหว่างชำระ ";
              }
              return MyCardLoan(
                balance:
                    f
                        .format(
                          double.parse(
                            loaninfo[index]["loanBalance"].toString(),
                          ),
                        )
                        .toString(),
                cardNumber: index,
                name: loaninfo[index]["accountName"],
                accountno: loaninfo[index]["accountNo"],
                typeaccount: loaninfo[index]["typeLoanName"],
                status: Stlo,
                color: Color.fromARGB(255, 228, 91, 13),
                minPayment: f.format(loaninfo[index]["minPayment"]),
                loaninfo: movementlaontinfo,
                term: loaninfo[index]["term"],
                totalamount: loaninfo[index]["totalAmount"],
              );
            },
          ),
        ),
        if (loaninfo.length > 1)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SmoothPageIndicator(
              controller: _controllerlo,
              count: loaninfo.length,
              effect: JumpingDotEffect(
                activeDotColor: Colors.orangeAccent,
                dotColor: Colors.white54,
              ),
            ),
          ),
      ],
    );
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
