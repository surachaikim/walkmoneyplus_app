import 'package:flutter/material.dart';

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
      elevation: 6,
      margin: const EdgeInsets.all(16.0),
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header ribbon with gradient
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1976D2), Color(0xFF0D47A1)],
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.savings,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          typeaccount,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          accountno,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusChip(),
                ],
              ),
            ),

            // Body content
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Account holder name first
                  Row(
                    children: [
                      Icon(Icons.person, size: 18, color: Colors.grey[700]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          name,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 13,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Balance section after name
                  Text(
                    'ยอดเงินคงเหลือ',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Flexible(
                        child: Text(
                          _formatCurrency(balance),
                          textAlign: TextAlign.right,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF1976D2),
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'บาท',
                        style: TextStyle(color: Colors.black54, fontSize: 12),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),
                  Divider(color: Colors.grey[300], height: 1),
                  const SizedBox(height: 16),

                  // Actions
                  Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
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
                          icon: const Icon(
                            Icons.arrow_downward_rounded,
                            size: 20,
                          ),
                          label: const Text(
                            'ฝากเงิน',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.green,
                            backgroundColor: Colors.greenAccent.withOpacity(
                              0.10,
                            ),
                            side: const BorderSide(
                              color: Colors.green,
                              width: 1.4,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ).copyWith(
                            overlayColor: MaterialStateProperty.all(
                              Colors.green.withOpacity(0.08),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (_normalizedStatus() != 'ห้ามถอน')
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
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
                            icon: const Icon(
                              Icons.arrow_upward_rounded,
                              size: 20,
                            ),
                            label: const Text(
                              'ถอนเงิน',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              backgroundColor: Colors.redAccent.withOpacity(
                                0.10,
                              ),
                              side: const BorderSide(
                                color: Colors.red,
                                width: 1.4,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ).copyWith(
                              overlayColor: MaterialStateProperty.all(
                                Colors.red.withOpacity(0.08),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _normalizedStatus() => status.trim();

  Widget _buildStatusChip() {
    final s = _normalizedStatus();
    Color statusColor;
    String statusText;

    switch (s) {
      case 'ปกติ':
        statusColor = Colors.greenAccent;
        statusText = 'ปกติ';
        break;
      case 'ห้ามถอน':
        statusColor = Colors.redAccent;
        statusText = 'ห้ามถอน';
        break;
      default:
        statusColor = Colors.grey;
        statusText = 'ปิดบัญชี';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, color: statusColor, size: 10),
          const SizedBox(width: 6),
          const SizedBox(width: 2),
          const SizedBox.shrink(),
          Text(
            statusText,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(String input) {
    // Remove existing commas/spaces
    final normalized = input.replaceAll(',', '').trim();
    final isNegative = normalized.startsWith('-');
    final cleaned = isNegative ? normalized.substring(1) : normalized;
    double? value = double.tryParse(cleaned);
    if (value == null) return input; // fallback

    // Keep decimals if provided (up to 2), otherwise none
    int decimals = 0;
    if (cleaned.contains('.')) {
      final frac = cleaned.split('.')[1];
      decimals = frac.isEmpty ? 0 : (frac.length > 2 ? 2 : frac.length);
    }

    final fixed = value.toStringAsFixed(decimals);
    final parts = fixed.split('.');
    final intPart = _addCommas(parts[0]);
    final fracPart = parts.length > 1 && decimals > 0 ? '.${parts[1]}' : '';
    final sign = isNegative ? '-' : '';
    return '$sign$intPart$fracPart';
  }

  String _addCommas(String digits) {
    // Add thousand separators to a string of digits
    final buffer = StringBuffer();
    final chars = digits.replaceAll(RegExp(r'[^0-9]'), '');
    for (int i = 0; i < chars.length; i++) {
      final fromEnd = chars.length - i;
      buffer.write(chars[i]);
      if (fromEnd > 1 && fromEnd % 3 == 1) {
        buffer.write(',');
      }
    }
    return buffer.toString();
  }
}
