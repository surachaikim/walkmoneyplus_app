import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'adddeposit.dart';
import 'addwithdraw.dart';

class MyCardDeposit extends StatelessWidget {
  final String balance;
  final int cardNumber;
  final String name;
  final String accountno;
  final String typeaccount;
  final String status;
  final Color color;
  final List movementinfo;

  const MyCardDeposit({
    Key? key,
    required this.balance,
    required this.cardNumber,
    required this.name,
    required this.accountno,
    required this.typeaccount,
    required this.status,
    required this.color,
    required this.movementinfo,
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
                  'บัญชีเงินฝาก $typeaccount',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 18,
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
                    'ยอดเงินคงเหลือ',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '\฿' + balance.toString(),
                    style: TextStyle(
                      color: Color(0xFF1976D2),
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
                            (context) => AdddepositScreen(
                              accountno: accountno,

                              balance: balance,
                            ),
                      ),
                    );
                  },
                  icon: Icon(Icons.add, color: Colors.white),
                  label: Text('ฝาก', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0), // ขอบไม่มน
                    ),
                  ),
                ),
                SizedBox(width: 10),
                if (status != " ห้ามถอน ")
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => AddwithdrawScreen(
                                accountno: accountno,

                                balance: balance,
                              ),
                        ),
                      );
                    },
                    icon: Icon(Icons.remove, color: Colors.white),
                    label: Text('ถอน', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
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
      case " ปกติ ":
        statusColor = Colors.green;
        statusText = "ปกติ";
        break;
      case " ห้ามถอน ":
        statusColor = Colors.red;
        statusText = "ห้ามถอน";
        break;
      default:
        statusColor = Colors.black;
        statusText = "ปิดบัญชี";
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
