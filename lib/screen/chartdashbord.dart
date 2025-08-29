import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:walkmoney/palette.dart';
import 'package:walkmoney/screen/trandeposit.dart';
import 'package:walkmoney/screen/tranloan.dart';
import 'package:walkmoney/screen/tranwithdraw.dart';
import 'package:walkmoney/service/config.dart';
import 'package:http/http.dart' as http;
import 'package:walkmoney/service/loading.dart';

class ChartDBScreen extends StatefulWidget {
  const ChartDBScreen({Key? key}) : super(key: key);

  @override
  State<ChartDBScreen> createState() => _ChartDBScreenState();
}

class _ChartDBScreenState extends State<ChartDBScreen>
    with TickerProviderStateMixin {
  String Loan = "0.00";
  String Deposit = "0.00";
  String Withdraw = "0.00";
  String Sum = "0.00";
  bool isLoading = true;

  late final Map<String, double> dataMap;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeData();
    _setupAnimations();
    _fetchData();
  }

  void _initializeData() {
    dataMap = <String, double>{
      "ฝากเงิน": 0.00,
      "ถอนเงิน": 0.00,
      "ชำระสินเชื่อ": 0.00,
    };
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 1.0, curve: Curves.elasticOut),
      ),
    );

    _animationController.forward();
  }

  Future<void> _fetchData() async {
    try {
      final url = Uri.parse(
        '${Config.UrlApi}/api/GetSumDashbord?UserId=${Config.UserId}&Cusid=${Config.CusId}',
      );

      final headers = {
        'Verify_identity': Config.Verify_identity,
        "Accept": "text/plain",
      };

      final response = await http.get(url, headers: headers);

      if (response.body != "Error") {
        final split = response.body.split(',');
        final values = {for (int i = 0; i < split.length; i++) i: split[i]};

        final formatter = NumberFormat('#,###', 'th_TH');

        Loan = formatter.format(double.parse(values[0]!));
        Deposit = formatter.format(double.parse(values[1]!));
        Withdraw = formatter.format(double.parse(values[2]!));
        Sum = formatter.format(
          double.parse(values[1]!) +
              double.parse(values[0]!) -
              double.parse(values[2]!),
        );

        dataMap["ฝากเงิน"] = double.parse(values[1]!);
        dataMap["ถอนเงิน"] = double.parse(values[2]!);
        dataMap["ชำระสินเชื่อ"] = double.parse(values[0]!);
      }
    } catch (e) {
      // Handle error silently or show error message
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: _buildAppBar(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Palette.kToDark.shade100, Palette.kToDark.shade900],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: isLoading ? _buildLoadingState() : _buildMainContent(),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        'แดชบอร์ด',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontSize: 20,
        ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
    );
  }

  Widget _buildLoadingState() {
    return const Center(child: Loading2());
  }

  Widget _buildMainContent() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildChartSection(),
              const SizedBox(height: 24),
              _buildTransactionSection(),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChartSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Palette.kToDark.shade200.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.pie_chart,
                  color: Palette.kToDark.shade200,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'สัดส่วนการเงิน',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Palette.kToDark.shade400,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Total amount section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Palette.kToDark.shade200, Palette.kToDark.shade400],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ยอดเงินรวม',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$Sum บาท',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: SizedBox(
              height: 160,
              child: PieChart(
                dataMap: dataMap,
                animationDuration: const Duration(milliseconds: 1000),
                chartRadius: 110,
                colorList: const [
                  Color(0xFF2E7D32), // Green for deposits
                  Color(0xFFD32F2F), // Red for withdrawals
                  Color(0xFFF57C00), // Orange for loans
                ],
                initialAngleInDegree: 0,
                chartType: ChartType.disc,
                legendOptions: const LegendOptions(
                  showLegendsInRow: false,
                  legendPosition: LegendPosition.right,
                  showLegends: true,
                  legendTextStyle: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
                chartValuesOptions: const ChartValuesOptions(
                  showChartValueBackground: true,
                  showChartValues: true,
                  showChartValuesInPercentage: true,
                  chartValueBackgroundColor: Colors.white,
                  chartValueStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    fontSize: 11,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.receipt_long,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'รายการธุรกรรม',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Column(
          children: [
            _buildTransactionCard(
              'ฝากเงิน',
              Deposit,
              Icons.savings,
              const [Color(0xFF2E7D32), Color(0xFF66BB6A)],
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Trandeposit(blance: Deposit),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _buildTransactionCard(
              'ถอนเงิน',
              Withdraw,
              Icons.money_off,
              const [Color(0xFFD32F2F), Color(0xFFEF5350)],
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Tranwithdraw(blance: Withdraw),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _buildTransactionCard(
              'สินเชื่อ',
              Loan,
              Icons.credit_card,
              const [Color(0xFFF57C00), Color(0xFFFFB74D)],
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Trandloan(blance: Loan),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTransactionCard(
    String title,
    String amount,
    IconData icon,
    List<Color> gradientColors,
    VoidCallback onTap,
  ) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: gradientColors[0].withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$amount บาท',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                    size: 16,
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
