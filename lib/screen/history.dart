import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:walkmoney/palette.dart';
import 'package:walkmoney/widgets/beautiful_loading.dart';

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
      var name = (p["accountName"] ?? '').toString().toLowerCase();
      var accountNo = (p["accountNo"] ?? '').toString();
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
              _buildControls(),
              Expanded(
                child:
                    isShow
                        ? const BeautifulLoading(
                          message: 'กำลังโหลดประวัติธุรกรรม...',
                        )
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
          // Date Filter Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Palette.kToDark.shade100.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.calendar_month,
                    color: Palette.kToDark.shade800,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "ข้อมูลย้อนหลัง",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Palette.kToDark.shade800,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Palette.kToDark.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Palette.kToDark.shade200),
                  ),
                  child: DropdownButton<String>(
                    value: dropdownValue,
                    style: TextStyle(
                      color: Palette.kToDark.shade800,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    icon: Icon(
                      Icons.arrow_drop_down,
                      color: Palette.kToDark.shade600,
                    ),
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
                                child: Text('$value วัน'),
                              ),
                            )
                            .toList(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Search Card
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              controller: txtQuery,
              onChanged: _search,
              style: TextStyle(color: Palette.kToDark.shade800),
              decoration: InputDecoration(
                hintText: 'ค้นหาชื่อหรือเลขบัญชี...',
                hintStyle: TextStyle(color: Palette.kToDark.shade400),
                prefixIcon: Icon(Icons.search, color: Palette.kToDark.shade600),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(32),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Palette.kToDark.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.history_toggle_off,
                size: 48,
                color: Palette.kToDark.shade400,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "ไม่พบข้อมูลธุรกรรม",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Palette.kToDark.shade800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "ลองเปลี่ยนจำนวนวันที่หรือรีเฟรช",
              style: TextStyle(fontSize: 14, color: Palette.kToDark.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _fetchData,
              icon: const Icon(Icons.refresh),
              label: const Text('รีเฟรช'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Palette.kToDark.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListView(List data) {
    // จัดกลุ่มข้อมูลตามวันที่
    Map<String, List> groupedData = {};
    for (var item in data) {
      String dateKey = '';
      if (item["movementDate"] != null) {
        try {
          DateTime date = DateTime.parse(item["movementDate"]);
          dateKey = DateFormat('dd MMMM yyyy', 'th_TH').format(date);
        } catch (e) {
          dateKey = 'ไม่ระบุวันที่';
        }
      } else {
        dateKey = 'ไม่ระบุวันที่';
      }

      if (!groupedData.containsKey(dateKey)) {
        groupedData[dateKey] = [];
      }
      groupedData[dateKey]!.add(item);
    }

    // เรียงลำดับวันที่
    List<String> sortedDates = groupedData.keys.toList();
    sortedDates.sort((a, b) {
      if (a == 'ไม่ระบุวันที่') return 1;
      if (b == 'ไม่ระบุวันที่') return -1;
      try {
        DateTime dateA = DateFormat('dd MMMM yyyy', 'th_TH').parse(a);
        DateTime dateB = DateFormat('dd MMMM yyyy', 'th_TH').parse(b);
        return dateB.compareTo(dateA); // เรียงจากใหม่ไปเก่า
      } catch (e) {
        return 0;
      }
    });

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      itemCount: sortedDates.length,
      itemBuilder: (context, index) {
        String dateKey = sortedDates[index];
        List dayTransactions = groupedData[dateKey]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header วันที่
            Container(
              margin: const EdgeInsets.only(top: 16, bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Palette.kToDark.shade600,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    dateKey,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Palette.kToDark.shade800,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Palette.kToDark.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${dayTransactions.length} รายการ',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Palette.kToDark.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // รายการธุรกรรมในวันนั้น
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children:
                    dayTransactions.asMap().entries.map((entry) {
                      int idx = entry.key;
                      var d = entry.value;

                      Color amountColor;
                      String typeText;
                      IconData typeIcon;

                      switch (d["type"]?.toString() ?? '') {
                        case "DP":
                          amountColor = Colors.green;
                          typeText = "ฝากเงิน";
                          typeIcon = Icons.savings;
                          break;
                        case "WD":
                          amountColor = Colors.red;
                          typeText = "ถอนเงิน";
                          typeIcon = Icons.money_off;
                          break;
                        default:
                          amountColor = Colors.orange;
                          typeText = "ชำระสินเชื่อ";
                          typeIcon = Icons.credit_card;
                      }

                      return Column(
                        children: [
                          ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: amountColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                typeIcon,
                                color: amountColor,
                                size: 20,
                              ),
                            ),
                            title: Text(
                              "${d["accountName"] ?? 'ไม่ระบุชื่อ'}",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Palette.kToDark.shade800,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "บัญชีเลขที่: ${d["accountNo"] ?? 'ไม่ระบุ'}",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Palette.kToDark.shade600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: amountColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    typeText,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: amountColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  d["amount"] != null
                                      ? "${NumberFormat('#,###', 'th_TH').format(double.tryParse(d["amount"].toString()) ?? 0)}"
                                      : "0",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: amountColor,
                                  ),
                                ),
                                Text(
                                  "บาท",
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Palette.kToDark.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (idx < dayTransactions.length - 1)
                            Divider(
                              height: 1,
                              indent: 60,
                              endIndent: 16,
                              color: Colors.grey.shade200,
                            ),
                        ],
                      );
                    }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }
}
