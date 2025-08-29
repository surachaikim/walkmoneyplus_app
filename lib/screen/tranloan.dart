import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:walkmoney/screen/menu.dart';
import 'package:walkmoney/screen/process.dart';
import 'package:walkmoney/screen/chartdashbord.dart';
import 'package:walkmoney/service/config.dart';
import 'package:http/http.dart' as http;

class Trandloan extends StatefulWidget {
  Trandloan({Key? key, required this.blance}) : super(key: key);
  final String blance;

  @override
  State<Trandloan> createState() => _TrandloanState();
}

class _TrandloanState extends State<Trandloan> {
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
          "&Type=LO" +
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
    var response = await http.post(url, headers: headers);
    var rp = response;
    setState(() {});
  }

  Widget build(BuildContext context) {
    return Container(
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text("รายการสินเชื่อ"),
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
                  color: Color.fromARGB(255, 14, 61, 216),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.height * 0.65,
                    height: 120,
                    child: Center(
                      child: Column(
                        children: [
                          SizedBox(height: 30),
                          Text(
                            f.format(double.parse('${bal}')) + " ฿",
                            style: TextStyle(fontSize: 30, color: Colors.white),
                          ),
                          SizedBox(height: 20),
                          Text(
                            "ณ " +
                                DateFormat.Hms(
                                  'th',
                                ).format(DateTime.now().toLocal()),
                            style: TextStyle(fontSize: 12, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Expanded(
                  child: ListView.separated(
                    itemCount: item.length,
                    itemBuilder: (BuildContext context, int index) {
                      return item[index]["stcancel"].toString() != "1" &&
                              item[index]["stsync"].toString() != "3"
                          ? ListTile(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
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
                                            item[index]["docId"].toString(),
                                          );

                                          Navigator.pushAndRemoveUntil(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (context) => Trandloan(
                                                    blance: '${bal}',
                                                  ),
                                            ),
                                            (Route<dynamic> route) => false,
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
                            trailing: Text(
                              item[index]["amount"].toString(),
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 15,
                              ),
                            ),
                            title: Text(
                              item[index]["accountNo"] +
                                  ":" +
                                  item[index]["accountName"].toString(),
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                              ),
                            ),
                            subtitle: Text(
                              formats.format(
                                    DateTime.parse(
                                      item[index]["movementDate"].toString(),
                                    ),
                                  ) +
                                  " " +
                                  item[index]["time"].toString(),
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.black,
                              ),
                            ),
                          )
                          : ListTile(
                            trailing:
                                item[index]["stsync"].toString() == "3"
                                    ? Text(
                                      item[index]["amount"].toString(),
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 14,
                                      ),
                                    )
                                    : Text(
                                      item[index]["amount"].toString(),
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 14,
                                      ),
                                    ),
                            title:
                                item[index]["stsync"].toString() == "3"
                                    ? Text(
                                      item[index]["accountNo"] +
                                          ":" +
                                          item[index]["accountName"].toString(),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    )
                                    : Text(
                                      item[index]["accountNo"] +
                                          ":" +
                                          item[index]["accountName"].toString(),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.red,
                                      ),
                                    ),
                            subtitle:
                                item[index]["stsync"].toString() == "3"
                                    ? Text(
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
                                        color: Colors.grey,
                                      ),
                                    )
                                    : Text(
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
                                        color: Colors.red,
                                      ),
                                    ),
                          );
                    },
                    separatorBuilder: (context, index) {
                      return Divider();
                    },
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
