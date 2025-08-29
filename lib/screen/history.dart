import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:walkmoney/palette.dart';
import 'package:walkmoney/service/loading3.dart';

import '../service/config.dart';
import 'package:http/http.dart' as http;

const List<String> list = <String>['1', '2', '3', '4', '5', '6', '7'];

class HistoryScreen extends StatefulWidget {
  HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

var formats = DateFormat.yMd('th');

class _HistoryScreenState extends State<HistoryScreen> {
  List data = [];
  List originalData = [];
  String dropdownValue = list.first;
  bool isShow = true;
  TextEditingController txtQuery = new TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      isShow = true;
    });

    var url = Uri.parse(
      "${Config.UrlApi}/api/GetTransactionhistory?Cusid=${Config.CusId}&Date=$dropdownValue&User=${Config.UserId}",
    );

    var headers = {
      'Verify_identity': Config.Verify_identity,
      "Accept": "application/json",
    };

    try {
      var response = await http.get(url, headers: headers);
      List<dynamic> jsonData = [];
      if (response.statusCode == 200 && response.body.isNotEmpty) {
        jsonData = jsonDecode(response.body);
      }
      setState(() {
        data = jsonData;
        originalData = jsonData;
        isShow = false;
      });
    } catch (e) {
      setState(() {
        isShow = false;
        data = [];
        originalData = [];
      });
    }
  }

  void _search(String query) {
    if (query.isEmpty) {
      setState(() {
        data = originalData;
      });
      return;
    }

    query = query.toLowerCase();
    List result = [];
    originalData.forEach((p) {
      var name = p["accountName"].toString().toLowerCase();
      var accountNo = p["accountNo"].toString();
      if (name.contains(query) || accountNo.contains(query)) {
        result.add(p);
      }
    });

    setState(() {
      data = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'ประวัติธุรกรรม',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
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
              _buildControls(),
              Expanded(
                child:
                    isShow
                        ? const Center(child: Loading3())
                        : data.isEmpty
                        ? _buildEmptyState()
                        : _buildListView(data),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControls() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "ข้อมูลย้อนหลัง",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 20),
                DropdownButton<String>(
                  value: dropdownValue,
                  dropdownColor: Palette.kToDark.shade400,
                  elevation: 16,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                  underline: Container(),
                  onChanged: (String? value) {
                    setState(() {
                      dropdownValue = value!;
                      _fetchData();
                    });
                  },
                  items:
                      list
                          .map<DropdownMenuItem<String>>(
                            (String value) => DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            ),
                          )
                          .toList(),
                ),
                const SizedBox(width: 20),
                const Text(
                  "วัน",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: txtQuery,
            onChanged: _search,
            style: const TextStyle(color: Colors.black),
            decoration: InputDecoration(
              hintText: "ค้นหาชื่อ หรือ เลขบัญชี...",
              hintStyle: TextStyle(color: Colors.grey[500]),
              filled: true,
              fillColor: Colors.white,
              prefixIcon: Icon(Icons.search, color: Palette.kToDark.shade200),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide.none,
              ),
              suffixIcon:
                  txtQuery.text.isNotEmpty
                      ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          txtQuery.clear();
                          _search('');
                        },
                      )
                      : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.history_toggle_off, size: 80, color: Colors.white54),
          const SizedBox(height: 16),
          const Text(
            "ไม่พบข้อมูลธุรกรรม",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "ลองเปลี่ยนจำนวนวันที่หรือรีเฟรช",
            style: TextStyle(fontSize: 14, color: Colors.white70),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _fetchData,
          ),
        ],
      ),
    );
  }

  Widget _buildListView(List data) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: data.length,
      itemBuilder: (context, index) {
        var d = data[index];
        Color amountColor;
        String typeText;

        switch (d["type"].toString()) {
          case "DP":
            amountColor = Colors.greenAccent;
            typeText = "ฝาก";
            break;
          case "WD":
            amountColor = Colors.redAccent;
            typeText = "ถอน";
            break;
          default:
            amountColor = Colors.orangeAccent;
            typeText = "ชำระกู้";
        }

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
          title: Text(
            "${d["accountName"]} : ${d["accountNo"]}",
            style: const TextStyle(
              fontSize: 15,
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          subtitle: Text(
            "${formats.format(DateTime.parse(d["movementDate"]))} ${d["time"]}",
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withOpacity(0.7),
              fontWeight: FontWeight.w600,
            ),
          ),
          trailing: Text(
            "$typeText ${d["amount"]}",
            style: TextStyle(
              color: amountColor,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      },
      separatorBuilder: (context, index) {
        return Divider(color: Colors.white.withOpacity(0.2));
      },
    );
  }
}
