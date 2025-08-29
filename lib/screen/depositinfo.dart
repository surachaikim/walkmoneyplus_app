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

import '../service/loading3.dart';
import 'loaninfo.dart';
import 'mycard.dart';
import 'serachname.dart';

class DepositinfoScreen extends StatefulWidget {
  DepositinfoScreen({
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
  State<DepositinfoScreen> createState() => _DepositinfoScreenState();
}

class _DepositinfoScreenState extends State<DepositinfoScreen> {
  final _controller = PageController();
  List accountInfo = [];
  List movementInfo = [];
  final formats = DateFormat.yMd('th');
  final f = NumberFormat('#,###.00', 'th_TH');

  int cardNum = 0;
  bool isLoading = true;
  bool isLoadingHistory = true;

  @override
  void initState() {
    super.initState();
    loadData(widget.idcard);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Loading()
        : Scaffold(
            appBar: AppBar(centerTitle: true, title: Text('ฝาก/ถอน')),
            backgroundColor: Colors.white,
            body: SafeArea(
              child: Column(
                children: [
                  SizedBox(height: 25),
                  if (accountInfo.isNotEmpty) ...[
                    Container(
                      height: 200,
                      child: PageView.builder(
                        controller: _controller,
                        onPageChanged: (page) {
                          setState(() {
                            cardNum = page;
                          });
                        },
                        itemBuilder: (context, index) {
                          return mycard(
                            balance: accountInfo[index]["balance"],
                            cardNumber: index,
                            name: accountInfo[index]["accountName"],
                            accountno: accountInfo[index]["accountNo"],
                            typeaccount: accountInfo[index]["typeAccName"],
                            status: accountInfo[index]["status"],
                            color: Color.fromARGB(255, 18, 76, 124),
                          );
                        },
                        itemCount: accountInfo.length,
                      ),
                    ),
                  ] else ...[
                    Container(
                      height: 200,
                      child: Center(child: Text("ไม่มีบัญชี !")),
                    ),
                  ],
                  SizedBox(height: 25),
                  SmoothPageIndicator(
                    controller: _controller,
                    count: accountInfo.length,
                    effect:
                        ExpandingDotsEffect(activeDotColor: Colors.orange),
                  ),
                  SizedBox(height: 25),
                  _buildActionButtons(),
                  SizedBox(height: 20),
                  _buildNavigationButtons(),
                ],
              ),
            ),
          );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _actionButton(
          'assets/images/deposit01.png',
          "ฝากเงิน",
          () {
            if (accountInfo.isNotEmpty) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AdddepositScreen(
                    accountno: '${accountInfo[cardNum]["accountNo"]}',
                    balance: '${accountInfo[cardNum]["balance"]}',
                  ),
                ),
              );
            }
          },
        ),
        _actionButton(
          'assets/images/withdraw.png',
          "ถอนเงิน",
          () {
            if (accountInfo.isNotEmpty) {
              if (accountInfo[cardNum]["status"] == "1") {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddwithdrawScreen(
                      accountno: '${accountInfo[cardNum]["accountNo"]}',
                      balance: '${accountInfo[cardNum]["balance"]}',
                    ),
                  ),
                );
              } else {
                _showErrorDialog('บัญชีนี้ห้ามถอน');
              }
            }
          },
        ),
        _actionButton(
          'assets/images/history.png',
          "ประวัติ",
          () async {
            if (accountInfo.isNotEmpty) {
              await getMovement(accountInfo[cardNum]["accountNo"]);
              _showHistoryModal();
            }
          },
        ),
      ],
    );
  }

  Widget _buildNavigationButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _actionButton(
          'assets/images/search3.png',
          "ค้นหา",
          () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => Menuscreen(tab: '0'),
              ),
            );
          },
        ),
        _actionButton(
          'assets/images/loan.png',
          "ชำระสินเชื่อ",
          () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => LoaninfoScreen(
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
        _actionButton(
          'assets/images/personal.png',
          "ข้อมูลสมาชิก",
          _showMemberInfoModal,
        ),
      ],
    );
  }

  Widget _actionButton(String imagePath, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
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
            child: Center(child: Image.asset(imagePath)),
          ),
          SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(message, style: TextStyle(color: Colors.red)),
          actions: <Widget>[
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: Text('ตกลง'),
            ),
          ],
        );
      },
    );
  }

  void _showHistoryModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          builder: (_, controller) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(25.0),
                  topRight: const Radius.circular(25.0),
                ),
              ),
              child: Column(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "รายการฝากถอน",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 25),
                  Expanded(
                    child: isLoadingHistory
                        ? Loading3()
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(0, 10, 10, 10),
                            itemCount: movementInfo.length,
                            itemBuilder: (BuildContext context, int index) {
                              return _buildHistoryItem(movementInfo[index]);
                            },
                            separatorBuilder: (BuildContext context, int index) =>
                                const Divider(),
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildHistoryItem(Map<String, dynamic> movement) {
    final isDeposit = movement["docType"] == "1";
    final amountColor = isDeposit ? Colors.green : Colors.red;
    final amountPrefix = isDeposit ? "+ " : "- ";

    return Container(
      height: 90,
      width: MediaQuery.of(context).size.width - 20,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topRight: const Radius.circular(25.0),
          bottomRight: const Radius.circular(25.0),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0xFFd8dbe0),
            offset: Offset(1, 1),
            blurRadius: 20.0,
            spreadRadius: 10,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                height: 60,
                width: 60,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: AssetImage('assets/images/cash-flow.png'),
                  ),
                ),
              ),
              SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "เลขที่เอกสาร : ${movement["docNo"]}",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "เลขที่บัญชี : ${movement["accountNo"]}",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey[400],
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    formats.format(DateTime.parse(movement["movementDate"])),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.all(10),
            child: Text(
              "$amountPrefix${movement["totalAmount"]}",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: amountColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showMemberInfoModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          builder: (_, controller) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(25.0),
                  topRight: const Radius.circular(25.0),
                ),
              ),
              child: Column(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "ข้อมูลสมาชิก",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 25),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.all(16),
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
                                _buildMemberInfoSection('ข้อมูลทั่วไป', [
                                  _buildInfoTile('ชื่อ-นามสกุล', widget.name),
                                  _buildInfoTile('เลขบัตรประชาชน', widget.idcardshow),
                                  _buildInfoTile('รหัสสมาชิก', widget.personid),
                                ]),
                                _buildMemberInfoSection('ข้อมูลที่อยู่', [
                                  _buildInfoTile('ที่อยู่ปัจจุบัน', widget.adress1),
                                  _buildInfoTile('ที่อยู่ที่ทำงาน', widget.adress2),
                                ]),
                                _buildMemberInfoSection('ข้อมูลอื่นๆ', [
                                  _buildInfoTile('เบอร์โทร', widget.phone),
                                  _buildInfoTile('Email', ''),
                                ]),
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
        );
      },
    );
  }

  Widget _buildMemberInfoSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Divider(),
        ...children,
        SizedBox(height: 12),
      ],
    );
  }

  Widget _buildInfoTile(String title, String subtitle) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
    );
  }

  Future<void> getMovement(String accountNo) async {
    setState(() => isLoadingHistory = true);
    try {
      var url = Uri.parse(
        '${Config.UrlApi}/api/GetMovement?Cusid=${Config.CusId}&AccountNo=$accountNo',
      );
      var headers = {
        'Verify_identity': Config.Verify_identity,
        "Accept": "application/json",
      };
      var response = await http.get(url, headers: headers).timeout(const Duration(seconds: 90));
      if (response.statusCode == 200) {
        setState(() {
          movementInfo = jsonDecode(response.body);
        });
      }
    } catch (e) {
      // Handle error
    } finally {
      setState(() => isLoadingHistory = false);
    }
  }

  Future<void> loadData(String idcard) async {
    try {
      var url = Uri.parse(
        '${Config.UrlApi}/api/GetAccountDeposit?Cusid=${Config.CusId}&Idcard=$idcard',
      );
      var headers = {
        'Verify_identity': Config.Verify_identity,
        "Accept": "application/json",
      };
      var response = await http.get(url, headers: headers).timeout(const Duration(seconds: 90));
      if (response.statusCode == 200) {
        setState(() {
          accountInfo = jsonDecode(response.body);
        });
      }
    } catch (e) {
      // Handle error
    } finally {
      setState(() => isLoading = false);
    }
  }
}