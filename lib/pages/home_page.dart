import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/finance_cubit.dart';
import 'income_page.dart';
import 'expenses_debts_page.dart';
import 'reports_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  String _userName = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('userName') ?? 'مستخدم';
    });
  }

  Future<void> _deleteUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Align(
            alignment: Alignment.centerRight,
            child: Text('تسجيل الخروج',
                style: GoogleFonts.cairo(fontWeight: FontWeight.bold))),
        content: Text('هل أنت متأكد من رغبتك في تسجيل الخروج ومسح بياناتك؟',
            style: GoogleFonts.cairo(), textAlign: TextAlign.right),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء',
                style: GoogleFonts.cairo(color: Colors.grey.shade700)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteUserData();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('خروج', style: GoogleFonts.cairo(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    return BlocBuilder<FinanceCubit, FinanceState>(
      builder: (context, state) {
        final cubit = context.read<FinanceCubit>();
        final balance = cubit.balance;
        final totalIncome = cubit.totalIncome;
        final totalPurchases = cubit.totalPurchases;
        final totalUnpaidDebts = cubit.totalUnpaidDebts;

        return Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 320,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF2C3E50), Color(0xFF3498DB)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                ),
              ),
            ),
            SafeArea(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              FadeInDown(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: IconButton(
                                    icon: const Icon(Icons.logout_rounded, color: Colors.white),
                                    onPressed: _showLogoutDialog,
                                  ),
                                ),
                              ),
                              FadeInDown(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text('مرحباً بعودتك', style: GoogleFonts.cairo(color: Colors.white70, fontSize: 14)),
                                    Text(_userName, style: GoogleFonts.cairo(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 30),
                          
                          // Balance Card
                          FadeInUp(
                            delay: const Duration(milliseconds: 200),
                            child: _buildBalanceCard(balance),
                          ),
                          const SizedBox(height: 30),

                          // Summary Cards
                          FadeInUp(
                            delay: const Duration(milliseconds: 400),
                            child: Row(
                              children: [
                                Expanded(child: _buildSummaryCard(title: 'إجمالي الدخل', amount: totalIncome, icon: Icons.arrow_downward_rounded, color: Colors.green)),
                                const SizedBox(width: 16),
                                Expanded(child: _buildSummaryCard(title: 'المشتريات', amount: totalPurchases, icon: Icons.shopping_bag, color: Colors.redAccent)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Debts Card
                          FadeInUp(
                            delay: const Duration(milliseconds: 600),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 5))],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(color: Colors.purple.withOpacity(0.1), shape: BoxShape.circle),
                                    child: const Icon(Icons.money_off, color: Colors.purple, size: 24),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text('الديون المستحقة (عليا)', style: GoogleFonts.cairo(color: Colors.grey.shade600, fontSize: 13)),
                                      Text('${totalUnpaidDebts.toStringAsFixed(0)} ج.م', style: GoogleFonts.cairo(color: const Color(0xFF2C3E50), fontSize: 18, fontWeight: FontWeight.bold), textDirection: TextDirection.rtl),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBalanceCard(double balance) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: balance >= 0 ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(balance >= 0 ? Icons.trending_up : Icons.trending_down, color: balance >= 0 ? Colors.green : Colors.red, size: 16),
                    const SizedBox(width: 4),
                    Text(balance >= 0 ? 'رصيد إيجابي' : 'رصيد سلبي', style: GoogleFonts.cairo(color: balance >= 0 ? Colors.green : Colors.red, fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Text('المتبقي معي', style: GoogleFonts.cairo(color: Colors.grey.shade600, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${balance.toStringAsFixed(2)} ج.م',
              style: GoogleFonts.cairo(fontSize: 36, fontWeight: FontWeight.bold, color: const Color(0xFF2C3E50)),
              textDirection: TextDirection.rtl,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({required String title, required double amount, required IconData icon, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: Text(title, style: GoogleFonts.cairo(color: Colors.grey.shade600, fontSize: 13)),
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: Text('${amount.toStringAsFixed(0)} ج.م', style: GoogleFonts.cairo(color: const Color(0xFF2C3E50), fontSize: 18, fontWeight: FontWeight.bold), textDirection: TextDirection.rtl),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _buildDashboard(),
      const ExpensesDebtsPage(),
      const IncomePage(),
      const ReportsPage(),
    ];

    Color getSelectedColor() {
      switch (_selectedIndex) {
        case 0: return const Color(0xFF3498DB); // أزرق للخلاصة
        case 1: return Colors.red; // أحمر للمشتريات
        case 2: return Colors.green; // أخضر للدخل
        case 3: return Colors.blue.shade900; // أزرق غامق للتقرير
        default: return const Color(0xFF3498DB);
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: SafeArea(
        top: _selectedIndex == 0 ? false : true,
        child: IndexedStack(
          index: _selectedIndex,
          children: pages,
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: _selectedIndex,
            backgroundColor: Colors.white,
            selectedItemColor: getSelectedColor(),
            unselectedItemColor: Colors.grey.shade400,
            selectedLabelStyle: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 12),
            unselectedLabelStyle: GoogleFonts.cairo(fontSize: 12),
            elevation: 0,
            onTap: (index) => setState(() => _selectedIndex = index),
            items: const [
              BottomNavigationBarItem(
                icon: Padding(padding: EdgeInsets.only(bottom: 4.0), child: Icon(Icons.dashboard_rounded)),
                label: 'الخلاصة',
              ),
              BottomNavigationBarItem(
                icon: Padding(padding: EdgeInsets.only(bottom: 4.0), child: Icon(Icons.shopping_cart_rounded)),
                label: 'المشتريات',
              ),
              BottomNavigationBarItem(
                icon: Padding(padding: EdgeInsets.only(bottom: 4.0), child: Icon(Icons.account_balance_wallet_rounded)),
                label: 'الدخل',
              ),
              BottomNavigationBarItem(
                icon: Padding(padding: EdgeInsets.only(bottom: 4.0), child: Icon(Icons.analytics_rounded)),
                label: 'التقرير',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
