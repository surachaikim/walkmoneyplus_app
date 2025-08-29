import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class mycard extends StatelessWidget {
  final String balance;
  final int cardNumber;
  final String name;
  final String accountno;
  final String typeaccount;
  final String status;
  final Color color;

  const mycard({
    Key? key,
    required this.balance,
    required this.cardNumber,
    required this.name,
    required this.accountno,
    required this.typeaccount,
    required this.status,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      margin: const EdgeInsets.all(16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  typeaccount,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _buildStatusWidget(),
              ],
            ),
            SizedBox(height: 20),
            Text(
              'ยอดเงินคงเหลือ',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              '\฿' + balance.toString(),
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  accountno,
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                Text(
                  name,
                  style: TextStyle(color: Colors.white, fontSize: 16),
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
      case "1":
        statusColor = Colors.green;
        statusText = "ปกติ";
        break;
      case "2":
        statusColor = Colors.red;
        statusText = "ห้ามถอน";
        break;
      default:
        statusColor = Colors.black;
        statusText = "ปิดบัญชี";
    }

    return Row(
      children: [
        Icon(
          Icons.circle,
          color: statusColor,
          size: 12,
        ),
        SizedBox(width: 8),
        Text(
          statusText,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
