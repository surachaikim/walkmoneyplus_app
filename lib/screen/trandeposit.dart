import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:walkmoney/screen/menu.dart';
import 'package:walkmoney/service/config.dart';
import 'package:http/http.dart' as http;

class Trandeposit extends StatefulWidget {
  Trandeposit({Key? key, required this.blance}) : super(key: key);
  final String blance;

  @override
  State<Trandeposit> createState() => _TrandepositState();
}

class _TrandepositState extends State<Trandeposit> {
  List item = [];
  List infoDeposit = [];
  var formats = DateFormat.yMd('th');

  String balshow = "";
  double bal = 0;

  var f = NumberFormat('#,###', 'th_TH');
  bool buttonenabled = false;
  @override
  void initState() {
    super.initState();

    getData();
    balshow = widget.blance;
    bal = double.parse(widget.blance.replaceAll(',', ''));
  }

  void getData() async {
    var url = Uri.parse(
      Config.UrlApi +
          "/api/GetTransactionTypebyuser?Cusid=" +
          Config.CusId +
          "&Type=DP" +
          "&User=" +
          Config.UserId,
    );

    var headers = {
      'Verify_identity': Config.Verify_identity,
      "Accept": "application/json",
    };
    var response = await http.get(url, headers: headers);
    var json = jsonDecode(response.body);

    setState(() {
      item = json;
    });
  }

  void CancelSt(docId) async {
    var url = Uri.parse(
      Config.UrlApi +
          "/api/CanceldTransaction?DocId=" +
          docId +
          "&St=1" +
          "&CusId=" +
          Config.CusId,
    );

    var headers = {
      'Verify_identity': Config.Verify_identity,
      "Accept": "application/json",
    };
    await http.post(url, headers: headers);
    // Balance updated
  }

  void loadAccountNo(AccountNo, amount) async {
    var url = Uri.parse(
      Config.UrlApi +
          '/api/GetDepositByAccountNo?AccountNo=' +
          AccountNo +
          '&Cusid=' +
          Config.CusId,
    );

    var headers = {
      'Verify_identity': Config.Verify_identity,
      "Accept": "application/json",
    };
    var response = await http.get(url, headers: headers);
    var json = jsonDecode(response.body);
    infoDeposit = json;

    updateBalance(amount);

    setState(() {
      infoDeposit = json;
    });
  }

  void updateBalance(amount) async {
    var Balance = 0.00;

    Balance = double.parse(infoDeposit[0]["balance"]) - double.parse(amount);

    var url = Uri.parse(
      Config.UrlApi +
          '/api/UpdateBalance?AccountNo=' +
          infoDeposit[0]["accountNo"].toString() +
          '&Balance=' +
          Balance.toString() +
          '&Cusid=' +
          Config.CusId,
    );

    var headers = {'Verify_identity': Config.Verify_identity};
    await http.post(url, headers: headers);
    // Balance update request sent
  }

  Widget build(BuildContext context) {
    return Container(
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text("รายการฝากเงิน"),
            leading: IconButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => Menuscreen(tab: '1')),
                );
              },
              icon: Icon(Icons.arrow_back),
            ),
            shadowColor: Color.fromARGB(255, 8, 64, 129),
          ),
          backgroundColor: Colors.white,
          body: Container(
            child: Column(
              children: <Widget>[
                SizedBox(height: 10),
                Card(
                  color: Color(0xFF1976D2),
                  elevation: 4,
                  shadowColor: Color(0xFF1976D2).withOpacity(0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    height: 80,
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "ยอดเงินคงเหลือ",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.8),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              f.format(double.parse('${bal}')) + " บาท",
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.account_balance_wallet,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: Card(
                      elevation: 1,
                      shadowColor: Colors.grey.withOpacity(0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.5,
                          child: ListView.separated(
                            physics: BouncingScrollPhysics(
                              parent: AlwaysScrollableScrollPhysics(),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 8),
                            itemCount: item.length,
                            itemBuilder: (BuildContext context, int index) {
                              return item[index]["stcancel"].toString() !=
                                          "1" &&
                                      item[index]["stsync"].toString() != "3"
                                  ? ListTile(
                                    dense: true,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            title: Text('ต้องการยกเลิกรายการ?'),
                                            actions: <Widget>[
                                              OutlinedButton(
                                                onPressed: () async {
                                                  bal =
                                                      double.parse('${bal}') -
                                                      double.parse(
                                                        item[index]["amount"]
                                                            .toString(),
                                                      );
                                                  CancelSt(
                                                    item[index]["docId"]
                                                        .toString(),
                                                  );
                                                  loadAccountNo(
                                                    item[index]["accountNo"]
                                                        .toString(),
                                                    item[index]["amount"]
                                                        .toString(),
                                                  );

                                                  Navigator.pushAndRemoveUntil(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder:
                                                          (context) =>
                                                              Trandeposit(
                                                                blance:
                                                                    '${bal}',
                                                              ),
                                                    ),
                                                    (Route<dynamic> route) =>
                                                        false,
                                                  );
                                                },
                                                child: Text('ตกลง'),
                                              ),
                                              OutlinedButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: Text('ยกเลิก'),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                    leading: Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        color: Colors.green.withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.arrow_upward,
                                        color: Colors.green,
                                        size: 14,
                                      ),
                                    ),
                                    trailing: Text(
                                      "+" + item[index]["amount"].toString(),
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    title: Text(
                                      item[index]["accountNo"] +
                                          ":" +
                                          item[index]["accountName"].toString(),
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    subtitle: Text(
                                      formats.format(
                                            DateTime.parse(
                                              item[index]["movementDate"]
                                                  .toString(),
                                            ),
                                          ) +
                                          " " +
                                          item[index]["time"].toString(),
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  )
                                  : ListTile(
                                    dense: true,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    leading: Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        color:
                                            item[index]["stsync"].toString() ==
                                                    "3"
                                                ? Colors.grey.withOpacity(0.1)
                                                : Colors.red.withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        item[index]["stsync"].toString() == "3"
                                            ? Icons.sync
                                            : Icons.cancel,
                                        color:
                                            item[index]["stsync"].toString() ==
                                                    "3"
                                                ? Colors.grey
                                                : Colors.red,
                                        size: 14,
                                      ),
                                    ),
                                    trailing: Text(
                                      "+" + item[index]["amount"].toString(),
                                      style: TextStyle(
                                        color:
                                            item[index]["stsync"].toString() ==
                                                    "3"
                                                ? Colors.grey
                                                : Colors.red,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    title: Text(
                                      item[index]["accountNo"] +
                                          ":" +
                                          item[index]["accountName"].toString(),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color:
                                            item[index]["stsync"].toString() ==
                                                    "3"
                                                ? Colors.grey
                                                : Colors.red,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    subtitle: Text(
                                      formats.format(
                                            DateTime.parse(
                                              item[index]["movementDate"]
                                                  .toString(),
                                            ),
                                          ) +
                                          " " +
                                          item[index]["time"].toString(),
                                      style: TextStyle(
                                        fontSize: 10,
                                        color:
                                            item[index]["stsync"].toString() ==
                                                    "3"
                                                ? Colors.grey.shade500
                                                : Colors.red.shade300,
                                      ),
                                    ),
                                  );
                            },
                            separatorBuilder: (context, index) {
                              return Divider(
                                height: 1,
                                indent: 16,
                                endIndent: 16,
                                color: Colors.grey.shade100,
                              );
                            },
                          ),
                        ),
                      ),
                    ),
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
