import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'addloan.dart';

class MyCardLoan extends StatelessWidget {
  final String balance;
  final int cardNumber;
  final String name;
  final String accountno;
  final String typeaccount;
  final String status;
  final Color color;
  final String minPayment;
  final List loaninfo;
  final String term;
  final String totalamount;

  const MyCardLoan({
    Key? key,
    required this.balance,
    required this.cardNumber,
    required this.name,
    required this.accountno,
    required this.typeaccount,
    required this.status,
    required this.color,
    required this.minPayment,
    required this.loaninfo,
    required this.term,
    required this.totalamount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      margin: const EdgeInsets.all(16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      color: Colors.white,
      child: Container(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  typeaccount,
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _buildStatusWidget(),
              ],
            ),
            Divider(color: Colors.grey[300]),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  accountno,
                  style: TextStyle(color: Colors.grey[600], fontSize: 18),
                ),
              ],
            ),
            Text(name, style: TextStyle(color: Colors.black54, fontSize: 16)),
            SizedBox(height: 20),
            Align(
              alignment: Alignment.centerRight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'ยอดหนี้คงเหลือ',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '\฿' + balance.toString(),
                    style: TextStyle(
                      color: Colors.orange[800],
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Spacer(), // ดันวิดเจ็ตที่เหลือไปด้านล่าง
            Divider(color: Colors.grey[300]),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => AddloanScreen(
                              accountno: accountno,
                              balance: balance,
                            ),
                      ),
                    );
                  },
                  icon: Icon(Icons.payment, color: Colors.white),
                  label: Text(
                    'ชำระเงินกู้',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0), // ขอบไม่มน
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusWidget() {
    Color statusColor;
    String statusText;

    switch (status) {
      case " ติดตามหนี้ ":
        statusColor = Colors.yellow;
        statusText = "ติดตามหนี้";
        break;
      case " ปิดสัญญา ":
        statusColor = Colors.black;
        statusText = "ปิดสัญญา";
        break;
      case " ระหว่างชำระ ":
        statusColor = Colors.green;
        statusText = "ระหว่างชำระ";
        break;
      default:
        statusColor = Colors.grey;
        statusText = "ไม่ทราบสถานะ";
    }

    return Row(
      children: [
        Icon(Icons.circle, color: statusColor, size: 12),
        SizedBox(width: 8),
        Text(
          statusText,
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
