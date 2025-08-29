import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:walkmoney/service/config.dart';
import 'package:http/http.dart' as http;

import '../model/deposit.dart';
import '../service/config.dart';

import 'package:flutter/material.dart';

import 'package:card_swiper/card_swiper.dart';
import 'package:walkmoney/screen/receipt.dart';
import 'package:walkmoney/screen/adddeposit.dart';
import 'package:walkmoney/screen/addloan.dart';
import 'package:walkmoney/screen/addwithdraw.dart';
import 'package:walkmoney/model/loan.dart';

import 'package:walkmoney/screen/menu.dart';

class ProcessScreen extends StatefulWidget {
  const ProcessScreen({
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
  State<ProcessScreen> createState() => _nameState();
}

final _textFieldController = TextEditingController();
List Accountinfo = [];
List loaninfo = [];
var f = NumberFormat('###.0#', 'th_TH');
String Amount = "";
String _scanBarcode = 'Unknown';

Deposit deposit = Deposit(
  Accountno: '',
  AccountName: '',
  MovementDate: '',
  Amount: '',
  PersonId: '',
  Type: '',
  DocNo: '',
);

Loan loan = Loan(
  Accountno: '',
  AccountName: '',
  DatePay: '',
  Amount: '',
  PersonId: '',
  DocId: '',
  UserId: '',
);

String MinPayment = '-';
String TotalAmount = '-';
String TypeLoanName = '-';
String PersonId = '-';
String DocId = "";

class _nameState extends State<ProcessScreen> {
  @override
  void initState() {
    super.initState();

    loaddata(widget.idcard);
    loadDataloan(widget.idcard);
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("ทำรายการ"),
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => Menuscreen(tab: '0')),
            );
          },
          icon: Icon(Icons.home),
        ),
        backgroundColor: Color.fromARGB(255, 248, 248, 246),
        shadowColor: Color.fromARGB(255, 8, 64, 129),
      ),
      backgroundColor: Color.fromARGB(255, 248, 248, 246),
      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SizedBox(height: 15),
            DefaultTabController(
              length: 3, // length of tabs
              initialIndex: 0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Container(
                    child: TabBar(
                      labelColor: Colors.blueGrey,
                      automaticIndicatorColorAdjustment: true,
                      unselectedLabelColor: Colors.black,
                      labelStyle: TextStyle(fontWeight: FontWeight.w800),
                      tabs: [
                        Tab(text: 'เงินฝาก'),
                        Tab(text: 'สินเชื่อ'),
                        Tab(text: 'สมาชิก'),
                      ],
                    ),
                  ),
                  Container(
                    height: 510, //height of TabBarView
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: Colors.grey, width: 0.5),
                      ),
                    ),
                    child: TabBarView(
                      children: <Widget>[
                        Container(
                          child: ListView.separated(
                            padding: const EdgeInsets.all(8),
                            itemCount: Accountinfo.length,
                            itemBuilder: (BuildContext context, int index) {
                              return Container(
                                height: 190,
                                color: Color.fromARGB(255, 248, 248, 246),
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    side: BorderSide(
                                      color: Colors.white70,
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      ListTile(
                                        tileColor: Colors.blueGrey,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.only(
                                            topRight: Radius.circular(15.0),
                                            topLeft: Radius.circular(15.0),
                                          ),
                                        ),
                                        title: Column(
                                          children: [
                                            Text(
                                              '${Accountinfo[index]["accountNo"]} : ${Accountinfo[index]["typeAccName"]} ',
                                              style: TextStyle(fontSize: 14),
                                            ),
                                            Text(
                                              '${Accountinfo[index]["accountName"]}',
                                              style: TextStyle(fontSize: 14),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        "ยอดเงินคงเหลือ ",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
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
                                      SizedBox(height: 5),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          ElevatedButton(
                                            child: const Text('ฝาก'),
                                            onPressed: () async {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder:
                                                      (
                                                        context,
                                                      ) => AdddepositScreen(
                                                        accountno:
                                                            '${Accountinfo[index]["accountNo"]}',
                                                        balance:
                                                            '${Accountinfo[index]["balance"]}',
                                                      ),
                                                ),
                                              );
                                            },
                                          ),
                                          const SizedBox(width: 8),
                                          ElevatedButton(
                                            child: const Text('ถอน'),
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder:
                                                      (
                                                        context,
                                                      ) => AddwithdrawScreen(
                                                        accountno:
                                                            '${Accountinfo[index]["accountNo"]}',
                                                        balance:
                                                            '${Accountinfo[index]["balance"]}',
                                                      ),
                                                ),
                                              );
                                            },
                                          ),
                                          const SizedBox(width: 8),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                            separatorBuilder:
                                (BuildContext context, int index) =>
                                    const Divider(),
                          ),
                        ),
                        Container(
                          child: Container(
                            child: ListView.separated(
                              padding: const EdgeInsets.all(8),
                              itemCount: loaninfo.length,
                              itemBuilder: (BuildContext context, int index) {
                                return Container(
                                  height: 230,
                                  color: Color.fromARGB(255, 248, 248, 246),
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                        color: Colors.white70,
                                        width: 1,
                                      ),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        ListTile(
                                          tileColor: Colors.blueGrey,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.only(
                                              topRight: Radius.circular(15.0),
                                              topLeft: Radius.circular(15.0),
                                            ),
                                          ),
                                          title: Column(
                                            children: [
                                              Text(
                                                ' ${loaninfo[index]["typeLoanName"]}  : ${loaninfo[index]["accountNo"]}',
                                                style: TextStyle(fontSize: 14),
                                              ),
                                              SizedBox(height: 5),
                                              Text(
                                                'ชื่อบัญชี :' +
                                                    '${loaninfo[index]["accountName"]}',
                                                style: TextStyle(fontSize: 14),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          child: Column(
                                            children: [
                                              SizedBox(height: 15),
                                              Row(
                                                children: [
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                      top: 10,
                                                      left: 40,
                                                    ),
                                                    child: Text(
                                                      "ยอดกู้คงเหลือ ",
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(width: 120),
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                      top: 10,
                                                    ),
                                                    child: Text(
                                                      f.format(
                                                            double.parse(
                                                              '${loaninfo[index]["loanBalance"]}',
                                                            ),
                                                          ) +
                                                          " ฿",
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                      top: 10,
                                                      left: 40,
                                                    ),
                                                    child: Text(
                                                      "ยอดที่ต้องชำระ ",
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(width: 120),
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                      top: 10,
                                                    ),
                                                    child: Text(
                                                      f.format(
                                                            double.parse(
                                                              '${loaninfo[index]["minPayment"]}',
                                                            ),
                                                          ) +
                                                          " ฿",
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 15),
                                              Padding(
                                                padding: EdgeInsets.fromLTRB(
                                                  0,
                                                  0,
                                                  0,
                                                  10,
                                                ),
                                                child: ElevatedButton(
                                                  child: const Text('จ่าย'),
                                                  onPressed: () async {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder:
                                                            (
                                                              context,
                                                            ) => AddloanScreen(
                                                              accountno:
                                                                  '${loaninfo[index]["accountNo"]}',
                                                              balance:
                                                                  '${loaninfo[index]["loanBalance"]}',
                                                            ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                              separatorBuilder:
                                  (BuildContext context, int index) =>
                                      const Divider(),
                            ),
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
                                  ListTile(
                                    title: Text('Email'),
                                    subtitle: Text(
                                      'Surachai.chumnoiy@gmail.com',
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void loaddata(idcard) async {
    var url = Uri.parse(
      Config.UrlApi +
          '/api/GetAccountDeposit?Cusid=' +
          Config.CusId +
          '&Idcard=' +
          '$idcard',
    );
    var headers = {
      'Verify_identity': Config.Verify_identity,
      "Accept": "application/json",
    };

    var response = await http.get(url, headers: headers);
    var json = jsonDecode(response.body);
    Accountinfo = [];
    Accountinfo = json;
    setState(() {
      Accountinfo = [];
      Accountinfo = json;
    });
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
    var response = await http.get(url, headers: headers);
    var json = jsonDecode(response.body);
    loaninfo = [];
    loaninfo = json;
    setState(() {
      loaninfo = [];
      loaninfo = json;
    });
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

  static Future<bool> AddData(
    AccountNo,
    AccountName,
    String Amount,
    UserId,
    MovementDate,
    PersonId,
    Type,
    DocId,
  ) async {
    var url = Uri.parse(
      Config.UrlApi +
          '/api/InsertDeposit?AccountNo=' +
          AccountNo +
          '&AccountName=' +
          AccountName +
          '&Amount=' +
          Amount +
          '&MovementDate=' +
          MovementDate +
          '&PersonId=' +
          PersonId +
          '&UserId=' +
          UserId +
          '&Type=' +
          Type +
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
